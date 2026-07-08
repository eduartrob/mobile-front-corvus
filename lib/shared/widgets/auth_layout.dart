import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/theme/app_dimens.dart';

class AuthLayout extends StatelessWidget {
  final String appTitle;
  final String cardTitle;
  final String? cardSubtitle;
  final List<Widget> children;
  final Widget? bottomContent;

  const AuthLayout({
    super.key,
    this.appTitle = 'Corvus',
    required this.cardTitle,
    this.cardSubtitle,
    required this.children,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenMargin,
        vertical: 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                  : colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset('assets/icons/logo.svg'),
          ),
          const SizedBox(height: 12),
          Text(
            appTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              letterSpacing: -1,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 24),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Using RepaintBoundary to isolate expensive drop shadows from text input repaints
          RepaintBoundary(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? colors.surface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? colors.outlineVariant.withValues(alpha: 0.2)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          blurRadius: 30, // Reduced from 50 to 30 for performance
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          blurRadius: 25, // Reduced from 40 to 25 for performance
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    cardTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (cardSubtitle != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      cardSubtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  ...children,
                ],
              ),
            ),
          ),

          if (bottomContent != null) ...[
            const SizedBox(height: 48),
            bottomContent!,
          ],
        ],
      ),
    );
  }
}
