class ApiConfig {
  // URLs de los microservicios / API Gateway
  // Cambiar localhost a 10.0.2.2 si corres en emulador Android
  // o a tu IP real de tu máquina (por ejemplo 192.168.x.x) si pruebas en un dispositivo físico.
  static const String apiGatewayUrl = 'http://207.180.215.71:3000/api/v1';
  
  // Auth Endpoints
  static const String authGoogleEndpoint = '/auth/google';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Headers comunes
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
