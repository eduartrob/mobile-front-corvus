import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/core/network/api_config.dart';

class ProfRulesRemoteDataSource {
  final http.Client client;
  final SecureStorageService _storage = SecureStorageService();

  ProfRulesRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> getConfig({bool forceRefresh = false, String? projectId}) async {
    final String pId = projectId ?? 'default';
    final cacheKey = 'cached_prof_config_$pId';
    final etagKey = 'etag_prof_config_$pId';

    if (!forceRefresh) {
      final cached = await _storage.read(key: cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }

    final urlStr = projectId != null
      ? '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}?projectId=$projectId'
      : '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}';
    final url = Uri.parse(urlStr);
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

  Future<Map<String, dynamic>> getClusterStats({bool forceRefresh = false, String? projectId}) async {
    final String pId = projectId ?? 'default';
    final cacheKey = 'cached_cluster_stats_$pId';
    if (!forceRefresh) {
      final cached = await _storage.read(key: cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }

    final urlStr = projectId != null
      ? '${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/clusters-stats?projectId=$projectId'
      : '${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/clusters-stats';
    final url = Uri.parse(urlStr);
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

  Future<void> updateConfig(List<String> allowedExtensions, String llmProvider, String driveFolderId, List<String> exclusionRules, List<Map<String, dynamic>> projectSections, int minTeamMembers, int maxTeamMembers, {String? authorName, String? authorPhotoUrl, String? authorId, String? projectId}) async {
    final urlStr = projectId != null
      ? '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}?projectId=$projectId'
      : '${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}';
    final url = Uri.parse(urlStr);
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);



      final body = json.encode({
        "allowed_extensions": allowedExtensions,
        "llm_provider": llmProvider,
        "drive_folder_id": driveFolderId,
        "exclusion_rules": exclusionRules,
        "project_sections": projectSections,
        "min_team_members": minTeamMembers,
        "max_team_members": maxTeamMembers,
        if (authorName != null) "authorName": authorName,
        if (authorPhotoUrl != null) "authorPhotoUrl": authorPhotoUrl,
        if (authorId != null) "authorId": authorId,
      });

      final response = await client.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        String msg = 'Failed to update config: ${response.statusCode}';
        try {
          final resBody = json.decode(utf8.decode(response.bodyBytes));
          if (resBody['detail'] != null) {
            msg = resBody['detail'].toString();
          } else if (resBody['message'] != null) {
            msg = resBody['message'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception('Error updating config: $e');
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
