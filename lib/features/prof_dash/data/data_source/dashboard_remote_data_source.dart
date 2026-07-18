import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';

class DashboardRemoteDataSource {
  final http.Client client;

  DashboardRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> fetchDashboardStats(
      {String? projectId, String? token}) async {
    final urlStr = projectId != null
        ? '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsDashboard}?projectId=$projectId'
        : '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsDashboard}';
    final url = Uri.parse(urlStr);
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response =
        await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
          'Error al cargar el dashboard (Código ${response.statusCode})');
    }
  }
}