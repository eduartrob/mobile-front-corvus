import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/components/custom_bottom_nav_bar.dart';

class ProfMainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProfMainLayout({super.key, required this.navigationShell});

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomAnimatedBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onItemTapped,
        items: const [
          CustomNavItemData(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dash',
          ),
          CustomNavItemData(
            icon: Icons.reviews_outlined,
            activeIcon: Icons.reviews,
            label: 'Reviews',
          ),
          CustomNavItemData(
            icon: Icons.gavel_outlined,
            activeIcon: Icons.gavel,
            label: 'Rules',
          ),
          CustomNavItemData(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
          ),
        ],
      ),
    );
  }
}
