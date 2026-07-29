import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_dash/data/models/prof_directory_model.dart';
import 'package:mobile/core/providers/auth_provider.dart';

class ProfDirectoryProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final http.Client client;
  final String projectId;

  // caché estático en ram para sobrevivir a la recreación del provider al cambiar de página
  static final Map<String, ProfDirectoryModel> _cache = {};

  ProfDirectoryModel? _directoryData;
  bool _isLoading = false;
  String? _errorMessage;

  ProfDirectoryProvider({required this.authProvider, required this.projectId, http.Client? client}) 
      : client = client ?? http.Client();

  ProfDirectoryModel? get directoryData => _directoryData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDirectory() async {
    if (authProvider.role?.toUpperCase() != 'PROFESOR' && authProvider.role?.toUpperCase() != 'DOCENTE') {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    // 1 carga optimista desde memoria ram
    if (_cache.containsKey(projectId)) {
      _directoryData = _cache[projectId];
      _isLoading = false;
      notifyListeners();
    } else {
      notifyListeners();
    }

    // 2 carga optimista desde sharedpreferences
    try {
      // pequeño retraso de 350ms para asegurar que la animación de la página terminó antes de bloquear el hilo
      await Future.delayed(const Duration(milliseconds: 350));
      
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('prof_directory_$projectId');
      if (cachedStr != null) {
        final decoded = json.decode(cachedStr);
        final model = ProfDirectoryModel.fromJson(decoded);
        _cache[projectId] = model;
        _directoryData = model;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    // 3 petición silenciosa al servidor background fetch 
    try {
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsProfDirectory}?project_id=$projectId');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      
      final token = authProvider.currentUser?.token;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        final newData = ProfDirectoryModel.fromJson(decodedData);
        
        _cache[projectId] = newData;
        _directoryData = newData;
        _errorMessage = null;

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prof_directory_$projectId', json.encode(newData.toJson()));
        } catch (_) {}

      } else {
        if (_directoryData == null) {
          _errorMessage = 'Error al cargar el directorio (Código ${response.statusCode})';
        }
      }
    } catch (e) {
      if (_directoryData == null) {
        _errorMessage = 'Error de conexión: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
