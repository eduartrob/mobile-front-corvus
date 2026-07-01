import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/sync_drive_folder_usecase.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/get_drive_folders_usecase.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/theme/theme_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/syncing_dots_text.dart';
import 'package:mobile/core/theme/app_dimens.dart';

import '../widgets/prof_header_info.dart';
import '../widgets/prof_stats_card.dart';
import '../widgets/drive_sync_modal.dart';

class ProfProfilePage extends StatefulWidget {
  const ProfProfilePage({super.key});

  @override
  State<ProfProfilePage> createState() => _ProfProfilePageState();
}

class _ProfProfilePageState extends State<ProfProfilePage> {
  bool course1Enabled = true;
  bool course2Enabled = true;
  bool course3Enabled = false;

  void _showUpcomingFeature(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final jwtToken = authProvider.currentUser?.token;
      if (jwtToken != null) {
        context.read<LinkedFoldersProvider>().loadFolders(jwtToken);
      }
    });
  }

  // Drive Sync Modal has been extracted to widgets/drive_sync_modal.dart


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.screenMargin),
        child: Column(
          children: [
            ProfHeaderInfo(user: user),
            const SizedBox(height: 32),
            const ProfStatsCard(),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Course\nAccess',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                InkWell(
                  onTap: () => _showUpcomingFeature(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Permissions\nManagement',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildCourseToggle(
                    context,
                    icon: Icons.code,
                    title: 'Software Engineering I',
                    subtitle: 'Undergraduate Core | 84 Students',
                    value: course1Enabled,
                    onChanged: (val) {
                      setState(() => course1Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
                  _buildCourseToggle(
                    context,
                    icon: Icons.storage,
                    title: 'Advanced Databases',
                    subtitle: 'Graduate Level | 42 Students',
                    value: course2Enabled,
                    iconColor: Colors.orange,
                    onChanged: (val) {
                      setState(() => course2Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
                  _buildCourseToggle(
                    context,
                    icon: Icons.psychology,
                    title: 'AI Ethics',
                    subtitle: 'Elective Seminar | 116 Students',
                    value: course3Enabled,
                    iconColor: Colors.lightBlue,
                    onChanged: (val) {
                      setState(() => course3Enabled = val);
                      _showUpcomingFeature(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Text(
              '* Toggling access immediately revokes student submission capabilities for the specific course.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
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
                        side: MaterialStateProperty.all(BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Icon(Icons.folder_shared, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Directorios Vinculados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Consumer<LinkedFoldersProvider>(
              builder: (context, linkedProvider, child) {
                if (linkedProvider.folders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        'No hay carpetas sincronizadas. Haz clic abajo para añadir tu primer repositorio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: linkedProvider.folders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final folder = linkedProvider.folders[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.05),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: folder['status'] == 'syncing'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                )
                              : Icon(Icons.check, color: Colors.green.shade700, size: 20),
                        ),
                        title: Text(
                          folder['name'] ?? 'Carpeta Desconocida',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: folder['status'] == 'syncing'
                            ? SyncingDotsText(
                                label: 'Sincronizando',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(
                                'Activa y Sincronizada',
                                style: TextStyle(fontSize: 12, color: Colors.green),
                              ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('¿Quitar acceso?'),
                                content: Text('¿Deseas dejar de visualizar "${folder['name']}" en Corvus? \n\n(Nota: Los vectores permanecerán en el motor de Corvus hasta que se implemente la eliminación completa en el servidor).'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<LinkedFoldersProvider>().removeFolder(folder['id']!);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Quitar', style: TextStyle(color: colorScheme.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final granted = await context.read<AuthProvider>().requestDriveAccess();
                  if (context.mounted) {
                    if (granted) {
                      DriveSyncModal.show(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Se requiere acceso a Drive para sincronizar.'),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_to_drive, size: 24),
                label: const Text(
                  'Sincronizar Repositorio de Proyectos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aviso de Privacidad y Uso Limitado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Corvus solicita acceso a Google Drive únicamente en modo lectura para extraer y vectorizar los documentos de tus repositorios históricos. La información procesada sirve exclusivamente para generar reportes analíticos de prevención de riesgo de colisión. NO se comparte con terceros ni se utiliza para publicidad, cumpliendo estrictamente con la Política de Uso Limitado (Google API Services User Data Policy).',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),            
            SizedBox(
              width: double.infinity,
              height: 55,
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
                icon: const Icon(Icons.logout, size: 24),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // _buildMetricCard extracted to ProfStatsCard

  Widget _buildCourseToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
