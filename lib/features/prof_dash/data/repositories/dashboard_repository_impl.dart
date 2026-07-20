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

    final alertsRaw = data['alerts'] as List? ?? [];

    int extractInt(dynamic jsonRoot, List<String> keys) {
      if (jsonRoot is! Map) return 0;
      final mapsToSearch = <Map>[
        jsonRoot,
        if (jsonRoot['data'] is Map) jsonRoot['data'] as Map,
        if (jsonRoot['metrics'] is Map) jsonRoot['metrics'] as Map,
        if (jsonRoot['stats'] is Map) jsonRoot['stats'] as Map,
        if (jsonRoot['dashboard'] is Map) jsonRoot['dashboard'] as Map,
        if (jsonRoot['result'] is Map) jsonRoot['result'] as Map,
        if (jsonRoot['data'] is Map && jsonRoot['data']['metrics'] is Map) jsonRoot['data']['metrics'] as Map,
        if (jsonRoot['data'] is Map && jsonRoot['data']['stats'] is Map) jsonRoot['data']['stats'] as Map,
      ];

      for (final map in mapsToSearch) {
        for (final key in keys) {
          if (map[key] != null) {
            final val = map[key];
            if (val is int) return val;
            if (val is num) return val.toInt();
            if (val is String) {
              final parsed = int.tryParse(val);
              if (parsed != null) return parsed;
            }
          }
        }
      }
      return 0;
    }

    final totalTeams = extractInt(data, ['total_teams', 'totalTeams', 'teams_count', 'teamsCount']);
    final readyProposals = extractInt(data, ['ready_proposals', 'readyProposals', 'proposals_ready', 'proposalsReady']);
    final studentsWithTeam = extractInt(data, [
      'students_with_team',
      'studentsWithTeam',
      'with_team',
      'withTeam',
      'alumnos_con_equipo',
      'con_equipo',
      'students_in_team',
      'in_team',
    ]);
    final studentsWithoutTeam = extractInt(data, [
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