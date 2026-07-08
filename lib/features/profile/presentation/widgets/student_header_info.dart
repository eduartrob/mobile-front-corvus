import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/profile/presentation/pages/edit_profile_page.dart' as mobile;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';

class StudentHeaderInfo extends StatefulWidget {
  final UserEntity? user;

  const StudentHeaderInfo({super.key, required this.user});

  @override
  State<StudentHeaderInfo> createState() => _StudentHeaderInfoState();
}

class _StudentHeaderInfoState extends State<StudentHeaderInfo> {
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Foto',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: CropStyle.circle,
            dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
          ),
          IOSUiSettings(
            title: 'Recortar Foto',
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _isUploading = true;
        });
        try {
          final bytes = await croppedFile.readAsBytes();
          
          // Validar tamaño <= 1 MB (1,048,576 bytes)
          if (bytes.length > 1048576) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La imagen es demasiado pesada. Máximo 1 MB.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final base64Image = base64Encode(bytes);
          final success = await context.read<AuthProvider>().updateProfilePicture(base64Image);
          
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto de perfil actualizada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al actualizar foto de perfil'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = widget.user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: InkWell(
              onTap: _isUploading ? null : _pickImage,
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                        ? NetworkImage(currentUser.photoUrl!)
                        : null,
                    child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  if (_isUploading)
                    const CircularProgressIndicator(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.profile;
              
              final nameToShow = (profile?.alumno != null && profile!.alumno.trim().isNotEmpty && profile.alumno != profile.correo) 
                  ? profile.alumno 
                  : ((currentUser?.name != null && currentUser!.name.trim().isNotEmpty) ? currentUser!.name : 'Nombre de Alumno');
                  
              final emailToShow = (profile?.correo != null && profile!.correo!.trim().isNotEmpty)
                  ? profile.correo!
                  : ((currentUser?.email != null && currentUser!.email.trim().isNotEmpty) ? currentUser!.email : 'correo@institucional.edu');

              return Column(
                children: [
                  Text(
                    nameToShow,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emailToShow,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (profile != null && profile.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ] else if (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Verificar Correo',
                            position: PopupMenuPosition.under,
                            elevation: 3,
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(
                                  'Tu correo no está verificado.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'go_edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 12),
                                    Text('Ir a Editar Perfil para verificar'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'go_edit') {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const mobile.EditProfilePage()),
                                );
                                if (context.mounted) {
                                  context.read<ProfileProvider>().fetchProfile(forceRefresh: true);
                                  context.read<AuthProvider>().checkAuthStatus();
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  if (profile != null) ...[
                    const SizedBox(height: 12),
                    if (profile.universidad != null && profile.universidad!.isNotEmpty)
                      Text(
                        profile.universidad!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (profile.carrera != null && profile.carrera!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          profile.carrera!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    if (profile.cuatrimestre != null && profile.cuatrimestre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Cuatrimestre: ${profile.cuatrimestre}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
