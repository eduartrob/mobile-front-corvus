import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/theme/app_dimens.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
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
    final user = context.watch<AuthProvider>().currentUser;
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

        final missingCount = 3 - displayTeam.members.length;

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
                        displayTeam.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayTeam.description,
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
                              'Miembros del Equipo',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${displayTeam.members.length}',
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
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2); // Redirects to tab index 2 (Sugerencias)
                    },
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
        );
      },
    );
  }
}
