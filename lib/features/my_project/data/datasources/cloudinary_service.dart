import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class CloudinaryService {
  static Future<String?> uploadFile(String filePath, {String resourceType = 'auto'}) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/${ApiConfig.cloudinaryCloudName}/$resourceType/upload');
      
      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = ApiConfig.cloudinaryUploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
