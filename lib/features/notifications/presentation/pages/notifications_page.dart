import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../provider/notifications_provider.dart';
import '../widgets/notification_item_card.dart';

class NotificationsPage extends StatefulWidget {
  static bool isOpen = false;
  final bool highlightLatest;
  const NotificationsPage({super.key, this.highlightLatest = false});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    NotificationsPage.isOpen = true;
    // Mark all as read when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().markAllAsReadOnOpen();
    });
  }

  @override
  void dispose() {
    NotificationsPage.isOpen = false;
    // Exit selection mode if user leaves via back/navigation
    context.read<NotificationsProvider>().exitSelectionMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationsView(highlightLatest: widget.highlightLatest);
  }
}

class _NotificationsView extends StatelessWidget {
  final bool highlightLatest;
  const _NotificationsView({this.highlightLatest = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<NotificationsProvider>();
    final notifications = provider.notifications;
    final isSelecting = provider.isSelectionMode;

    return PopScope(
      // When in selection mode, intercept back to exit selection — not navigate away
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isSelecting) {
          provider.exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isSelecting
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => provider.exitSelectionMode(),
                )
              : null,
          title: Text(
            isSelecting
                ? '${provider.selectedIds.length} seleccionada${provider.selectedIds.length == 1 ? '' : 's'}'
                : 'Notificaciones',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isSelecting
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(
            color: isSelecting
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
          actions: [
            if (isSelecting) ...[
              // Select / deselect all
              if (provider.selectedIds.length < notifications.length)
                TextButton(
                  onPressed: () {
                    for (final n in notifications) {
                      if (!provider.selectedIds.contains(n.id)) {
                        provider.toggleSelection(n.id);
                      }
                    }
                  },
                  child: const Text('Todas'),
                ),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                tooltip: 'Borrar seleccionadas',
                onPressed: () async {
                  final count = provider.selectedIds.length;
                  await provider.deleteSelected();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '$count notificacion${count == 1 ? '' : 'es'} eliminada${count == 1 ? '' : 's'}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ] else if (notifications.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Marcar todas como leídas',
                onPressed: () {
                  provider.markAllAsRead();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas marcadas como leídas'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'clear_all') {
                    provider.clearAll();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones eliminadas'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded, size: 20),
                        SizedBox(width: 12),
                        Text('Limpiar todo'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 72,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes notificaciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomRefreshIndicator(
                  // Disable pull-to-refresh while in selection mode
                  triggerMode: isSelecting
                      ? IndicatorTriggerMode.onEdge
                      : IndicatorTriggerMode.onEdge,
                  notificationPredicate: isSelecting
                      ? (_) => false  // block scroll notifications → no refresh
                      : defaultScrollNotificationPredicate,
                  builder: (BuildContext context, Widget child,
                      IndicatorController controller) {
                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        final double value = controller.value;
                        final double rotate =
                            (value * 2 * 3.14159) % (2 * 3.14159);
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            if (controller.isDragging ||
                                controller.isArmed ||
                                controller.isLoading)
                              Positioned(
                                top: 20,
                                child: Transform.rotate(
                                  angle: rotate,
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: colorScheme.primary,
                                    size: 32 * value.clamp(0.5, 1.0),
                                  ),
                                ),
                              ),
                            Transform.translate(
                              offset: Offset(0.0, 60.0 * value),
                              child: child,
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onRefresh: () async {
                    await provider.fetchNotifications();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationItemCard(
                        notification: notification,
                        autoExpandAndHighlight:
                            highlightLatest && index == 0,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
