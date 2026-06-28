import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/services/notification_service.dart';

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
        
        final updatedFolders = backendFolders.map((e) {
          final id = e['folder_id'].toString();
          final name = e['folder_name'].toString();
          
          final localFolder = _folders.firstWhere((f) => f['id'] == id, orElse: () => {});
          String status = localFolder['status'] ?? 'synced';
          
          return {
            'id': id,
            'name': name,
            'status': status,
          };
        }).toList();
        
        _folders = updatedFolders;
        await _saveFolders();
        notifyListeners();
        
        for (final folder in _folders) {
          if (folder['status'] == 'syncing') {
            _checkStatusOnceOrResume(folder['id']!, jwtToken);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching folders from backend: $e');
    }
  }

  Future<void> addFolder(String id, String name, String jwtToken, {bool isSynced = false}) async {
    // Evitar duplicados
    if (!_folders.any((f) => f['id'] == id)) {
      _folders.add({'id': id, 'name': name, 'status': isSynced ? 'synced' : 'syncing'});
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
      
      if (!isSynced) {
        // Iniciar el polling en background solo si se está sincronizando
        _startPollingLoop(id, jwtToken);
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

  Future<void> markAsSynced(String id) async {
    final index = _folders.indexWhere((f) => f['id'] == id);
    if (index != -1) {
      _folders[index]['status'] = 'synced';
      await _saveFolders();
      notifyListeners();
    }
  }

  Future<void> _saveFolders() async {
    try {
      final data = jsonEncode(_folders);
      await _storage.write(key: _storageKey, value: data);
    } catch (e) {
      debugPrint('Error saving linked folders: $e');
    }
  }

  Future<void> _checkStatusOnceOrResume(String id, String jwtToken) async {
    try {
      final statusUrl = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/sync-status/$id');
      final response = await http.get(statusUrl, headers: {
        'Authorization': 'Bearer $jwtToken',
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progress = data['progress'] as int? ?? 0;
        final total = data['total'] as int? ?? 1;
        
        if (progress >= total && total > 0) {
          // Ya terminó mientras la app estaba cerrada. 
          // Omitimos notificacion local porque FCM ya debió haberla enviado.
          await markAsSynced(id);
        } else {
          _startPollingLoop(id, jwtToken);
        }
      } else if (response.statusCode == 404) {
         await markAsSynced(id);
      }
    } catch (e) {
      debugPrint('Error checking status on load: $e');
    }
  }

  void _startPollingLoop(String id, String jwtToken) async {
    bool isSyncing = true;
    while (isSyncing) {
      final currentFolder = _folders.firstWhere((f) => f['id'] == id, orElse: () => {});
      if (currentFolder.isEmpty || currentFolder['status'] != 'syncing') {
        break; // Detener si se eliminó o ya se marcó como synced
      }
      
      try {
        final statusUrl = Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/sync-status/$id');
        final response = await http.get(statusUrl, headers: {
          'Authorization': 'Bearer $jwtToken',
        });
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final progress = data['progress'] as int? ?? 0;
          final total = data['total'] as int? ?? 1;
          final msg = data['message'] ?? 'Procesando...';
          
          NotificationService().showProgressNotification(
            progress: progress,
            maxProgress: total,
            title: 'Sincronización de Archivos',
            message: msg,
          );
          
          if (progress >= total && total > 0) {
            isSyncing = false;
            await markAsSynced(id);
            // Nota: NO enviamos showSuccessNotification aquí,
            // ya que Firebase (FCM) enviará la notificación final a main.dart.
          }
        } else if (response.statusCode == 404) {
          isSyncing = false;
          await markAsSynced(id);
        }
      } catch (e) {
        debugPrint('Error en polling loop: $e');
      }
      
      if (isSyncing) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }
}
