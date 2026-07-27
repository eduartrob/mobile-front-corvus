import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;

  const Label({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
