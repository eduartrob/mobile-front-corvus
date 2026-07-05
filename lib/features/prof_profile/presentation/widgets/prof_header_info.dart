import 'package:flutter/material.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';

class ProfHeaderInfo extends StatelessWidget {
  final UserEntity? user;

  const ProfHeaderInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final currentUser = user;

    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                ? NetworkImage(currentUser.photoUrl!)
                : null,
            child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
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
            color: colorScheme.primary.withValues(alpha: 0.15),
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
      ],
    );
  }
}
