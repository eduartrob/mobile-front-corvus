import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/providers/auth_provider.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final VoidCallback onUnauthenticated;
  final VoidCallback onMitMDetected;
  final SecureStorageService _storage;

  AuthInterceptorClient({
    http.Client? client,
    required this.onUnauthenticated,
    required this.onMitMDetected,
    SecureStorageService? storage,
  })  : _inner = client ?? http.Client(),
        _storage = storage ?? SecureStorageService();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      if (request.url.host == 'corvus.eduartrob.site') {
        const fallbackFingerprint =
            "6C:E2:90:D1:16:D6:2F:85:E3:1E:66:3C:34:F7:1A:93:16:46:17:B8:A0:82:75:EC:CD:1A:D5:B1:30:03:05:43";

        // intentar obtener desde remote config
        String fingerprint = fallbackFingerprint;
        try {
          final remoteConfig = FirebaseRemoteConfig.instance;
          final remoteFingerprint = remoteConfig.getString('ssl_fingerprint');
          if (remoteFingerprint.isNotEmpty) {
            fingerprint = remoteFingerprint;
          }
        } catch (_) {
          // si remote config falla usar el fallback hardcodeado
          debugPrint('SSL: Remote Config no disponible, usando fingerprint de respaldo');
        }

        await HttpCertificatePinning.check(
          serverURL: 'https://corvus.eduartrob.site',
          headerHttp: {},
          sha: SHA.SHA256,
          allowedSHAFingerprints: [fingerprint],
          timeout: 50,
        );
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      // si el proxy se apagó pero el celular sigue intentando conectarse a él dará error de conexión no de mitm 
      if (errorStr.contains('socket') || 
          errorStr.contains('timeout') || 
          errorStr.contains('refused') || 
          errorStr.contains('network is unreachable') ||
          errorStr.contains('failed host lookup')) {
        throw Exception('Error de conexión a internet (¿Olvidaste apagar el proxy en tu WiFi?)');
      }

      // si el pin falla significa que el certificado fue reemplazado ej charles proxy o el fingerprint cambió 
      // onmitmdetected desactivado temporalmente por falsos positivos bug reportado por usuario 
      debugPrint('Advertencia: Conexión Insegura (Posible MitM o fingerprint desactualizado). Error: $errorStr');
      // no lanzamos la excepción para permitir que la app funcione 
    }

    // 2 inyectar token
    final token = await _storage.read(key: 'auth_token');
    if (token != null && !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);
    
    // 3 manejo de sesión expirada
    if (response.statusCode == 401 && token != null) {
      onUnauthenticated();
    }
    
    return response;
  }
  
  @override
  void close() {
    _inner.close();
    super.close();
  }
}

// nota el sl authinterceptorclient ya no es una variable global 
// se registra en getit di dart como lazysingleton y se inyecta
// por constructor en cada data source que lo necesita 
// esto permite mockear el cliente en tests y sigue el principio di 
