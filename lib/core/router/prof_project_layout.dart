import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';

class ProfProjectLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ProfProjectLayout({super.key, required this.navigationShell});

  @override
  State<ProfProjectLayout> createState() => _ProfProjectLayoutState();
}

class _ProfProjectLayoutState extends State<ProfProjectLayout> {
  int _previousIndex = 0;

  void _onItemTapped(int index) {
    if (index == widget.navigationShell.currentIndex) return;

    setState(() {
      _previousIndex = widget.navigationShell.currentIndex;
    });

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final isSlidingRight = currentIndex > _previousIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        if (currentIndex != 0) {
          // Volver al tablero (índice 0)
          setState(() => _previousIndex = currentIndex);
          widget.navigationShell.goBranch(0);
          return;
        }

        // Estamos en el tablero: volver a la lista de proyectos
        context.go('/prof-dash');
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
            child: widget.navigationShell,
          ),
        ),
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: currentIndex,
          onTap: _onItemTapped,
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