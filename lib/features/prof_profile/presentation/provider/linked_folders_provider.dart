import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';

class LinkedFoldersProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'corvus_linked_folders';

  List<Map<String, String>> _folders = [];

  List<Map<String, String>> get folders => _folders;

  LinkedFoldersProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> loadFolders(String jwtToken) async {
    // 1. Cargar caché local primero para respuesta inmediata
    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _folders = decoded.map((e) => Map<String, String>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading linked folders from cache: $e');
    }

    // 2. Obtener estado real del backend
    try {
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/folders');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $jwtToken',
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> backendFolders = jsonDecode(response.body);
        _folders = backendFolders.map((e) => {
          'id': e['folder_id'].toString(),
          'name': e['folder_name'].toString(),
        }).toList();
        await _saveFolders();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching folders from backend: $e');
    }
  }

  Future<void> addFolder(String id, String name, String jwtToken) async {
    // Evitar duplicados
    if (!_folders.any((f) => f['id'] == id)) {
      _folders.add({'id': id, 'name': name});
      await _saveFolders();
      notifyListeners();

      // Guardar en el backend
      try {
        final url = Uri.parse('${ApiConfig.apiGatewayUrl}/auth/folders');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
          body: jsonEncode({
            'folder_id': id,
            'folder_name': name,
          }),
        );
      } catch (e) {
        debugPrint('Error saving folder to backend: $e');
      }
    }
  }

  Future<void> removeFolder(String id) async {
    _folders.removeWhere((f) => f['id'] == id);
    await _saveFolders();
    notifyListeners();
  }

  Future<void> clearFolders() async {
    _folders.clear();
    await _storage.delete(key: _storageKey);
    notifyListeners();
  }

  Future<void> _saveFolders() async {
    try {
      final data = jsonEncode(_folders);
      await _storage.write(key: _storageKey, value: data);
    } catch (e) {
      debugPrint('Error saving linked folders: $e');
    }
  }
}
