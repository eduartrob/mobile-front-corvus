import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/core/error/error_handler.dart';
import 'package:mobile/features/profile/data/models/profile_completo_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProfileRemoteDataSource({required this.client});

  Future<ProfileCompletoModel?> getCachedProfile() async {
    final cachedStr = await _storage.read(key: 'cached_profile_complete');
    if (cachedStr != null) {
      try {
        final body = json.decode(cachedStr);
        return ProfileCompletoModel.fromJson(body);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<ProfileCompletoModel> getPerfilCompleto({bool forceRefresh = false}) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/profile/complete${forceRefresh ? "?force_refresh=true" : ""}');

    try {
      final response = await client.get(url, headers: ApiConfig.defaultHeaders).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        final body = json.decode(bodyText);
        final model = ProfileCompletoModel.fromJson(body);
        
        if (!model.isProcessing) {
          await _storage.write(key: 'cached_profile_complete', value: bodyText);
        }
        
        return model;
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        final errorJson = json.decode(bodyText);
        throw mapHttpError(response.statusCode, bodyText);
      }
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String enrollmentId,
    required String semester,
    required List<String> skills,
    List<String>? careers,
  }) async {
    try {
      // 1. Actualizar nombre/matrícula/cuatrimestre en auth service
      final authUrl = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/profile');
      
      final Map<String, dynamic> bodyData = {
        'full_name': fullName,
        'enrollment_id': enrollmentId,
        'semester': semester,
        'skills': skills,
      };
      
      if (careers != null) {
        bodyData['careers'] = careers;
      }

      final authResponse = await client.put(
        authUrl,
        headers: ApiConfig.defaultHeaders,
        body: json.encode(bodyData),
      ).timeout(ApiConfig.connectionTimeout);

      if (authResponse.statusCode != 200) {
        final errorJson = json.decode(utf8.decode(authResponse.bodyBytes));
        throw Exception(errorJson['error'] ?? 'Error al actualizar perfil');
      }

    } catch (e, st) {
      throw NetworkException(e.toString());
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
    } catch (e, st) {
      throw NetworkException(e.toString());
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
    } catch (e, st) {
      throw NetworkException(e.toString());
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
    } catch (e, st) {
      throw NetworkException(e.toString());
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
    } catch (e, st) {
      throw NetworkException(e.toString());
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
    } catch (e, st) {
      throw NetworkException(e.toString());
    }
  }
}
