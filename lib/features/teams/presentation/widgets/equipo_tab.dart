import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'team_members_list.dart';
import 'dashed_border_painter.dart';

class EquipoTab extends StatelessWidget {
  final String myAvatarUrl;
  final String? userName;
  final String? userEmail;
  final VoidCallback onLeaveTeam;

  const EquipoTab({
    super.key,
    required this.myAvatarUrl,
    this.userName,
    this.userEmail,
    required this.onLeaveTeam,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project detail box with dashed border
          CustomPaint(
            painter: DashedBorderPainter(
              color: colorScheme.primary.withValues(alpha: 0.6),
              borderRadius: 12.0,
              dashLength: 5.0,
              gap: 3.0,
              strokeWidth: 1.2,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proyecto Final: "${l10n.teamManagementTitle}". ${l10n.teamManagementDesc}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Equipo Completo',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '3/3',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          TeamMembersList(
            myAvatarUrl: myAvatarUrl,
            userName: userName,
            userEmail: userEmail,
          ),
          const SizedBox(height: 36),
          Center(
            child: SizedBox(
              width: 220,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onLeaveTeam,
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: const Text('Salir del equipo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
