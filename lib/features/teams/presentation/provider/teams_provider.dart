import 'package:flutter/foundation.dart';
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myTeam = await _repository.getMyTeam(projectId: projectId);
      String? resolvedProjectId;

      if (_myTeam != null) {
        _finalReviewStatus =
            await _repository.getFinalReviewStatus(_myTeam!.id);
        resolvedProjectId = _myTeam!.project?['id']?.toString() ??
            _myTeam!.project?['id_proyecto']?.toString();
      } else {
        _finalReviewStatus = null;
        final projectData = await _repository.fetchProjectId();
        resolvedProjectId = projectData?['projectId']?.toString();
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
      _myTeam =
          await _repository.updateTeam(name, description, socialLinks);
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
      await _repository.leaveTeam();
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
      await _repository.sendInvitation(studentId);
      _suggestions.removeWhere((student) => student.id == studentId);
      fetchRequests();
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
      await _repository.acceptRequest(requestId);
      fetchMyTeam();
      fetchRequests();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}