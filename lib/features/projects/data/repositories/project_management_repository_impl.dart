import 'package:mobile/features/projects/data/project_api.dart';
import 'package:mobile/features/projects/domain/repositories/project_management_repository.dart';

class ProjectManagementRepositoryImpl implements ProjectManagementRepository {
  final ProjectApi _api;

  ProjectManagementRepositoryImpl({ProjectApi? api}) : _api = api ?? ProjectApi();

  @override
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
    int teamSize = 4,
    required String token,
    String? themeColor,
    String? themePattern,
  }) {
    return _api.createProject(
      name: name,
      description: description,
      teamSize: teamSize,
      token: token,
      themeColor: themeColor,
      themePattern: themePattern,
    );
  }

  @override
  Future<Map<String, dynamic>> joinProject({
    required String code,
    required String token,
  }) {
    return _api.joinProject(code: code, token: token);
  }

  @override
  Future<Map<String, dynamic>> getMyProjects({required String token}) {
    return _api.getMyProjects(token: token);
  }

  @override
  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String name,
    required String token,
    String? themeColor,
    String? themePattern,
  }) {
    return _api.updateProject(
      projectId: projectId,
      name: name,
      token: token,
      themeColor: themeColor,
      themePattern: themePattern,
    );
  }

  @override
  Future<void> deleteProject({
    required String projectId,
    required String token,
  }) {
    return _api.deleteProject(projectId: projectId, token: token);
  }

  @override
  Future<List<dynamic>> getProjectStudents({
    required String projectId,
    required String token,
  }) {
    return _api.getProjectStudents(projectId: projectId, token: token);
  }

  @override
  Future<bool> acceptInvitation({
    required String projectId,
    required String token,
  }) {
    return _api.acceptInvitation(projectId: projectId, token: token);
  }

  @override
  Future<bool> rejectInvitation({
    required String projectId,
    required String token,
  }) {
    return _api.rejectInvitation(projectId: projectId, token: token);
  }
}