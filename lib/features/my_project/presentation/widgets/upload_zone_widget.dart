import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';

class UploadZoneWidget extends StatelessWidget {
  final MyProjectProvider provider;

  const UploadZoneWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final exts = provider.allowedExtensionsString;
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        color: colorScheme.outlineVariant,
        strokeWidth: 2,
        dashPattern: const [6, 4],
        radius: const Radius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Agrega tu propuesta aquí',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tamaño máximo: 10 MB. Formatos: $exts',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => provider.pickFile(context.read<AuthProvider>().currentUser?.id ?? '', l10n),
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.browseFiles),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              foregroundColor: colorScheme.onSurface,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
