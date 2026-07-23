import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class ProfessorApi {
  Future<List<dynamic>> searchProfessors({
    required String query,
    required String token,
    String? projectId,
  }) async {
    final url = projectId != null
        ? '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsSearch}?q=$query&projectId=$projectId'
        : '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsSearch}?q=$query';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['results'] ?? [];
    } else {
      throw Exception('Error al buscar docentes: ${response.statusCode} - ${response.body}');
    }
  }
}
