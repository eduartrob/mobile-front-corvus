import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SearchRemoteDataSource {
  Future<Map<String, dynamic>> searchSmart(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final String _baseUrl = '${ApiConfig.apiGatewayUrl}/clustering/subject';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<Map<String, dynamic>> searchSmart(String query) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/search-smart'),
        headers: headers,
        body: jsonEncode({'query': query}),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        var errorMsg = 'Error en la búsqueda (HTTP ${response.statusCode})';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['detail'] != null && errorBody['detail'].toString().isNotEmpty) {
            errorMsg = errorBody['detail'].toString();
          } else if (errorBody['error'] != null && errorBody['error'].toString().isNotEmpty) {
            errorMsg = errorBody['error'].toString();
          } else if (errorBody['message'] != null && errorBody['message'].toString().isNotEmpty) {
            errorMsg = errorBody['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Excepción al buscar: $e');
    }
  }
}
