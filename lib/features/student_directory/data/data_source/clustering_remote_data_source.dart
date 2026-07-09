import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class ClusteringRemoteDataSource {
  final http.Client client;

  ClusteringRemoteDataSource({required this.client});

  // GET /clustering/groups/login
  Future<Map<String, dynamic>> loginClassroom() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/login');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error al iniciar sesión en Classroom');
  }

  // GET /clustering/groups/courses
  Future<List<dynamic>> getClassroomCourses() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/courses');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    return [];
  }

  // POST /clustering/groups/cluster/<courseId>
  Future<Map<String, dynamic>> processClustering(String courseId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/cluster/$courseId');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error al procesar el agrupamiento');
  }

  // GET /clustering/groups/cluster/<courseId>/summary
  Future<Map<String, dynamic>> getClusteringSummary(String courseId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/cluster/$courseId/summary');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error al obtener el resumen de grupos');
  }

  // POST /clustering/groups/sync-perfil
  Future<Map<String, dynamic>> syncStudentProfile() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/sync-perfil');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error al sincronizar el perfil del estudiante');
  }

  // GET /clustering/groups/mi-perfil/completo
  Future<Map<String, dynamic>> getFullStudentProfile() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/mi-perfil/completo');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
    throw Exception('Error al obtener el perfil completo del estudiante');
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
