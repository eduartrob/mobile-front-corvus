import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CustomNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CustomAnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItemData> items;

  const CustomAnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            return CustomNavItem(
              item: items[index],
              isSelected: currentIndex == index,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class CustomNavItem extends StatefulWidget {
  final CustomNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CustomNavItem> createState() => _CustomNavItemState();
}

class _CustomNavItemState extends State<CustomNavItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 150),
    );

    // Animación de rebote doble MÁS suave para el icono
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0).chain(CurveTween(curve: Curves.easeInQuad)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -2.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0).chain(CurveTween(curve: Curves.easeInQuad)), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _controller, 
      curve: const Interval(0.0, 0.8),
    ));

    // Animación de giro para el rombo (de 0 a 45 grados)
    _rotateAnimation = Tween<double>(begin: 0.0, end: math.pi / 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Animación de aparición (escala) para el rombo
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rombo que gira (Fondo)
                      if (_scaleAnimation.value > 0)
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      // Icono que rebota
                      Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: Icon(
                          widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                          color: widget.isSelected ? colorScheme.onPrimaryContainer : color,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
