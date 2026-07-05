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

  Future<bool> _onBackPressed() async {
    // Si no estamos en Dashboard (pestaña 0), volver a él
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return true; // Interceptado: no cierres la app
    }

    // Ya estamos en Dashboard: doble toque para salir
    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toca "Volver" de nuevo para salir'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true; // Interceptado: no cierres la app todavía
    }

    // Segunda vez: cerrar la app
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BackButtonListener(
      onBackButtonPressed: _onBackPressed,
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
