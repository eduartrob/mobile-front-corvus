import 'package:flutter/material.dart';

/// Un Avatar reutilizable en toda la app que muestra de forma elegante el
/// anillo/borde dorado/naranja glowing de la Membresía PRO cuando `isPro` es true.
class ProAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final bool isPro;
  final String fallbackInitial;
  final VoidCallback? onTap;

  const ProAvatar({
    super.key,
    this.photoUrl,
    required this.radius,
    required this.isPro,
    this.fallbackInitial = 'U',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double borderWidth = isPro ? 3.0 : 0.0;
    final double innerRadius = isPro ? (radius - 2.5) : radius;

    final avatarWidget = Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: isPro
            ? [
                BoxShadow(
                  color: const Color(0xFFFFA500).withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1.5,
                )
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: innerRadius,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
            ? NetworkImage(photoUrl!)
            : null,
        child: (photoUrl == null || photoUrl!.isEmpty)
            ? Text(
                fallbackInitial.isNotEmpty ? fallbackInitial[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: innerRadius * 0.9,
                  color: Colors.black87,
                ),
              )
            : null,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }
    return avatarWidget;
  }
}
