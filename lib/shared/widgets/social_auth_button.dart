import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/l10n/app_localizations.dart';

class SocialAuthButton extends StatelessWidget {
  final bool isLoading;
  final bool isGoogle;
  final VoidCallback? onTap;
  final String? label;

  const SocialAuthButton({
    super.key,
    this.isLoading = false,
    this.isGoogle = true,
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceContainer : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onSurface,
                  ),
                )
              else if (isGoogle)
                SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 20,
                  height: 20,
                )
              else
                Icon(Icons.apple, color: colors.onSurface, size: 20),
              const SizedBox(width: 12),
              Text(
                label ?? (isLoading ? l10n.signingIn : l10n.continueWithGoogle),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
