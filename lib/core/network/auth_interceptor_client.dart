import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final VoidCallback onUnauthenticated;
  final FlutterSecureStorage _storage;

  AuthInterceptorClient({
    http.Client? client,
    required this.onUnauthenticated,
    FlutterSecureStorage? storage,
  })  : _inner = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // leer token
    final token = await _storage.read(key: 'auth_token');
    if (token != null && !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);
    
    // si da 401 expiro
    if (response.statusCode == 401) {
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

// Cliente global que intercepta el 401 para hacer logout
final apiClient = AuthInterceptorClient(
  onUnauthenticated: () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Desconecta al usuario usando la instancia real del Provider
      try {
        Provider.of<AuthProvider>(context, listen: false).logout();
      } catch (e) {
        debugPrint('Error durante el logout interceptado: $e');
      }
    } else {
      // Si no hay contexto, al menos intentamos usar el sl como fallback
      try {
        sl<AuthProvider>().logout();
      } catch (_) {}
    }
  },
);
