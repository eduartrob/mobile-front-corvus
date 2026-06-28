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

class ProfProfilePage extends StatefulWidget {
  const ProfProfilePage({super.key});

  @override
  State<ProfProfilePage> createState() => _ProfProfilePageState();
}

class _ProfProfilePageState extends State<ProfProfilePage> {
  // Estados para los switches de cursos
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

  void _showDriveSyncModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final futureFolders = () async {
      final authProvider = context.read<AuthProvider>();
      final token = await authProvider.getDriveAccessToken();
      if (token == null) return <Map<String, dynamic>>[];
      return await sl<GetDriveFoldersUseCase>().call(token);
    }();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return DefaultTabController(
              length: 2,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: colorScheme.primary.withOpacity(0.3))),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(Icons.add_to_drive, color: colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Google Drive',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Busca y selecciona la carpeta raíz de tus proyectos históricos.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar carpeta...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Mi unidad'),
                        Tab(text: 'Compartidos'),
                      ],
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: futureFolders,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          final allFolders = snapshot.data ?? [];
                          
                          // Filtrado local
                          final filteredFolders = allFolders.where((f) {
                            final name = (f['name'] ?? '').toLowerCase();
                            return name.contains(searchQuery);
                          }).toList();
                          
                          final myDrive = filteredFolders.where((f) => f['sharedWithMe'] != true).toList();
                          final sharedWithMe = filteredFolders.where((f) => f['sharedWithMe'] == true).toList();
                          
                          Widget buildList(List<Map<String, dynamic>> list) {
                            if (list.isEmpty) {
                              return Center(
                                child: Text(
                                  searchQuery.isEmpty 
                                    ? 'No hay carpetas aquí.' 
                                    : 'No se encontraron resultados.',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final folder = list[index];
                                return _buildFolderItem(context, folder['name'] ?? 'Sin nombre', folderId: folder['id'] ?? '');
                              },
                            );
                          }

                          return TabBarView(
                            children: [
                              buildList(myDrive),
                              buildList(sharedWithMe),
                            ],
                          );
                        }, // Closes builder
                      ), // Closes FutureBuilder
                    ), // Closes Expanded
                  ], // Closes Column children
                ), // Closes Column
              ), // Closes Material
              ), // Closes Container
            ); // Closes DefaultTabController
          },
        );
      },
    );
  }

  Widget _buildFolderItem(BuildContext context, String folderName, {String folderId = 'MOCK_FOLDER_ID'}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(Icons.folder, color: colorScheme.primary.withOpacity(0.8), size: 28),
      title: Text(
        folderName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Capturar referencias antes de cerrar el modal
        final authProvider = context.read<AuthProvider>();
        final linkedFolders = context.read<LinkedFoldersProvider>();
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        Navigator.pop(context); // Cierra el bottom sheet

        final accessToken = await authProvider.getDriveAccessToken();
        final jwtToken = authProvider.currentUser?.token;

        if (accessToken == null || jwtToken == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Error: No se pudo obtener las credenciales necesarias (Drive o Corvus).'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }

        // Feedback inmediato en la UI
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Conectando con Corvus para procesar "$folderName"...'),
            duration: const Duration(seconds: 2),
          ),
        );

        try {
          final userId = authProvider.currentUser?.id;
          if (userId == null) throw Exception('Usuario no autenticado (ID nulo)');

          final syncUseCase = sl<SyncDriveFolderUseCase>();
          final result = await syncUseCase(folderId, accessToken, jwtToken, userId);
          
          if (result['success'] == true) {
            final syncSkipped = result['sync_skipped'] == true;

            // Añadir al provider local y backend
            linkedFolders.addFolder(folderId, folderName, jwtToken, isSynced: syncSkipped);

            if (syncSkipped) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text('Carpeta vinculada (Ya estaba sincronizada previamente en Corvus).'),
                  backgroundColor: Colors.blue.shade700,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              // Feedback de éxito en la UI
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text('¡Carpeta vinculada! El procesamiento ha comenzado en segundo plano.'),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // Mostrar notificación persistente en 0%
              await NotificationService().showProgressNotification(
                progress: 0,
                maxProgress: 100,
                title: 'Sincronización de Archivos',
                message: 'Preparando vectorización de $folderName...',
              );

              // Nota: El polling de progreso (la actualización en segundo plano)
              // ahora es manejado automáticamente por LinkedFoldersProvider
              // de manera resiliente, incluso si el usuario navega a otra pantalla.
            }
          }
        } catch (e) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: const CorvusTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Cabecera Perfil
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Nombre de Profesor',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.email ?? 'correo@institucional.edu',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Department of Computer Science',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Senior Researcher in Applied Ethics & Data Systems. Managing lead for the Distributed Intelligence Lab.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tarjetas de Métricas (2x2 Grid)
            Row(
              children: [
                Expanded(child: _buildMetricCard(context, label: 'COURSES', value: '06')),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(context, label: 'STUDENTS', value: '242')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricCard(context, label: 'ARTICLES', value: '18')),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(context, label: 'RATING', value: '4.9')),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sección Course Access
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
            
            // Cursos Switches
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
            
            // Selector de Apariencia
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
            
            // Sección de Carpetas Vinculadas
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
            
            // Lista dinámica de carpetas
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
            
            // Drive Sync Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Solicitar permiso incremental
                  final granted = await context.read<AuthProvider>().requestDriveAccess();
                  if (context.mounted) {
                    if (granted) {
                      _showDriveSyncModal(context);
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
            
            // Privacy Notice
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
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Mostrar overlay oscuro de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Ejecutar logout que limpiará Google y storage
                  await context.read<AuthProvider>().logout();
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Cerrar overlay
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
            
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

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
