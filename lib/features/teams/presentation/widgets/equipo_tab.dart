import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'team_members_list.dart';
import 'dashed_border_painter.dart';

class EquipoTab extends StatelessWidget {
  final String myAvatarUrl;
  final String? userName;
  final String? userEmail;
  final VoidCallback onLeaveTeam;
  final VoidCallback? onSearchMembers;
  final String projectId;

  const EquipoTab({
    super.key,
    required this.myAvatarUrl,
    this.userName,
    this.userEmail,
    required this.onLeaveTeam,
    this.onSearchMembers,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final projectProvider = context.watch<MyProjectProvider>();
    final currentUserId = user?.id ?? '';

    final projProvider = context.watch<ProjectProvider>();
    final project = projProvider.myProjects.firstWhere(
      (p) => p['id'] == projectId,
      orElse: () => null,
    );
    
    final pastelColors = const [
      Color(0xFF5C88DA), Color(0xFF9A73C9), 
      Color(0xFF56A98A), Color(0xFFD98A53), Color(0xFFD67389),
    ];

    Color pColor = Colors.deepPurpleAccent;
    if (project != null) {
      if (project['theme_color'] != null) {
        final colorStr = project['theme_color'].toString().replaceAll('#', '0xFF');
        pColor = Color(int.parse(colorStr));
      } else {
        pColor = pastelColors[project['id'].hashCode.abs() % pastelColors.length];
      }
    }

    return Consumer<TeamsProvider>(
      builder: (context, teamsProvider, child) {
        if (teamsProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final team = teamsProvider.myTeam;
        final bool isVirtual = team == null;

        final displayTeam = team ?? TeamModel(
          id: 'virtual-team',
          name: l10n.myTeam,
          description: l10n.virtualTeamDesc,
          members: [
            TeamMemberModel(
              id: currentUserId,
              name: userName ?? user?.name ?? l10n.studentDefaultName,
              email: userEmail ?? user?.email ?? '',
              avatarUrl: myAvatarUrl,
              role: 'LEADER',
            ),
          ],
          socialLinks: [],
        );

        final maxMembers = teamsProvider.maxTeamMembers;
        final missingCount = maxMembers - displayTeam.members.length;
        final isAdmin = displayTeam.members.isNotEmpty && displayTeam.members[0].id == currentUserId;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 36),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      pColor.withValues(alpha: 0.35),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (project != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: pColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: pColor.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  if (project['theme_pattern'] != null)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SvgPicture.asset(
                                          'assets/patterns/${project['theme_pattern']}.svg',
                                          fit: BoxFit.none,
                                          colorFilter: ColorFilter.mode(
                                            ThemeData.estimateBrightnessForColor(pColor) == Brightness.dark
                                                ? Colors.white.withValues(alpha: 0.2)
                                                : Colors.grey.shade700.withValues(alpha: 0.2),
                                            BlendMode.srcATop,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.class_, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            project['name'],
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Text(
                            l10n.yourTeamBadge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: pColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: pColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
                                ]
                              ),
                              child: Icon(Icons.groups_rounded, color: pColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                displayTeam.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 70),
                          child: Text(
                            displayTeam.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline, size: 14, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                l10n.teamMembersCount(displayTeam.members.length.toString(), maxMembers.toString()),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: TextButton.icon(
                          onPressed: () => context.push('/manage-team'),
                          icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                          label: Text(l10n.manage),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.6),
                            foregroundColor: Colors.deepPurple.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teamsProvider.finalReviewStatus != null)
                      _buildProposalStatusBanner(context, teamsProvider.finalReviewStatus!, l10n),
                    if (teamsProvider.finalReviewStatus != null)
                      const SizedBox(height: 16),
                    TeamMembersList(
                      members: displayTeam.members,
                      currentUserId: currentUserId,
                    ),
              if (missingCount > 0) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          missingCount == 1
                              ? l10n.missingOneMember
                              : l10n.missingMembers(missingCount.toString()),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onSearchMembers ?? () {},
                    icon: const Icon(Icons.search, size: 20),
                    label: Text(
                      l10n.searchMembers,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
              if (!isVirtual) ...[
                const SizedBox(height: 36),
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: onLeaveTeam,
                      icon: const Icon(Icons.exit_to_app, size: 18),
                      label: Text(l10n.leaveTeam),
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
              ],
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    ),
  );
      },
    );
  }

  Widget _buildProposalStatusBanner(BuildContext context, Map<String, dynamic> statusData, AppLocalizations l10n) {
    final status = statusData['status'] as String? ?? 'UNKNOWN';
    final colorScheme = Theme.of(context).colorScheme;
    
    Color bgColor;
    Color fgColor;
    IconData icon;
    String title;
    String subtitle = l10n.proposalPendingDesc;

    switch (status) {
      case 'PENDING':
        bgColor = Colors.amber.shade100;
        fgColor = Colors.amber.shade900;
        icon = Icons.hourglass_empty;
        title = l10n.proposalSent;
        break;
      case 'APPROVED':
        bgColor = Colors.green.shade100;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle;
        title = l10n.proposalApproved;
        subtitle = l10n.proposalApprovedDesc;
        break;
      case 'REJECTED':
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        icon = Icons.cancel;
        title = l10n.proposalRejected;
        subtitle = statusData['reason'] ?? l10n.proposalRejectedDesc;
        break;
      case 'SUMMONED':
        bgColor = Colors.blue.shade100;
        fgColor = Colors.blue.shade900;
        icon = Icons.calendar_month;
        title = l10n.summonedForReview;
        final date = statusData['appointment_date'] != null 
            ? DateTime.tryParse(statusData['appointment_date']) 
            : null;
        if (date != null) {
          subtitle = l10n.appointmentDate('${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}') + '\n';
        } else {
          subtitle = '';
        }
        if (statusData['location_link'] != null) {
          subtitle += l10n.appointmentLocation(statusData['location_link']);
        }
        break;
      default:
        bgColor = colorScheme.surfaceContainerHighest;
        fgColor = colorScheme.onSurfaceVariant;
        icon = Icons.info;
        title = l10n.proposalStatusUnknown;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fgColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: fgColor.withValues(alpha: 0.8),
                    fontSize: 14,
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