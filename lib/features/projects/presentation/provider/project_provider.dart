import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/projects/data/project_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      
      if (_myProjects.isEmpty && _invitations.isEmpty) {
        final cachedProjects = prefs.getString('cached_projects');
        final cachedInvitations = prefs.getString('cached_invitations');
        if (cachedProjects != null) {
          _myProjects = json.decode(cachedProjects);
        }
        if (cachedInvitations != null) {
          _invitations = json.decode(cachedInvitations);
        }
        if (_myProjects.isNotEmpty || _invitations.isNotEmpty) {
          notifyListeners();
        }
      }

      final data = await _api.getMyProjects(token: token);
      _myProjects = data['projects'] ?? [];
      _invitations = data['invitations'] ?? [];
      
      await prefs.setString('cached_projects', json.encode(_myProjects));
      await prefs.setString('cached_invitations', json.encode(_invitations));

      _error = null;
      if (quiet) notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      if (quiet) notifyListeners();
    } finally {
      if (!quiet) _setLoading(false);
    }
  }

  Future<bool> createProject({
    required String name,
    String? description,
    int teamSize = 4,
    required String token,
    String? themeColor,
    String? themePattern,
  }) async {
    _setLoading(true);
    try {
      await _api.createProject(
        name: name,
        description: description,
        teamSize: teamSize,
        token: token,
        themeColor: themeColor,
        themePattern: themePattern,
      );
      await loadMyProjects(token);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
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
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<bool> updateProjectName({
    required String projectId,
    required String newName,
    required String token,
    String? themeColor,
    String? themePattern,
  }) async {
    _setLoading(true);
    try {
      await _api.updateProject(
        projectId: projectId, 
        name: newName, 
        token: token,
        themeColor: themeColor,
        themePattern: themePattern,
      );
      
      // Update local list
      final index = _myProjects.indexWhere((p) => p['id'] == projectId);
      if (index != -1) {
        _myProjects[index]['name'] = newName;
        if (themeColor != null) _myProjects[index]['theme_color'] = themeColor;
        if (themePattern != null) _myProjects[index]['theme_pattern'] = themePattern;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProject({
    required String projectId,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _api.deleteProject(projectId: projectId, token: token);
      
      // Update local list
      _myProjects.removeWhere((p) => p['id'] == projectId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
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
      _error = e.toString().replaceAll('Exception: ', '');
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
      _error = e.toString().replaceAll('Exception: ', '');
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
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() async {
    _myProjects = [];
    _invitations = [];
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_projects');
      await prefs.remove('cached_invitations');
    } catch (_) {}
  }
}
