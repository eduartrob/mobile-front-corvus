import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_dash/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/prof_dash/domain/repositories/dashboard_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';

class ProfDashboardProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final DashboardRepository _repository;

  ProfDashboardProvider({
    required AuthProvider authProvider,
    required DashboardRepository repository,
  })  : _authProvider = authProvider,
        _repository = repository;

  DashboardEntity? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentProjectId;

  DashboardEntity? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clear() {
    _dashboardData = null;
    _currentProjectId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDashboardStats({String? projectId}) async {
    if (_currentProjectId != projectId) {
      _dashboardData = null;
      _currentProjectId = projectId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _repository.loadDashboardStats(
        projectId: projectId,
        token: _authProvider.currentUser?.token,
      );

      int withTeam = stats.studentsWithTeam;
      int withoutTeam = stats.studentsWithoutTeam;

      // Fallback: si conEquipo/sinEquipo vienen en 0 y hay projectId, consultar el directorio para calcular exacto
      if ((withTeam == 0 && withoutTeam == 0) && projectId != null && projectId.isNotEmpty) {
        try {
          final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.teamsProfDirectory}?project_id=$projectId');
          final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
          final token = _authProvider.currentUser?.token;
          if (token != null) headers['Authorization'] = 'Bearer $token';

          final resp = await http.get(url, headers: headers).timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200) {
            final dirData = json.decode(utf8.decode(resp.bodyBytes));
            final teams = dirData['teams'] as List? ?? [];
            final unassigned = dirData['studentsWithoutTeam'] ??
                dirData['students_without_team'] ??
                dirData['unassigned_students'] ??
                dirData['unassigned'] ??
                [];

            int calculatedWithTeam = 0;
            for (var t in teams) {
              if (t is Map) {
                final members = t['members'] as List? ?? [];
                calculatedWithTeam += members.length;
              }
            }

            if (calculatedWithTeam > 0) withTeam = calculatedWithTeam;
            if (unassigned is List) withoutTeam = unassigned.length;
          }
        } catch (e) {
          debugPrint('Error fetching directory fallback metrics: $e');
        }
      }

      _dashboardData = DashboardEntity(
        totalTeams: stats.totalTeams,
        readyProposals: stats.readyProposals,
        studentsWithTeam: withTeam,
        studentsWithoutTeam: withoutTeam,
        alerts: stats.alerts,
      );
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}