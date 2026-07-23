/// Jerarquía de excepciones tipadas de la app.
/// Cada tipo mapea a un mensaje amigable para el usuario final.
/// Los data sources lanzan estas excepciones; los providers las capturan.
library;

import 'package:mobile/l10n/app_localizations.dart';

sealed class AppException implements Exception {
  final String? technicalDetail;
  const AppException([this.technicalDetail]);

  /// Retorna el mensaje que el usuario debe ver.
  /// Si no hay contexto/l10n disponible, usa el fallback en español.
  String userFacingMessage([AppLocalizations? l10n]) => _fallback;

  String get _fallback =>
      'Ocurrió un error inesperado. Por favor reintenta.';

  @override
  String toString() => '${runtimeType.toString()}: $technicalDetail';
}

/// Error de red — sin conexión, timeout de socket, DNS, etc.
class NetworkException extends AppException {
  const NetworkException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.networkError ??
      'Problema de conexión a internet. Verifica tu red e inténtalo de nuevo.';
}

/// Error de timeout — la petición tardó demasiado.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.networkError ??
      'La petición tardó demasiado. Verifica tu conexión e inténtalo de nuevo.';
}

/// Error del servidor — respuesta HTTP con código de error.
class ServerException extends AppException {
  final int statusCode;
  const ServerException(this.statusCode, [super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) {
    switch (statusCode) {
      case 401:
        return l10n?.sessionExpired ??
            'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.';
      case 403:
        return l10n?.forbiddenAction ??
            'No tienes permiso para realizar esta acción.';
      case 404:
        return l10n?.resourceNotFound ??
            'El recurso solicitado no fue encontrado.';
      case 409:
        return technicalDetail ?? 'Ya existe un conflicto con esta operación.';
      case 413:
        return l10n?.fileTooLarge ??
            'El archivo excede el tamaño máximo permitido.';
      case 422:
        return technicalDetail ?? 'Los datos enviados no son válidos.';
      case 429:
        return l10n?.tooManyRequests ??
            'Demasiadas solicitudes. Espera un momento e intenta de nuevo.';
      case 500:
      case 502:
      case 503:
        return l10n?.serverErrorContactSupport(l10n?.supportEmail ?? '') ??
            'Ocurrió un inconveniente en el servidor. Por favor reintenta.';
      default:
        return l10n?.serverErrorContactSupport(l10n?.supportEmail ?? '') ??
            'Ocurrió un error inesperado. Por favor reintenta.';
    }
  }
}

/// Error de parseo — el JSON o formato de respuesta no es el esperado.
class ParseException extends AppException {
  const ParseException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.serverErrorContactSupport(l10n?.supportEmail ?? '') ??
      'Error al procesar la respuesta del servidor. Por favor reintenta.';
}

/// Error de validación — el backend rechazó los datos con un mensaje legible.
/// [userMessage] ya es un string listo para mostrar al usuario.
class ValidationException extends AppException {
  final String userMessage;
  const ValidationException(this.userMessage) : super(userMessage);

  @override
  String userFacingMessage([AppLocalizations? l10n]) => userMessage;
}

/// Error de tipo de archivo no soportado.
class UnsupportedFileTypeException extends AppException {
  const UnsupportedFileTypeException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.unsupportedFileType ?? 'Tipo de archivo no soportado.';
}

/// Error de seguridad — MitM detectado.
class SecurityException extends AppException {
  const SecurityException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.securityAlert ??
      'Alerta de Seguridad: Se detectó una conexión insegura. '
      'Por tu seguridad, la operación fue bloqueada.';
}

/// Error de autenticación de terceros (Google, Drive).
class AuthException extends AppException {
  const AuthException([super.technicalDetail]);

  @override
  String userFacingMessage([AppLocalizations? l10n]) =>
      l10n?.errorCredentialsDriveCorvus ??
      'Error al autenticar. Por favor, vuelve a iniciar sesión.';
}
