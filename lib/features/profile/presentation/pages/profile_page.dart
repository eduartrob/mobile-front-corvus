import 'package:flutter/material.dart';
import 'package:mobile/features/profile/presentation/pages/edit_profile_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/settings_page.dart' as mobile;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/core/constants/app_version.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import '../widgets/student_header_info.dart';
import '../widgets/student_stats_card.dart';
import '../widgets/technical_skills_section.dart';
import '../widgets/recent_activity_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileProvider>().fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final profileProvider = context.watch<ProfileProvider>();
    final isProcessing = profileProvider.profile?.isProcessing == true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileProvider>().fetchProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.screenMargin),
          child: Column(
            children: [
              StudentHeaderInfo(user: user),
              
              if (isProcessing) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "La IA de Corvus está analizando tus tareas y perfil en segundo plano. Esto tomará unos segundos...",
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              const SizedBox(height: 20),
              
              const TechnicalSkillsSection(),
              
              const SizedBox(height: 20),
              
              const RecentActivitySection(),
              
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
              
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit, color: colorScheme.primary),
                      title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const mobile.EditProfilePage()),
                        );
                        if (context.mounted) {
                          context.read<ProfileProvider>().getPerfilCompleto();
                          context.read<AuthProvider>().checkAuthStatus();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.settings, color: colorScheme.primary),
                      title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const mobile.SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

