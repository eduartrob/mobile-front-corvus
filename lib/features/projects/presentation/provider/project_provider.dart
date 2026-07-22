import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/features/projects/data/project_api.dart';
import 'package:mobile/features/projects/data/repositories/project_management_repository_impl.dart';
import 'package:mobile/features/projects/domain/repositories/project_management_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectManagementRepository _repository;

  ProjectProvider({ProjectManagementRepository? repository})
      : _repository = repository ?? ProjectManagementRepositoryImpl();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<dynamic> _myProjects = [];
  List<dynamic> get myProjects => _myProjects;

  List<dynamic> _invitations = [];
  List<dynamic> get invitations => _invitations;

  List<dynamic> _archivedProjects = [];
  List<dynamic> get archivedProjects => _archivedProjects;

  Future<void> loadMyProjects(String token, {bool quiet = false, String? userId}) async {
    if (!quiet) _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsKey = userId != null ? 'user_${userId}_cached_projects' : 'cached_projects';
      final invitationsKey = userId != null ? 'user_${userId}_cached_invitations' : 'cached_invitations';

      if (_myProjects.isEmpty && _invitations.isEmpty) {
        final cachedProjects = prefs.getString(projectsKey);
        final cachedInvitations = prefs.getString(invitationsKey);
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

      final data = await _repository.getMyProjects(token: token);
      _myProjects = data['projects'] ?? [];
      _invitations = data['invitations'] ?? [];

      _myProjects.sort((a, b) {
        final aDateStr = a['updated_at'] ?? a['updatedAt'];
        final bDateStr = b['updated_at'] ?? b['updatedAt'];
        final aDate = aDateStr != null ? DateTime.tryParse(aDateStr.toString()) : null;
        final bDate = bDateStr != null ? DateTime.tryParse(bDateStr.toString()) : null;
        if (aDate != null && bDate != null) {
          return bDate.compareTo(aDate);
        } else if (aDate != null) {
          return -1;
        } else if (bDate != null) {
          return 1;
        }
        return 0;
      });

      await prefs.setString(projectsKey, json.encode(_myProjects));
      await prefs.setString(invitationsKey, json.encode(_invitations));

      _error = null;
      if (quiet) notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      if (quiet) notifyListeners();
    } finally {
      if (!quiet) _setLoading(false);
    }
  }

  Future<void> loadArchivedProjects(String token, {bool quiet = false}) async {
    if (!quiet) _setLoading(true);
    try {
      final data = await _repository.getArchivedProjects(token: token);
      _archivedProjects = data['projects'] ?? [];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      if (quiet) notifyListeners();
    } finally {
      if (!quiet) _setLoading(false);
    }
  }

  Future<bool> archiveProjects({
    required List<String> projectIds,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _repository.archiveProjects(projectIds: projectIds, token: token);
      // Remove from active projects list locally
      _myProjects.removeWhere((p) => projectIds.contains(p['id']));
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> unarchiveProjects({
    required List<String> projectIds,
    required String token,
  }) async {
    _setLoading(true);
    try {
      await _repository.unarchiveProjects(projectIds: projectIds, token: token);
      // Remove from archived projects list locally
      _archivedProjects.removeWhere((p) => projectIds.contains(p['id']));
      // Force a reload of the active projects so they appear there
      await loadMyProjects(token, quiet: true);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
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
      await _repository.createProject(
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
      final res = await _repository.joinProject(code: code, token: token);
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
      await _repository.updateProject(
        projectId: projectId,
        name: newName,
        token: token,
        themeColor: themeColor,
        themePattern: themePattern,
      );

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
      await _repository.deleteProject(projectId: projectId, token: token);
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
      return await _repository.getProjectStudents(projectId: projectId, token: token);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return [];
    }
  }

  Future<bool> acceptProjectInvitation({required String projectId, required String token}) async {
    _setLoading(true);
    try {
      final success = await _repository.acceptInvitation(projectId: projectId, token: token);
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
      final success = await _repository.rejectInvitation(projectId: projectId, token: token);
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

  void clear({String? userId}) async {
    _myProjects = [];
    _invitations = [];
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsKey = userId != null ? 'user_${userId}_cached_projects' : 'cached_projects';
      final invitationsKey = userId != null ? 'user_${userId}_cached_invitations' : 'cached_invitations';
      await prefs.remove(projectsKey);
      await prefs.remove(invitationsKey);
    } catch (_) {}
  }

  void touchProject(String projectId) {
    final index = _myProjects.indexWhere((p) => p['id'] == projectId);
    if (index != -1) {
      final project = _myProjects.removeAt(index);
      project['updated_at'] = DateTime.now().toIso8601String();
      _myProjects.insert(0, project);
      notifyListeners();
    }
  }
}