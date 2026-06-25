import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

abstract class SyncRemoteDataSource {
  Future<Map<String, dynamic>> processFolder(String folderId, String accessToken, String jwtToken);
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken);
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  @override
  Future<Map<String, dynamic>> processFolder(String folderId, String accessToken, String jwtToken) async {
    try {
      final response = await http.post(
        Uri.parse('http://107.23.55.129:3000/api/v1/clustering/integrator/process-folder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'folder_id': folderId,
          'access_token': accessToken,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 202 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'sync_skipped': body['sync_skipped'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Fallo al iniciar sincronización: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken) async {
    try {
      // DEBUG: verificar que el token no sea null/vacío
      print('🔑 [DRIVE] accessToken length: ${accessToken.length}');
      print('🔑 [DRIVE] accessToken prefix: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');

      final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
        'q': "mimeType='application/vnd.google-apps.folder' and trashed=false",
        'fields': "files(id,name,owners)",
      });
      print('🌐 [DRIVE] URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 [DRIVE] Status: ${response.statusCode}');
      print('📡 [DRIVE] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;
        print('📁 [DRIVE] Folders found: ${files.length}');
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
        throw Exception('Error al obtener carpetas de Drive: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [DRIVE] Error: $e');
      throw Exception('Fallo al conectar con Google Drive: $e');
    }
  }
}
