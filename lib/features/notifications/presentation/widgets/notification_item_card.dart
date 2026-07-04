import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/app_notification.dart';
import '../provider/notifications_provider.dart';

class NotificationItemCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationItemCard({super.key, required this.notification});

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color iconColor;
    Color bgColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.success:
        iconColor = const Color(0xFF10B981); // Emerald Green
        bgColor = const Color(0xFFECFDF5);
        iconData = Icons.check_circle_outline_rounded;
        break;
      case NotificationType.warning:
        iconColor = const Color(0xFFF59E0B); // Amber Yellow
        bgColor = const Color(0xFFFEF3C7);
        iconData = Icons.error_outline_rounded;
        break;
      case NotificationType.error:
        iconColor = const Color(0xFFEF4444); // Rose Red
        bgColor = const Color(0xFFFEE2E2);
        iconData = Icons.cancel_outlined;
        break;
      case NotificationType.info:
        iconColor = const Color(0xFF3B82F6); // Blue Info
        bgColor = const Color(0xFFEFF6FF);
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? colorScheme.outlineVariant.withOpacity(0.3)
              : colorScheme.primary.withOpacity(0.15),
          width: notification.isRead ? 1 : 1.5,
        ),
      ),
      color: notification.isRead
          ? colorScheme.surface
          : colorScheme.primary.withOpacity(0.02),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationsProvider>().markAsRead(notification.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle Indicator
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Message & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Unread Blue Dot
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
