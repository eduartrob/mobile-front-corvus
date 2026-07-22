import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/profile/presentation/pages/edit_field_page.dart';
import 'package:mobile/features/profile/presentation/pages/edit_skills_page.dart';
import 'package:mobile/features/profile/presentation/pages/edit_email_page.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/pro_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressQuality: 70,
          maxWidth: 800,
          maxHeight: 800,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar foto',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              backgroundColor: Colors.black,
              dimmedLayerColor: Colors.black87,
              cropFrameColor: Colors.transparent,
              cropGridColor: Colors.transparent,
              hideBottomControls: false,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: 'Recortar foto',
              aspectRatioLockEnabled: true,
              resetButtonHidden: true,
              cropStyle: CropStyle.circle,
            ),
          ],
        );

        if (croppedFile != null) {
          final authProvider = context.read<AuthProvider>();
          final bytes = await croppedFile.readAsBytes();
          
          // Determinar el MIME type básico
          String mimeType = 'image/jpeg';
          if (croppedFile.path.toLowerCase().endsWith('.png')) mimeType = 'image/png';
          if (croppedFile.path.toLowerCase().endsWith('.webp')) mimeType = 'image/webp';
          
          final base64Image = 'data:$mimeType;base64,${base64Encode(bytes)}';
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subiendo foto...')),
          );
          
          final success = await authProvider.updateProfilePicture(base64Image);
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto actualizada correctamente')),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al actualizar la foto')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateField(String field, String value) async {
    final provider = context.read<ProfileProvider>();
    final currentProfile = provider.profile;
    
    await provider.updateProfile(
      fullName: field == 'name' ? value : (currentProfile?.alumno ?? ''),
      enrollmentId: field == 'matricula' ? value : (currentProfile?.matricula ?? ''),
      semester: field == 'cuatrimestre' ? value : (currentProfile?.cuatrimestre ?? ''),
      skills: currentProfile?.habilidades.map((e) => e.habilidad).toList() ?? [],
    );
  }

  void _showPhotoMenu(BuildContext context, AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Subir foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar foto'),
                        content: const Text('¿Estás seguro de que deseas eliminar tu foto de perfil?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eliminando foto...')),
                      );
                      final success = await authProvider.deleteProfilePicture();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Foto eliminada correctamente')),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al eliminar la foto')),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;
    
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  ProAvatar(
                    photoUrl: currentUser?.photoUrl,
                    radius: 80,
                    isPro: authProvider.isProActive,
                    fallbackInitial: currentUser?.name ?? 'U',
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () => _showPhotoMenu(context, authProvider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Nombre
            ListTile(
              leading: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
              title: Text('Nombre', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.alumno ?? 'No especificado',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFieldPage(
                      title: 'Nombre',
                      label: 'Tu nombre completo',
                      initialValue: profile?.alumno ?? '',
                      description: 'Este es el nombre que verán los demás usuarios de Corvus en tu perfil y al buscarte.',
                      keyboardType: TextInputType.name,
                      onSave: (val) => _updateField('name', val),
                    ),
                  ),
                );
              },
            ),
            const Divider(indent: 72, endIndent: 16),
            
            // Matrícula
            ListTile(
              leading: Icon(Icons.badge_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('Matrícula', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.matricula ?? 'No especificada',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFieldPage(
                      title: 'Matrícula',
                      label: 'Tu matrícula universitaria',
                      initialValue: profile?.matricula ?? '',
                      keyboardType: TextInputType.number,
                      onSave: (val) => _updateField('matricula', val),
                    ),
                  ),
                );
              },
            ),
            const Divider(indent: 72, endIndent: 16),
            
            // Cuatrimestre
            ListTile(
              leading: Icon(Icons.school_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('Cuatrimestre', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.cuatrimestre ?? 'No especificado',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFieldPage(
                      title: 'Cuatrimestre',
                      label: 'Cuatrimestre actual',
                      initialValue: profile?.cuatrimestre ?? '',
                      keyboardType: TextInputType.number,
                      onSave: (val) => _updateField('cuatrimestre', val),
                    ),
                  ),
                );
              },
            ),
            const Divider(indent: 72, endIndent: 16),
            
            // Carrera (Not editable)
            ListTile(
              leading: Icon(Icons.book_outlined, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              title: Text('Carrera', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.carrera ?? 'No especificada',
                style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
              ),
            ),
            const Divider(indent: 72, endIndent: 16),
            
            // Correo electrónico
            ListTile(
              leading: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('Correo electrónico', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.correo ?? 'No especificado',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (context) {
                      final bool isLinked = profile?.isGoogleLinked == true || 
                          (profile?.googleEmail != null && profile!.googleEmail!.isNotEmpty);
                      final bool isVerified = (profile?.isVerified == true) || isLinked;
                      
                      if (isVerified) {
                        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
                      } else {
                        return const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditEmailPage()),
                );
              },
            ),
            const Divider(indent: 72, endIndent: 16),
            
            // Habilidades
            ListTile(
              leading: Icon(Icons.psychology_outlined, color: colorScheme.onSurfaceVariant),
              title: Text('Habilidades', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w400)),
              subtitle: Text(
                profile?.habilidades != null && profile!.habilidades.isNotEmpty
                    ? profile.habilidades.map((e) => e.habilidad).join(', ')
                    : 'Agrega tus habilidades',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSkillsPage(
                      initialSkills: profile?.habilidades.map((e) => e.habilidad).toList() ?? [],
                    ),
                  ),
                );
              },
            ),
            const Divider(indent: 72, endIndent: 16),
            
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
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
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
