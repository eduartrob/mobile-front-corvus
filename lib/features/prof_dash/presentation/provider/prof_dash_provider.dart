import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/prof_dash/data/models/prof_dashboard_model.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class ProfDashboardProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final http.Client client;

  ProfDashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastProjectId;

  ProfDashboardProvider({required this.authProvider, http.Client? client}) 
      : client = client ?? http.Client();

  ProfDashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardStats({String? projectId}) async {
    if (projectId != null && projectId != _lastProjectId) {
      _dashboardData = null;
      _lastProjectId = projectId;
    }

    if (authProvider.role?.toUpperCase() != 'PROFESOR' && authProvider.role?.toUpperCase() != 'DOCENTE') {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final urlStr = projectId != null 
        ? '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsDashboard}?projectId=$projectId'
        : '${ApiConfig.apiGatewayUrl}${ApiEndpoints.professorsDashboard}';
      final url = Uri.parse(urlStr);
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      
      final token = authProvider.currentUser?.token;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await client.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        _dashboardData = ProfDashboardModel.fromJson(decodedData);
      } else {
        _errorMessage = 'Error al cargar el dashboard (Código ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
