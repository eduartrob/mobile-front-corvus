import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:mobile/core/error/error_handler.dart';

enum SolicitudFilter {
  recibidas,
  enviadas,
}

class TeamProjectData {
  TeamModel? myTeam;
  Map<String, dynamic>? finalReviewStatus;
  List<Student> suggestions = [];
  List<Solicitud> requests = [];
  bool isLoading = false;       // sugerencias / solicitudes / acciones generales
  bool isLoadingTeam = false;   // SOLO carga del equipo principal
  String? errorMessage;
  SolicitudFilter selectedFilter = SolicitudFilter.recibidas;
  int maxTeamMembers = 4;
  bool hasLoadedOnce = false;

  Map<String, dynamic> toJson() {
    return {
      if (myTeam != null) 'myTeam': myTeam!.toJson(),
      'finalReviewStatus': finalReviewStatus,
      'maxTeamMembers': maxTeamMembers,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    if (json['myTeam'] != null) {
      myTeam = TeamModel.fromJson(json['myTeam']);
    }
    finalReviewStatus = json['finalReviewStatus'];
    if (json['maxTeamMembers'] != null) {
      maxTeamMembers = json['maxTeamMembers'];
    }
  }
}

class TeamsProvider extends ChangeNotifier {
  final TeamsRepository _repository;

  TeamsProvider({required TeamsRepository repository})
      : _repository = repository;

  final Map<String, TeamProjectData> _teamCache = {};
  String? _activeProjectId; // project_id activo para todas las operaciones

  TeamProjectData get _current {
    if (_activeProjectId == null) return TeamProjectData();
    return _teamCache[_activeProjectId!] ??= TeamProjectData();
  }

  TeamModel? get myTeam => _current.myTeam;
  Map<String, dynamic>? get finalReviewStatus => _current.finalReviewStatus;
  List<Student> get suggestions => _current.suggestions;
  List<Solicitud> get requests => _current.requests;
  bool get isLoading => _current.isLoading;
  bool get isLoadingTeam => _current.isLoadingTeam;
  String? get errorMessage => _current.errorMessage;
  SolicitudFilter get selectedFilter => _current.selectedFilter;
  String? get activeProjectId => _activeProjectId;
  bool get hasLoadedOnce => _current.hasLoadedOnce;

  List<Solicitud> get filteredSolicitudes {
    final targetState = _current.selectedFilter == SolicitudFilter.recibidas
        ? SolicitudState.recibida
        : SolicitudState.enviada;
    return _current.requests.where((s) => s.state == targetState).toList();
  }

  void clear() {
    _current.myTeam = null;
    _current.finalReviewStatus = null;
    _current.suggestions = [];
    _current.requests = [];
    _activeProjectId = null;
    _current.isLoading = false;
    _current.errorMessage = null;
    _current.selectedFilter = SolicitudFilter.recibidas;
    notifyListeners();
  }

  void selectFilter(SolicitudFilter filter) {
    if (_current.selectedFilter != filter) {
      _current.selectedFilter = filter;
      notifyListeners();
      fetchRequests();
    }
  }

  int get maxTeamMembers => _current.myTeam?.maxMembers ?? _current.maxTeamMembers;

  Future<void> fetchMyTeam({String? projectId, bool forceRefresh = false}) async {
    final bool switchedContext = _activeProjectId != projectId;

    if (projectId != null) {
      _activeProjectId = projectId;
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('teams_details_$projectId');
        if (cached != null) {
          _current.fromJson(json.decode(cached));
          _current.hasLoadedOnce = true;
        }
      } catch (_) {}
    }

    // If we already have real data for this project and it's not a forced refresh,
    // show cached data immediately and skip the loading spinner.
    if (_current.hasLoadedOnce && !forceRefresh) {
      if (switchedContext) notifyListeners();
      return;
    }

    // Only show loading spinner on first load for this project
    if (!_current.hasLoadedOnce) {
      _current.isLoadingTeam = true;
      if (switchedContext) {
        notifyListeners();
      } else {
        Future.microtask(() => notifyListeners());
      }
    }

    _current.errorMessage = null;

    try {
      // Lanzar fetchConfig en paralelo con getMyTeam si ya tenemos projectId
      Future<Map<String, dynamic>> configFuture = projectId != null
          ? _repository.fetchConfig(projectId: projectId).catchError((_) => <String, dynamic>{})
          : Future.value(<String, dynamic>{});

      final fetchedTeam = await _repository.getMyTeam(projectId: projectId);
      _current.myTeam = fetchedTeam;
      if (fetchedTeam != null) {
        notifyListeners();
      }

      // Use resolvedProjectId only if no explicit projectId was given
      // This keeps the cache key consistent with what was passed in
      String? resolvedProjectId = projectId;
      if (resolvedProjectId == null) {
        if (_current.myTeam != null) {
          resolvedProjectId = _current.myTeam!.project?['id']?.toString() ??
              _current.myTeam!.project?['id_proyecto']?.toString();
        } else {
          final projectData = await _repository.fetchProjectId();
          resolvedProjectId = projectData?['projectId']?.toString();
        }
        // Only update _activeProjectId when we didn't have one to begin with
        if (resolvedProjectId != null) {
          _activeProjectId = resolvedProjectId;
          configFuture = _repository.fetchConfig(projectId: resolvedProjectId).catchError((_) => <String, dynamic>{});
        }
      }

      Future<Map<String, dynamic>?> reviewStatusFuture = _current.myTeam != null
          ? _repository.getFinalReviewStatus(_current.myTeam!.id).catchError((_) => null)
          : Future.value(null);

      final results = await Future.wait([reviewStatusFuture, configFuture]);
      _current.finalReviewStatus = results[0];
      final config = results[1] as Map<String, dynamic>;

      if (config.isNotEmpty && config['max_team_members'] != null) {
        _current.maxTeamMembers =
            int.tryParse(config['max_team_members'].toString()) ?? 4;
      }

      _current.hasLoadedOnce = true;
      if (resolvedProjectId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('teams_details_$resolvedProjectId', json.encode(_current.toJson()));
        } catch (_) {}
      }
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _current.isLoadingTeam = false;
      notifyListeners();
    }
  }

  TeamModel? getTeamForProject(String pid) => _teamCache[pid]?.myTeam;

  Future<void> silentWarmUp(String pid) async {
    final data = _teamCache.putIfAbsent(pid, () => TeamProjectData());
    if (!data.hasLoadedOnce) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('teams_details_$pid');
        if (cached != null) {
          data.fromJson(json.decode(cached));
          data.hasLoadedOnce = true;
        }
      } catch (_) {}
    }
    
    if (data.hasLoadedOnce || data.isLoadingTeam) return;

    data.isLoadingTeam = true;
    try {
      final fetchedTeam = await _repository.getMyTeam(projectId: pid);
      data.myTeam = fetchedTeam;

      Future<Map<String, dynamic>?> reviewStatusFuture = fetchedTeam != null
          ? _repository.getFinalReviewStatus(fetchedTeam.id).catchError((_) => null)
          : Future.value(null);

      Future<Map<String, dynamic>> configFuture = _repository
          .fetchConfig(projectId: pid)
          .catchError((_) => <String, dynamic>{});

      final results = await Future.wait([reviewStatusFuture, configFuture]);
      data.finalReviewStatus = results[0] as Map<String, dynamic>?;
      final config = results[1] as Map<String, dynamic>;

      if (config.isNotEmpty && config['max_team_members'] != null) {
        data.maxTeamMembers = int.tryParse(config['max_team_members'].toString()) ?? 4;
      }
      data.hasLoadedOnce = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('teams_details_$pid', json.encode(data.toJson()));
      } catch (_) {}
    } catch (_) {
      // Ignore in silent warmup
    } finally {
      data.isLoadingTeam = false;
    }
  }

  Future<void> updateTeamDetails(
      String name, String description, List<SocialLinkModel> socialLinks) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      _current.myTeam = await _repository.updateTeam(
        name,
        description,
        socialLinks,
        projectId: _activeProjectId, // pasar siempre el projectId activo
      );
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveTeam() async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      await _repository.leaveTeam();
      _current.myTeam = null;
      fetchSuggestions(projectId: _activeProjectId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMember(String memberId) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      await _repository.removeMember(memberId);
      if (_current.myTeam != null) {
        final updatedMembers =
            _current.myTeam!.members.where((m) => m.id != memberId).toList();
        _current.myTeam = TeamModel(
          id: _current.myTeam!.id,
          name: _current.myTeam!.name,
          description: _current.myTeam!.description,
          members: updatedMembers,
          socialLinks: _current.myTeam!.socialLinks,
          project: _current.myTeam!.project,
        );
      }
      fetchSuggestions(projectId: _activeProjectId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestions(
      {String? skill, String? search, bool showAll = false, String? projectId}) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getSuggestions(
          skill: skill, search: search, showAll: showAll, projectId: projectId);
      _current.suggestions = results.where((s) => s.id != null).toList();
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequests({String? projectId}) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      final filterStr = _current.selectedFilter == SolicitudFilter.recibidas
          ? 'recibidas'
          : 'enviadas';
      _current.requests = await _repository.getRequests(filterStr, projectId: projectId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInvitation(String studentId) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendInvitation(studentId, projectId: _activeProjectId);
      _current.suggestions.removeWhere((student) => student.id == studentId);
      fetchRequests(projectId: _activeProjectId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequest(String requestId) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      await _repository.cancelRequest(requestId);
      _current.requests.removeWhere((r) => r.id == requestId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId) async {
    _current.isLoading = true;
    _current.errorMessage = null;
    notifyListeners();

    try {
      await _repository.acceptRequest(requestId, projectId: _activeProjectId);
      // Refrescar equipo y config (número de integrantes puede haber cambiado)
      await fetchMyTeam(projectId: _activeProjectId);
      fetchRequests(projectId: _activeProjectId);
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      rethrow;
    } finally {
      _current.isLoading = false;
      notifyListeners();
    }
  }
}