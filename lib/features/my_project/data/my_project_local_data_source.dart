import 'dart:convert';
import 'package:mobile/core/services/secure_storage_service.dart';

class MyProjectLocalDataSource {
  final SecureStorageService _storage;

  MyProjectLocalDataSource() : _storage = SecureStorageService();

  String _getKey(String userId) => 'detailed_analysis_$userId';

  Future<void> saveDetailedAnalysis(String userId, Map<String, dynamic> data) async {
    try {
      final jsonString = json.encode(data);
      await _storage.write(key: _getKey(userId), value: jsonString);
    } catch (e) {
      print('Error saving detailed analysis to secure storage: $e');
    }
  }

  Future<Map<String, dynamic>?> getDetailedAnalysis(String userId) async {
    try {
      final jsonString = await _storage.read(key: _getKey(userId));
      if (jsonString != null) {
        return json.decode(jsonString);
      }
    } catch (e) {
      print('Error reading detailed analysis from secure storage: $e');
    }
    return null;
  }

  Future<void> clearDetailedAnalysis(String userId) async {
    try {
      await _storage.delete(key: _getKey(userId));
    } catch (e) {
      print('Error deleting detailed analysis from secure storage: $e');
    }
  }
}
