import 'package:flutter/material.dart';

class RiskCard extends StatelessWidget {
  final String collisionRisk;
  final String collisionExplanation;

  const RiskCard({
    super.key,
    required this.collisionRisk,
    required this.collisionExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color riskColor = colorScheme.error;
    Color riskBgColor = colorScheme.errorContainer.withValues(alpha: 0.5);
    IconData riskIcon = Icons.warning;

    final riskLower = collisionRisk.toLowerCase();
    if (riskLower.contains('falsa alarma') || riskLower.contains('bajo')) {
      riskColor = Colors.green.shade700;
      riskBgColor = Colors.green.shade100;
      riskIcon = Icons.verified_user_outlined;
    } else if (riskLower.contains('medio')) {
      riskColor = Colors.orange.shade800;
      riskBgColor = Colors.orange.shade100;
      riskIcon = Icons.info_outline;
    } else if (riskLower.contains('no detectado')) {
      riskColor = colorScheme.primary;
      riskBgColor = colorScheme.primaryContainer.withValues(alpha: 0.3);
      riskIcon = Icons.shield_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: riskBgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: riskBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(riskIcon, size: 20, color: riskColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Riesgo: $collisionRisk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: riskColor),
                ),
              ),
            ],
          ),
          if (collisionExplanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              collisionExplanation,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ]
        ],
      ),
    );
  }
}
