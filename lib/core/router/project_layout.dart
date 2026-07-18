import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';

class ProjectLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ProjectLayout({super.key, required this.navigationShell});

  @override
  State<ProjectLayout> createState() => _ProjectLayoutState();
}

class _ProjectLayoutState extends State<ProjectLayout> {
  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        // Si no estamos en la primera pestaña (Mi Equipo), regresar a ella
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        // Ya estamos en Mi Equipo: volver a la lista de proyectos
        context.go('/projects');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: widget.navigationShell,
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onItemTapped,
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