enum NotificationType { success, warning, error, info, security, payment }

class AppNotification {
  final String id;
  final String message;
  final String? notifTitle;
  final String? deepLink;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? authorName;
  final String? authorPhotoUrl;

  const AppNotification({
    required this.id,
    required this.message,
    this.notifTitle,
    this.deepLink,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.authorName,
    this.authorPhotoUrl,
  });

  AppNotification copyWith({
    String? id,
    String? message,
    String? notifTitle,
    String? deepLink,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? authorName,
    String? authorPhotoUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      notifTitle: notifTitle ?? this.notifTitle,
      deepLink: deepLink ?? this.deepLink,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
    );
  }
}
