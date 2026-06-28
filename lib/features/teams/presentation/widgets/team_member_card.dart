import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class TeamMemberCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String email;
  final bool isLeader;
  final bool isMe;

  const TeamMemberCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.email,
    this.isLeader = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isLeader)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.youLeader,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
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
