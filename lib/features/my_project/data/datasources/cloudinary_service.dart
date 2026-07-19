import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class CloudinaryService {
  static Future<String?> uploadFile(String filePath, {String resourceType = 'auto', String? folder}) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/${ApiConfig.cloudinaryCloudName}/$resourceType/upload');
      
      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = ApiConfig.cloudinaryUploadPreset;
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['secure_url'] as String?;
      } else {
        throw Exception('Cloudinary upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Cloudinary upload error: $e');
    }
  }
}
