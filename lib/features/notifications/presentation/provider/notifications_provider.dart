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

  // Selection mode
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
      // 1. Try to fetch from remote and sync to local
      try {
        final remoteData = await _remoteDataSource.fetchMyNotifications();
        await NotificationsLocalDataSource.deleteAllRemote();
        for (var n in remoteData) {
          await NotificationsLocalDataSource.insertNotification({
            'id': n['id'],
            'title': n['title'],
            'body': n['body'],
            'type': n['type'],
            'deepLink': n['deepLink'],
            'timestamp': n['timestamp'],
            'isRead': n['isRead'] ? 1 : 0,
            'authorName': n['authorName'],
            'authorPhotoUrl': n['authorPhotoUrl'],
          });
        }
      } catch (e) {
        debugPrint('Failed to sync from remote: $e');
      }

      // 2. Load from local DB
      final data = await NotificationsLocalDataSource.getNotifications();
      final storage = SecureStorageService();
      final role = await storage.read(key: 'auth_role');

      var parsedNotifications = data
          .map((n) => AppNotification(
                id: n['id'].toString(),
                notifTitle: n['title']?.toString(),
                message: n['title'] != null && n['title'] != ''
                    ? "${n['title']}\n${n['body']}"
                    : n['body'],
                deepLink: n['deepLink']?.toString(),
                timestamp: DateTime.parse(n['timestamp']),
                type: _getTypeFromString(n['type']),
                isRead: n['isRead'] == 1,
                authorName: n['authorName'],
                authorPhotoUrl: n['authorPhotoUrl'],
              ))
          .toList();

      if (role == 'PROFESOR') {
        parsedNotifications = parsedNotifications.where((n) {
          final isConfigUpdate = n.message.contains('Temas para Proyecto') ||
              n.message.contains('estructura de proyecto');
          return !isConfigUpdate;
        }).toList();
      }

      _notifications = parsedNotifications;
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (!silent) _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leídas (local + servidor) cuando
  /// el usuario abre la pantalla de notificaciones.
  Future<void> markAllAsReadOnOpen() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // Actualización optimista en memoria
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    // Persistir en local
    await NotificationsLocalDataSource.markAllAsRead();

    // Persistir en servidor (una petición por notificación no leída)
    for (final n in unread) {
      try {
        await _remoteDataSource.markAsRead(n.id);
      } catch (e) {
        debugPrint('Error marking ${n.id} as read on server: $e');
      }
    }
  }

  // ── Selection mode ────────────────────────────────────────────────────────

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

  // ── Mark as read ──────────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    // Optimistic update
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
    // Optimistic update
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    await NotificationsLocalDataSource.markAllAsRead();

    // Sync each to server
    for (final n in _notifications) {
      try {
        await _remoteDataSource.markAsRead(n.id);
      } catch (e) {
        debugPrint('Error marking ${n.id} as read on server: $e');
      }
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final idsToDelete = _selectedIds.toList();

    // Optimistic update
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
      // Refresh to restore state if server failed
      await fetchNotifications(silent: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    // Optimistic remove
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
    // Optimistic update
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

  // ── Helpers ───────────────────────────────────────────────────────────────

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
