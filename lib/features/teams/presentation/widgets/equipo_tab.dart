import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:go_router/go_router.dart';
import 'team_members_list.dart';
import 'dashed_border_painter.dart';

class EquipoTab extends StatelessWidget {
  final String myAvatarUrl;
  final String? userName;
  final String? userEmail;
  final VoidCallback onLeaveTeam;
  final VoidCallback? onSearchMembers;

  const EquipoTab({
    super.key,
    required this.myAvatarUrl,
    this.userName,
    this.userEmail,
    required this.onLeaveTeam,
    this.onSearchMembers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().currentUser;
    final projectProvider = context.watch<MyProjectProvider>();
    final currentUserId = user?.id ?? '';

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
          name: 'Mi Equipo',
          description: 'Crea tu equipo personalizando el nombre en el botón "Gestionar" de la derecha y busca integrantes en la pestaña "Sugerencias".',
          members: [
            TeamMemberModel(
              id: currentUserId,
              name: userName ?? user?.name ?? 'Estudiante',
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
              // Sophisticated Project detail box (touches edges)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 36),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurpleAccent.withValues(alpha: 0.25),
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
                        // "TU EQUIPO" badge
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
                            'TU EQUIPO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade600,
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
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                                ]
                              ),
                              child: Icon(Icons.groups_rounded, color: Colors.deepPurple.shade400, size: 24),
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
                          padding: const EdgeInsets.only(right: 70), // space for floating avatars
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
                        // Integrantes pill
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
                                '${displayTeam.members.length} / $maxMembers miembros',
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
                          label: const Text('Gestionar'),
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
              // Rest of the content wrapped in padding
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teamsProvider.finalReviewStatus != null)
                      _buildProposalStatusBanner(context, teamsProvider.finalReviewStatus!),
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
                              ? 'Te falta 1 integrante'
                              : 'Te faltan $missingCount integrantes',
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
                    label: const Text(
                      'Buscar integrantes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildProposalStatusBanner(BuildContext context, Map<String, dynamic> statusData) {
    final status = statusData['status'] as String? ?? 'UNKNOWN';
    final colorScheme = Theme.of(context).colorScheme;
    
    Color bgColor;
    Color fgColor;
    IconData icon;
    String title;
    String subtitle = 'El profesorado revisará pronto tu proyecto.';

    switch (status) {
      case 'PENDING':
        bgColor = Colors.amber.shade100;
        fgColor = Colors.amber.shade900;
        icon = Icons.hourglass_empty;
        title = 'Propuesta Enviada';
        break;
      case 'APPROVED':
        bgColor = Colors.green.shade100;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle;
        title = 'Propuesta Aprobada';
        subtitle = '¡Felicidades! Pueden continuar con el proyecto.';
        break;
      case 'REJECTED':
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        icon = Icons.cancel;
        title = 'Propuesta Rechazada';
        subtitle = statusData['reason'] ?? 'La propuesta no cumple con los criterios académicos.';
        break;
      case 'SUMMONED':
        bgColor = Colors.blue.shade100;
        fgColor = Colors.blue.shade900;
        icon = Icons.calendar_month;
        title = 'Citados a Revisión';
        final date = statusData['appointment_date'] != null 
            ? DateTime.tryParse(statusData['appointment_date']) 
            : null;
        if (date != null) {
          subtitle = 'Fecha: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}\n';
        } else {
          subtitle = '';
        }
        if (statusData['location_link'] != null) {
          subtitle += 'Lugar/Enlace: ${statusData['location_link']}';
        }
        break;
      default:
        bgColor = colorScheme.surfaceContainerHighest;
        fgColor = colorScheme.onSurfaceVariant;
        icon = Icons.info;
        title = 'Estado de propuesta desconocido';
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
