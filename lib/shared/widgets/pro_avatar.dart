import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double borderWidth = isPro ? 3.0 : 0.0;
    final double innerRadius = isPro ? (radius - 2.5) : radius;

    final avatarWidget = Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPro
            ? LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: isPro
            ? [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1.5,
                )
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: innerRadius,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
            ? CachedNetworkImageProvider(photoUrl!)
            : null,
        child: (photoUrl == null || photoUrl!.isEmpty)
            ? Text(
                fallbackInitial.isNotEmpty ? fallbackInitial[0].toUpperCase() : 'U',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: innerRadius * 0.9,
                  color: colorScheme.onSurfaceVariant,
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
