enum NotificationType { success, warning, error, info }

class AppNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
