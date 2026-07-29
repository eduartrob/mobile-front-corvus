import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/providers/auth_provider.dart';
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

  final Map<String, DashboardEntity> _cache = {};
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
    final String pId = projectId ?? 'default';

    if (_currentProjectId != projectId) {
      _currentProjectId = projectId;
      _errorMessage = null;
      _isLoading = true;

      // 1. Carga optimista desde memoria RAM (Caché instantáneo)
      if (_cache.containsKey(pId)) {
        _dashboardData = _cache[pId];
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners(); // Mostrar loading mientras revisamos SharedPreferences
      }

      // 2. Carga optimista desde SharedPreferences (Caché persistente)
      try {
        // Pequeño retraso de 350ms para asegurar que la animación de la página terminó antes de bloquear el hilo
        await Future.delayed(const Duration(milliseconds: 350));
        
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString('prof_dashboard_$pId');
        if (cachedData != null) {
          final decoded = json.decode(cachedData);
          final entity = DashboardEntity.fromJson(decoded);
          _cache[pId] = entity;
          if (_currentProjectId == projectId) {
            _dashboardData = entity;
            _isLoading = false;
            notifyListeners();
          }
        }
      } catch (_) {}
    }

    // 3. Petición silenciosa al servidor (Background Fetch)
    try {
      final newData = await _repository.loadDashboardStats(
        projectId: projectId,
        token: _authProvider.currentUser?.token,
      );
      
      _cache[pId] = newData;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('prof_dashboard_$pId', json.encode(newData.toJson()));
      } catch (_) {}

      if (_currentProjectId == projectId) {
        _dashboardData = newData;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (_currentProjectId == projectId) {
        // Solo mostrar el error si no hay datos en caché, de lo contrario lo ignoramos silenciosamente
        if (_dashboardData == null) {
          _errorMessage = 'Error de conexión: $e';
        }
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}