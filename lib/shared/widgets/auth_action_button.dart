import 'package:flutter/material.dart';

class AuthActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: onPressed == null || isLoading
          ? colors.primary.withValues(alpha: 0.6)
          : colors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        splashColor: colors.onPrimary.withValues(alpha: 0.2),
        highlightColor: colors.shadow.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onPrimary,
                  ),
                )
              else ...[
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: colors.onPrimary, size: 20),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
