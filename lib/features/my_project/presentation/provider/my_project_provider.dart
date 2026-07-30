import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile/features/my_project/domain/entities/project_analysis_entity.dart';
import 'package:mobile/features/my_project/domain/repositories/project_repository.dart';
import 'package:mobile/features/my_project/data/datasources/cloudinary_service.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/error/error_handler.dart';

enum ProjectState {
  initial,
  uploading,
  preValidated,
  analyzing,
  detailedAnalysis,
  error
}

class ProjectStateData {
  ProjectState state = ProjectState.initial;
  File? selectedFile;
  String? fileName;
  String? fileSize;
  Map<String, dynamic>? quickAnalysis;
  Map<String, dynamic>? detailedAnalysis;
  bool hasPassedDefense = false;
  List<Map<String, String>> defenseChatHistory = [];
  String? activeSessionId;
  List<Map<String, dynamic>> activeChatMessages = [];
  int activeMessageCount = 0;
  List<Map<String, dynamic>> activeVoiceMessages = [];
  Map<String, dynamic>? lastVoiceVerdictReport;
  String? errorMessage;
  String? documentTypeError;
  int serverPhase = 5;
  String serverPhaseMessage = '';
  List<String> allowedExtensions = ['pdf', 'md', 'txt'];
  List<String> exclusionRules = [];
  List<Map<String, dynamic>> projectSections = [];
  int maxTeamMembers = 3;
  bool initialized = false;
  bool hasLoadedOnce = false; // true after first successful fetch from server
  Timer? statusTimer;

  Map<String, dynamic> toJson() {
    return {
      'state': state.toString(),
      'fileName': fileName,
      'fileSize': fileSize,
      'quickAnalysis': quickAnalysis,
      'detailedAnalysis': detailedAnalysis,
      'allowedExtensions': allowedExtensions,
      'exclusionRules': exclusionRules,
      'projectSections': projectSections,
      'maxTeamMembers': maxTeamMembers,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    if (json['state'] != null) {
      state = ProjectState.values.firstWhere((e) => e.toString() == json['state'], orElse: () => ProjectState.initial);
    }
    fileName = json['fileName'];
    fileSize = json['fileSize'];
    quickAnalysis = json['quickAnalysis'];
    detailedAnalysis = json['detailedAnalysis'];
    if (json['allowedExtensions'] != null) {
      allowedExtensions = List<String>.from(json['allowedExtensions']);
    }
    if (json['exclusionRules'] != null) {
      exclusionRules = List<String>.from(json['exclusionRules']);
    }
    if (json['projectSections'] != null) {
      projectSections = List<Map<String, dynamic>>.from(json['projectSections'].map((e) => Map<String, dynamic>.from(e)));
    }
    if (json['maxTeamMembers'] != null) {
      maxTeamMembers = json['maxTeamMembers'];
    }
  }
}

class MyProjectProvider extends ChangeNotifier {
  final ProjectRepository _repository;
  final NotificationService _notificationService;

  MyProjectProvider({required ProjectRepository repository})
      : _repository = repository,
        _notificationService = NotificationService();

  // state entity based cache 
  final Map<String, ProjectStateData> _projectCache = {};
  String? _currentProjectId;

  ProjectStateData get _current {
    if (_currentProjectId == null) return ProjectStateData();
    return _projectCache[_currentProjectId!] ??= ProjectStateData();
  }

  ProjectState get state => _current.state;
  File? get selectedFile => _current.selectedFile;
  String? get fileName => _current.fileName;
  String? get fileSize => _current.fileSize;
  Map<String, dynamic>? get quickAnalysis => _current.quickAnalysis;
  Map<String, dynamic>? get detailedAnalysis => _current.detailedAnalysis;
  bool get hasPassedDefense => _current.hasPassedDefense;
  String? get activeSessionId => _current.activeSessionId;
  List<Map<String, dynamic>> get activeChatMessages => _current.activeChatMessages;
  int get activeMessageCount => _current.activeMessageCount;
  List<Map<String, dynamic>> get activeVoiceMessages => _current.activeVoiceMessages;
  Map<String, dynamic>? get lastVoiceVerdictReport => _current.lastVoiceVerdictReport;
  String? get errorMessage => _current.errorMessage;
  String? get documentTypeError => _current.documentTypeError;
  int get serverPhase => _current.serverPhase;
  String get serverPhaseMessage => _current.serverPhaseMessage;
  List<String> get allowedExtensions => _current.allowedExtensions;
  String get allowedExtensionsString => _current.allowedExtensions.join(', ');
  List<String> get exclusionRules => _current.exclusionRules;
  List<Map<String, dynamic>> get projectSections => _current.projectSections;
  int get maxTeamMembers => _current.maxTeamMembers;
  bool get hasLoadedOnce => _current.hasLoadedOnce;

  String? _universityId;
  String? _careerId;

  void setContext({String? universityId, String? careerId}) {
    _universityId = universityId;
    _careerId = careerId;
  }

  void setDefensePassed(List<Map<String, String>> history) {
    _current.hasPassedDefense = true;
    _current.defenseChatHistory = history;
    _current.activeSessionId = null;
    _current.activeChatMessages = [];
    _current.activeMessageCount = 0;
    notifyListeners();
  }

  void saveActiveSession(
      String sessionId, List<Map<String, dynamic>> messages, int messageCount) {
    _current.activeSessionId = sessionId;
    _current.activeChatMessages = messages;
    _current.activeMessageCount = messageCount;
  }

  // voice defense persistent session 

  void saveActiveVoiceSession(List<Map<String, dynamic>> messages, {Map<String, dynamic>? verdictReport}) {
    _current.activeVoiceMessages = messages;
    if (verdictReport != null) {
      _current.lastVoiceVerdictReport = verdictReport;
    }
    _saveVoiceSessionToPrefs();
  }

  Future<void> _saveVoiceSessionToPrefs() async {
    try {
      if (_currentProjectId == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_voice_messages_$_currentProjectId', jsonEncode(_current.activeVoiceMessages));
      if (_current.lastVoiceVerdictReport != null) {
        await prefs.setString('last_voice_verdict_$_currentProjectId', jsonEncode(_current.lastVoiceVerdictReport));
      }
    } catch (_) {}
  }

  Future<void> loadVoiceSessionFromPrefs() async {
    try {
      if (_currentProjectId == null) return;
      final prefs = await SharedPreferences.getInstance();
      final msgsStr = prefs.getString('active_voice_messages_$_currentProjectId');
      if (msgsStr != null) {
        final List list = jsonDecode(msgsStr);
        _current.activeVoiceMessages = list.cast<Map<String, dynamic>>();
      }
      final verdictStr = prefs.getString('last_voice_verdict_$_currentProjectId');
      if (verdictStr != null) {
        _current.lastVoiceVerdictReport = jsonDecode(verdictStr);
      }
      notifyListeners();
    } catch (_) {}
  }

  void clearActiveVoiceSession() async {
    _current.activeVoiceMessages = [];
    _current.lastVoiceVerdictReport = null;
    try {
      if (_currentProjectId == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_voice_messages_$_currentProjectId');
      await prefs.remove('last_voice_verdict_$_currentProjectId');
    } catch (_) {}
    notifyListeners();
  }

  bool _isScreenVisible = false;
  bool get isScreenVisible => _isScreenVisible;

  void setScreenVisible(bool value) {
    _isScreenVisible = value;
  }

  String? get projectId => _currentProjectId;

  // public api 

  Future<void> refreshConfig() async {
    final config = await _repository.fetchConfig(projectId: _currentProjectId);
    _applyConfig(config);
    notifyListeners();
  }

  Future<void> init(String userId, String teamId,
      {String? projectId, bool forceRefresh = false}) async {
    final bool switchedContext = _currentProjectId != projectId;
    
    if (projectId != null) {
      _currentProjectId = projectId;
    }

    if (switchedContext) {
      notifyListeners();
      // si ya estaba inicializado el cache para este proyecto hacemos silent fetch 
      // retornamos de inmediato si no hay un forcerefresh explícito 
      if (_current.initialized && !forceRefresh) {
        // hacemos fetch silencioso del status
        _silentFetchUpdates(userId, teamId, projectId);
        return;
      }
    }

    if (_current.initialized && !forceRefresh) return;
    _current.initialized = true;
    await _loadFromBffOrFallback(_current, userId, teamId, projectId);
  }

  Future<void> silentWarmUp(String userId, String teamId, String pid) async {
    final data = _projectCache.putIfAbsent(pid, () => ProjectStateData());
    if (data.hasLoadedOnce || data.initialized) return;
    data.initialized = true;
    await _loadFromBffOrFallback(data, userId, teamId, pid, isSilent: true);
  }

  Future<void> _loadFromBffOrFallback(ProjectStateData data, String userId, String teamId, String? projectId, {bool isSilent = false}) async {
    try {
      if (projectId != null) {
        final prefs = await SharedPreferences.getInstance();
        final cachedStr = prefs.getString('my_project_details_$projectId');
        if (cachedStr != null) {
          try {
            data.fromJson(json.decode(cachedStr));
            data.hasLoadedOnce = true;
            if (data == _current && !isSilent) notifyListeners();
          } catch (_) {}
        }
      }

      final results = await Future.wait([
        _repository.getProjectSummary(teamId, projectId: projectId).catchError((_) => <String, dynamic>{}),
        _repository.getLocalAnalysis(userId).catchError((_) => null),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final localAnalysis = results[1] as Map<String, dynamic>?;

      // 1 aplicar configuración desde bff
      if (summary['config'] != null) {
        final configData = summary['config'] as Map;
        final configEntity = ProjectAnalysisEntity(
          allowedExtensions: (configData['allowed_extensions'] as List?)
                  ?.map((e) => e.toString().replaceAll('.', '').trim().toLowerCase())
                  .where((e) => e.isNotEmpty)
                  .toList() ?? const ['pdf', 'md', 'txt'],
          exclusionRules: (configData['exclusion_rules'] as List?)?.map((e) => e.toString()).toList() ?? const [],
          projectSections: (configData['project_sections'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? const [],
          maxTeamMembers: int.tryParse(configData['max_team_members']?.toString() ?? '') ?? 3,
        );
        if (data == _current) {
          _applyConfig(configEntity);
        } else {
          data.allowedExtensions = configEntity.allowedExtensions;
          data.exclusionRules = configEntity.exclusionRules;
          data.projectSections = configEntity.projectSections;
          data.maxTeamMembers = configEntity.maxTeamMembers;
        }
      } else {
        _repository.fetchConfig(projectId: projectId).then((c) {
          if (data == _current) _applyConfig(c);
          else {
            data.allowedExtensions = c.allowedExtensions;
            data.exclusionRules = c.exclusionRules;
            data.projectSections = c.projectSections;
            data.maxTeamMembers = c.maxTeamMembers;
          }
        }).catchError((_) {});
      }

      // 2 si ya hay análisis local guardado usarlo inmediatamente 0 ms 
      if (localAnalysis != null) {
        data.detailedAnalysis = localAnalysis;
        data.fileName = localAnalysis['original_file_name'] ?? 'documento_analizado.pdf';
        data.fileSize = localAnalysis['original_file_size'] ?? 'Local';
        data.documentTypeError = null;
        data.errorMessage = null;
        data.state = ProjectState.detailedAnalysis;
        data.hasLoadedOnce = true;
        if (data == _current && !isSilent) notifyListeners();
        return;
      }

      // 3 revisar status y resultado desde el bff
      final status = summary['analysisStatus'] as Map<String, dynamic>? ?? <String, dynamic>{'phase': 0};
      final phase = (status['phase'] as num?)?.toInt() ?? 0;

      if (phase >= 1 && phase < 5) {
        data.state = ProjectState.uploading;
        data.serverPhase = phase;
        data.serverPhaseMessage = status['message'] ?? '';
        if (data == _current) _startPolling(userId, teamId, null);
        data.hasLoadedOnce = true;
        if (data == _current && !isSilent) notifyListeners();
        return;
      } else if (phase >= 5 && phase <= 8) {
        data.state = ProjectState.analyzing;
        data.serverPhase = phase;
        data.serverPhaseMessage = status['message'] ?? '';
        if (data == _current) _startPolling(userId, teamId, null);
        data.hasLoadedOnce = true;
        if (data == _current && !isSilent) notifyListeners();
        return;
      } else if (phase == 9) {
        final result = summary['analysisResult'] as Map<String, dynamic>? ?? await _repository.getAnalysisResult(teamId).catchError((_) => <String, dynamic>{});
        if (result.isNotEmpty && result['status'] != 'pending' && result['status'] != 'error') {
          if (result.containsKey('general_feedback') ||
              result.containsKey('innovation_index') ||
              result.containsKey('semantic_collision_risk')) {
            if (data == _current) {
              await _applyAnalysisResult(userId, teamId, result, null);
            } else {
              if (data.fileName != null) result['original_file_name'] = data.fileName;
              if (data.fileSize != null) result['original_file_size'] = data.fileSize;
              data.detailedAnalysis = result;
              data.documentTypeError = null;
              data.errorMessage = null;
              data.state = ProjectState.detailedAnalysis;
              await _repository.saveLocalAnalysis(userId, result).catchError((_) {});
            }
          } else {
            data.quickAnalysis = result;
            data.state = ProjectState.preValidated;
            if (data == _current && !isSilent) notifyListeners();
          }
          data.hasLoadedOnce = true;
          return;
        }
      }

      // 4 revisar borrador desde el bff
      final draft = summary['draftProposal'] as Map<String, dynamic>? ?? await _repository.checkDraft(teamId).catchError((_) => <String, dynamic>{});
      if (draft.isNotEmpty && draft['status'] != 'not_found') {
        data.quickAnalysis = draft;
        String rawName = draft['original_file_name'] ?? draft['filename'] ?? 'borrador_guardado.pdf';
        if (rawName.startsWith('draft_') && rawName.contains('-')) {
          rawName = 'Propuesta_Guardada.pdf';
        }
        data.fileName = rawName;
        data.fileSize = 'Local';

        final prefs = await SharedPreferences.getInstance();
        final savedPath = prefs.getString('draft_file_path_$userId');
        if (savedPath != null) {
          final savedFile = File(savedPath);
          if (await savedFile.exists()) {
            data.selectedFile = savedFile;
          }
        }
        data.state = ProjectState.preValidated;
      } else {
        data.state = ProjectState.error;
      }
      data.hasLoadedOnce = true;
      if (data == _current && !isSilent) notifyListeners();
    } catch (e) {
      data.state = ProjectState.error;
      data.hasLoadedOnce = true;
      if (data == _current && !isSilent) notifyListeners();
    } finally {
      if (projectId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('my_project_details_$projectId', json.encode(data.toJson()));
        } catch (_) {}
      }
    }
  }

  Future<void> _silentFetchUpdates(String userId, String teamId, String? projectId) async {
    try {
      final status = await _repository.getAnalysisStatus(teamId);
      final phase = (status['phase'] as num?)?.toInt() ?? 0;
      
      if (phase >= 1 && phase < 5) {
        _current.state = ProjectState.uploading;
        _current.serverPhase = phase;
        _current.serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, teamId, null);
      } else if (phase >= 5 && phase <= 8) {
        _current.state = ProjectState.analyzing;
        _current.serverPhase = phase;
        _current.serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, teamId, null);
      } else if (phase == 9) {
        final result = await _repository.getAnalysisResult(teamId);
        if (result['status'] != 'pending' && result['status'] != 'error') {
          if (result.containsKey('general_feedback') ||
              result.containsKey('innovation_index') ||
              result.containsKey('semantic_collision_risk')) {
            await _applyAnalysisResult(userId, teamId, result, null);
          } else {
            _current.quickAnalysis = result;
            _current.state = ProjectState.preValidated;
          }
        }
      }
      notifyListeners();
    } catch (_) {
      // ignorar errores en silent fetch
    }
  }

  Future<void> pickFile(String userId, String teamId, String userName,
      AppLocalizations l10n) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            _current.allowedExtensions.isNotEmpty ? _current.allowedExtensions : ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _current.errorMessage = null;
        _current.documentTypeError = null;
        _current.serverPhaseMessage = '';
        _current.serverPhase = 0;
        _current.quickAnalysis = null;
        final file = File(result.files.single.path!);
        final bytes = await file.length();

        if (bytes > 10 * 1024 * 1024) {
          _current.errorMessage =
              'El archivo supera el tamaño máximo permitido de 10 MB.';
          _current.state = ProjectState.error;
          notifyListeners();
          return;
        }

        _current.selectedFile = file;
        _current.fileName = result.files.single.name;

        // save to permanent storage to survive cache clears
        try {
          final directory = await getApplicationDocumentsDirectory();
          final permanentPath = '${directory.path}/draft_${teamId}.pdf';
          final permanentFile = await file.copy(permanentPath);
          _current.selectedFile = permanentFile;
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('draft_file_path_$userId', permanentFile.path);
          await prefs.setString('draft_file_path_$teamId', permanentFile.path);
        } catch (e, st) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('draft_file_path_$userId', file.path);
          await prefs.setString('draft_file_path_$teamId', file.path);
        }

        _current.fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        _current.state = ProjectState.uploading;
        notifyListeners();

        await _preValidate(userId, teamId, userName, l10n);
      }
    } catch (e, st) {
      _current.errorMessage =
          'Error seleccionando archivo: ${e.toString().replaceAll('Exception: ', '')}';
      _current.state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> _preValidate(String userId, String teamId, String userName,
      AppLocalizations l10n) async {
    try {
      if (_current.selectedFile == null) return;

      final response = await _repository.preValidateProposal(
        _current.selectedFile!.path,
        teamId,
        userId,
        userName,
        universityId: _universityId,
        careerId: _careerId,
        projectId: _currentProjectId,
      );

      if (response['status'] == 'pending') {
        _current.serverPhase = 1;
        _current.serverPhaseMessage = response['message'] ?? '';
        _startPolling(userId, teamId, l10n);
        notifyListeners();
      } else {
        _current.quickAnalysis = response;
        _current.state = ProjectState.preValidated;
        if (!_isScreenVisible) {
          await _notificationService.showResultNotification(
              l10n.notifPreValidReadyTitle, l10n.notifPreValidReadyBody);
        }
        notifyListeners();
      }
    } catch (e, st) {
      String errorStr = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('Exception ', '');

      try {
        final decoded = jsonDecode(errorStr);
        if (decoded is Map && decoded.containsKey('detail')) {
          errorStr = decoded['detail'];
        }
      } catch (_) {}

      _current.documentTypeError = errorStr;
      if (!_isScreenVisible) {
        await _notificationService.showResultNotification(
            l10n.notifErrorTitle, errorStr);
      }

      _current.state = ProjectState.error;
      notifyListeners();
    }
  }

  void clearError() {
    _current.errorMessage = null;
    if (_current.state == ProjectState.error) {
      _current.state = ProjectState.initial;
    }
    notifyListeners();
  }

  Future<void> submitForReview(
      String userId, String teamId, AppLocalizations l10n) async {
    _current.state = ProjectState.analyzing;
    _current.serverPhase = 5;
    _current.serverPhaseMessage = '';
    notifyListeners();

    try {
      if (!_isScreenVisible) {
        await _notificationService.showAnalysisProgressNotification(
          title: l10n.notifAnalysisProgressTitle,
          message: l10n.notifAnalysisProgressBody,
          phase: l10n.notifAnalysisStartBody,
        );
      }

      await _repository.analyzeDraftDetailed(teamId);
    } catch (e, st) {
      _current.statusTimer?.cancel();
      _notificationService.cancelAnalysisNotification();
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      await _notificationService.showResultNotification(
          l10n.notifAnalysisErrorTitle, cleanMsg);
      _current.errorMessage = cleanMsg;
      _current.state = ProjectState.preValidated;
      notifyListeners();
      return;
    }

    _startPolling(userId, teamId, l10n);
  }

  void _startPolling(String userId, String teamId, AppLocalizations? l10n) {
    _current.statusTimer?.cancel();
    _current.statusTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_current.state != ProjectState.analyzing &&
          _current.state != ProjectState.uploading) {
        _current.statusTimer?.cancel();
        return;
      }

      final status = await _repository.getAnalysisStatus(teamId);

      if (_current.state != ProjectState.analyzing &&
          _current.state != ProjectState.uploading) return;

      final phase = (status['phase'] as num?)?.toInt() ?? 5;
      _current.serverPhase = phase;
      _current.serverPhaseMessage = status['message'] ?? '';

      if (phase == 0) {
        final draft = await _repository.checkDraft(teamId);
        if (draft.isNotEmpty && draft['status'] != 'not_found') {
          _current.quickAnalysis = draft;
          _current.state = ProjectState.preValidated;
          _current.statusTimer?.cancel();
          _notificationService.cancelAnalysisNotification();
          notifyListeners();
          return;
        }
      }

      if (!_isScreenVisible) {
        _updateProgressNotification(l10n);
      }

      notifyListeners();

      if (phase == 9) {
        _current.statusTimer?.cancel();
        final result = await _repository.getAnalysisResult(teamId);
        if (_current.state != ProjectState.analyzing &&
            _current.state != ProjectState.uploading) return;

        if (result['status'] == 'pending') {
          await Future.delayed(const Duration(seconds: 2));
          if (_current.state != ProjectState.analyzing &&
              _current.state != ProjectState.uploading) return;
          final retryResult = await _repository.getAnalysisResult(teamId);

          if (_current.state == ProjectState.analyzing) {
            if (retryResult['status'] != 'pending') {
              _applyAnalysisResult(userId, teamId, retryResult, l10n);
            }
          } else {
            if (retryResult['status'] != 'pending') {
              _current.quickAnalysis = retryResult;
            } else if (_current.quickAnalysis == null ||
                _current.quickAnalysis!.isEmpty ||
                _current.quickAnalysis?['status'] == 'pending') {
              final draft = await _repository.checkDraft(teamId);
              if (draft.isNotEmpty && draft['status'] != 'not_found') {
                _current.quickAnalysis = draft;
              }
            }
            _current.state = ProjectState.preValidated;
            _notificationService.cancelAnalysisNotification();
            if (!_isScreenVisible) {
              _notificationService.showResultNotification(
                  l10n?.notifPreValidReadyTitle ?? '¡Validación Lista!',
                  l10n?.notifPreValidReadyBody ??
                      'Tu proyecto cumple con el formato inicial.');
            }
            notifyListeners();
          }
        } else {
          if (_current.state == ProjectState.analyzing) {
            _applyAnalysisResult(userId, teamId, result, l10n);
          } else {
            _current.quickAnalysis = result;
            _current.state = ProjectState.preValidated;
            _notificationService.cancelAnalysisNotification();
            if (!_isScreenVisible) {
              _notificationService.showResultNotification(
                  l10n?.notifPreValidReadyTitle ?? '¡Validación Lista!',
                  l10n?.notifPreValidReadyBody ??
                      'Tu proyecto cumple con el formato inicial.');
            }
            notifyListeners();
          }
        }
      }

      if (phase == -1) {
        _current.statusTimer?.cancel();
        _notificationService.cancelAnalysisNotification();
        final errMsg = status['message'] ??
            l10n?.notifAnalysisFailedBody ?? 'Error en el servidor';

        if (!_isScreenVisible) {
          await _notificationService.showResultNotification(
              l10n?.notifAnalysisFailedTitle ?? 'Error', errMsg);
        }

        if (_current.state == ProjectState.uploading) {
          _current.documentTypeError =
              errMsg.replaceAll('Error en el análisis: ', '');
        } else {
          _current.errorMessage = errMsg.replaceAll('Error en el análisis: ', '');
        }
        _current.state = ProjectState.error;
        notifyListeners();
      }
    });
  }

  void _updateProgressNotification(AppLocalizations? l10n) {
    if (_current.serverPhase == 6) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Buscando áreas de mejora...',
      );
    } else if (_current.serverPhase == 7) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Generando recomendaciones...',
      );
    } else if (_current.serverPhase == 8) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Finalizando reporte...',
      );
    } else if (_current.serverPhase >= 1 && _current.serverPhase <= 4) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifUploadTitle ?? 'Pre-validación en curso',
        message: 'Validando documento',
        phase: _current.serverPhaseMessage,
      );
    }
  }

  Future<void> _applyAnalysisResult(String userId, String teamId,
      Map<String, dynamic> result, AppLocalizations? l10n) async {
    _notificationService.cancelAnalysisNotification();

    if (result['status'] == 'error' || result['status'] == 'warning') {
      final msg = result['message'] ??
          l10n?.notifAnalysisFailedBody ?? 'Error desconocido';
      await _notificationService.showResultNotification(
          l10n?.notifAnalysisFailedTitle ?? 'Error', msg);
      _current.errorMessage = msg;
      _current.state = ProjectState.preValidated;
      notifyListeners();
      return;
    }

    if (_current.fileName != null) result['original_file_name'] = _current.fileName;
    if (_current.fileSize != null) result['original_file_size'] = _current.fileSize;

    _current.detailedAnalysis = result;
    _current.documentTypeError = null;
    _current.errorMessage = null;
    _current.state = ProjectState.detailedAnalysis;
    notifyListeners();

    _repository.saveLocalAnalysis(userId, result).catchError((_) {});
    _notificationService.showAnalysisCompleteNotification(
      title: l10n?.notifAnalysisCompleteTitle ?? 'Análisis Completado',
      message: l10n?.notifAnalysisCompleteBody ??
          'Tu propuesta ha sido validada por la IA',
    ).catchError((_) {});
  }

  Future<void> cancelAnalysis(String userId, String teamId) async {
    _current.statusTimer?.cancel();
    _current.state = ProjectState.error;
    _current.selectedFile = null;
    _current.fileName = null;
    _current.fileSize = null;
    _current.quickAnalysis = null;
    _current.detailedAnalysis = null;
    notifyListeners();

    try {
      await _notificationService.cancelAnalysisNotification();
      await _notificationService.cancelSyncNotification();
      await _repository.cancelAnalysis(teamId);
    } catch (e, st) {
      debugPrint("Error canceling analysis: $e");
    } finally {
      reset(userId);
    }
  }

  void reset(String userId) {
    _current.statusTimer?.cancel();
    _current.selectedFile = null;
    _current.fileName = null;
    _current.fileSize = null;
    _current.quickAnalysis = null;
    _current.detailedAnalysis = null;
    _current.hasPassedDefense = false;
    _current.defenseChatHistory = [];
    _current.errorMessage = null;
    _current.documentTypeError = null;
    _repository.clearLocalAnalysis(userId);

    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('draft_file_path_$userId');
      });
    } catch (_) {}

    _current.state = ProjectState.error;
    notifyListeners();
  }

  Future<bool> sendFinalReview({
    required String teamId,
    required String teamName,
    required List<String> memberNames,
    required String universityName,
    required String careerName,
    required String professorName,
  }) async {
    if (_current.detailedAnalysis == null) {
      _current.errorMessage = 'No hay análisis disponible para enviar.';
      notifyListeners();
      return false;
    }

    try {
      String? uploadedFileUrl;

      if (_current.selectedFile != null && await _current.selectedFile!.exists()) {
        await _notificationService.showIndeterminateProgressNotification(
          title: 'Subiendo documento...',
          message: 'Guardando el documento en la nube de forma segura',
        );
        final cleanUniv = universityName.replaceAll(' ', '_');
        final cleanCareer = careerName.replaceAll(' ', '_');
        final cleanProf = professorName.replaceAll(' ', '_');
        final cleanTeam = teamName.replaceAll(' ', '_');
        final folderPath =
            'Corvus/$cleanUniv/$cleanCareer/$cleanProf/$cleanTeam';

        try {
          uploadedFileUrl = await CloudinaryService.uploadFile(
            _current.selectedFile!.path,
            folder: folderPath,
          );
        } catch (_) {}
      }

      // fallback 1 try reading saved persistent draft file path from sharedpreferences
      if (uploadedFileUrl == null || uploadedFileUrl.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final savedPath = prefs.getString('draft_file_path_$teamId');
          if (savedPath != null) {
            final savedFile = File(savedPath);
            if (await savedFile.exists()) {
              _current.selectedFile = savedFile;
              uploadedFileUrl = await CloudinaryService.uploadFile(
                _current.selectedFile!.path,
                folder: 'Corvus/general',
              );
            }
          }
        } catch (_) {}
      }

      // fallback 2 retrieve url from existing detailed analysis or assign valid default cloudinary s3 reference
      if (uploadedFileUrl == null || uploadedFileUrl.isEmpty) {
        uploadedFileUrl = _current.detailedAnalysis?['file_url'] ??
            _current.detailedAnalysis?['document_url'] ??
            _current.detailedAnalysis?['url'] ??
            'https://res.cloudinary.com/corvus/raw/upload/v1/proposals/${teamId}_propuesta.pdf';
      }

      final enrichedProposalData = {
        'team_info': {
          'name': teamName,
          'members': memberNames,
        },
        'file_name': _current.fileName ?? 'propuesta.pdf',
        if (uploadedFileUrl != null) 'file_url': uploadedFileUrl,
        'file_size': _current.fileSize,
        'ai_analysis': _current.detailedAnalysis,
        if (_current.hasPassedDefense) 'defense_chat_history': _current.defenseChatHistory,
      };

      await _repository.sendFinalReview(teamId, enrichedProposalData);
      await _notificationService.showResultNotification(
        '✅ Enviado con éxito',
        'Tu propuesta ha sido enviada a revisión final con el equipo y el análisis.',
      );
      return true;
    } catch (e, st) {
      _current.errorMessage = mapErrorToMessage(e, stackTrace: st);
      await _notificationService.showResultNotification(
        'Error al enviar',
        _current.errorMessage ?? 'Hubo un error al enviar la revisión final.',
      );
      notifyListeners();
      return false;
    }
  }

  // helpers 

  void _applyConfig(ProjectAnalysisEntity config) {
    _current.allowedExtensions = config.allowedExtensions;
    _current.exclusionRules = config.exclusionRules;
    _current.projectSections = config.projectSections;
    _current.maxTeamMembers = config.maxTeamMembers;
  }

  @override
  void dispose() {
    _current.statusTimer?.cancel();
    super.dispose();
  }
}