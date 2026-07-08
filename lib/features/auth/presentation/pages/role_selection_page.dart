import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_dimens.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenMargin, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                          : colors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Corvus',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 40),
                    height: 4,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Bienvenido de nuevo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selecciona el rol con el que\ndeseas ingresar a la plataforma',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _RoleButton(
                    title: 'Alumno',
                    icon: Icons.person,
                    onTap: () {
                      context.push('/login', extra: 'ALUMNO');
                    },
                    isDark: isDark,
                    colors: colors,
                    customIconColor: Colors.blueAccent,
                  ),
                  const SizedBox(height: 24),
                  _RoleButton(
                    title: 'Docente',
                    icon: Icons.school,
                    onTap: () {
                      context.push('/login', extra: 'DOCENTE');
                    },
                    isDark: isDark,
                    colors: colors,
                    customIconColor: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme colors;
  final Color? customIconColor;

  const _RoleButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.colors,
    this.customIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.2)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: customIconColor ?? colors.primary, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
