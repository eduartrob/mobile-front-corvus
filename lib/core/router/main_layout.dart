import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) {
      if (index == 0) {
        context.read<InspirationProvider>().refreshIndicatorKey.currentState?.show();
      }
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomAnimatedBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: [
          CustomNavItemData(
            icon: Icons.lightbulb_outline,
            activeIcon: Icons.lightbulb,
            label: l10n.navInspiration,
          ),
          CustomNavItemData(
            icon: Icons.folder_open,
            activeIcon: Icons.folder,
            label: l10n.navMyProject,
          ),
          CustomNavItemData(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: l10n.navTeams,
          ),
          CustomNavItemData(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
