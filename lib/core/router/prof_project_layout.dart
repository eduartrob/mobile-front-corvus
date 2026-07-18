import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';

class ProfProjectLayout extends StatefulWidget {
  final String projectId;
  final Widget child;

  const ProfProjectLayout({super.key, required this.projectId, required this.child});

  @override
  State<ProfProjectLayout> createState() => _ProfProjectLayoutState();
}

class _ProfProjectLayoutState extends State<ProfProjectLayout> {
  int _previousIndex = 0;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.endsWith('/dashboard')) return 0;
    if (location.endsWith('/reviews')) return 1;
    if (location.endsWith('/rules')) return 2;
    if (location.endsWith('/settings')) return 3;
    // /config es una página empujada sobre el dashboard; se considera tablero.
    if (location.endsWith('/config')) return 0;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    final currentIndex = _calculateSelectedIndex(context);
    if (index == currentIndex) return;

    setState(() {
      _previousIndex = currentIndex;
    });

    switch (index) {
      case 0:
        context.go('/prof-project/${widget.projectId}/dashboard');
        break;
      case 1:
        context.go('/prof-project/${widget.projectId}/reviews');
        break;
      case 2:
        context.go('/prof-project/${widget.projectId}/rules');
        break;
      case 3:
        context.go('/prof-project/${widget.projectId}/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final isSlidingRight = currentIndex > _previousIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final location = GoRouterState.of(context).uri.path;
        Future.microtask(() {
          if (!context.mounted) return;
          if (location.endsWith('/config')) {
            // /config fue empujado sobre el tablero o tabs: solo pop
            if (context.canPop()) context.pop();
          } else if (currentIndex != 0) {
            // Si estamos en reviews, rules o settings, volver al tablero
            setState(() {
              _previousIndex = currentIndex;
            });
            context.go('/prof-project/${widget.projectId}/dashboard');
          } else {
            // Si estamos en el tablero principal del proyecto, salir al listado global
            context.go('/prof-dash');
          }
        });
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isIncoming = child.key == ValueKey(currentIndex);
            final dx = isIncoming
                ? (isSlidingRight ? 1.0 : -1.0)
                : (isSlidingRight ? -1.0 : 1.0);
            
            final offsetAnimation = Tween<Offset>(
              begin: Offset(dx, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          child: SizedBox(
            key: ValueKey(currentIndex),
            child: widget.child,
          ),
        ),
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          items: const [
            CustomNavItemData(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Tablero',
            ),
            CustomNavItemData(
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment,
              label: 'Revisiones',
            ),
            CustomNavItemData(
              icon: Icons.gavel_outlined,
              activeIcon: Icons.gavel,
              label: 'Reglas',
            ),
            CustomNavItemData(
              icon: Icons.people_outline,
              activeIcon: Icons.people,
              label: 'Docentes',
            ),
          ],
        ),
      ),
    );
  }
}
