import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/shared/domain/entities/student.dart';

class StudentDirectoryRemoteDataSource {
  final http.Client client;

  StudentDirectoryRemoteDataSource({required this.client});

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
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
    return [];
  }

  void _handleError(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    String errorMessage = 'Error del servidor (${response.statusCode})';
    try {
      final errorJson = json.decode(bodyText);
      errorMessage = errorJson['detail'] ?? errorJson['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = 'Error del servidor (\${response.statusCode})';
    }
    throw mapHttpError(response.statusCode, bodyText);
  }
}
