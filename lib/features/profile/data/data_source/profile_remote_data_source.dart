import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';

class ProfileRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage;

  ProfileRemoteDataSource({required this.client, FlutterSecureStorage? storage})
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

  Future<ProfileCompletoModel> getPerfilCompleto({bool forceRefresh = false}) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/mi-perfil/completo${forceRefresh ? "?force_refresh=true" : ""}');

    try {
      final response = await client.get(url, headers: _getHeaders(token)).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        return ProfileCompletoModel.fromJson(body);
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        final errorJson = json.decode(bodyText);
        throw Exception(errorJson['detail'] ?? errorJson['message'] ?? 'Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
