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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        // Si no estamos en la primera pestaña (Inspiración), regresar a ella
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        // Ya estamos en Inspiración: doble toque para salir
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Toca "Volver" de nuevo para salir'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        SystemNavigator.pop();
      },
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
              icon: Icons.class_outlined,
              activeIcon: Icons.class_,
              label: 'Proyectos',
            ),
            CustomNavItemData(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: l10n.navSearch,
            ),
          ],
        ),
      ),
    );
  }
}
