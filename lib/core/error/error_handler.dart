import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/error/app_exception.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Convierte cualquier excepción (nativa o [AppException]) en un mensaje
/// amigable para el usuario final, en español.
///
/// Uso en providers:
/// ```dart
/// } on AppException catch (e) {
///   _error = mapErrorToMessage(e, l10n: l10n);
/// } catch (e, st) {
///   _error = mapErrorToMessage(e, l10n: l10n, stackTrace: st);
/// }
/// ```
String mapErrorToMessage(
  Object error, {
  AppLocalizations? l10n,
  StackTrace? stackTrace,
}) {
  // Loguear detalles técnicos en debug (nunca en producción al usuario)
  if (kDebugMode) {
    debugPrint('🔴 Error capturado: $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  // 1. Nuestras excepciones tipadas — retornan el mensaje directamente
  if (error is AppException) {
    return error.userFacingMessage(l10n);
  }

  // 2. Excepciones de red del SDK de Dart/Flutter
  if (error is SocketException) {
    return l10n?.networkError ??
        'Problema de conexión a internet. Verifica tu red e inténtalo de nuevo.';
  }

  if (error is TimeoutException) {
    return l10n?.networkError ??
        'La petición tardó demasiado. Verifica tu conexión e inténtalo de nuevo.';
  }

  if (error is HandshakeException) {
    return 'Error de seguridad en la conexión. Contacta a soporte si persiste.';
  }

  if (error is FormatException) {
    return l10n?.serverErrorContactSupport ??
        'Error al procesar la respuesta del servidor. Por favor reintenta.';
  }

  // 3. Excepciones genéricas de Dart — limpiar el prefijo "Exception: "
  final rawMessage = error.toString();
  final cleaned = rawMessage
      .replaceAll('Exception: ', '')
      .replaceAll('Exception:', '')
      .trim();

  // Si el mensaje parece amigable (no es un StackTrace ni mensaje técnico),
  // lo devolvemos limpio; de lo contrario, usamos el fallback genérico.
  final isTechnical = cleaned.contains('SocketException') ||
      cleaned.contains('HttpException') ||
      cleaned.contains('FormatException') ||
      cleaned.contains('type \'') ||
      cleaned.contains('#0') || // inicio de stack trace
      cleaned.startsWith('{') || // JSON crudo
      cleaned.startsWith('<'); // HTML crudo (ej. página de error del servidor)

  if (isTechnical) {
    return l10n?.serverErrorContactSupport ??
        'Ocurrió un inconveniente temporal. Por favor reintenta en un momento.';
  }

  // Si el mensaje es legible (vino del backend como string amigable),
  // lo devolvemos tal cual — es lo que el backend quería mostrar.
  return cleaned.isNotEmpty
      ? cleaned
      : (l10n?.serverErrorContactSupport ??
          'Ocurrió un error inesperado. Por favor reintenta.');
}

/// Lanza la [AppException] correcta a partir de un error HTTP nativo.
/// Usar en data sources para normalizar errores de la capa de datos.
AppException mapHttpError(int statusCode, String? body) {
  // Intentar extraer el mensaje del body del backend si es JSON
  String? backendMessage;
  if (body != null && body.isNotEmpty) {
    try {
      // Buscar patrones comunes de error: { "message": "..." } o { "error": "..." }
      final msgMatch = RegExp(r'"(?:message|error|msg)"\s*:\s*"([^"]+)"')
          .firstMatch(body);
      if (msgMatch != null) {
        backendMessage = msgMatch.group(1);
      }
    } catch (_) {}
  }

  switch (statusCode) {
    case 401:
      return const ServerException(401);
    case 403:
      return const ServerException(403);
    case 404:
      return const ServerException(404);
    case 409:
      return ServerException(409, backendMessage);
    case 413:
      return const ServerException(413);
    case 422:
      return ServerException(422, backendMessage);
    case 429:
      return const ServerException(429);
    default:
      if (statusCode >= 500) return ServerException(statusCode, backendMessage);
      if (backendMessage != null) return ValidationException(backendMessage);
      return ServerException(statusCode);
  }
}
