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
  DateTime? _lastPressedAt;

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) return;

    final path = GoRouterState.of(context).uri.path;
    final rootPaths = ['/prof-dash', '/prof-reviews', '/prof-rules', '/prof-history'];
    
    if (!rootPaths.contains(path)) {
      if (context.canPop()) {
        context.pop();
      }
      return;
    }

    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        _lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toca "Volver" de nuevo para salir'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
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
      ),
    );
  }
}
