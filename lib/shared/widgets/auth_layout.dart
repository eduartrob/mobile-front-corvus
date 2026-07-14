import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final String appTitle;
  final String cardTitle;
  final String? cardSubtitle;
  final Widget? customSubtitle;
  final List<Widget> children;
  final Widget? bottomContent;
  final bool showLogo;
  final EdgeInsets padding;
  final Widget? leading;

  const AuthLayout({
    super.key,
    this.appTitle = 'Corvus',
    required this.cardTitle,
    this.cardSubtitle,
    this.customSubtitle,
    required this.children,
    this.bottomContent,
    this.showLogo = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: leading != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: leading,
            )
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [colors.surface, colors.surfaceContainerLowest]
                : [
                    colors.surface,
                    colors.primaryContainer.withValues(alpha: 0.35),
                    colors.surface,
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _DecorativeOrb(
                size: 320,
                color: colors.primary.withValues(alpha: isDark ? 0.06 : 0.10),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: _DecorativeOrb(
                size: 260,
                color: colors.tertiary.withValues(alpha: isDark ? 0.05 : 0.08),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: padding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showLogo) ...[
                          _AuthHeader(colors: colors, isDark: isDark),
                          const SizedBox(height: 32),
                        ],
                        _AuthCard(
                          colors: colors,
                          isDark: isDark,
                          title: cardTitle,
                          subtitle: cardSubtitle,
                          customSubtitle: customSubtitle,
                          children: children,
                        ),
                        if (bottomContent != null) ...[
                          const SizedBox(height: 48),
                          bottomContent!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final ColorScheme colors;
  final bool isDark;

  const _AuthHeader({required this.colors, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'auth_logo',
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                  : colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: isDark ? 0.1 : 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icons/logo2.png',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Corvus',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.tertiary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final ColorScheme colors;
  final bool isDark;
  final String title;
  final String? subtitle;
  final Widget? customSubtitle;
  final List<Widget> children;

  const _AuthCard({
    required this.colors,
    required this.isDark,
    required this.title,
    this.subtitle,
    this.customSubtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: isDark ? 0.15 : 0.06),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (customSubtitle != null) ...[
              const SizedBox(height: 8),
              customSubtitle!,
            ] else if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }
}
