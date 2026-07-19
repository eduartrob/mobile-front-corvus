import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/core/network/api_config.dart';

abstract class SyncRemoteDataSource {
  Future<Map<String, dynamic>> processFolder(String folderId, String accessToken, String jwtToken, String userId);
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken);
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  @override
  Future<Map<String, dynamic>> processFolder(String folderId, String accessToken, String jwtToken, String userId) async {
    try {
      final response = await apiClient.post(
        Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorProcessFolder}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'folder_id': folderId,
          'access_token': accessToken,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 202 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'sync_skipped': body['sync_skipped'] ?? false,
        };
      } else {
        var error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        if (error is Map) {
          error = error['message'] ?? error['detail'] ?? error.toString();
        }
        throw Exception(error.toString());
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken) async {
    try {
      final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
        'q': "mimeType='application/vnd.google-apps.folder' and trashed=false",
        'fields': "files(id,name,owners)",
      });

      final response = await apiClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;
        return files.map((f) {
          final owners = f['owners'] as List?;
          final isMine = owners != null && owners.isNotEmpty ? (owners[0]['me'] == true) : true;
          return {
            'id': f['id'],
            'name': f['name'],
            'sharedWithMe': !isMine,
          };
        }).toList();
      } else {
        final bodyText = response.body;
        var error = 'Error al obtener carpetas de Drive: ${response.statusCode}';
        try {
            final errJson = jsonDecode(bodyText);
            error = errJson['error']?['message'] ?? errJson['error'] ?? error;
        } catch (_) {}
        throw Exception(error);
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }
}
