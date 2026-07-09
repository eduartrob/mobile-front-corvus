import re

with open("lib/features/profile/presentation/widgets/student_header_info.dart", "r") as f:
    content = f.read()

replacement = """
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        await context.read<AuthProvider>().updateProfilePicture(base64Image);
      } finally {
        setState(() {
          _isUploading = false;
        });
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
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
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
          const SizedBox(height: 16),
          Text(
            currentUser?.name ?? 'Nombre de Alumno',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            currentUser?.email ?? 'correo@institucional.edu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
"""

with open("lib/features/profile/presentation/widgets/student_header_info.dart", "w") as f:
    f.write(replacement.strip() + "\n")
