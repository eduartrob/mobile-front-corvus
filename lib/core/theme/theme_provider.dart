import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  static const _storageKey = 'app_theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    try {
      final savedTheme = await _storage.read(key: _storageKey);
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    try {
      if (mode == ThemeMode.light) {
        await _storage.write(key: _storageKey, value: 'light');
      } else if (mode == ThemeMode.dark) {
        await _storage.write(key: _storageKey, value: 'dark');
      } else {
        await _storage.delete(key: _storageKey);
      }
    } catch (e) {
    }
  }
}
