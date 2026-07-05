import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/solicitudes_provider.dart';
import '../provider/mock_solicitudes.dart';

class SolicitudesTab extends StatelessWidget {
  const SolicitudesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SolicitudesProvider>(
      builder: (context, provider, child) {
        final filteredList = provider.filteredSolicitudes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Aceptadas',
                    filter: SolicitudFilter.aceptadas,
                    currentFilter: provider.selectedFilter,
                    onTap: (filter) => provider.selectFilter(filter),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    context,
                    label: 'Enviadas',
                    filter: SolicitudFilter.enviadas,
                    currentFilter: provider.selectedFilter,
                    onTap: (filter) => provider.selectFilter(filter),
                  ),
                ],
              ),
            ),
            // List of Request Cards
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 64,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay solicitudes en esta sección',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final solicitud = filteredList[index];
                        return _SolicitudCard(
                          solicitud: solicitud,
                          onInvite: () => provider.inviteStudent(solicitud.id),
                          onReject: () => provider.rejectStudent(solicitud.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required SolicitudFilter filter,
    required SolicitudFilter currentFilter,
    required ValueChanged<SolicitudFilter> onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentFilter == filter;

    return GestureDetector(
      onTap: () => onTap(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onInvite;
  final VoidCallback onReject;

  const _SolicitudCard({
    required this.solicitud,
    required this.onInvite,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final student = solicitud.student;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(student.avatarUrl),
                  radius: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.username,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (student.isVerified)
                  Icon(
                    Icons.verified,
                    color: colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              student.bio,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: student.tags.map((tag) {
                final isSpecial = tag == 'UI/UX';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSpecial
                        ? const Color(0xFFE0E7FF)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSpecial
                          ? const Color(0xFF4338CA)
                          : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (solicitud.state == SolicitudState.enviada) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar solicitud',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
