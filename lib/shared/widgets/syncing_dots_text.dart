import 'package:flutter/material.dart';

/// Widget de animación de puntos suspensivos tipo "Sincronizando..."
/// Reemplaza el Stream.periodic anterior. Usa AnimationController
/// interno — no crea ningún Stream, no genera tráfico de eventos externos.
class SyncingDotsText extends StatefulWidget {
  final String label;
  final TextStyle? style;

  const SyncingDotsText({
    super.key,
    required this.label,
    this.style,
  });

  @override
  State<SyncingDotsText> createState() => _SyncingDotsTextState();
}

class _SyncingDotsTextState extends State<SyncingDotsText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          if (mounted) {
            setState(() {
              _dotCount = (_dotCount + 1) % 4;
            });
          }
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = List.generate(_dotCount, (_) => '.').join(' ');
    return Text(
      '${widget.label}$dots',
      style: widget.style,
    );
  }
}
