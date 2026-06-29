class ApiConfig {
  static const String apiGatewayUrl = 'https://corvus.eduartrob.site/api/v1';
  
  static const String authGoogleEndpoint = '/auth/google';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
