import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';

class StudentHeaderInfo extends StatelessWidget {
  final UserEntity? user;

  const StudentHeaderInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final currentUser = user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
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
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Nombre de Alumno',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'correo@institucional.edu',
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
