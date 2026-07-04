import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      message: 'Tu propuesta fue aceptada por el comité de docentes.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.success,
    ),
    AppNotification(
      id: '2',
      message: 'Tu propuesta fue aceptada con observaciones por el comité de docentes.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.warning,
    ),
    AppNotification(
      id: '3',
      message: 'Tu propuesta no fue aceptada por el comité de docentes.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.error,
    ),
    AppNotification(
      id: '4',
      message: 'Has sido aceptado en el equipo CodeSoft.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.success,
    ),
    AppNotification(
      id: '5',
      message: 'No has sido seleccionado para el equipo CodeHub.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.error,
    ),
    AppNotification(
      id: '6',
      message: 'Se terminó el proceso de análisis de IA de tu propuesta.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      type: NotificationType.info,
    ),
  ];

  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    _notifications = _notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    notifyListeners();
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
