import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_dash/data/models/prof_directory_model.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class ProfDirectoryProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final http.Client client;

  ProfDirectoryModel? _directoryData;
  bool _isLoading = false;
  String? _errorMessage;

  ProfDirectoryProvider({required this.authProvider, http.Client? client}) 
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
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/prof/directory');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      
      final token = authProvider.currentUser?.token;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        _directoryData = ProfDirectoryModel.fromJson(decodedData);
      } else {
        _errorMessage = 'Error al cargar el directorio (Código ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
