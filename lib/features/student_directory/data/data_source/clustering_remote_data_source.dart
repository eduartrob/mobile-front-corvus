import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/error/error_handler.dart';

class ClusteringRemoteDataSource {
  final http.Client client;

  ClusteringRemoteDataSource({required this.client});

  // get clustering groups login
  Future<Map<String, dynamic>> loginClassroom() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsLogin}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    throw Exception('Error al iniciar sesión en Classroom');
  }

  // get clustering groups courses
  Future<List<dynamic>> getClassroomCourses() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsCourses}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    return [];
  }

  // post clustering groups cluster courseid 
  Future<Map<String, dynamic>> processClustering(String courseId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsCluster(courseId)}');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    throw Exception('Error al procesar el agrupamiento');
  }

  // get clustering groups cluster courseid summary
  Future<Map<String, dynamic>> getClusteringSummary(String courseId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsClusterSummary(courseId)}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    throw Exception('Error al obtener el resumen de grupos');
  }

  // post clustering groups sync perfil
  Future<Map<String, dynamic>> syncStudentProfile() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsSyncPerfil}');

    try {
      final response = await client.post(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    throw Exception('Error al sincronizar el perfil del estudiante');
  }

  // get clustering groups mi perfil completo
  Future<Map<String, dynamic>> getFullStudentProfile() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.clusteringGroupsMiPerfilCompleto}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        _handleError(response);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    throw Exception('Error al obtener el perfil completo del estudiante');
  }

  void _handleError(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    try {
      final errorJson = json.decode(bodyText);
      throw mapHttpError(response.statusCode, bodyText);
    } catch (_) {
      throw Exception('Error del servidor: ${response.statusCode} - $bodyText');
    }
  }
}
