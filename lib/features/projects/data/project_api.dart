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

  Future<List<dynamic>> getMyProjects({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}/projects/my-projects'),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['projects'] ?? [];
    } else {
      throw Exception('Error al obtener proyectos: ${response.statusCode} - ${response.body}');
    }
  }
}
