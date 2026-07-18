import 'package:flutter/material.dart';

class CorvusSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CorvusSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<CorvusSkeleton> createState() => _CorvusSkeletonState();
}

class _CorvusSkeletonState extends State<CorvusSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[50]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Animate from left to right (-2.0 to 2.0)
        final slide = -2.0 + (_controller.value * 4.0);
        
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(slide - 1.5, 0),
              end: Alignment(slide + 1.5, 0),
            ),
          ),
        );
      },
    );
  }
}
