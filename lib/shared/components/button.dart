import 'package:flutter/material.dart';
import 'package:mobile/core/theme/util.dart';
import 'package:mobile/core/theme/theme.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: MaterialTheme.purpleGradient,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
