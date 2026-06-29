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
      request.fields['user_id'] = userId;
      request.headers.addAll(ApiConfig.defaultHeaders);
      
      // -# reintento el keystore de android puede fallar al volver de filepicker
      var token = await _storage.read(key: 'auth_token');
      if (token == null) {
        await Future.delayed(const Duration(milliseconds: 600));
        token = await _storage.read(key: 'auth_token');
      }
      if (token == null) {
        throw Exception('Sesión no encontrada. Por favor cierra y abre la app nuevamente.');
      }
      request.headers['Authorization'] = 'Bearer $token';
      request.headers.remove('Content-Type');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error en la pre-validación: ${response.body}');
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
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
          return {};
        }
        return data;
      } else {
        throw Exception('Error al consultar borrador: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalysisStatus(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analysis-status/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return {'phase': 5, 'message': 'Procesando propuesta...'};
  }

  Future<void> analyzeDraftDetailed(String userId) async {
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        final bodyText = utf8.decode(response.bodyBytes);
        try {
          final errorJson = json.decode(bodyText);
          throw Exception(errorJson['detail'] ?? bodyText);
        } catch (_) {
          throw Exception(bodyText);
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> getAnalysisResult(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/analysis-result/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return {'status': 'pending'};
  }

  Future<void> cancelAnalysis(String userId) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/cancel-analysis/$userId');

    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      await client.post(url, headers: headers);
    } catch (_) {
    }
  }
}
