import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
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
    try {
      // Validamos el host destino si es nuestro servidor principal
      if (request.url.host == 'corvus.eduartrob.site') {
        await HttpCertificatePinning.check(
          serverURL: 'https://corvus.eduartrob.site',
          headerHttp: {},
          sha: SHA.SHA256,
          allowedSHAFingerprints: [
            "6C:E2:90:D1:16:D6:2F:85:E3:1E:66:3C:34:F7:1A:93:16:46:17:B8:A0:82:75:EC:CD:1A:D5:B1:30:03:05:43"
          ],
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

      // Si el pin falla, significa que el certificado fue reemplazado (ej. Charles Proxy)
      onMitMDetected();
      throw Exception('Conexión Insegura (Posible ataque MitM detectado). Abortando petición.');
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

// Cliente global que intercepta el 401 para hacer logout y previene ataques MitM
final apiClient = AuthInterceptorClient(
  onUnauthenticated: () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.sessionExpired ?? 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      // redirigir al login
      context.go('/login');
      
      // Desconecta al usuario usando la instancia real del Provider
      try {
        Provider.of<AuthProvider>(context, listen: false).logout();
      } catch (e) {
        debugPrint('Error durante el logout interceptado: $e');
      }
      // Si no hay contexto, al menos intentamos usar el sl como fallback
      try {
        sl<AuthProvider>().logout();
      } catch (_) {}
    }
  },
  onMitMDetected: () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alerta de Seguridad Crítica Se ha detectado una conexión insegura. Por su seguridad, la conexión ha sido bloqueada inmediatamente.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 8),
        ),
      );
    }
  },
);
