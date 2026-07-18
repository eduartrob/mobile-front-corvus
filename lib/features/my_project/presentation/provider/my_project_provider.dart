import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/my_project/domain/entities/project_analysis_entity.dart';
import 'package:mobile/features/my_project/domain/repositories/project_repository.dart';
import 'package:mobile/features/my_project/data/datasources/cloudinary_service.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/l10n/app_localizations.dart';

enum ProjectState {
  initial,
  uploading,
  preValidated,
  analyzing,
  detailedAnalysis,
  error
}

class MyProjectProvider extends ChangeNotifier {
  final ProjectRepository _repository;
  final NotificationService _notificationService;

  MyProjectProvider({required ProjectRepository repository})
      : _repository = repository,
        _notificationService = NotificationService();

  // ── State ──────────────────────────────────────────────────────────────
  ProjectState _state = ProjectState.initial;
  ProjectState get state => _state;

  File? _selectedFile;
  File? get selectedFile => _selectedFile;

  String? _fileName;
  String? get fileName => _fileName;

  String? _fileSize;
  String? get fileSize => _fileSize;

  Map<String, dynamic>? _quickAnalysis;
  Map<String, dynamic>? _detailedAnalysis;
  bool _hasPassedDefense = false;
  List<Map<String, String>> _defenseChatHistory = [];

  String? _activeSessionId;
  List<Map<String, dynamic>> _activeChatMessages = [];
  int _activeMessageCount = 0;

  Map<String, dynamic>? get quickAnalysis => _quickAnalysis;
  Map<String, dynamic>? get detailedAnalysis => _detailedAnalysis;
  bool get hasPassedDefense => _hasPassedDefense;

  String? _universityId;
  String? _careerId;

  void setContext({String? universityId, String? careerId}) {
    _universityId = universityId;
    _careerId = careerId;
  }

  void setDefensePassed(List<Map<String, String>> history) {
    _hasPassedDefense = true;
    _defenseChatHistory = history;
    _activeSessionId = null;
    _activeChatMessages = [];
    _activeMessageCount = 0;
    notifyListeners();
  }

  String? get activeSessionId => _activeSessionId;
  List<Map<String, dynamic>> get activeChatMessages => _activeChatMessages;
  int get activeMessageCount => _activeMessageCount;

  void saveActiveSession(
      String sessionId, List<Map<String, dynamic>> messages, int messageCount) {
    _activeSessionId = sessionId;
    _activeChatMessages = messages;
    _activeMessageCount = messageCount;
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _documentTypeError;
  String? get documentTypeError => _documentTypeError;

  int _serverPhase = 5;
  int get serverPhase => _serverPhase;

  String _serverPhaseMessage = '';
  String get serverPhaseMessage => _serverPhaseMessage;

  Timer? _statusTimer;
  bool _initialized = false;
  bool _isScreenVisible = false;
  bool get isScreenVisible => _isScreenVisible;

  void setScreenVisible(bool value) {
    _isScreenVisible = value;
  }

  String? _projectId;
  String? get projectId => _projectId;

  // ── Config from server ─────────────────────────────────────────────────
  List<String> _allowedExtensions = ['pdf', 'md', 'txt'];
  List<String> get allowedExtensions => _allowedExtensions;
  String get allowedExtensionsString => _allowedExtensions.join(', ');

  List<String> _exclusionRules = [];
  List<String> get exclusionRules => _exclusionRules;

  List<Map<String, dynamic>> _projectSections = [];
  List<Map<String, dynamic>> get projectSections => _projectSections;

  int _maxTeamMembers = 3;
  int get maxTeamMembers => _maxTeamMembers;

  // ── Public API ─────────────────────────────────────────────────────────

  Future<void> refreshConfig() async {
    final config = await _repository.fetchConfig(projectId: _projectId);
    _applyConfig(config);
    notifyListeners();
  }

  Future<void> init(String userId, String teamId,
      {String? projectId, bool forceRefresh = false}) async {
    if (_projectId != projectId) {
      _initialized = false;
      _state = ProjectState.initial;
      _quickAnalysis = null;
      _detailedAnalysis = null;
      _hasPassedDefense = false;
      _defenseChatHistory = [];
      _activeSessionId = null;
      _activeChatMessages = [];
      _activeMessageCount = 0;
      _fileName = null;
      _fileSize = null;
      _selectedFile = null;
      notifyListeners();
    }

    if (_initialized && !forceRefresh) return;
    _initialized = true;
    _projectId = projectId;

    try {
      final config = await _repository.fetchConfig(projectId: projectId);
      _applyConfig(config);

      final localAnalysis = await _repository.getLocalAnalysis(userId);
      if (localAnalysis != null) {
        _detailedAnalysis = localAnalysis;
        _fileName = localAnalysis['original_file_name'] ??
            'documento_analizado.pdf';
        _fileSize = localAnalysis['original_file_size'] ?? 'Local';
        _documentTypeError = null;
        _errorMessage = null;
        _state = ProjectState.detailedAnalysis;
        notifyListeners();
        return;
      }

      final status = await _repository.getAnalysisStatus(teamId);
      final phase = (status['phase'] as num?)?.toInt() ?? 0;

      if (phase >= 1 && phase < 5) {
        _state = ProjectState.uploading;
        _serverPhase = phase;
        _serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, teamId, null);
        notifyListeners();
        return;
      } else if (phase >= 5 && phase <= 8) {
        _state = ProjectState.analyzing;
        _serverPhase = phase;
        _serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, teamId, null);
        notifyListeners();
        return;
      } else if (phase == 9) {
        final result = await _repository.getAnalysisResult(teamId);
        if (result['status'] != 'pending' && result['status'] != 'error') {
          if (result.containsKey('general_feedback') ||
              result.containsKey('innovation_index') ||
              result.containsKey('semantic_collision_risk')) {
            await _applyAnalysisResult(userId, teamId, result, null);
          } else {
            _quickAnalysis = result;
            _state = ProjectState.preValidated;
            notifyListeners();
          }
          return;
        }
      }

      final draft = await _repository.checkDraft(teamId);
      if (draft.isNotEmpty && draft['status'] != 'not_found') {
        _quickAnalysis = draft;
        _fileName = draft['filename'] ?? 'borrador_guardado.pdf';
        _fileSize = 'Local';

        final prefs = await SharedPreferences.getInstance();
        final savedPath = prefs.getString('draft_file_path_$userId');
        if (savedPath != null) {
          final savedFile = File(savedPath);
          if (await savedFile.exists()) {
            _selectedFile = savedFile;
          }
        }

        _state = ProjectState.preValidated;
        notifyListeners();
      } else {
        _state = ProjectState.error;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error inicializando MyProjectProvider: $e");
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> pickFile(String userId, String teamId, String userName,
      AppLocalizations l10n) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            _allowedExtensions.isNotEmpty ? _allowedExtensions : ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _errorMessage = '';
        _documentTypeError = '';
        _serverPhaseMessage = '';
        _serverPhase = 0;
        _quickAnalysis = null;
        final file = File(result.files.single.path!);
        final bytes = await file.length();

        if (bytes > 10 * 1024 * 1024) {
          _errorMessage =
              'El archivo supera el tamaño máximo permitido de 10 MB.';
          _state = ProjectState.error;
          notifyListeners();
          return;
        }

        _selectedFile = file;
        _fileName = result.files.single.name;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('draft_file_path_$userId', file.path);

        _fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        _state = ProjectState.uploading;
        notifyListeners();

        await _preValidate(userId, teamId, userName, l10n);
      }
    } catch (e) {
      _errorMessage =
          'Error seleccionando archivo: ${e.toString().replaceAll('Exception: ', '')}';
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> _preValidate(String userId, String teamId, String userName,
      AppLocalizations l10n) async {
    try {
      if (_selectedFile == null) return;

      final response = await _repository.preValidateProposal(
        _selectedFile!.path,
        teamId,
        userId,
        userName,
        universityId: _universityId,
        careerId: _careerId,
      );

      if (response['status'] == 'pending') {
        _serverPhase = 1;
        _serverPhaseMessage = response['message'] ?? '';
        _startPolling(userId, teamId, l10n);
        notifyListeners();
      } else {
        _quickAnalysis = response;
        _state = ProjectState.preValidated;
        if (!_isScreenVisible) {
          await _notificationService.showResultNotification(
              l10n.notifPreValidReadyTitle, l10n.notifPreValidReadyBody);
        }
        notifyListeners();
      }
    } catch (e) {
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

      _documentTypeError = errorStr;
      if (!_isScreenVisible) {
        await _notificationService.showResultNotification(
            l10n.notifErrorTitle, errorStr);
      }

      _state = ProjectState.error;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == ProjectState.error) {
      _state = ProjectState.initial;
    }
    notifyListeners();
  }

  Future<void> submitForReview(
      String userId, String teamId, AppLocalizations l10n) async {
    _state = ProjectState.analyzing;
    _serverPhase = 5;
    _serverPhaseMessage = '';
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
    } catch (e) {
      _statusTimer?.cancel();
      _notificationService.cancelAnalysisNotification();
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      await _notificationService.showResultNotification(
          l10n.notifAnalysisErrorTitle, cleanMsg);
      _errorMessage = cleanMsg;
      _state = ProjectState.preValidated;
      notifyListeners();
      return;
    }

    _startPolling(userId, teamId, l10n);
  }

  void _startPolling(String userId, String teamId, AppLocalizations? l10n) {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_state != ProjectState.analyzing &&
          _state != ProjectState.uploading) {
        _statusTimer?.cancel();
        return;
      }

      final status = await _repository.getAnalysisStatus(teamId);

      if (_state != ProjectState.analyzing &&
          _state != ProjectState.uploading) return;

      final phase = (status['phase'] as num?)?.toInt() ?? 5;
      _serverPhase = phase;
      _serverPhaseMessage = status['message'] ?? '';

      if (!_isScreenVisible) {
        _updateProgressNotification(l10n);
      }

      notifyListeners();

      if (phase == 9) {
        _statusTimer?.cancel();
        final result = await _repository.getAnalysisResult(teamId);
        if (_state != ProjectState.analyzing &&
            _state != ProjectState.uploading) return;

        if (result['status'] == 'pending') {
          await Future.delayed(const Duration(seconds: 2));
          if (_state != ProjectState.analyzing &&
              _state != ProjectState.uploading) return;
          final retryResult = await _repository.getAnalysisResult(teamId);

          if (_state == ProjectState.analyzing) {
            if (retryResult['status'] != 'pending') {
              _applyAnalysisResult(userId, teamId, retryResult, l10n);
            }
          } else {
            if (retryResult['status'] != 'pending') {
              _quickAnalysis = retryResult;
            } else if (_quickAnalysis == null ||
                _quickAnalysis!.isEmpty ||
                _quickAnalysis?['status'] == 'pending') {
              final draft = await _repository.checkDraft(teamId);
              if (draft.isNotEmpty && draft['status'] != 'not_found') {
                _quickAnalysis = draft;
              }
            }
            _state = ProjectState.preValidated;
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
          if (_state == ProjectState.analyzing) {
            _applyAnalysisResult(userId, teamId, result, l10n);
          } else {
            _quickAnalysis = result;
            _state = ProjectState.preValidated;
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
        _statusTimer?.cancel();
        _notificationService.cancelAnalysisNotification();
        final errMsg = status['message'] ??
            l10n?.notifAnalysisFailedBody ?? 'Error en el servidor';

        if (!_isScreenVisible) {
          await _notificationService.showResultNotification(
              l10n?.notifAnalysisFailedTitle ?? 'Error', errMsg);
        }

        if (_state == ProjectState.uploading) {
          _documentTypeError =
              errMsg.replaceAll('Error en el análisis: ', '');
        } else {
          _errorMessage = errMsg.replaceAll('Error en el análisis: ', '');
        }
        _state = ProjectState.error;
        notifyListeners();
      }
    });
  }

  void _updateProgressNotification(AppLocalizations? l10n) {
    if (_serverPhase == 6) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Buscando áreas de mejora...',
      );
    } else if (_serverPhase == 7) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Generando recomendaciones...',
      );
    } else if (_serverPhase == 8) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifAnalysisProgressTitle ?? 'Análisis en curso',
        message: l10n?.notifAnalysisProgressBody ?? 'Procesando...',
        phase: 'Finalizando reporte...',
      );
    } else if (_serverPhase >= 1 && _serverPhase <= 4) {
      _notificationService.showAnalysisProgressNotification(
        title: l10n?.notifUploadTitle ?? 'Pre-validación en curso',
        message: 'Validando documento',
        phase: _serverPhaseMessage,
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
      _errorMessage = msg;
      _state = ProjectState.preValidated;
      notifyListeners();
      return;
    }

    if (_fileName != null) result['original_file_name'] = _fileName;
    if (_fileSize != null) result['original_file_size'] = _fileSize;

    _detailedAnalysis = result;
    _documentTypeError = null;
    _errorMessage = null;
    _state = ProjectState.detailedAnalysis;
    await _repository.saveLocalAnalysis(userId, result);
    await _notificationService.showAnalysisCompleteNotification(
      title: l10n?.notifAnalysisCompleteTitle ?? 'Análisis Completado',
      message: l10n?.notifAnalysisCompleteBody ??
          'Tu propuesta ha sido validada por la IA',
    );
    notifyListeners();
  }

  Future<void> cancelAnalysis(String userId, String teamId) async {
    _statusTimer?.cancel();
    _state = ProjectState.error;
    _selectedFile = null;
    _fileName = null;
    _fileSize = null;
    _quickAnalysis = null;
    _detailedAnalysis = null;
    notifyListeners();

    try {
      await _notificationService.cancelAnalysisNotification();
      await _notificationService.cancelSyncNotification();
      await _repository.cancelAnalysis(teamId);
    } catch (e) {
      debugPrint("Error canceling analysis: $e");
    } finally {
      reset(userId);
    }
  }

  void reset(String userId) {
    _statusTimer?.cancel();
    _selectedFile = null;
    _fileName = null;
    _fileSize = null;
    _quickAnalysis = null;
    _detailedAnalysis = null;
    _hasPassedDefense = false;
    _defenseChatHistory = [];
    _errorMessage = null;
    _documentTypeError = null;
    _repository.clearLocalAnalysis(userId);

    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('draft_file_path_$userId');
      });
    } catch (_) {}

    _state = ProjectState.error;
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
    if (_detailedAnalysis == null) {
      _errorMessage = 'No hay análisis disponible para enviar.';
      notifyListeners();
      return false;
    }

    try {
      String? uploadedFileUrl;

      if (_selectedFile != null) {
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

        uploadedFileUrl = await CloudinaryService.uploadFile(
          _selectedFile!.path,
          folder: folderPath,
        );
      }

      final enrichedProposalData = {
        'team_info': {
          'name': teamName,
          'members': memberNames,
        },
        'file_name': _fileName ?? 'propuesta.pdf',
        if (uploadedFileUrl != null) 'file_url': uploadedFileUrl,
        'file_size': _fileSize,
        'ai_analysis': _detailedAnalysis,
        if (_hasPassedDefense) 'defense_chat_history': _defenseChatHistory,
      };

      await _repository.sendFinalReview(teamId, enrichedProposalData);
      await _notificationService.showResultNotification(
        '✅ Enviado con éxito',
        'Tu propuesta ha sido enviada a revisión final con el equipo y el análisis.',
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      await _notificationService.showResultNotification(
        'Error al enviar',
        _errorMessage ?? 'Hubo un error al enviar la revisión final.',
      );
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _applyConfig(ProjectAnalysisEntity config) {
    _allowedExtensions = config.allowedExtensions;
    _exclusionRules = config.exclusionRules;
    _projectSections = config.projectSections;
    _maxTeamMembers = config.maxTeamMembers;
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}