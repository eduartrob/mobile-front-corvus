import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';

class ProjectLayout extends StatelessWidget {
  final String projectId;
  final Widget child;

  const ProjectLayout({super.key, required this.projectId, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.endsWith('/teams')) return 0;
    if (location.endsWith('/proposal')) return 1;
    if (location.endsWith('/chat')) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    final currentIndex = _calculateSelectedIndex(context);
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/project/$projectId/teams');
        break;
      case 1:
        context.go('/project/$projectId/proposal');
        break;
      case 2:
        context.go('/project/$projectId/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final currentIdx = _calculateSelectedIndex(context);
        Future.microtask(() {
          if (!context.mounted) return;
          if (currentIdx != 0) {
            _onItemTapped(context, 0);
          } else {
            context.go('/projects');
          }
        });
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          items: const [
            CustomNavItemData(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups,
              label: 'Mi Equipo',
            ),
            CustomNavItemData(
              icon: Icons.upload_file_outlined,
              activeIcon: Icons.upload_file,
              label: 'Propuesta',
            ),
            CustomNavItemData(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
