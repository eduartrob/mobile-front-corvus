import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/prof_dash/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/prof_dash/domain/repositories/dashboard_repository.dart';

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

  Future<void> loadDashboardStats({String? projectId}) async {
    final role = _authProvider.role?.toUpperCase();
    if (role != 'PROFESOR' && role != 'DOCENTE') {
      return;
    }

    if (_currentProjectId != projectId) {
      _dashboardData = null;
      _currentProjectId = projectId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _repository.loadDashboardStats(
        projectId: projectId,
        token: _authProvider.currentUser?.token,
      );
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}