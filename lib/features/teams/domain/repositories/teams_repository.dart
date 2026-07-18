import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';

/// Contrato de dominio para operaciones de equipos.
abstract class TeamsRepository {
  Future<TeamModel?> getMyTeam({String? projectId});
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId);
  Future<TeamModel> updateTeam(String name, String description, List<SocialLinkModel> socialLinks, {String? projectId});
  Future<void> leaveTeam();
  Future<void> removeMember(String memberId);
  Future<List<Student>> getSuggestions({String? skill, String? search, bool showAll = false, String? projectId});
  Future<List<Solicitud>> getRequests(String filter, {String? projectId});
  Future<void> sendInvitation(String studentId, {String? projectId});
  Future<void> cancelRequest(String requestId);
  Future<void> acceptRequest(String requestId, {String? projectId});
  Future<Map<String, dynamic>> fetchConfig({String? projectId});
  Future<Map<String, dynamic>?> fetchProjectId();
}