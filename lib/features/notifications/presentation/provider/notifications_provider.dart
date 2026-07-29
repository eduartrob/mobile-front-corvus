import 'package:flutter/foundation.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../data/notifications_local_data_source.dart';
import '../../data/notifications_remote_data_source.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';

class NotificationsProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  // selection mode
  Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  final NotificationsRemoteDataSource _remoteDataSource =
      NotificationsRemoteDataSource(client: sl<AuthInterceptorClient>());

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedIds => _selectedIds;

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      // 1 try to fetch from remote and sync to local
      try {
        final remoteData = await _remoteDataSource.fetchMyNotifications();
        
        // preserve local read state before wiping
        final currentLocal = await NotificationsLocalDataSource.getNotifications();
        final readStatusMap = <String, bool>{};
        for (var n in currentLocal) {
          if (n['isRead'] == 1) {
            readStatusMap[n['id'].toString()] = true;
          }
        }

        await NotificationsLocalDataSource.deleteAllRemote();
        for (var n in remoteData) {
          final nId = n['id'].toString();
          final isReadLocally = readStatusMap[nId] ?? false;
          final isReadRemote = n['isRead'] == true;
          
          await NotificationsLocalDataSource.insertNotification({
            'id': n['id'],
            'title': n['title'],
            'body': n['body'],
            'type': n['type'],
            'deepLink': n['deepLink'],
            'timestamp': n['timestamp'],
            'isRead': (isReadLocally || isReadRemote) ? 1 : 0,
            'authorName': n['authorName'],
            'authorPhotoUrl': n['authorPhotoUrl'],
          });
        }
      } catch (e) {
        debugPrint('Failed to sync from remote: $e');
      }

      // 2 load from local db
      final data = await NotificationsLocalDataSource.getNotifications();
      final storage = SecureStorageService();
      final role = await storage.read(key: 'auth_role');

      final myName = await storage.read(key: 'auth_name');

      var parsedNotifications = data
          .map((n) => AppNotification(
                id: n['id'].toString(),
                notifTitle: n['title']?.toString(),
                message: n['title'] != null && n['title'] != ''
                    ? "${n['title']}\n${n['body']}"
                    : n['body'],
                deepLink: n['deepLink']?.toString(),
                rawType: n['type']?.toString(),
                timestamp: DateTime.parse(n['timestamp']),
                type: _getTypeFromString(n['type']),
                isRead: n['isRead'] == 1,
                authorName: n['authorName'],
                authorPhotoUrl: n['authorPhotoUrl'],
              ))
          .where((n) {
            // no mostrar notificaciones si el autor es el propio usuario
            if (n.authorName != null && myName != null && n.authorName == myName) {
              // limpiar de forma silenciosa del servidor local para no ocupar espacio
              NotificationsLocalDataSource.deleteNotification(n.id).catchError((_) {});
              _remoteDataSource.deleteNotification(n.id).catchError((_) {});
              return false;
            }
            return true;
          })
          .toList();

      final deduplicated = <AppNotification>[];
      for (final n in parsedNotifications) {
        final isDuplicate = deduplicated.any((existing) => 
            existing.message == n.message && 
            existing.type == n.type &&
            n.timestamp.difference(existing.timestamp).inMinutes.abs() < 5
        );
        if (!isDuplicate) {
          deduplicated.add(n);
        } else {
          // self heal delete the duplicate from the server asynchronously
          _remoteDataSource.deleteNotification(n.id).catchError((_) {});
          NotificationsLocalDataSource.deleteNotification(n.id).catchError((_) {});
        }
      }

      _notifications = deduplicated;
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (!silent) _isLoading = false;
      notifyListeners();
    }
  }

  /// marca todas las notificaciones como leídas local servidor cuando
  /// el usuario abre la pantalla de notificaciones 
  Future<void> markAllAsReadOnOpen() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // actualización optimista en memoria
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    // persistir en local
    await NotificationsLocalDataSource.markAllAsRead();

    // persistir en servidor una petición por notificación no leída 
    for (final n in unread) {
      try {
        await _remoteDataSource.markAsRead(n.id);
      } catch (e) {
        debugPrint('Error marking ${n.id} as read on server: $e');
      }
    }
  }

  // selection mode 

  void enterSelectionMode(String firstId) {
    _isSelectionMode = true;
    _selectedIds = {firstId};
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      if (_selectedIds.isEmpty) _isSelectionMode = false;
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  // kept for compatibility
  void clearSelection() => exitSelectionMode();

  // mark as read 

  Future<void> markAsRead(String id) async {
    // optimistic update
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();

    try {
      await _remoteDataSource.markAsRead(id);
      await NotificationsLocalDataSource.markAsRead(id);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    // optimistic update
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    await NotificationsLocalDataSource.markAllAsRead();

    // sync each to server
    for (final n in _notifications) {
      try {
        await _remoteDataSource.markAsRead(n.id);
      } catch (e) {
        debugPrint('Error marking ${n.id} as read on server: $e');
      }
    }
  }

  // delete 

  Future<void> deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final idsToDelete = _selectedIds.toList();

    // optimistic update
    _notifications.removeWhere((n) => idsToDelete.contains(n.id));
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();

    try {
      await _remoteDataSource.deleteBulk(idsToDelete);
      for (var id in idsToDelete) {
        await NotificationsLocalDataSource.deleteNotification(id);
      }
    } catch (e) {
      debugPrint('Error deleting bulk notifications: $e');
      // refresh to restore state if server failed
      await fetchNotifications(silent: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    // optimistic remove
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    try {
      await _remoteDataSource.deleteNotification(id);
      await NotificationsLocalDataSource.deleteNotification(id);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      await fetchNotifications(silent: true);
    }
  }

  Future<void> clearAll() async {
    // optimistic update
    _notifications.clear();
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();

    try {
      await _remoteDataSource.deleteAll();
      await NotificationsLocalDataSource.deleteAll();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      await fetchNotifications(silent: true);
    }
  }

  void clear() {
    _notifications = [];
    _isLoading = false;
    _isSelectionMode = false;
    _selectedIds = {};
    notifyListeners();
  }

  // helpers 

  NotificationType _getTypeFromString(String? typeStr) {
    switch (typeStr) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'security_login':
      case 'security_new_device':
        return NotificationType.security;
      case 'payment_update':
        return NotificationType.payment;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}
