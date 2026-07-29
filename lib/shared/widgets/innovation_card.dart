import 'package:flutter/material.dart';

class InnovationCard extends StatelessWidget {
  final int innovationIndex;

  const InnovationCard({
    super.key,
    required this.innovationIndex,
  });

  Color _getScoreColor(int score, ColorScheme colorScheme) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.orange.shade600;
    return colorScheme.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Alto Potencial';
    if (score >= 60) return 'Mejorable';
    return 'Baja Diferenciación';
  }

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Índice de Innovación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, size: 18, color: colorScheme.secondary.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: innovationIndex / 100.0,
                  strokeWidth: 12,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: _getScoreColor(innovationIndex, colorScheme),
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$innovationIndex',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorScheme.onSurface, height: 1),
                      ),
                      Text(
                        '%',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreLabel(innovationIndex),
                    style: TextStyle(
                      fontSize: 12, 
                      color: _getScoreColor(innovationIndex, colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
