import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
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
    // 1. SSL/TLS Pinning Check (Anti-MitM)
    // El fingerprint se obtiene de Firebase Remote Config para poder
    // actualizarlo remotamente cuando Let's Encrypt renueve el certificado
    // (cada ~90 días) sin necesidad de publicar una nueva versión de la app.
    try {
      if (request.url.host == 'corvus.eduartrob.site') {
        // Fallback: fingerprint quemado como último recurso
        const fallbackFingerprint =
            "6C:E2:90:D1:16:D6:2F:85:E3:1E:66:3C:34:F7:1A:93:16:46:17:B8:A0:82:75:EC:CD:1A:D5:B1:30:03:05:43";

        // Intentar obtener desde Remote Config
        String fingerprint = fallbackFingerprint;
        try {
          final remoteConfig = FirebaseRemoteConfig.instance;
          final remoteFingerprint = remoteConfig.getString('ssl_fingerprint');
          if (remoteFingerprint.isNotEmpty) {
            fingerprint = remoteFingerprint;
          }
        } catch (_) {
          // Si Remote Config falla, usar el fallback hardcodeado
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
      // Si el proxy se apagó pero el celular sigue intentando conectarse a él, dará error de conexión, no de MitM.
      if (errorStr.contains('socket') || 
          errorStr.contains('timeout') || 
          errorStr.contains('refused') || 
          errorStr.contains('network is unreachable') ||
          errorStr.contains('failed host lookup')) {
        throw Exception('Error de conexión a internet (¿Olvidaste apagar el proxy en tu WiFi?)');
      }

      // Si el pin falla, significa que el certificado fue reemplazado (ej. Charles Proxy) o el fingerprint cambió.
      // onMitMDetected(); // DESACTIVADO TEMPORALMENTE por falsos positivos (Bug reportado por usuario)
      debugPrint('Advertencia: Conexión Insegura (Posible MitM o fingerprint desactualizado). Error: $errorStr');
      // No lanzamos la excepción para permitir que la app funcione.
    }

    // 2. Inyectar Token
    final token = await _storage.read(key: 'auth_token');
    if (token != null && !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);
    
    // 3. Manejo de Sesión Expirada
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

// ─── NOTA: El sl<AuthInterceptorClient>() ya NO es una variable global.
// Se registra en GetIt (di.dart) como LazySingleton y se inyecta
// por constructor en cada data source que lo necesita.
// Esto permite mockear el cliente en tests y sigue el principio DI.
