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

    return DashboardEntity(
      totalTeams: data['total_teams'] ?? 0,
      readyProposals: data['ready_proposals'] ?? 0,
      studentsWithTeam: metrics['students_with_team'] ?? 0,
      studentsWithoutTeam: metrics['students_without_team'] ?? 0,
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