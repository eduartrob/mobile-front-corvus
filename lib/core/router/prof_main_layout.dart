import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ProfMainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ProfMainLayout({super.key, required this.navigationShell});

  @override
  State<ProfMainLayout> createState() => _ProfMainLayoutState();
}

class _ProfMainLayoutState extends State<ProfMainLayout> {


  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: CustomAnimatedBottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onItemTapped,
        items: [
          CustomNavItemData(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: l10n.profNavDash,
          ),
          CustomNavItemData(
            icon: Icons.reviews_outlined,
            activeIcon: Icons.reviews,
            label: l10n.profNavReviews,
          ),
          CustomNavItemData(
            icon: Icons.gavel_outlined,
            activeIcon: Icons.gavel,
            label: l10n.profNavRules,
          ),
          CustomNavItemData(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: l10n.profNavHistory,
          ),
        ],
      ),
    );
  }
}
