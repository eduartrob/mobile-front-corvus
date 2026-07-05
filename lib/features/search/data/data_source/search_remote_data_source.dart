import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

abstract class SearchRemoteDataSource {
  Future<Map<String, dynamic>> searchSmart(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final String _baseUrl = 'http://10.0.2.2:8000/api/v1';

  @override
  Future<Map<String, dynamic>> searchSmart(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/search-smart'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'query': query}),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorMsg = 'Error en la búsqueda';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['detail'] != null) {
            errorMsg = errorBody['detail'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Excepción al buscar: $e');
    }
  }
}
