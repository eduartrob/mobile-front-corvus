import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/get_drive_folders_usecase.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/sync_drive_folder_usecase.dart';
import 'package:mobile/core/services/notification_service.dart';

class DriveSyncModal {
  static void show(BuildContext context) {
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFolderItem(BuildContext context, String folderName, {String folderId = 'MOCK_FOLDER_ID'}) {
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
        final authProvider = context.read<AuthProvider>();
        final linkedFolders = context.read<LinkedFoldersProvider>();
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        Navigator.pop(context);

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
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text('¡Carpeta vinculada! El procesamiento ha comenzado en segundo plano.'),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              await NotificationService().showProgressNotification(
                progress: 0,
                maxProgress: 100,
                title: 'Sincronización de Archivos',
                message: 'Preparando vectorización de $folderName...',
              );
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
}
