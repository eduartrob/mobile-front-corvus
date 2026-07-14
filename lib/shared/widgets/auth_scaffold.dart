import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showLogo;
  final EdgeInsets padding;
  final bool bottomAlign;
  final String? role;
  /// Painter opcional para fondo animado (se renderiza aislado con RepaintBoundary)
  final CustomPainter? backgroundPainter;

  const AuthScaffold({
    super.key,
    required this.child,
    this.showLogo = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
    this.bottomAlign = false,
    this.role,
    this.backgroundPainter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Diseño NUEVO: card blanca hasta el fondo + logo en círculo ──
    if (showLogo) {
      final topPad = MediaQuery.of(context).padding.top;
      const headerHeight = 160.0;
      const circleRadius = 44.0;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Fondo degradado pantalla completa
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colors.surface,
                          colors.primaryContainer.withValues(alpha: 0.2),
                          colors.surface,
                        ]
                      : (role == 'DOCENTE' || role == 'PROFESOR')
                          ? [
                              colors.tertiaryContainer,
                              colors.surface,
                            ]
                          : [
                              colors.primaryContainer,
                              colors.surface,
                            ],
                ),
              ),
            ),
            // Painter animado de fondo (aislado para no contaminar repaints)
            if (backgroundPainter != null)
              Positioned.fill(
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: CustomPaint(painter: backgroundPainter),
                  ),
                ),
              ),
            // Orbe decorativo único basado en el rol (evita cruce de colores)
            Positioned(
              top: -80,
              right: -100,
              child: _DecorativeOrb(
                size: 500,
                color: (role == 'DOCENTE' || role == 'PROFESOR')
                    ? colors.tertiary.withValues(alpha: isDark ? 0.08 : 0.15)
                    : colors.primary.withValues(alpha: isDark ? 0.08 : 0.15),
              ),
            ),
            // Título "Corvus" en cabecera
            Positioned(
              top: topPad + 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Corvus',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Card blanca llega hasta el fondo
            Positioned(
              top: headerHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainerLow : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: circleRadius + 20,
                      left: 28,
                      right: 28,
                      bottom: 32,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
            // Círculo con logo sobresaliendo sobre la card
            Positioned(
              top: headerHeight - circleRadius,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? colors.surfaceContainerHighest
                        : Colors.white,
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icons/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Diseño ORIGINAL: fondo + contenido scrollable (sin card fija) ──
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          colors.surface,
                          colors.primaryContainer.withValues(alpha: 0.2),
                          colors.surface,
                        ]
                      : (role == 'DOCENTE' || role == 'PROFESOR')
                          ? [
                              colors.tertiaryContainer,
                              colors.primaryContainer.withValues(alpha: 0.1),
                              colors.tertiaryContainer,
                            ]
                          : [
                              colors.primaryContainer,
                              colors.tertiaryContainer.withValues(alpha: 0.1),
                              colors.primaryContainer,
                            ],
                ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -150,
              child: _DecorativeOrb(
                size: 450,
                color: (role == 'DOCENTE' || role == 'PROFESOR')
                    ? colors.primary.withValues(alpha: isDark ? 0.05 : 0.10)
                    : colors.primary.withValues(alpha: isDark ? 0.15 : 0.30),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: _DecorativeOrb(
                size: 400,
                color: (role == 'DOCENTE' || role == 'PROFESOR')
                    ? colors.tertiary.withValues(alpha: isDark ? 0.20 : 0.40)
                    : colors.tertiary.withValues(alpha: isDark ? 0.05 : 0.10),
              ),
            ),
            // Painter animado de fondo (aislado)
            if (backgroundPainter != null)
              Positioned.fill(
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: CustomPaint(painter: backgroundPainter),
                  ),
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
                      children: [child],
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

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class AuthFooter extends StatelessWidget {
  final String? primaryText;
  final String? actionText;
  final VoidCallback? onActionTap;

  const AuthFooter({
    super.key,
    this.primaryText,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (primaryText != null && actionText != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                primaryText!,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterLink(
              label: l10n.terms,
              onTap: () async {
                final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/terminos.html');
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(width: 20),
            _FooterLink(
              label: l10n.privacy,
              onTap: () async {
                final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/privacidad.html');
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(width: 20),
            _FooterLink(
              label: l10n.help,
              onTap: () async {
                final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/ayuda.html');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  final mailUrl = Uri.parse('mailto:soporte@corvus.edu.mx');
                  await launchUrl(mailUrl);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FooterLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: colors.onSurfaceVariant,
          decoration: TextDecoration.underline,
          decorationColor: colors.outline,
        ),
      ),
    );
  }
}