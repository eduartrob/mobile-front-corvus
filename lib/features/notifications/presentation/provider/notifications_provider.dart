import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/app_notification.dart';
import '../../data/notifications_local_data_source.dart';
import '../../data/notifications_remote_data_source.dart';

class NotificationsProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  
  final NotificationsRemoteDataSource _remoteDataSource = NotificationsRemoteDataSource(client: http.Client());

  // Selection mode variables
  Set<String> _selectedIds = {};

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  bool get isSelectionMode => _selectedIds.isNotEmpty;
  Set<String> get selectedIds => _selectedIds;

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      // 1. Try to fetch from remote
      try {
        final remoteData = await _remoteDataSource.fetchMyNotifications();
        // Overwrite local DB completely for simplicity in sync
        await NotificationsLocalDataSource.deleteAll();
        for (var n in remoteData) {
          await NotificationsLocalDataSource.insertNotification({
            'id': n['id'],
            'title': n['title'],
            'body': n['body'],
            'type': n['type'],
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
      const storage = FlutterSecureStorage();
      final role = await storage.read(key: 'auth_role');

      var parsedNotifications = data.map((n) => AppNotification(
        id: n['id'].toString(),
        message: n['title'] != null && n['title'] != '' ? "${n['title']}\n${n['body']}" : n['body'],
        timestamp: DateTime.parse(n['timestamp']),
        type: _getTypeFromString(n['type']),
        isRead: n['isRead'] == 1,
        authorName: n['authorName'],
        authorPhotoUrl: n['authorPhotoUrl'],
      )).toList();

      if (role == 'PROFESOR') {
        // Ocultar notificaciones de configuración al profesor
        parsedNotifications = parsedNotifications.where((n) {
          final isConfigUpdate = n.message.contains('Temas para Proyecto') || n.message.contains('estructura de proyecto');
          return !isConfigUpdate;
        }).toList();
      }

      _notifications = parsedNotifications;
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final idsToDelete = _selectedIds.toList();
    _isLoading = true;
    notifyListeners();
    try {
      await _remoteDataSource.deleteBulk(idsToDelete);
      for (var id in idsToDelete) {
        await NotificationsLocalDataSource.deleteNotification(id);
      }
      _selectedIds.clear();
      await fetchNotifications(silent: true);
    } catch (e) {
      debugPrint('Error deleting bulk notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _remoteDataSource.markAsRead(id);
      await NotificationsLocalDataSource.markAsRead(id);
      await fetchNotifications(silent: true);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    // Currently backend doesn't have a markAllAsRead endpoint, but we can iterate or skip
    // Let's just update local for now or we can implement it in the backend later
    await NotificationsLocalDataSource.markAllAsRead();
    await fetchNotifications(silent: true);
  }

  Future<void> clearAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _remoteDataSource.deleteAll();
      await NotificationsLocalDataSource.deleteAll();
      _notifications.clear();
      _selectedIds.clear();
    } catch (e) {
       debugPrint('Error clearing notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  NotificationType _getTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'info':
      default:
        return NotificationType.info;
    }
  }
}
