import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/auth_action_button.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/role_selector.dart';
import 'package:mobile/shared/widgets/social_auth_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, this.role = 'ALUMNO'});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SecurityService _securityService = SecurityService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late String _currentRole;
  
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    _securityService.preventScreenshots(true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  void _handleRoleChanged(String newRole) {
    setState(() {
      _currentRole = newRole;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final l10n = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      _showSnack(l10n.requiredField);
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnack(l10n.invalidEmail);
      return false;
    }

    if (password.length < 6) {
      _showSnack(l10n.invalidPassword);
      return false;
    }

    return true;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    setState(() => _isEmailLoading = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isEmailLoading = false);

    if (authProvider.status == AuthStatus.authenticated) {
      _navigateBasedOnRole(authProvider);
    } else {
      _showSnack(authProvider.errorMessage ?? AppLocalizations.of(context)!.unknownError);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);

    final authProvider = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (authProvider.status == AuthStatus.authenticated) {
      _navigateBasedOnRole(authProvider);
    } else if (authProvider.errorMessage != null &&
        authProvider.errorMessage!.startsWith('USER_NOT_REGISTERED|')) {
      final parts = authProvider.errorMessage!.split('|');
      final email = parts[1];
      final authCode = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;

      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      provider.clearData();

      const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final rnd = Random();
      final randomPassword = String.fromCharCodes(Iterable.generate(
          12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

      provider.setRegisterData(
        email: email,
        password: randomPassword,
        role: _currentRole,
        googleAuthCode: authCode,
      );

      if (_currentRole == 'DOCENTE' || _currentRole == 'PROFESOR') {
        context.push('/register-teacher-verification');
      } else {
        context.push('/register-student-university');
      }
    } else {
      String msg = authProvider.errorMessage ?? l10n.unknownError;
      if (msg == 'AUTH_NOT_ALLOWED') {
        msg = 'Dominio de correo no permitido.';
      } else if (msg == 'AUTH_CANCELED') {
        msg = 'Inicio de sesión cancelado.';
      }
      _showSnack(msg);
    }
  }

  void _navigateBasedOnRole(AuthProvider authProvider) {
    final actualRole = authProvider.currentUser?.role?.toUpperCase() ?? _currentRole.toUpperCase();
    final uiRole = _currentRole.toUpperCase() == 'PROFESOR' ? 'DOCENTE' : _currentRole.toUpperCase();
    final backendRole = actualRole == 'PROFESOR' ? 'DOCENTE' : actualRole;

    if (uiRole != backendRole) {
      authProvider.logout();
      _showSnack(
        'Esta cuenta pertenece a un $actualRole. Por favor ingresa desde la sección correcta.',
      );
      return;
    }

    if (backendRole == 'DOCENTE') {
      context.pushReplacement('/prof-dash');
    } else {
      context.pushReplacement('/inspiration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      role: _currentRole,
      bottomAlign: true,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.welcomeBack,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              height: 3,
              width: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          RoleSelector(
            selectedRole: _currentRole,
            onRoleChanged: _handleRoleChanged,
          ),
          const SizedBox(height: 24),
          InputCompleted(
            label: l10n.email,
            hint: 'ejemplo@correo.com',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            iconColor: colors.primary,
          ),
          const SizedBox(height: 16),
          InputCompleted(
            label: l10n.password,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: true,
            controller: _passwordController,
            iconColor: colors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.universityEmailHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return AuthActionButton(
                text: l10n.login,
                icon: Icons.arrow_forward,
                isLoading: _isEmailLoading,
                onPressed: authProvider.status == AuthStatus.loading ? null : _handleEmailLogin,
              );
            },
          ),
          const SizedBox(height: 24),
          AuthDivider(label: l10n.orContinueWith),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return SocialAuthButton(
                isLoading: _isGoogleLoading,
                onTap: authProvider.status == AuthStatus.loading ? null : _handleGoogleLogin,
              );
            },
          ),
          const SizedBox(height: 24),
          AuthFooter(
            primaryText: '${l10n.noAccount} ',
            actionText: l10n.register,
            onActionTap: () {
              context.read<RegistrationProvider>().clearData();
              context.push('/register', extra: _currentRole);
            },
          ),
        ],
      ),
    );
  }
}