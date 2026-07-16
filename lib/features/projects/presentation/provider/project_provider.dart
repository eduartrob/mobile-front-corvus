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

  List<dynamic> _invitations = [];
  List<dynamic> get invitations => _invitations;

  Future<void> loadMyProjects(String token, {bool quiet = false}) async {
    if (!quiet) _setLoading(true);
    try {
      final data = await _api.getMyProjects(token: token);
      _myProjects = data['projects'] ?? [];
      _invitations = data['invitations'] ?? [];
      _error = null;
      if (quiet) notifyListeners(); // Need to notify if we didn't call _setLoading
    } catch (e) {
      _error = e.toString();
      if (quiet) notifyListeners(); // Need to notify to show errors if necessary
    } finally {
      if (!quiet) _setLoading(false);
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

  Future<String?> joinProject({
    required String code,
    required String token,
  }) async {
    _setLoading(true);
    try {
      final res = await _api.joinProject(code: code, token: token);
      await loadMyProjects(token);
      return res['project'] != null ? res['project']['id'] : null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<bool> updateProjectName({
    required String projectId,
    required String newName,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _api.updateProject(projectId: projectId, name: newName, token: token);
      
      // Update local list
      final index = _myProjects.indexWhere((p) => p['id'] == projectId);
      if (index != -1) {
        _myProjects[index]['name'] = newName;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<dynamic>> getProjectStudents({
    required String projectId,
    required String token,
  }) async {
    try {
      return await _api.getProjectStudents(projectId: projectId, token: token);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<bool> acceptProjectInvitation({required String projectId, required String token}) async {
    _setLoading(true);
    try {
      final success = await _api.acceptInvitation(projectId: projectId, token: token);
      if (success) {
        await loadMyProjects(token);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectProjectInvitation({required String projectId, required String token}) async {
    _setLoading(true);
    try {
      final success = await _api.rejectInvitation(projectId: projectId, token: token);
      if (success) {
        await loadMyProjects(token);
      }
      return success;
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

  void clear() {
    _myProjects = [];
    _invitations = [];
    _error = null;
    notifyListeners();
  }
}
