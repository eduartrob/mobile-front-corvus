import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/services/security_service.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/auth_action_button.dart';
import 'package:mobile/shared/widgets/auth_scaffold.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/role_selector.dart';
import 'package:mobile/shared/widgets/social_auth_button.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, this.role = 'ALUMNO'});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SecurityService _securityService = SecurityService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  late String _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    _securityService.preventScreenshots(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      if (provider.email.isNotEmpty) _emailController.text = provider.email;
      if (provider.password.isNotEmpty) {
        _passwordController.text = provider.password;
        _confirmPasswordController.text = provider.password;
      }
      _emailController.addListener(() => provider.email = _emailController.text);
      _passwordController.addListener(() => provider.password = _passwordController.text);
      provider.role = _currentRole;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityService.preventScreenshots(false);
    super.dispose();
  }

  void _handleRoleChanged(String newRole) {
    setState(() {
      _currentRole = newRole;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    provider.role = _currentRole;
  }

  bool _validateInputs() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    // Trim passwords to prevent accidental trailing spaces
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    if (email.isEmpty) {
      setState(() => _emailError = l10n.requiredField);
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() => _emailError = l10n.invalidEmail);
        isValid = false;
      }
    }

    if (password.isEmpty) {
      setState(() => _passwordError = l10n.requiredField);
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = l10n.invalidPassword);
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = l10n.requiredField);
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = l10n.passwordMismatch);
      isValid = false;
    }

    if (!isValid) {
      _showSnack(l10n.requiredField); // Or just show the generic snackbar
    }

    return isValid;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _continueRegistration() {
    FocusScope.of(context).unfocus();
    if (!_validateInputs()) return;

    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    provider.setRegisterData(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _currentRole,
    );

    if (_currentRole == 'DOCENTE' || _currentRole == 'PROFESOR') {
      if (mounted) context.push('/register-teacher-verification');
    } else {
      if (mounted) context.push('/register-student-university');
    }
  }

  Future<void> _handleGoogleRegister() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: kIsWeb
            ? null
            : '1078483343139-2fobsjceva5r60i6vrpcg4jbjddmj4uo.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null || !mounted) return;

      final email = googleUser.email;
      final authCode = googleUser.serverAuthCode;

      const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final rnd = Random();
      final randomPassword = String.fromCharCodes(Iterable.generate(
          12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      provider.setRegisterData(
        email: email,
        password: randomPassword,
        role: _currentRole,
        googleAuthCode: authCode,
      );

      if (!mounted) return;
      if (_currentRole == 'DOCENTE' || _currentRole == 'PROFESOR') {
        context.push('/register-teacher-verification');
      } else {
        context.push('/register-student-university');
      }
    } catch (e) {
      if (mounted) _showSnack('Error con Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      bottomAlign: true,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.register,
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
            '${l10n.registerAsStudent.replaceFirst(l10n.student, '')}${_currentRole == 'ALUMNO' ? l10n.student : l10n.teacher}',
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
            hint: 'ejemplo@acaderag.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            iconColor: colors.primary,
            errorText: _emailError,
          ),
          if (_currentRole == 'ALUMNO') ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.universityEmailHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          InputCompleted(
            label: l10n.password,
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: true,
            controller: _passwordController,
            iconColor: colors.primary,
            errorText: _passwordError,
          ),
          const SizedBox(height: 16),
          InputCompleted(
            label: l10n.confirmPassword,
            hint: '••••••••',
            icon: Icons.lock_reset_outlined,
            obscure: true,
            controller: _confirmPasswordController,
            iconColor: colors.primary,
            errorText: _confirmPasswordError,
          ),
          const SizedBox(height: 24),
          AuthActionButton(
            text: l10n.register,
            icon: Icons.arrow_forward,
            onPressed: _continueRegistration,
          ),
          const SizedBox(height: 24),
          AuthDivider(label: l10n.orRegisterWith),
          const SizedBox(height: 16),
          SocialAuthButton(
            onTap: _handleGoogleRegister,
          ),
          const SizedBox(height: 24),
          AuthFooter(
            primaryText: '${l10n.haveAccount} ',
            actionText: l10n.login,
            onActionTap: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
