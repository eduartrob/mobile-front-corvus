import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/teams/data/models/solicitud_model.dart';
import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';

enum SolicitudFilter {
  aceptadas,
  enviadas,
}

class TeamsProvider extends ChangeNotifier {
  final TeamsRemoteDataSource remoteDataSource;

  TeamsProvider({TeamsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? TeamsRemoteDataSource(client: http.Client());

  TeamModel? _myTeam;
  List<Student> _suggestions = [];
  List<Solicitud> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  SolicitudFilter _selectedFilter = SolicitudFilter.aceptadas;

  TeamModel? get myTeam => _myTeam;
  List<Student> get suggestions => _suggestions;
  List<Solicitud> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SolicitudFilter get selectedFilter => _selectedFilter;

  List<Solicitud> get filteredSolicitudes {
    final targetState = _selectedFilter == SolicitudFilter.aceptadas
        ? SolicitudState.aceptada
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

  Future<void> fetchMyTeam() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myTeam = await remoteDataSource.getMyTeam();
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
      _myTeam = await remoteDataSource.updateTeam(name, description, socialLinks);
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

  Future<void> fetchSuggestions({String? skill}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suggestions = await remoteDataSource.getSuggestions(skill: skill);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final filterStr = _selectedFilter == SolicitudFilter.aceptadas ? 'aceptadas' : 'enviadas';
      _requests = await remoteDataSource.getRequests(filterStr);
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
      await remoteDataSource.sendInvitation(studentId);
      fetchSuggestions();
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

  Future<void> acceptRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.acceptRequest(requestId);
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
