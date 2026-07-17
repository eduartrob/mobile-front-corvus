import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';

class ProfProjectLayout extends StatelessWidget {
  final String projectId;
  final Widget child;

  const ProfProjectLayout({super.key, required this.projectId, required this.child});

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

    if (currentIndex == 0 && index != 0) {
      // Tablero → tab secundario: PUSH para preservar la pila del root navigator
      switch (index) {
        case 1: context.push('/prof-project/$projectId/reviews'); break;
        case 2: context.push('/prof-project/$projectId/rules'); break;
        case 3: context.push('/prof-project/$projectId/settings'); break;
      }
    } else if (index == 0 && currentIndex != 0) {
      // Tab secundario → Tablero: POP si hay algo en la pila
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/prof-project/$projectId/dashboard');
      }
    } else {
      // Cambio entre tabs secundarios: pop el actual y push el nuevo en microtask
      if (context.canPop()) {
        context.pop();
        Future.microtask(() {
          if (!context.mounted) return;
          switch (index) {
            case 1: context.push('/prof-project/$projectId/reviews'); break;
            case 2: context.push('/prof-project/$projectId/rules'); break;
            case 3: context.push('/prof-project/$projectId/settings'); break;
          }
        });
      } else {
        // Fallback: go() si no hay nada que popear
        switch (index) {
          case 0: context.go('/prof-project/$projectId/dashboard'); break;
          case 1: context.go('/prof-project/$projectId/reviews'); break;
          case 2: context.go('/prof-project/$projectId/rules'); break;
          case 3: context.go('/prof-project/$projectId/settings'); break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final location = GoRouterState.of(context).uri.path;
        Future.microtask(() {
          if (!context.mounted) return;
          if (location.endsWith('/config')) {
            // /config fue empujado sobre el tablero: solo pop
            if (context.canPop()) context.pop();
          } else {
            // Para cualquier tab: pop si hay algo en la pila, sino ir a prof-dash
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/prof-dash');
            }
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
