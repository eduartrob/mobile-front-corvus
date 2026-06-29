import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/data/data_source/inspiration_remote_data_source.dart';
import 'package:http/http.dart' as http;

class InspirationProvider extends ChangeNotifier {
  final InspirationRemoteDataSource _dataSource;
  
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  List<ProjectEntity> _projects = [];
  List<ProjectEntity> get projects => _projects;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _showWelcome = true;
  bool get showWelcome => _showWelcome;

  InspirationProvider({InspirationRemoteDataSource? dataSource}) 
      : _dataSource = dataSource ?? InspirationRemoteDataSource(client: http.Client()) {
    _init();
  }

  Future<void> _init() async {
    await checkWelcomeStatus();
    await loadProjects();
  }

  Future<void> checkWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _showWelcome = !(prefs.getBool('has_seen_welcome_inspiration') ?? false);
    notifyListeners();
  }

  Future<void> dismissWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome_inspiration', true);
    _showWelcome = false;
    notifyListeners();
  }

  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (_projects.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _projects = await _dataSource.getUnexploredProjects(forceRefresh: forceRefresh);
    } catch (e) {
      print("Error detallado en loadProjects: $e");
      if (_projects.isEmpty) _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
