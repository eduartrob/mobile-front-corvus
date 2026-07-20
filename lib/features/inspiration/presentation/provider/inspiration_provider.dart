import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/data/data_source/inspiration_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'dart:async';

class InspirationProvider extends ChangeNotifier {
  final InspirationRemoteDataSource _dataSource;
  
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  List<ProjectEntity> _projects = [];
  List<ProjectEntity> get projects => _projects;
  
  // Timer for auto-refresh
  Timer? _refreshTimer;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 1;
  static const int _limit = 10;

  bool _showWelcome = true;
  bool get showWelcome => _showWelcome;

  InspirationProvider({InspirationRemoteDataSource? dataSource}) 
      : _dataSource = dataSource ?? InspirationRemoteDataSource(client: apiClient) {
    _init();
  }

  Future<void> _init() async {
    await checkWelcomeStatus();
    // Siempre forzar recarga del servidor al iniciar:
    // el TTL del cache en InspirationRemoteDataSource controla si realmente
    // hace la petición de red o usa el cache local (≤ 30 min).
    await loadProjects(forceRefresh: true);
  }

  String? _userId;

  void setUserId(String? userId) {
    _userId = userId;
  }

  String get _welcomeKey => _userId != null ? 'user_${_userId}_has_seen_welcome_inspiration' : 'has_seen_welcome_inspiration';

  Future<void> checkWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _showWelcome = !(prefs.getBool(_welcomeKey) ?? false);
    notifyListeners();
  }

  Future<void> dismissWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
    _showWelcome = false;
    notifyListeners();
  }

  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (_projects.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _currentPage = 1;
      final newProjects = await _dataSource.getUnexploredProjects(
        forceRefresh: forceRefresh,
        page: _currentPage,
        limit: _limit,
      );
      _projects = newProjects;
      _hasMore = newProjects.length == _limit;
      _checkAndStartAutoRefresh();
    } catch (e) {
      debugPrint("Error detallado en loadProjects: $e");
      if (_projects.isEmpty) _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newProjects = await _dataSource.getUnexploredProjects(
        forceRefresh: true, // we want fresh data for subsequent pages
        page: nextPage,
        limit: _limit,
      );

      if (newProjects.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        _projects.addAll(newProjects);
        _hasMore = newProjects.length == _limit;
        _checkAndStartAutoRefresh();
      }
    } catch (e) {
      debugPrint("Error fetching more projects: $e");
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  void _checkAndStartAutoRefresh() {
    _refreshTimer?.cancel();
    if (_projects.any((p) => p.analysisStatus == 'pending')) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (!_projects.any((p) => p.analysisStatus == 'pending')) {
          timer.cancel();
          return;
        }
        try {
          final fresh = await _dataSource.getUnexploredProjects(forceRefresh: true);
          if (fresh.isNotEmpty) {
            _projects = fresh;
            notifyListeners();
            if (!_projects.any((p) => p.analysisStatus == 'pending')) {
              timer.cancel();
            }
          }
        } catch (_) {}
      });
    }
  }

  void clear() {
    _refreshTimer?.cancel();
    _projects = [];
    _isLoading = false;
    _isFetchingMore = false;
    _hasMore = true;
    _currentPage = 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<ProjectEntity?> trackNicheView(String nicheId, String? userAvatar) async {
    try {
      final updatedProject = await _dataSource.trackNicheView(nicheId, userAvatar);
      if (updatedProject != null) {
        final index = _projects.indexWhere((p) => p.id == nicheId);
        if (index != -1) {
          _projects[index] = updatedProject;
          notifyListeners();
        }
        return updatedProject;
      }
    } catch (e) {
      debugPrint("Error en trackNicheView: $e");
    }
    return null;
  }

  Future<String> validateIdea(String idea) async {
    return await _dataSource.validateIdea(idea);
  }
}
