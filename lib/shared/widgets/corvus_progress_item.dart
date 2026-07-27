import 'package:flutter/material.dart';

class CorvusProgressItem extends StatelessWidget {
  final String label;
  final int percentage;

  const CorvusProgressItem({
    super.key,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
          color: colorScheme.tertiary,
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }
}
