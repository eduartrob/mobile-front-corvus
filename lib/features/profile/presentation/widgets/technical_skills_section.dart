import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';

class TechnicalSkillsSection extends StatelessWidget {
  const TechnicalSkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final colorScheme = Theme.of(context).colorScheme;

    if (profileProvider.isLoading && profileProvider.profile == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final habilidades = profile?.habilidades ?? [];

    if (habilidades.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No se han detectado habilidades aún. Presiona Editar para agregar tus habilidades.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
<<<<<<< Updated upstream
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.technicalSkills,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.psychology),
                tooltip: 'Calcular Habilidades con IA',
                onPressed: () => _recalculateSkills(context, profileProvider),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...habilidades.take(displayCount).map((hab) => _buildChip(context, hab.habilidad)),
              if (totalCount > 6)
                _buildWhiteLinkCard(context, remainingCount, () => _showAllSkillsModal(context, habilidades)),
            ],
          ),
        ],
=======
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: habilidades.map((hab) => _buildChip(context, hab.habilidad)).toList(),
>>>>>>> Stashed changes
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
<<<<<<< Updated upstream

  Widget _buildWhiteLinkCard(BuildContext context, int count, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ver $count habilidades más',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black54),
          ],
        ),
      ),
    );
  }
=======
>>>>>>> Stashed changes
}
