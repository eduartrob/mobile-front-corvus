import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/teams_provider.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/teams/presentation/widgets/team_members_list.dart';

class SolicitudesTab extends StatelessWidget {
  const SolicitudesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<TeamsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredList = provider.filteredSolicitudes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: l10n.received,
                    filter: SolicitudFilter.recibidas,
                    currentFilter: provider.selectedFilter,
                    onTap: (filter) => provider.selectFilter(filter),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    context,
                    label: l10n.sent,
                    filter: SolicitudFilter.enviadas,
                    currentFilter: provider.selectedFilter,
                    onTap: (filter) => provider.selectFilter(filter),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredList.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () => provider.fetchRequests(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mail_outline,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noRequests,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchRequests(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final solicitud = filteredList[index];
                          return _SolicitudCard(
                            solicitud: solicitud,
                            l10n: l10n,
                            onReject: () {
                              provider.cancelRequest(solicitud.id).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.requestCancelled),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${l10n.notifErrorTitle}: $error'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              });
                            },
                            onAccept: () {
                              provider.acceptRequest(solicitud.id).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.invitationAccepted),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${l10n.notifErrorTitle}: $error'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              });
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required SolicitudFilter filter,
    required SolicitudFilter currentFilter,
    required ValueChanged<SolicitudFilter> onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(filter),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final AppLocalizations l10n;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const _SolicitudCard({
    required this.solicitud,
    required this.l10n,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final student = solicitud.student;
    
    final provider = context.watch<TeamsProvider>();
    final myTeamCount = provider.myTeam?.members.length ?? 0;
    final isReceiverInTeam = myTeamCount > 1;
    final inviteText = isReceiverInTeam ? l10n.wantsToJoinGroup : l10n.invitedToGroup;

    return InvitationCard(
      name: student.name,
      username: student.username,
      bio: student.bio,
      tags: student.tags,
      avatarUrl: student.avatarUrl,
      isVerified: student.isVerified,
      headerWidget: solicitud.state == SolicitudState.recibida
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                inviteText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            )
          : null,
      customActionWidget: solicitud.state == SolicitudState.recibida
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.delete,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.accept,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}