import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/data/data_source/inspiration_local_data_source.dart';

class InspirationProvider extends ChangeNotifier {
  final InspirationLocalDataSource _dataSource;
  
  List<ProjectEntity> _projects = [];
  List<ProjectEntity> get projects => _projects;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _showWelcome = true;
  bool get showWelcome => _showWelcome;

  InspirationProvider({InspirationLocalDataSource? dataSource}) 
      : _dataSource = dataSource ?? InspirationLocalDataSource() {
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

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await _dataSource.getUnexploredProjects();
    } catch (e) {
      _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
