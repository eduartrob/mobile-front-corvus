class ApiConfig {
  static const String apiGatewayUrl = 'https://corvus.eduartrob.site/api/v1';
  
//  static const String apiGatewayUrl = 'https://corvus.eduartrob.site:8443/api/v1';

  static const String authGoogleEndpoint = '/auth/google';
  
  static const Duration connectionTimeout = Duration(seconds: 120);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
