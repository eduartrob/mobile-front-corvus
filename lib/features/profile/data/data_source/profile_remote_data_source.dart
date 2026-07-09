import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';

class ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSource({required this.client});

  Future<ProfileCompletoModel> getPerfilCompleto({bool forceRefresh = false}) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/mi-perfil/completo${forceRefresh ? "?force_refresh=true" : ""}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

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

  Future<void> updateProfile({
    required String fullName,
    required String enrollmentId,
    required String semester,
    required List<String> skills,
  }) async {
    try {
      // 1. Actualizar nombre/matrícula/cuatrimestre en auth service
      final authUrl = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/profile');
      final authResponse = await client.put(
        authUrl,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'full_name': fullName,
          'enrollment_id': enrollmentId,
          'semester': semester,
          'skills': skills,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (authResponse.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(authResponse.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al actualizar perfil');
      }

    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> requestVerificationCode(String type) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/verify/request');
    try {
      final response = await client.post(
        url, 
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'type': type}),
      ).timeout(ApiConfig.connectionTimeout);
      if (response.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al solicitar código');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> confirmVerificationCode(String code, String type) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/verify/confirm');
    try {
      final response = await client.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'code': code, 'type': type}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al verificar código');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> linkGoogleAccount(String authCode) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/link-google');
    try {
      final response = await client.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'authCode': authCode}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al vincular cuenta');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> addSecondaryEmail(String email) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/profile/secondary-email');
    try {
      final response = await client.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'email': email}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al añadir correo secundario');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteEmail(String type) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/profile/email');
    try {
      final response = await client.delete(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'type': type}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al borrar correo');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
