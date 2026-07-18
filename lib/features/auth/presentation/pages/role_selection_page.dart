import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/auth_action_button.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/shared/widgets/role_selector.dart';
import 'package:url_launcher/url_launcher.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  String _selectedRole = 'ALUMNO';
  late AnimationController _animationController;
  late AnimationController _orbController; // orbes de fondo
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _securityService.preventScreenshots(true);

    // Animación de entrada de UI
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _securityService.preventScreenshots(false);
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    context.push('/login', extra: _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isStudent = _selectedRole.toUpperCase() == 'ALUMNO';

    return AuthScaffold(
      role: _selectedRole,
      showLogo: false,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/icons/logo2.png', height: 72),
                const SizedBox(height: 16),
                Text(
                  '¡Bienvenido a Corvus!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Plataforma de innovación diseñada para revolucionar la evaluación, validación y acompañamiento de proyectos universitarios.',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
                    ),
                  ),
                  child: RoleSelector(
                    selectedRole: _selectedRole,
                    onRoleChanged: (role) => setState(() => _selectedRole = role),
                  ),
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
                    ),
                  ),
                  child: _RolePreview(isStudent: isStudent, colors: colors),
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.6, 1.0),
                      ),
                    ),
                    child: AuthActionButton(
                      text: 'Iniciar',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _navigateToLogin,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthFooter(
                  primaryText: '${l10n.termsOfUse} ',
                  actionText: l10n.termsOfService,
                  onActionTap: () async {
                    final url = Uri.parse(
                        'https://eduartrob.github.io/CORVUS/pages/terminos.html');
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _RolePreview extends StatelessWidget {
  final bool isStudent;
  final ColorScheme colors;

  const _RolePreview({required this.isStudent, required this.colors});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<bool>(isStudent),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isStudent
              ? colors.primaryContainer.withValues(alpha: 0.4)
              : colors.tertiaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isStudent ? colors.primary : colors.tertiary)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isStudent ? Icons.school : Icons.co_present,
                color: isStudent ? colors.primary : colors.tertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStudent ? 'Acceso para Alumnos' : 'Acceso para Docentes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isStudent
                        ? 'Explora proyectos, forma equipos y desarrolla tu propuesta académica.'
                        : 'Revisa propuestas, gestiona reglas y supervisa el progreso de tus alumnos.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
