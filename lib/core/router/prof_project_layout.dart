import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';
import 'package:mobile/features/prof_dash/presentation/pages/prof_dash_page.dart';
import 'package:mobile/features/prof_reviews/presentation/pages/prof_reviews_page.dart';
import 'package:mobile/features/prof_rules/presentation/pages/prof_rules_page.dart';
import 'package:mobile/features/projects/presentation/pages/prof_project_settings_page.dart';

class ProfProjectLayout extends StatefulWidget {
  final String projectId;
  final int initialTab;

  const ProfProjectLayout({
    super.key,
    required this.projectId,
    this.initialTab = 0,
  });

  @override
  State<ProfProjectLayout> createState() => _ProfProjectLayoutState();
}

class _ProfProjectLayoutState extends State<ProfProjectLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    // Actualizar URL sin recrear el widget
    context.go('/prof-project/${widget.projectId}?tab=$index');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          context.go('/prof-project/${widget.projectId}?tab=0');
          return;
        }

        context.go('/prof-dash');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            ProfDashPage(projectId: widget.projectId),
            ProfReviewsPage(projectId: widget.projectId),
            ProfRulesPage(projectId: widget.projectId),
            ProfProjectSettingsPage(projectId: widget.projectId),
          ],
        ),
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: _currentIndex,
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