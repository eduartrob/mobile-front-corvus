import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/domain/entities/project_analysis_entity.dart';
import 'package:mobile/features/my_project/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final MyProjectRemoteDataSource _remoteDataSource;
  final MyProjectLocalDataSource _localDataSource;

  ProjectRepositoryImpl({
    required MyProjectRemoteDataSource remoteDataSource,
    required MyProjectLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<ProjectAnalysisEntity> fetchConfig({String? projectId}) async {
    final uri = Uri.parse(
        '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}')
        .replace(queryParameters:
            projectId != null ? {'projectId': projectId} : null);
    final response = await _remoteDataSource.client.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        return ProjectAnalysisEntity(
          allowedExtensions: (data['allowed_extensions'] as List?)
                  ?.map((e) =>
                      e.toString().replaceAll('.', '').trim().toLowerCase())
                  .where((e) => e.isNotEmpty)
                  .toList() ??
              const ['pdf', 'md', 'txt'],
          exclusionRules: (data['exclusion_rules'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          projectSections: (data['project_sections'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              const [],
          maxTeamMembers:
              int.tryParse(data['max_team_members']?.toString() ?? '') ?? 3,
        );
      }
    }
    return const ProjectAnalysisEntity();
  }

  @override
  Future<Map<String, dynamic>?> getLocalAnalysis(String userId) =>
      _localDataSource.getDetailedAnalysis(userId);

  @override
  Future<void> saveLocalAnalysis(String userId, Map<String, dynamic> result) =>
      _localDataSource.saveDetailedAnalysis(userId, result);

  @override
  Future<void> clearLocalAnalysis(String userId) =>
      _localDataSource.clearDetailedAnalysis(userId);

  @override
  Future<Map<String, dynamic>> getAnalysisStatus(String teamId) =>
      _remoteDataSource.getAnalysisStatus(teamId);

  @override
  Future<Map<String, dynamic>> getAnalysisResult(String teamId) =>
      _remoteDataSource.getAnalysisResult(teamId);

  @override
  Future<Map<String, dynamic>> checkDraft(String teamId) =>
      _remoteDataSource.checkDraft(teamId);

  @override
  Future<Map<String, dynamic>> preValidateProposal(
    String filePath,
    String teamId,
    String userId,
    String userName, {
    String? universityId,
    String? careerId,
    String? projectId,
  }) =>
      _remoteDataSource.preValidateProposal(
        filePath,
        teamId,
        userId,
        userName,
        universityId: universityId,
        careerId: careerId,
        projectId: projectId,
      );

  @override
  Future<void> analyzeDraftDetailed(String teamId) =>
      _remoteDataSource.analyzeDraftDetailed(teamId);

  @override
  Future<void> cancelAnalysis(String teamId) =>
      _remoteDataSource.cancelAnalysis(teamId);

  @override
  Future<Map<String, dynamic>> sendFinalReview(
    String teamId,
    Map<String, dynamic> proposalData,
  ) =>
      _remoteDataSource.sendFinalReview(teamId, proposalData);

  @override
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId) =>
      _remoteDataSource.getFinalReviewStatus(teamId);
}