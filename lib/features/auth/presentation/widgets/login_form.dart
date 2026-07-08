import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_input_completed.dart';
import 'package:mobile/shared/widgets/corvus_button.dart';
import 'package:mobile/shared/widgets/auth_layout.dart';

class LoginForm extends StatefulWidget {
  final String role;
  const LoginForm({super.key, this.role = 'ALUMNO'});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo y contraseña')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El formato del correo es inválido')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    if (widget.role == 'DOCENTE' || widget.role == 'PROFESOR') {
      context.pushReplacement('/prof-dash');
    } else {
      context.pushReplacement('/inspiration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AuthLayout(
      appTitle: l10n.appTitle,
      cardTitle: l10n.welcomeBack,
      cardSubtitle: 'Ingresa como ${widget.role}',
      children: [
        InputCompleted(
          label: 'Correo electrónico',
          hint: 'ejemplo@correo.com',
          icon: Icons.email,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          iconColor: Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        InputCompleted(
          label: 'Contraseña',
          hint: '••••••••',
          icon: Icons.lock,
          obscure: true,
          controller: _passwordController,
          iconColor: Colors.redAccent,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Olvidé mi contraseña',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        CorvusButton(
          text: "Iniciar Sesión",
          onPressed: _validateAndSubmit,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'O continuar con',
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
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final isLoading = authProvider.status == AuthStatus.loading;
            
            return InkWell(
              onTap: isLoading 
                  ? null 
                  : () async {
                      await authProvider.signInWithGoogle();
                    },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceContainer : Colors.white,
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
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onSurface,
                        ),
                      )
                    else
                      SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 20,
                        height: 20,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      isLoading ? l10n.signingIn : l10n.continueWithGoogle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes una cuenta? ',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push('/register', extra: widget.role);
              },
              child: Text(
                'Regístrate',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
      bottomContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/terminos.html');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: Text(
              l10n.terms,
              style: TextStyle(
                fontSize: 12, 
                color: colors.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/privacidad.html');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: Text(
              l10n.privacy,
              style: TextStyle(
                fontSize: 12, 
                color: colors.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () async {
              final url = Uri.parse('https://eduartrob.github.io/CORVUS/pages/ayuda.html');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (_) {
                final mailUrl = Uri.parse('mailto:soporte@corvus.edu.mx');
                await launchUrl(mailUrl);
              }
            },
            child: Text(
              l10n.help,
              style: TextStyle(
                fontSize: 12, 
                color: colors.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
