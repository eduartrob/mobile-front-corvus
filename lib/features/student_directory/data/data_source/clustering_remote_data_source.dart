import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/network/api_config.dart';

class ClusteringRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;

  ClusteringRemoteDataSource({required this.client, FlutterSecureStorage? storage})
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

  // GET /clustering/groups/login
  Future<Map<String, dynamic>> loginClassroom() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/login');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/courses');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/cluster/$courseId');

    try {
      final response = await client.post(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/cluster/$courseId/summary');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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

  // GET /clustering/groups/mi-perfil/completo
  Future<Map<String, dynamic>> getFullStudentProfile() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/groups/mi-perfil/completo');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

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
