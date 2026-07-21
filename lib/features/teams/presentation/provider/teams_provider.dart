import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/teams/domain/repositories/teams_repository.dart';

enum SolicitudFilter {
  recibidas,
  enviadas,
}

class TeamsProvider extends ChangeNotifier {
  final TeamsRepository _repository;

  TeamsProvider({required TeamsRepository repository})
      : _repository = repository;

  TeamModel? _myTeam;
  Map<String, dynamic>? _finalReviewStatus;
  List<Student> _suggestions = [];
  List<Solicitud> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  SolicitudFilter _selectedFilter = SolicitudFilter.recibidas;
  String? _activeProjectId; // project_id activo para todas las operaciones

  TeamModel? get myTeam => _myTeam;
  Map<String, dynamic>? get finalReviewStatus => _finalReviewStatus;
  List<Student> get suggestions => _suggestions;
  List<Solicitud> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SolicitudFilter get selectedFilter => _selectedFilter;
  String? get activeProjectId => _activeProjectId;

  List<Solicitud> get filteredSolicitudes {
    final targetState = _selectedFilter == SolicitudFilter.recibidas
        ? SolicitudState.recibida
        : SolicitudState.enviada;
    return _requests.where((s) => s.state == targetState).toList();
  }

  void clear() {
    _myTeam = null;
    _finalReviewStatus = null;
    _suggestions = [];
    _requests = [];
    _activeProjectId = null;
    _isLoading = false;
    _errorMessage = null;
    _selectedFilter = SolicitudFilter.recibidas;
    notifyListeners();
  }

  void selectFilter(SolicitudFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
      fetchRequests();
    }
  }

  int _maxTeamMembers = 4;
  int get maxTeamMembers => _myTeam?.maxMembers ?? _maxTeamMembers;

  Future<void> fetchMyTeam({String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    _myTeam = null;
    _finalReviewStatus = null;
    notifyListeners();

    try {
      _myTeam = await _repository.getMyTeam(projectId: projectId);
      String? resolvedProjectId = projectId;

      if (_myTeam != null) {
        try {
          FirebaseMessaging.instance.subscribeToTopic('team_${_myTeam!.id}');
        } catch (_) {}
        _finalReviewStatus =
            await _repository.getFinalReviewStatus(_myTeam!.id);
        // Prefer the explicit project_id passed; fallback to what's in the team object
        resolvedProjectId ??= _myTeam!.project?['id']?.toString() ??
            _myTeam!.project?['id_proyecto']?.toString();
      } else {
        _finalReviewStatus = null;
        if (resolvedProjectId == null) {
          final projectData = await _repository.fetchProjectId();
          resolvedProjectId = projectData?['projectId']?.toString();
        }
      }

      // Store active project ID for use in other operations
      if (resolvedProjectId != null) {
        _activeProjectId = resolvedProjectId;
      }

      // Fetch config to get maxTeamMembers using projectId
      if (resolvedProjectId != null) {
        final config = await _repository.fetchConfig(projectId: resolvedProjectId);
        if (config['max_team_members'] != null) {
          _maxTeamMembers =
              int.tryParse(config['max_team_members'].toString()) ?? 4;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTeamDetails(
      String name, String description, List<SocialLinkModel> socialLinks) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myTeam = await _repository.updateTeam(
        name,
        description,
        socialLinks,
        projectId: _activeProjectId, // pasar siempre el projectId activo
      );
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
      final currentTeamId = _myTeam?.id;
      await _repository.leaveTeam();

      if (currentTeamId != null && currentTeamId.isNotEmpty) {
        try {
          final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
          final title = 'Integrante Abandonó el Equipo';
          final body = 'Un compañero ha abandonado el equipo de proyecto.';

          apiClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': 'team_$currentTeamId',
              'title': title,
              'body': body,
              'data': {
                'type': 'team_update',
                'title': title,
                'message': body,
                'teamId': currentTeamId,
              }
            })
          ).then((_) {}).catchError((_) {});

          try {
            FirebaseMessaging.instance.unsubscribeFromTopic('team_$currentTeamId');
          } catch (_) {}
        } catch (_) {}
      }

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
      final currentTeamId = _myTeam?.id;
      await _repository.removeMember(memberId);
      if (_myTeam != null) {
        final updatedMembers =
            _myTeam!.members.where((m) => m.id != memberId).toList();
        _myTeam = TeamModel(
          id: _myTeam!.id,
          name: _myTeam!.name,
          description: _myTeam!.description,
          members: updatedMembers,
          socialLinks: _myTeam!.socialLinks,
          project: _myTeam!.project,
        );
      }

      // Notificar al integrante removido directamente y al grupo
      try {
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
        final titleUser = 'Removido del Equipo';
        final bodyUser = 'El líder te ha removido del equipo de proyecto.';

        apiClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': 'user_$memberId',
            'title': titleUser,
            'body': bodyUser,
            'data': {
              'type': 'team_update',
              'title': titleUser,
              'message': bodyUser,
            }
          })
        ).then((_) {}).catchError((_) {});

        if (currentTeamId != null && currentTeamId.isNotEmpty) {
          final titleTeam = 'Integrante Removido';
          final bodyTeam = 'Un integrante ha sido removido del equipo.';

          apiClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': 'team_$currentTeamId',
              'title': titleTeam,
              'body': bodyTeam,
              'data': {
                'type': 'team_update',
                'title': titleTeam,
                'message': bodyTeam,
                'teamId': currentTeamId,
              }
            })
          ).then((_) {}).catchError((_) {});
        }
      } catch (_) {}
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestions(
      {String? skill, String? search, bool showAll = false, String? projectId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getSuggestions(
          skill: skill, search: search, showAll: showAll, projectId: projectId);
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
    notifyListeners();

    try {
      final filterStr = _selectedFilter == SolicitudFilter.recibidas
          ? 'recibidas'
          : 'enviadas';
      _requests = await _repository.getRequests(filterStr, projectId: projectId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInvitation(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendInvitation(studentId, projectId: _activeProjectId);
      _suggestions.removeWhere((student) => student.id == studentId);
      fetchRequests(projectId: _activeProjectId);

      // Notificar al estudiante invitado directamente
      try {
        final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
        final title = 'Nueva Invitación de Equipo';
        final teamName = _myTeam?.name ?? 'un equipo';
        final body = 'Has recibido una invitación para unirte a $teamName.';

        apiClient.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'topic': 'user_$studentId',
            'title': title,
            'body': body,
            'data': {
              'type': 'team_request',
              'title': title,
              'message': body,
            }
          })
        ).then((_) {}).catchError((_) {});
      } catch (_) {}
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
      await _repository.cancelRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.acceptRequest(requestId, projectId: _activeProjectId);
      // Refrescar equipo y config (número de integrantes puede haber cambiado)
      await fetchMyTeam(projectId: _activeProjectId);
      fetchRequests(projectId: _activeProjectId);

      // Notificar a todos los integrantes del equipo para que se actualicen en tiempo real
      if (_myTeam != null && _myTeam!.id.isNotEmpty) {
        try {
          final uri = Uri.parse('${ApiConfig.apiGatewayUrl}/notifications/topic/push');
          final teamId = _myTeam!.id;
          final title = 'Nuevo Integrante en el Equipo';
          final body = 'Un nuevo integrante se ha unido al equipo.';

          apiClient.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'topic': 'team_$teamId',
              'title': title,
              'body': body,
              'data': {
                'type': 'team_accept',
                'title': title,
                'message': body,
                'teamId': teamId,
              }
            })
          ).then((_) {}).catchError((_) {});
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}