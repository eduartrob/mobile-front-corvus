import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/shared/widgets/pro_avatar.dart';
import 'package:mobile/features/teams/presentation/widgets/user_profile_modal.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/teams/presentation/widgets/team_member_card.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';

class TeamMembersList extends StatelessWidget {
  final List<TeamMemberModel> members;
  final String currentUserId;

  const TeamMembersList({
    super.key,
    required this.members,
    required this.currentUserId,
  });

  void _showRemoveConfirmationDialog(BuildContext context, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
            'Se le notificará a ${member.name} que ha sido removido del equipo. Esta acción no se puede deshacer.',
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
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TeamsProvider>().removeMember(member.id).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.name} ha sido removido del equipo'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al remover integrante: $error'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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

    final isAdmin = members.isNotEmpty && members[0].id == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Integrantes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...members.map((member) {
          final isMe = member.id == currentUserId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TeamMemberCard(
              avatarUrl: member.avatarUrl,
              name: member.name,
              email: member.email,
              isMe: isMe,
              isLeader: member.role == 'LEADER' || member.role == 'LÍDER' || member.role == 'LIDER',
              onRemove: (!isAdmin || isMe) ? null : () => _showRemoveConfirmationDialog(context, member),
            ),
          );
        }),
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
  final bool isVerified;
  final VoidCallback? onSendRequest;
  final bool targetHasTeam;
  final bool iHaveTeam;

  const InvitationCard({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.tags,
    required this.avatarUrl,
    this.isVerified = true,
    this.onSendRequest,
    this.targetHasTeam = false,
    this.iHaveTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Widget actionBtn = const SizedBox.shrink();
    if (!(targetHasTeam && iHaveTeam)) {
      actionBtn = SizedBox(
        width: double.infinity,
        child: FilledButton(
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
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            targetHasTeam ? 'Solicitar unirse' : 'Invitar',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    String displayBio = bio;
    if (displayBio.length > 25) {
      displayBio = '${displayBio.substring(0, 25)}...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showUserProfileModal(
            context: context,
            name: name,
            avatarUrl: avatarUrl,
            bio: bio, // full bio for the modal
            tags: tags,
            actionButton: actionBtn,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  final isMeMember = avatarUrl == auth.currentUser?.photoUrl || name == auth.currentUser?.name;
                  final isUserPro = (isMeMember && auth.isProActive);
                  return ProAvatar(
                    photoUrl: avatarUrl,
                    radius: 40,
                    isPro: isUserPro,
                    fallbackInitial: name,
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue.shade700,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alumno',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!(targetHasTeam && iHaveTeam)) ...[
                      const SizedBox(height: 12),
                      actionBtn,
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
