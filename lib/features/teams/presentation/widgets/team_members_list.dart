import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/teams/presentation/widgets/team_member_card.dart';
import 'package:go_router/go_router.dart';

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

  void _showRemoveConfirmationDialog(BuildContext context, String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 40,
          ),
          title: Text(
            '¿Eliminar de tu equipo?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Se le notificará amablemente a $memberName que ha sido removido del equipo. Esta acción no se puede deshacer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Sin funcionar (no-op)
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Acción no implementada temporalmente'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Integrantes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/manage-team'),
              icon: const Icon(Icons.manage_accounts_outlined, size: 18),
              label: const Text('Gestionar'),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TeamMemberCard(
          avatarUrl: myAvatarUrl,
          name: userName ?? 'Alex Rivera',
          email: userEmail ?? 'arivera@university.edu',
          isMe: true,
        ),
        const SizedBox(height: 12),
        TeamMemberCard(
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXgTC4DnAYNbbZqJiR2_eXQVjVBBU9UAfGrdGXOt0kuaQU0pB6NC2VA430rwd4RXjZ_hC5Hfq92mwXe2lxvfwHF5PEWKa6lPQkYXOsjQVHelRTzu19Dvk4rGSpIO4madR4j--BNrWFv3pXGHVjKPbA1Gwxzy-16impgeDJrVMZ3ur9i2TBCFnRgU_T3BSzAWjaze7feR8wzo2PmgLdiKJ29z5fHVKDnAVOwtf1F07fAyiIjCOTBsgAtrbB2A7g3j41-3bOoHBHjQM',
          name: 'Elena Morales',
          email: 'emorales@university.edu',
          onRemove: () => _showRemoveConfirmationDialog(context, 'Elena Morales'),
        ),
        const SizedBox(height: 12),
        TeamMemberCard(
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrL7ehJPOSPFx9kjB2ZvERwzM3OMH8QIwIepB1EPeDn4nneI-XG4DzjJS4U4PbpYTnR-4eZt0JNAZodSqDIh8ddQ5DaGmmlhQ0oR-bgeevIdAUyjzJPhUB5ensFdryjBeIM5P_3kvP1jO2wq1hVCHPr6ZEuQzqa2_Vs_MnF2jOpDPQtSSBSbCbNl7YS_wCAsLGUTPVjepr0lY4VoAGE3GAa5EdTE-XhuxekDzHw7L5qtKjFrupUbS_x0d3pjJUISMHWC_oG_ayC_8',
          name: 'David Chen',
          email: 'dchen@university.edu',
          onRemove: () => _showRemoveConfirmationDialog(context, 'David Chen'),
        ),
      ],
    );
  }
}

class InvitationCard extends StatelessWidget {
  final String name;
  final String username;
  final String bio;
  final List<String> tags;
  final String avatarUrl;
  final VoidCallback? onSendRequest;

  const InvitationCard({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.tags,
    required this.avatarUrl,
    this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bio,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isSpecial = tag == 'UI/UX';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSpecial 
                        ? const Color(0xFFE0E7FF) 
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSpecial 
                          ? const Color(0xFF4338CA) 
                          : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (onSendRequest != null) {
                    onSendRequest!();
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Solicitud enviada a $name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F82FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enviar solicitud',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
