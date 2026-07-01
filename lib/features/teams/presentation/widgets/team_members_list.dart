import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/teams/presentation/widgets/team_member_card.dart';

class TeamMembersList extends StatelessWidget {
  final String myAvatarUrl;
  final String? userName;
  final String? userEmail;

  const TeamMembersList({
    super.key,
    required this.myAvatarUrl,
    this.userName,
    this.userEmail,
  });

  void _showUpcomingFeature(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.featureUpcoming),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.members,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showUpcomingFeature(context, l10n),
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: Text(l10n.manage),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        TeamMemberCard(
          avatarUrl: myAvatarUrl,
          name: userName ?? 'Alex Rivera',
          email: userEmail ?? 'arivera@university.edu',
          isLeader: true,
          isMe: true,
        ),
        const SizedBox(height: 12),
        TeamMemberCard(
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXgTC4DnAYNbbZqJiR2_eXQVjVBBU9UAfGrdGXOt0kuaQU0pB6NC2VA430rwd4RXjZ_hC5Hfq92mwXe2lxvfwHF5PEWKa6lPQkYXOsjQVHelRTzu19Dvk4rGSpIO4madR4j--BNrWFv3pXGHVjKPbA1Gwxzy-16impgeDJrVMZ3ur9i2TBCFnRgU_T3BSzAWjaze7feR8wzo2PmgLdiKJ29z5fHVKDnAVOwtf1F07fAyiIjCOTBsgAtrbB2A7g3j41-3bOoHBHjQM',
          name: 'Elena Morales',
          email: 'emorales@university.edu',
        ),
        const SizedBox(height: 12),
        TeamMemberCard(
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrL7ehJPOSPFx9kjB2ZvERwzM3OMH8QIwIepB1EPeDn4nneI-XG4DzjJS4U4PbpYTnR-4eZt0JNAZodSqDIh8ddQ5DaGmmlhQ0oR-bgeevIdAUyjzJPhUB5ensFdryjBeIM5P_3kvP1jO2wq1hVCHPr6ZEuQzqa2_Vs_MnF2jOpDPQtSSBSbCbNl7YS_wCAsLGUTPVjepr0lY4VoAGE3GAa5EdTE-XhuxekDzHw7L5qtKjFrupUbS_x0d3pjJUISMHWC_oG_ayC_8',
          name: 'David Chen',
          email: 'dchen@university.edu',
        ),
        
        const SizedBox(height: 32),
        
        Row(
          children: [
            Icon(Icons.mail_outline, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              l10n.pendingInvitations,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'sgarcia@university.edu',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.twoDaysAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showUpcomingFeature(context, l10n),
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.teamFullInviteNotice,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
