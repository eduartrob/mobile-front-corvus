import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';
import 'package:mobile/features/teams/presentation/pages/teams_page.dart';
import 'package:mobile/features/my_project/presentation/pages/my_project_page.dart';
import 'package:mobile/features/my_project/presentation/pages/team_chat_page.dart';

class ProjectLayout extends StatefulWidget {
  final String projectId;
  final int initialTab;

  const ProjectLayout({
    super.key,
    required this.projectId,
    this.initialTab = 0,
  });

  @override
  State<ProjectLayout> createState() => _ProjectLayoutState();
}

class _ProjectLayoutState extends State<ProjectLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant ProjectLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        context.go('/projects');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TeamsPage(projectId: widget.projectId),
            const MyProjectPage(),
            const TeamChatPage(),
          ],
        ),
        bottomNavigationBar: CustomAnimatedBottomNavBar(
          currentIndex: _currentIndex,
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