import 'package:flutter/material.dart';
import 'package:mobile/features/profile/presentation/pages/edit_profile_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/settings_page.dart' as mobile;
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/core/constants/app_version.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import '../widgets/student_header_info.dart';
import 'package:mobile/features/profile/presentation/pages/skills_section_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/saved_projects_page.dart';
import 'package:mobile/features/profile/presentation/pages/activity_history_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/app_update_page.dart' as mobile;
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const mobile.EditProfilePage()),
              );
              if (mounted) {
                context.read<ProfileProvider>().fetchProfile(forceRefresh: true);
                context.read<AuthProvider>().checkAuthStatus();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileProvider>().fetchProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              // Habilidades
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.code, color: colorScheme.onSurfaceVariant, size: 28),
                title: const Text('Habilidades', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                subtitle: const Text('Administra tus habilidades técnicas y blandas'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const mobile.SkillsSectionPage()),
                  );
                },
              ),
              
              // Actividad Reciente
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.history, color: colorScheme.onSurfaceVariant, size: 28),
                title: const Text('Actividad reciente', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const mobile.ActivityHistoryPage()),
                  );
                },
              ),
              
              // Guardados
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.bookmark, color: colorScheme.onSurfaceVariant, size: 28),
                title: const Text('Guardados', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                subtitle: const Text('Tus propuestas de proyectos para después'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedProjectsPage()),
                  );
                },
              ),
              
              // Unirse a Proyecto
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.group_add, color: colorScheme.primary, size: 28),
                title: Text('Unirse a Proyecto', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: colorScheme.primary)),
                subtitle: const Text('Ingresa un código para unirte al proyecto de tu clase'),
                onTap: () {
                  context.push('/join-project');
                },
              ),
              
              // Apariencia
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.palette_outlined, color: colorScheme.onSurfaceVariant, size: 28),
                title: const Text('Apariencia', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                subtitle: const Text('Estilo de la aplicación, tema oscuro o claro'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const mobile.SettingsPage()),
                  );
                },
              ),
              
              // Actualización de la aplicación
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: Icon(Icons.system_update, color: colorScheme.onSurfaceVariant, size: 28),
                title: const Text('Actualización de la aplicación', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const mobile.AppUpdatePage()),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Cerrar sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    context.read<ProjectProvider>().clear();
                    await context.read<AuthProvider>().logout();
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    backgroundColor: Colors.red.withValues(alpha: 0.05),
                    overlayColor: Colors.red.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              

              
              const SizedBox(height: 48),
              
              Center(
                child: Text(
                  '© 2026 Corvus. Todos los derechos reservados.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

