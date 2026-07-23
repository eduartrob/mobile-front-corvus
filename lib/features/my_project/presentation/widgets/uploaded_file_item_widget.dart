import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/my_project/presentation/widgets/document_preview_banner_widget.dart';

class UploadedFileItemWidget extends StatelessWidget {
  final MyProjectProvider provider;

  const UploadedFileItemWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final auth = context.read<AuthProvider>();
    final teamsProvider = context.read<TeamsProvider>();
    final userId = auth.currentUser?.id ?? '';
    final myTeam = teamsProvider.myTeam;
    final isLeader = myTeam != null && myTeam.members.isNotEmpty && (myTeam.members[0].id == userId || myTeam.members[0].email == auth.currentUser?.email);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => openDocumentFile(context, provider),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.picture_as_pdf, color: colorScheme.error),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.fileName ?? 'documento.pdf',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.fileSize} • ${l10n.uploadedToday}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (provider.state == ProjectState.preValidated && isLeader)
            IconButton(
              onPressed: () {
                provider.cancelAnalysis(userId, myTeam.id);
              },
              icon: Icon(Icons.cancel, color: colorScheme.onSurfaceVariant),
              hoverColor: colorScheme.errorContainer,
            ),
        ],
      ),
    ),
  ),
),
    );
  }
}
