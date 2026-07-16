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
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects'),
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
      throw Exception('Error al crear proyecto: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> joinProject({
    required String code,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/join'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al unirse al proyecto: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getMyProjects({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/my-projects'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener proyectos: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String name,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/$projectId'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar proyecto: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<dynamic>> getProjectStudents({
    required String projectId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/$projectId/students'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['students'] ?? [];
    } else {
      throw Exception('Error al obtener alumnos: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> acceptInvitation({required String projectId, required String token}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/$projectId/collaborators/accept'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> rejectInvitation({required String projectId, required String token}) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/$projectId/collaborators/reject'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
