import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LinkedFoldersProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'corvus_linked_folders';

  List<Map<String, String>> _folders = [];

  List<Map<String, String>> get folders => _folders;

  LinkedFoldersProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> loadFolders() async {
    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _folders = decoded.map((e) => Map<String, String>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading linked folders: $e');
    }
  }

  Future<void> addFolder(String id, String name) async {
    // Evitar duplicados
    if (!_folders.any((f) => f['id'] == id)) {
      _folders.add({'id': id, 'name': name});
      await _saveFolders();
      notifyListeners();
    }
  }

  Future<void> removeFolder(String id) async {
    _folders.removeWhere((f) => f['id'] == id);
    await _saveFolders();
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
