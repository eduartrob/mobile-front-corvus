import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/shared/widgets/corvus_input.dart';
import 'package:mobile/shared/widgets/corvus_label.dart';

class InputCompleted extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? iconColor;

  const InputCompleted({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.iconColor,
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
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          iconColor: iconColor,
        ),
      ],
    );
  }
}
