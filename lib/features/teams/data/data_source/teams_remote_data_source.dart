import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';

class TeamsRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;

  TeamsRemoteDataSource({required this.client, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Sesión no encontrada. Por favor inicia sesión nuevamente.');
    }
    return token;
  }

  Map<String, String> _getHeaders(String token) {
    return {
      ...ApiConfig.defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  // 👥 GET /teams/my-team
  Future<TeamModel?> getMyTeam() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-team');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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

  // 👥 PUT /teams/my-team
  Future<TeamModel> updateTeam(String name, String description, List<SocialLinkModel> socialLinks) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-team');

    try {
      final response = await client.put(
        url,
        headers: _getHeaders(token),
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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-team/leave');

    try {
      final response = await client.post(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 👥 DELETE /teams/my-team/members/<memberId>
  Future<void> removeMember(String memberId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-team/members/$memberId');

    try {
      final response = await client.delete(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 👥 GET /teams/suggestions
  Future<List<Student>> getSuggestions({String? skill}) async {
    final token = await _getToken();
    var uriString = '${ApiConfig.apiGatewayUrl}/teams/suggestions';
    if (skill != null && skill.isNotEmpty && skill != 'All Skills') {
      uriString += '?skill=${Uri.encodeComponent(skill)}';
    }
    final url = Uri.parse(uriString);

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/requests?filter=$filter');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => Solicitud.fromJson(item)).toList();
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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/requests');

    try {
      final response = await client.post(
        url,
        headers: _getHeaders(token),
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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/requests/$requestId');

    try {
      final response = await client.delete(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 📩 POST /teams/requests/<requestId>/accept
  Future<void> acceptRequest(String requestId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/requests/$requestId/accept');

    try {
      final response = await client.post(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200 && response.statusCode != 204) {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _handleError(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    try {
      final errorJson = json.decode(bodyText);
      throw Exception(errorJson['detail'] ?? errorJson['message'] ?? 'Error del servidor (${response.statusCode})');
    } catch (_) {
      throw Exception('Error del servidor: ${response.statusCode} - $bodyText');
    }
  }
}
