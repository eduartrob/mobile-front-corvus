import 'package:mobile/features/prof_dash/data/data_source/dashboard_remote_data_source.dart';
import 'package:mobile/features/prof_dash/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/prof_dash/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<DashboardEntity> loadDashboardStats(
      {String? projectId, String? token}) async {
    final data = await _remoteDataSource.fetchDashboardStats(
      projectId: projectId,
      token: token,
    );

    final metrics = data['metrics'] as Map<String, dynamic>? ?? {};
    final alertsRaw = data['alerts'] as List? ?? [];

    int extractInt(dynamic root, Map<String, dynamic> sub, List<String> keys) {
      for (final key in keys) {
        if (sub[key] != null) {
          final val = sub[key];
          if (val is int) return val;
          if (val is num) return val.toInt();
          if (val is String) return int.tryParse(val) ?? 0;
        }
        if (root is Map && root[key] != null) {
          final val = root[key];
          if (val is int) return val;
          if (val is num) return val.toInt();
          if (val is String) return int.tryParse(val) ?? 0;
        }
      }
      return 0;
    }

    final totalTeams = extractInt(data, metrics, ['total_teams', 'totalTeams', 'teams_count', 'teamsCount']);
    final readyProposals = extractInt(data, metrics, ['ready_proposals', 'readyProposals', 'proposals_ready', 'proposalsReady']);
    final studentsWithTeam = extractInt(data, metrics, [
      'students_with_team',
      'studentsWithTeam',
      'with_team',
      'withTeam',
      'alumnos_con_equipo',
      'con_equipo',
      'students_in_team',
    ]);
    final studentsWithoutTeam = extractInt(data, metrics, [
      'students_without_team',
      'studentsWithoutTeam',
      'without_team',
      'withoutTeam',
      'unassigned_students',
      'unassignedStudents',
      'unassigned',
      'alumnos_sin_equipo',
      'sin_equipo',
      'rezagados',
      'students_lagging',
      'lagging_students',
    ]);

    return DashboardEntity(
      totalTeams: totalTeams,
      readyProposals: readyProposals,
      studentsWithTeam: studentsWithTeam,
      studentsWithoutTeam: studentsWithoutTeam,
      alerts: alertsRaw.map((a) {
        final alert = a as Map<String, dynamic>;
        return DashboardAlertEntity(
          icon: alert['icon'] ?? 'info_outline',
          color: alert['color'] ?? 'primary',
          text: alert['text'] ?? '',
        );
      }).toList(),
    );
  }
}