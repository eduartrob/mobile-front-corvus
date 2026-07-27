enum NotificationType { success, warning, error, info, security, payment }

class AppNotification {
  final String id;
  final String message;
  final String? notifTitle;
  final String? deepLink;
  final String? rawType;
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
    this.rawType,
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
    String? rawType,
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
      rawType: rawType ?? this.rawType,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
    );
  }
}
