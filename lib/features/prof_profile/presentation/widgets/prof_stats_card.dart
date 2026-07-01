import 'package:flutter/material.dart';

class ProfStatsCard extends StatelessWidget {
  const ProfStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
