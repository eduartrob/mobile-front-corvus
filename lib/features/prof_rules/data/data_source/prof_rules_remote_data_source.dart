import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/network/api_config.dart';

class ProfRulesRemoteDataSource {
  final http.Client client;
  final SecureStorageService _storage = SecureStorageService();

  ProfRulesRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> getConfig({bool forceRefresh = false}) async {
    final cacheKey = 'cached_prof_config';
    final etagKey = 'etag_prof_config';

    if (!forceRefresh) {
      final cached = await _storage.read(key: cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }

    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/config');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      final etag = await _storage.read(key: etagKey);
      if (etag != null) {
        headers['If-None-Match'] = etag;
      }

      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 304) {
        final cached = await _storage.read(key: cacheKey);
        if (cached != null) return json.decode(cached);
      } else if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        await _storage.write(key: cacheKey, value: bodyText);
        final newEtag = response.headers['etag'];
        if (newEtag != null) {
          await _storage.write(key: etagKey, value: newEtag);
        }
        return json.decode(bodyText);
      }
      throw Exception('Failed to load config: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading config: $e');
    }
  }

  Future<Map<String, dynamic>> getClusterStats({bool forceRefresh = false}) async {
    final cacheKey = 'cached_cluster_stats';
    if (!forceRefresh) {
      final cached = await _storage.read(key: cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }

    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/clusters-stats');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        await _storage.write(key: cacheKey, value: bodyText);
        return json.decode(bodyText);
      }
      throw Exception('Failed to load cluster stats: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading cluster stats: $e');
    }
  }

  Future<void> updateConfig(List<String> allowedExtensions, String llmProvider, String driveFolderId, List<String> exclusionRules, List<Map<String, dynamic>> projectSections, {String? authorName, String? authorPhotoUrl}) async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/config');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      final body = json.encode({
        "allowed_extensions": allowedExtensions,
        "llm_provider": llmProvider,
        "drive_folder_id": driveFolderId,
        "exclusion_rules": exclusionRules,
        "project_sections": projectSections,
        if (authorName != null) "authorName": authorName,
        if (authorPhotoUrl != null) "authorPhotoUrl": authorPhotoUrl,
      });

      final response = await client.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to update config: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating config: $e');
    }
  }

  Future<List<Map<String, dynamic>>> generateSectionsWithAI() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/generate-sections');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      final response = await client.post(url, headers: headers).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data['sections'] ?? []);
      }
      throw Exception('Failed to generate sections: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error generating sections: $e');
    }
  }

  Future<void> notifyRulesUpdate() async {
    final url = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/notify-rules');
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      await client.post(url, headers: headers).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Ignorar errores en notificación
    }
  }
}
