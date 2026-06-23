import 'package:flutter/material.dart';
import 'package:mobile/shared/components/Input.dart';
import 'package:mobile/shared/components/label.dart';

class InputCompleted extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;

  const InputCompleted({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(text: label),
        const SizedBox(height: 8),
        Input(
          hint: hint,
          icon: icon,
          obscure: obscure,
        ),
      ],
    );
  }
}
