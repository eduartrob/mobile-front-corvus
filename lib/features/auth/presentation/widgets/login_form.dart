import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/core/theme/app_dimens.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin, vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                  ? colors.surfaceContainerHighest.withOpacity(0.5) 
                  : colors.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            l10n.appTitle,
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
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? colors.surface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark 
                    ? colors.outlineVariant.withOpacity(0.2) 
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.22),
                        blurRadius: 50,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 25,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.18),
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFF1E40AF).withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
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
                const SizedBox(height: 12),
                Text(
                  l10n.loginSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final isLoading = authProvider.status == AuthStatus.loading;
                    
                    String getLocalizedError() {
                      if (authProvider.errorMessage == 'AUTH_NOT_ALLOWED') {
                        return l10n.loginErrorNotAllowedEmail;
                      } else if (authProvider.errorMessage == 'AUTH_CANCELED') {
                        return 'Canceled';
                      }
                      return authProvider.errorMessage ?? l10n.serverErrorContactSupport;
                    }

                    return Column(
                      children: [
                        if (authProvider.errorMessage != null && authProvider.errorMessage != 'AUTH_CANCELED') ...[
                          Text(
                            getLocalizedError(),
                            style: TextStyle(color: colors.error, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        InkWell(
                          onTap: isLoading 
                              ? null 
                              : () async {
                                  await authProvider.signInWithGoogle();
                                  
                                  if (authProvider.status == AuthStatus.error && context.mounted && authProvider.errorMessage != 'AUTH_CANCELED') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error_outline, color: colors.onError),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                getLocalizedError(),
                                                style: TextStyle(color: colors.onError),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: colors.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(20),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
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
                                    ? colors.outlineVariant.withOpacity(0.3) 
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
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                Divider(color: colors.outlineVariant.withOpacity(0.2)),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.exclusiveAccessInfo,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Row(
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
          const SizedBox(height: 16),
          Text(
            '© 2026 Corvus',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
