import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/profile/presentation/pages/edit_field_page.dart';
import 'package:mobile/features/profile/presentation/pages/edit_skills_page.dart';
import 'package:mobile/features/profile/presentation/pages/edit_email_page.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
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
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                        ? NetworkImage(currentUser.photoUrl!)
                        : null,
                    child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
                        ? Icon(Icons.person, size: 70, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: colorScheme.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _pickImage,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 24),
                        ),
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
                  if (profile?.isVerified == true)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  else
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
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
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
