import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';

class TeamsRemoteDataSource {
  final http.Client client;

  TeamsRemoteDataSource({required this.client});

  // 👥 GET /teams/my-team
  Future<TeamModel?> getMyTeam() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsMyTeam}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body == null || (body is Map && body.isEmpty)) return null;
        return TeamModel.fromJson(body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    return null;
  }

  // 📝 GET /final-reviews/team/<teamId>
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.finalReviewByTeam(teamId)}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return body['review'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // 👥 PUT /teams/my-team
  Future<TeamModel> updateTeam(String name, String description, List<SocialLinkModel> socialLinks) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsMyTeam}');

    try {
      final response = await client.put(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'name': name,
          'description': description,
          'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return TeamModel.fromJson(body);
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error desconocido al actualizar equipo');
  }

  // 👥 POST /teams/my-team/leave
  Future<void> leaveTeam() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsMyTeamLeave}');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 👥 DELETE /teams/my-team/members/<memberId>
  Future<void> removeMember(String memberId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamMemberById(memberId)}');

    try {
      final response = await client.delete(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 🔍 GET /clustering/teams/suggestions
  Future<List<Student>> getSuggestions({String? skill, String? search, bool showAll = false}) async {
    var uriString = '${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsSuggestions}';
    final queryParams = <String>[];
    if (skill != null && skill.isNotEmpty && skill.toLowerCase() != 'all skills') {
      queryParams.add('skill=${Uri.encodeComponent(skill)}');
    }
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (showAll) {
      queryParams.add('show_all=true');
    }
    
    if (queryParams.isNotEmpty) {
      uriString += '?${queryParams.join('&')}';
    }
    
    final url = Uri.parse(uriString);

    try {
      final response = await client.get(
        url, 
        headers: ApiConfig.defaultHeaders
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => Student.fromJson(item)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    return [];
  }

  // GET /clustering/teams/students
  Future<List<Student>> getStudentDirectory({String? skill}) async {
    var uriString = '${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsStudents}';
    if (skill != null && skill.isNotEmpty && skill.toLowerCase() != 'all skills') {
      uriString += '?skill=${Uri.encodeComponent(skill)}';
    }
    
    final url = Uri.parse(uriString);

    try {
      final response = await client.get(
        url, 
        headers: ApiConfig.defaultHeaders
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => Student.fromJson(item)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    return [];
  }

  // 📩 GET /teams/requests?filter=enviadas|aceptadas
  Future<List<Solicitud>> getRequests(String filter) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsRequests}?filter=$filter');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List body = json.decode(utf8.decode(response.bodyBytes));
        final forcedState = filter == 'enviadas' ? SolicitudState.enviada : SolicitudState.recibida;
        return body.map((item) => Solicitud.fromJson(item, forcedState: forcedState)).toList();
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    return [];
  }

  // 📩 POST /teams/requests
  Future<void> sendInvitation(String studentId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsRequests}');

    try {
      final response = await client.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'studentId': studentId}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 📩 DELETE /teams/requests/<requestId>
  Future<void> cancelRequest(String requestId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamRequestById(requestId)}');

    try {
      final response = await client.delete(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 📩 POST /teams/requests/<requestId>/accept
  Future<void> acceptRequest(String requestId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamRequestAccept(requestId)}');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _handleError(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    String errorMessage = 'Error del servidor (${response.statusCode})';
    try {
      final errorJson = json.decode(bodyText);
      errorMessage = errorJson['detail'] ?? errorJson['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = 'Error del servidor: ${response.statusCode} - $bodyText';
    }
    throw Exception(errorMessage);
  }
}
