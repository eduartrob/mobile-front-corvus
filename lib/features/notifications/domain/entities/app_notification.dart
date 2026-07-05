enum NotificationType { success, warning, error, info }

class AppNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? authorName;
  final String? authorPhotoUrl;

  const AppNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.authorName,
    this.authorPhotoUrl,
  });

  AppNotification copyWith({
    String? id,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? authorName,
    String? authorPhotoUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
    );
  }
}
