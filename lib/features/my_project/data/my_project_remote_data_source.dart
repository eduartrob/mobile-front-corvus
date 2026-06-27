import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/network/api_config.dart';

class MyProjectRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;

  MyProjectRemoteDataSource({required this.client, FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> preValidateProposal(String filePath, String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/pre-validate-proposal');

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['user_id'] = userId; // Añadimos el ID del usuario como campo del formulario
      request.headers.addAll(ApiConfig.defaultHeaders);
      
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.headers.remove('Content-Type');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error en la pre-validación: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> checkDraft(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/draft-proposal/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'not_found') {
          return {}; // No hay borrador
        }
        return data; // Retorna el quick_analysis
      } else {
        throw Exception('Error al consultar borrador: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeDraftDetailed(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analyze-draft-proposal');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userId;
      request.headers.addAll(ApiConfig.defaultHeaders);
      
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.headers.remove('Content-Type');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error en el análisis detallado del borrador: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
