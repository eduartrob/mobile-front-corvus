import 'package:flutter/material.dart';

class Title extends StatelessWidget {
  final String text;

  const Title({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
