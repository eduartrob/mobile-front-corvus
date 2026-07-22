import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiGatewayUrl => dotenv.env['API_GATEWAY_URL'] ?? 'https://corvus.eduartrob.site/api/v1';

  static const String authGoogleEndpoint = '/auth/google';
  
  static const Duration connectionTimeout = Duration(seconds: 120);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cloudinary constants
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'zpqp1swt';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'corvus_unsigned';
}
