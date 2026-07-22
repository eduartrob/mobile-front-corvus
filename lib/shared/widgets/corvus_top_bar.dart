import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/shared/widgets/pro_avatar.dart';

class CorvusTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final Widget? titleWidget;
  final bool hideActions;
  final List<Widget>? extraActions;
  final bool showBackButton;

  const CorvusTopBar({
    super.key,
    this.showLogo = true,
    this.titleWidget,
    this.hideActions = false,
    this.extraActions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.select<AuthProvider, String?>((a) => a.currentUser?.photoUrl);
    final role = context.select<AuthProvider, String?>((a) => a.role);
    
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final bool hasBackArrow = showBackButton && canPop;
    final bool actuallyShowLogo = showLogo && !hasBackArrow;

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrolledUnderElevation: 0,
      titleSpacing: actuallyShowLogo && titleWidget == null ? 16.0 : 0.0,
      title: titleWidget ?? (actuallyShowLogo 
          ? Image.asset(
              'assets/icons/logo2.png',
              height: 32,
              width: 32,
            ) 
          : null),
      actions: hideActions ? const [] : [
        if (extraActions != null) ...extraActions!,
        // Notifications Bell
        Consumer<NotificationsProvider>(
          builder: (context, notificationsProvider, child) {
            final unreadCount = notificationsProvider.unreadCount;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),

        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (role == 'PROFESOR') {
                  if (GoRouterState.of(context).matchedLocation != '/prof-profile') {
                     context.push('/prof-profile');
                  }
                } else {
                  if (GoRouterState.of(context).matchedLocation != '/profile') {
                    context.push('/profile');
                  }
                }
              },
              customBorder: const CircleBorder(),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ProAvatar(
                    photoUrl: authProvider.currentUser?.photoUrl,
                    radius: 18,
                    isPro: authProvider.isProActive,
                    fallbackInitial: authProvider.currentUser?.name ?? 'U',
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
