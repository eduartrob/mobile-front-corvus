import 'package:flutter/material.dart';
import 'package:mobile/features/projects/data/project_api.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectApi _api = ProjectApi();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<dynamic> _myProjects = [];
  List<dynamic> get myProjects => _myProjects;

  Future<void> loadMyProjects(String token) async {
    _setLoading(true);
    try {
      _myProjects = await _api.getMyProjects(token: token);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProject({
    required String name,
    String? description,
    int teamSize = 4,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _api.createProject(
        name: name,
        description: description,
        teamSize: teamSize,
        token: token,
      );
      await loadMyProjects(token);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> joinProject({
    required String code,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _api.joinProject(code: code, token: token);
      await loadMyProjects(token);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
