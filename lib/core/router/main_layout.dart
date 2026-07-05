import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  DateTime? _lastPressedAt;

  void _onItemTapped(BuildContext context, int index) {
    if (index == widget.navigationShell.currentIndex) {
      if (index == 0) {
        context.read<InspirationProvider>().refreshIndicatorKey.currentState?.show();
      }
      return;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) return;

    final path = GoRouterState.of(context).uri.path;
    final rootPaths = ['/inspiration', '/my-project', '/search', '/teams'];
    
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
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: l10n.navSearch,
            ),
            CustomNavItemData(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups,
              label: l10n.navTeams,
            ),
          ],
        ),
      ),
    );
  }
}
