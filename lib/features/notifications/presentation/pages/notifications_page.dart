import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../provider/notifications_provider.dart';
import '../widgets/notification_item_card.dart';

class NotificationsPage extends StatelessWidget {
  final bool highlightLatest;
  const NotificationsPage({super.key, this.highlightLatest = false});

  @override
  Widget build(BuildContext context) {
    return _NotificationsView(highlightLatest: highlightLatest);
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

    return Scaffold(
      appBar: AppBar(
        leading: provider.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => provider.clearSelection(),
              )
            : null,
        title: Text(
          provider.isSelectionMode
              ? '${provider.selectedIds.length} Seleccionadas'
              : 'Notificaciones',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: provider.isSelectionMode ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: provider.isSelectionMode ? colorScheme.onSurfaceVariant : colorScheme.onSurface),
        actions: [
          if (provider.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Borrar seleccionadas',
              onPressed: () {
                provider.deleteSelected();
              },
            )
          else if (notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all),
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
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Limpiar todas',
              onPressed: () {
                provider.clearAll();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificaciones eliminadas'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ]
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
                builder: (BuildContext context, Widget child, IndicatorController controller) {
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final double value = controller.value;
                      final double rotate = (value * 2 * 3.14159) % (2 * 3.14159); // Simple rotation for bell
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          if (controller.isDragging || controller.isArmed || controller.isLoading)
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItemCard(
                      notification: notification,
                      autoExpandAndHighlight: highlightLatest && index == 0,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
