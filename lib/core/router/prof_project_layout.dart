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

    switch (index) {
      case 0:
        context.go('/prof-project/$projectId/dashboard');
        break;
      case 1:
        context.go('/prof-project/$projectId/reviews');
        break;
      case 2:
        context.go('/prof-project/$projectId/rules');
        break;
      case 3:
        context.go('/prof-project/$projectId/settings');
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
        final location = GoRouterState.of(context).uri.path;
        final currentIdx = _calculateSelectedIndex(context);
        // Si estamos en /config (página empujada sobre el tablero),
        // regresar al tablero del proyecto, no salir al dashboard.
        Future.microtask(() {
          if (!context.mounted) return;
          if (location.endsWith('/config')) {
            _onItemTapped(context, 0);
          } else if (currentIdx != 0) {
            // Estamos en un tab secundario (reviews, rules, settings).
            // Regresar al tablero de forma sincrónica para evitar carreras.
            _onItemTapped(context, 0);
          } else {
            // Ya estamos en el tablero: salir al dashboard de proyectos.
            context.go('/prof-dash');
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
