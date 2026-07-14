import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/app_notification.dart';
import '../provider/notifications_provider.dart';

class NotificationItemCard extends StatefulWidget {
  final AppNotification notification;
  final bool autoExpandAndHighlight;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.autoExpandAndHighlight = false,
  });

  @override
  State<NotificationItemCard> createState() => _NotificationItemCardState();
}

class _NotificationItemCardState extends State<NotificationItemCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _highlightController;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.autoExpandAndHighlight;
    
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.autoExpandAndHighlight) {
      _startHighlightAnimation();
    }
  }

  void _startHighlightAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _highlightController.forward().then((_) {
          _highlightController.reverse();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant NotificationItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoExpandAndHighlight != oldWidget.autoExpandAndHighlight && widget.autoExpandAndHighlight) {
      setState(() {
        _isExpanded = true;
      });
      _startHighlightAnimation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _colorTween = ColorTween(
      begin: widget.notification.isRead
          ? colorScheme.surfaceContainerLow
          : colorScheme.surfaceContainerHighest,
      end: colorScheme.primaryContainer.withValues(alpha: 0.4),
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return 'Hace ${m == 0 ? 1 : m} min';
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
    final notification = widget.notification;

    Color iconColor;
    Color bgColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.success:
        iconColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        iconData = Icons.check_circle_outline_rounded;
        break;
      case NotificationType.warning:
        iconColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFEF3C7);
        iconData = Icons.error_outline_rounded;
        break;
      case NotificationType.error:
        iconColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        iconData = Icons.cancel_outlined;
        break;
      case NotificationType.info:
        iconColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFEFF6FF);
        iconData = Icons.info_outline_rounded;
        break;
    }

    Widget leadingWidget;
    if (notification.authorPhotoUrl != null && notification.authorPhotoUrl!.isNotEmpty) {
      leadingWidget = CircleAvatar(
        radius: 21,
        backgroundImage: NetworkImage(notification.authorPhotoUrl!),
      );
    } else {
      leadingWidget = Container(
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
      );
    }

    // Dividimos el mensaje en título (primera línea) y cuerpo (resto),
    // asumiendo que el backend los manda separados por \n (nuestro provider hace eso).
    final parts = notification.message.split('\n');
    final title = parts.isNotEmpty ? parts.first : '';
    final body = parts.length > 1 ? parts.sublist(1).join('\n') : '';

    return AnimatedBuilder(
      animation: _highlightController,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: notification.isRead ? 0 : 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: _colorTween.value,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () {
              final provider = context.read<NotificationsProvider>();
              if (!provider.isSelectionMode) {
                provider.enterSelectionMode(notification.id);
              } else {
                provider.toggleSelection(notification.id);
              }
            },
            onTap: () {
              final provider = context.read<NotificationsProvider>();
              if (provider.isSelectionMode) {
                provider.toggleSelection(notification.id);
                return;
              }
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (!notification.isRead) {
                context.read<NotificationsProvider>().markAsRead(notification.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (context.watch<NotificationsProvider>().isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 8.0),
                      child: Checkbox(
                        value: context.watch<NotificationsProvider>().selectedIds.contains(notification.id),
                        onChanged: (val) {
                          context.read<NotificationsProvider>().toggleSelection(notification.id);
                        },
                      ),
                    ),
                  leadingWidget,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.authorName != null && notification.authorName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              notification.authorName!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          AnimatedCrossFade(
                            firstChild: Text(
                              body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            secondChild: Text(
                              body,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            crossFadeState: _isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                            sizeCurve: Curves.easeInOut,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}
