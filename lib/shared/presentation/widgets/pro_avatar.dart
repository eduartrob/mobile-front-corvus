import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/theme/app_gradients.dart';
import 'package:mobile/core/theme/app_colors.dart';
/// anillo borde dorado naranja glowing de la membresía pro cuando ispro es true 
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
                colors: AppGradients.proGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: isPro
            ? [
                BoxShadow(
                  color: AppColors.proBadgeOrange.withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: innerRadius,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
            ? CachedNetworkImageProvider(photoUrl!)
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
