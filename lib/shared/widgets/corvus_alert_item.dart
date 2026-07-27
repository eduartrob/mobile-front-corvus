import 'package:flutter/material.dart';

class CorvusAlertItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const CorvusAlertItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  fontSize: 14,
                ),
          ),
        ),
      ],
    );
  }
}
