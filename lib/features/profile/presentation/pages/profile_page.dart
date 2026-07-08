import 'package:flutter/material.dart';
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
              
              const StudentStatsCard(),
              
              const SizedBox(height: 20),
              
              const TechnicalSkillsSection(),
              
              const SizedBox(height: 20),
              
              const RecentActivitySection(),
              
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.appearance,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: const Icon(Icons.settings),
                            label: Text(l10n.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.wb_sunny),
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.nightlight_round),
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        selected: {context.watch<ThemeProvider>().themeMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          context.read<ThemeProvider>().setThemeMode(newSelection.first);
                        },
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    await context.read<AuthProvider>().logout();
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Column(
                children: [
                  Text(
                    'Versión ${AppVersion.version}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Corvus. Todos los derechos reservados.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
