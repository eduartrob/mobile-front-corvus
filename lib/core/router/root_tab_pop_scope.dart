import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RootTabPopScope extends StatefulWidget {
  final Widget child;
  final String fallbackPath;

  const RootTabPopScope({
    super.key,
    required this.child,
    required this.fallbackPath,
  });

  @override
  State<RootTabPopScope> createState() => _RootTabPopScopeState();
}

class _RootTabPopScopeState extends State<RootTabPopScope> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final path = GoRouterState.of(context).uri.path;
        
        if (path != widget.fallbackPath) {
          context.go(widget.fallbackPath);
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
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
      },
      child: widget.child,
    );
  }
}
