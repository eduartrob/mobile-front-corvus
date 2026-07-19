import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/teams/domain/repositories/teams_repository.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource _remoteDataSource;

  TeamsRepositoryImpl({required TeamsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<TeamModel?> getMyTeam({String? projectId}) =>
      _remoteDataSource.getMyTeam(projectId: projectId);

  @override
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId) =>
      _remoteDataSource.getFinalReviewStatus(teamId);

  @override
  Future<TeamModel> updateTeam(
          String name, String description, List<SocialLinkModel> socialLinks,
          {String? projectId}) =>
      _remoteDataSource.updateTeam(name, description, socialLinks,
          projectId: projectId);

  @override
  Future<void> leaveTeam() => _remoteDataSource.leaveTeam();

  @override
  Future<void> removeMember(String memberId) =>
      _remoteDataSource.removeMember(memberId);

  @override
  Future<List<Student>> getSuggestions(
          {String? skill, String? search, bool showAll = false, String? projectId}) =>
      _remoteDataSource.getSuggestions(
          skill: skill, search: search, showAll: showAll, projectId: projectId);

  @override
  Future<List<Solicitud>> getRequests(String filter, {String? projectId}) =>
      _remoteDataSource.getRequests(filter, projectId: projectId);

  @override
  Future<void> sendInvitation(String studentId, {String? projectId}) =>
      _remoteDataSource.sendInvitation(studentId, projectId: projectId);

  @override
  Future<void> cancelRequest(String requestId) =>
      _remoteDataSource.cancelRequest(requestId);

  @override
  Future<void> acceptRequest(String requestId, {String? projectId}) =>
      _remoteDataSource.acceptRequest(requestId, projectId: projectId);

  @override
  Future<Map<String, dynamic>> fetchConfig({String? projectId}) async {
    final uri = Uri.parse(
        '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}')
        .replace(queryParameters:
            projectId != null ? {'projectId': projectId} : null);
    final response =
        await _remoteDataSource.client.get(uri, headers: ApiConfig.defaultHeaders);
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>?> fetchProjectId() async {
    try {
      final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-project-id');
      final response =
          await _remoteDataSource.client.get(uri, headers: ApiConfig.defaultHeaders);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return null;
  }
}