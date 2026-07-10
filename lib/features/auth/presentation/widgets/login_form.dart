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
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';
import 'dart:math';

class LoginForm extends StatefulWidget {
  final String role;
  final Function(String)? onRoleChanged;

  const LoginForm({
    super.key,
    required this.role,
    this.onRoleChanged,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
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

    try {
      await context.read<AuthProvider>().loginWithEmail(email, password);
      
      final authProvider = context.read<AuthProvider>();
      if (authProvider.status == AuthStatus.authenticated) {
        final actualRole = authProvider.currentUser?.role?.toUpperCase() ?? widget.role.toUpperCase();
        final uiRole = widget.role.toUpperCase() == 'PROFESOR' ? 'DOCENTE' : widget.role.toUpperCase();
        final backendRole = actualRole == 'PROFESOR' ? 'DOCENTE' : actualRole;

        if (uiRole != backendRole) {
          await authProvider.logout();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Esta cuenta pertenece a un $actualRole. Por favor ingresa desde la sección correcta.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (backendRole == 'DOCENTE') {
          context.pushReplacement('/prof-dash');
        } else {
          context.pushReplacement('/inspiration');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString().replaceAll('Exception: ', '')}')),
      );
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
      customSubtitle: Column(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                final newRole = widget.role == 'ALUMNO' ? 'DOCENTE' : 'ALUMNO';
                _emailController.clear();
                _passwordController.clear();
                widget.onRoleChanged?.call(newRole);
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInBack,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.8, 0.0), 
                    end: Offset.zero
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                key: ValueKey<String>(widget.role),
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.role == 'ALUMNO' ? Icons.school : Icons.co_present,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ingresa como ${widget.role}',
                      style: TextStyle(
                        fontSize: 18,
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, size: 14, color: colors.outline),
              const SizedBox(width: 4),
              Text(
                'Desliza el texto para cambiar',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Te recomendamos registrarte con tu correo institucional de la universidad.',
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
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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
            
            return Material(
              color: isDark ? colors.surfaceContainer : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: isLoading 
                    ? null 
                    : () async {
                        await authProvider.signInWithGoogle();
                        
                        if (authProvider.status == AuthStatus.authenticated) {
                          final actualRole = authProvider.currentUser?.role?.toUpperCase() ?? widget.role.toUpperCase();
                          final uiRole = widget.role.toUpperCase() == 'PROFESOR' ? 'DOCENTE' : widget.role.toUpperCase();
                          final backendRole = actualRole == 'PROFESOR' ? 'DOCENTE' : actualRole;

                          if (uiRole != backendRole) {
                            await authProvider.logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Esta cuenta pertenece a un $actualRole. Por favor ingresa desde la sección correcta.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          if (backendRole == 'DOCENTE') {
                            context.pushReplacement('/prof-dash');
                          } else {
                            context.pushReplacement('/inspiration');
                          }
                        } else if (authProvider.errorMessage != null && authProvider.errorMessage!.startsWith('USER_NOT_REGISTERED|')) {
                          final parts = authProvider.errorMessage!.split('|');
                          final email = parts[1];
                          final authCode = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;

                          final provider = Provider.of<RegistrationProvider>(context, listen: false);
                          
                          const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                          final rnd = Random();
                          final randomPassword = String.fromCharCodes(Iterable.generate(
                            12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

                          provider.setRegisterData(
                            email: email,
                            password: randomPassword,
                            role: widget.role,
                            googleAuthCode: authCode,
                          );

                          if (widget.role == 'DOCENTE' || widget.role == 'PROFESOR') {
                            context.push('/register-teacher-verification');
                          } else {
                            context.push('/register-student-university');
                          }
                        } else {
                          String msg = authProvider.errorMessage ?? 'Error al iniciar sesión';
                          if (msg == 'AUTH_NOT_ALLOWED') {
                            msg = 'Dominio de correo no permitido.';
                          } else if (msg == 'AUTH_CANCELED') {
                            msg = 'Inicio de sesión cancelado.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
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
            InkWell(
              onTap: () {
                context.push('/register', extra: widget.role);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  'Regístrate',
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
