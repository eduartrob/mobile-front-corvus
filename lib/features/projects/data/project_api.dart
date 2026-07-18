import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class ProjectApi {
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
    int teamSize = 4,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projects}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'team_size': teamSize,
      }),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _handleError(response, 'Error al crear proyecto');
    }
  }

  Future<Map<String, dynamic>> joinProject({
    required String code,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectsJoin}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _handleError(response, 'Error al unirse al proyecto');
    }
  }

  Future<Map<String, dynamic>> getMyProjects({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectsMyProjects}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _handleError(response, 'Error al obtener proyectos');
    }
  }

  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String name,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectById(projectId)}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      _handleError(response, 'Error al actualizar proyecto');
    }
  }

  Future<void> deleteProject({
    required String projectId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectById(projectId)}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      _handleError(response, 'Error al eliminar proyecto');
    }
  }

  Future<List<dynamic>> getProjectStudents({
    required String projectId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectStudents(projectId)}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['students'] ?? [];
    } else {
      _handleError(response, 'Error al obtener alumnos');
    }
  }

  Future<bool> acceptInvitation({required String projectId, required String token}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectCollaboratorsAccept(projectId)}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> rejectInvitation({required String projectId, required String token}) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.projectCollaboratorsReject(projectId)}'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Never _handleError(http.Response response, String prefix) {
    String errorMessage = '$prefix (${response.statusCode})';
    try {
      final errorJson = jsonDecode(response.body);
      errorMessage = '$prefix: ${errorJson['detail'] ?? errorJson['message'] ?? errorMessage}';
    } catch (_) {
      errorMessage = '$prefix: ${response.statusCode} - ${response.body}';
    }
    throw Exception(errorMessage);
  }
}
