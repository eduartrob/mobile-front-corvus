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
import 'package:mobile/features/profile/presentation/pages/skills_section_page.dart' as mobile;
import 'package:mobile/features/profile/presentation/pages/recent_activity_section_page.dart' as mobile;
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
                    MaterialPageRoute(builder: (context) => const mobile.RecentActivitySectionPage()),
                  );
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
                    
                    await context.read<AuthProvider>().logout();
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text('Cerrar sesión', style: TextStyle(color: colorScheme.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.red.withValues(alpha: 0.5))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Peligro', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.red.withValues(alpha: 0.5))),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Borrar cuenta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Dismiss',
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return Center(
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Eliminar Cuenta',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '¿Estás seguro de que deseas eliminar tu cuenta permanentemente? \n\n'
                                    'Toda tu información personal, habilidades, materias y configuraciones serán eliminadas. '
                                    'Solo tu historial de actividades quedará registrado de forma anónima.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop(); // Close dialog
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                            
                                            final success = await context.read<AuthProvider>().deleteAccount();
                                            
                                            if (context.mounted) {
                                              Navigator.of(context).pop(); // Close loading
                                              if (success) {
                                                context.go('/');
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Error al borrar la cuenta. Intenta de nuevo.')),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder: (context, animation, secondaryAnimation, child) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Eliminar cuenta', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
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
