import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const MetricsCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.bar_chart, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text('Métricas de Calidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 24),
          _buildMetricBar('Rigor Académico', (metrics['academic_rigor'] ?? metrics['academic_rigor_score'] ?? 0) as int, colorScheme.primary, colorScheme),
          const SizedBox(height: 24),
          _buildMetricBar('Relevancia Técnica', (metrics['technical_relevance'] ?? metrics['technical_relevance_score'] ?? 0) as int, colorScheme.secondary, colorScheme),
          const SizedBox(height: 24),
          _buildMetricBar('Claridad Estructural', (metrics['structural_clarity'] ?? metrics['structural_clarity_score'] ?? 0) as int, colorScheme.tertiary, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value, Color color, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
            Text('$value/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
