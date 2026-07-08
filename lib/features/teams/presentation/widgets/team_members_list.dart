import 'package:flutter/material.dart';
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
                  borderRadius: BorderRadius.circular(10),
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
        ...members.map((member) {
          final isMe = member.id == currentUserId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TeamMemberCard(
              avatarUrl: member.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
              name: member.name,
              email: member.email,
              isMe: isMe,
              onRemove: isMe ? null : () => _showRemoveConfirmationDialog(context, member),
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

  const InvitationCard({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.tags,
    required this.avatarUrl,
    this.isVerified = true,
    this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                avatarUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 80),
                ),
              ),
              if (isVerified)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (username.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                SizedBox(
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
                    child: const Text(
                      'Enviar solicitud',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
