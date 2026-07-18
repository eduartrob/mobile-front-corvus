import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'dart:convert';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';

enum SolicitudFilter {
  recibidas,
  enviadas,
}

class TeamsProvider extends ChangeNotifier {
  final TeamsRemoteDataSource remoteDataSource;

  TeamsProvider({TeamsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? TeamsRemoteDataSource(client: apiClient);

  String? _currentProjectId;
  String? get currentProjectId => _currentProjectId;

  TeamModel? _myTeam;
  Map<String, dynamic>? _finalReviewStatus;
  List<Student> _suggestions = [];
  List<Solicitud> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  SolicitudFilter _selectedFilter = SolicitudFilter.recibidas;

  TeamModel? get myTeam => _myTeam;
  Map<String, dynamic>? get finalReviewStatus => _finalReviewStatus;
  List<Student> get suggestions => _suggestions;
  List<Solicitud> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SolicitudFilter get selectedFilter => _selectedFilter;

  List<Solicitud> get filteredSolicitudes {
    final targetState = _selectedFilter == SolicitudFilter.recibidas
        ? SolicitudState.recibida
        : SolicitudState.enviada;
    return _requests.where((s) => s.state == targetState).toList();
  }

  void selectFilter(SolicitudFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
      fetchRequests();
    }
  }

  int _maxTeamMembers = 4;
  int get maxTeamMembers => _maxTeamMembers;

  Future<void> fetchMyTeam({String? projectId}) async {
    if (projectId != null && projectId != _currentProjectId) {
      _myTeam = null;
      _finalReviewStatus = null;
      _suggestions = [];
      _requests = [];
      _maxTeamMembers = 4;
    }

    _isLoading = true;
    _errorMessage = null;
    if (projectId != null) {
      _currentProjectId = projectId;
    }
    notifyListeners();

    try {
      _myTeam = await remoteDataSource.getMyTeam(projectId: _currentProjectId);
      String? actualProjectId = _currentProjectId;

      if (_myTeam != null) {
        _finalReviewStatus = await remoteDataSource.getFinalReviewStatus(_myTeam!.id);
        actualProjectId = _myTeam!.project?['id']?.toString() 
            ?? _myTeam!.project?['id_proyecto']?.toString() ?? actualProjectId;
        _currentProjectId = actualProjectId;
      } else {
        _finalReviewStatus = null;
        if (actualProjectId == null) {
          try {
            final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/teams/my-project-id');
            final response = await remoteDataSource.client.get(uri, headers: ApiConfig.defaultHeaders);
            if (response.statusCode == 200) {
              final data = json.decode(utf8.decode(response.bodyBytes));
              actualProjectId = data['projectId']?.toString() ?? actualProjectId;
              _currentProjectId = actualProjectId;
            }
          } catch (e) {
            // ignore error
          }
        }
      }

      // Fetch config to get maxTeamMembers using projectId
      if (actualProjectId != null) {
        try {
          final uri = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.integratorAdminConfig}')
              .replace(queryParameters: {'projectId': actualProjectId});
          final response = await remoteDataSource.client.get(uri, headers: ApiConfig.defaultHeaders);
          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));
            if (data != null && data['max_team_members'] != null) {
              _maxTeamMembers = int.tryParse(data['max_team_members'].toString()) ?? 4;
            }
          }
        } catch (e) {
          // ignore error and use default
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTeamDetails(String name, String description, List<SocialLinkModel> socialLinks) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myTeam = await remoteDataSource.updateTeam(name, description, socialLinks, projectId: _currentProjectId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveTeam() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.leaveTeam();
      _myTeam = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMember(String memberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.removeMember(memberId);
      if (_myTeam != null) {
        final updatedMembers = _myTeam!.members.where((m) => m.id != memberId).toList();
        _myTeam = TeamModel(
          id: _myTeam!.id,
          name: _myTeam!.name,
          description: _myTeam!.description,
          members: updatedMembers,
          socialLinks: _myTeam!.socialLinks,
          project: _myTeam!.project,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestions({String? skill, String? search, bool showAll = false, String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    if (projectId != null) {
      _currentProjectId = projectId;
    }
    notifyListeners();

    try {
      final results = await remoteDataSource.getSuggestions(skill: skill, search: search, showAll: showAll, projectId: _currentProjectId);
      _suggestions = results.where((s) => s.id != null).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequests({String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    if (projectId != null) {
      _currentProjectId = projectId;
    }
    notifyListeners();

    try {
      final filterStr = _selectedFilter == SolicitudFilter.recibidas ? 'recibidas' : 'enviadas';
      _requests = await remoteDataSource.getRequests(filterStr, projectId: _currentProjectId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInvitation(String studentId, {String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    if (projectId != null) {
      _currentProjectId = projectId;
    }
    notifyListeners();

    try {
      await remoteDataSource.sendInvitation(studentId, projectId: _currentProjectId);
      
      // Eliminar al estudiante de las sugerencias locales inmediatamente
      _suggestions.removeWhere((student) => student.id == studentId);
      
      fetchRequests();
      // Ya no llamamos fetchSuggestions sin parámetros aquí
      // para evitar perder el filtro actual que tenía el usuario.
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.cancelRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId, {String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    if (projectId != null) {
      _currentProjectId = projectId;
    }
    notifyListeners();

    try {
      await remoteDataSource.acceptRequest(requestId, projectId: _currentProjectId);
      fetchMyTeam(projectId: _currentProjectId);
      fetchRequests(projectId: _currentProjectId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
