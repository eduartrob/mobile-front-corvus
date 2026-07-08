import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  final String role;
  const RegisterPage({super.key, this.role = 'ALUMNO'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Center(
              child: _RegisterForm(role: role),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final String role;
  const _RegisterForm({required this.role});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      
      if (provider.email.isNotEmpty) _emailController.text = provider.email;
      if (provider.password.isNotEmpty) {
        _passwordController.text = provider.password;
        _confirmPasswordController.text = provider.password;
      }
      
      _emailController.addListener(() {
        provider.email = _emailController.text;
      });
      _passwordController.addListener(() {
        provider.password = _passwordController.text;
      });
      provider.role = widget.role;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AuthLayout(
      appTitle: 'Corvus',
      cardTitle: 'Crear Cuenta',
      cardSubtitle: 'Registrándote como ${widget.role}',
      children: [
        InputCompleted(
          label: "Correo Electrónico",
          hint: "ejemplo@acaderag.com",
          icon: Icons.mail,
          controller: _emailController,
          iconColor: Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        InputCompleted(
          label: "Contraseña",
          hint: "••••••••",
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
          iconColor: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        InputCompleted(
          label: "Repetir Contraseña",
          hint: "••••••••",
          icon: Icons.lock_reset,
          obscure: true,
          controller: _confirmPasswordController,
          iconColor: Colors.redAccent,
        ),
        const SizedBox(height: 32),
        
        CorvusButton(
          text: "Continuar",
          onPressed: () {
            FocusScope.of(context).unfocus();
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            final confirmPassword = _confirmPasswordController.text;

            if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, completa todos los campos')),
              );
              return;
            }

            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, ingresa un correo válido')),
              );
              return;
            }

            if (password.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
              );
              return;
            }

            if (password != confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Las contraseñas no coinciden')),
              );
              return;
            }

            // Save to provider
            final provider = Provider.of<RegistrationProvider>(context, listen: false);
            provider.setRegisterData(
              email: email,
              password: password,
              role: widget.role,
            );

            if (widget.role == 'DOCENTE' || widget.role == 'PROFESOR') {
              context.push('/register-teacher-verification');
            } else {
              context.push('/register-student-university');
            }
          },
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'O registrarse con',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: Divider(color: colors.outlineVariant.withValues(alpha: 0.3))),
          ],
        ),
        const SizedBox(height: 16),
        
        Material(
          color: isDark ? colors.surfaceContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              // Google sign-in logic for registration, same as login practically,
              // but we will redirect to the next steps
              if (widget.role == 'DOCENTE' || widget.role == 'PROFESOR') {
                context.push('/register-teacher-verification');
              } else {
                context.push('/register-student-university');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? colors.outlineVariant.withValues(alpha: 0.3) 
                      : const Color(0xFFE2E8F0),
                ),
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.continueWithGoogle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes cuenta? ',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            InkWell(
              onTap: () {
                context.pop();
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  'Inicia sesión',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
