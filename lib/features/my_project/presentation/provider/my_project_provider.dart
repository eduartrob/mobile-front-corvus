import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:http/http.dart' as http;
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
  final MyProjectRemoteDataSource _dataSource;
  final MyProjectLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  MyProjectProvider() 
      : _dataSource = MyProjectRemoteDataSource(client: http.Client()),
        _localDataSource = MyProjectLocalDataSource(),
        _notificationService = NotificationService();

  ProjectState _state = ProjectState.initial;
  ProjectState get state => _state;

  File? _selectedFile;
  File? get selectedFile => _selectedFile;
  
  String? _fileName;
  String? get fileName => _fileName;
  
  String? _fileSize;
  String? get fileSize => _fileSize;

  Map<String, dynamic>? _quickAnalysis;
  Map<String, dynamic>? get quickAnalysis => _quickAnalysis;

  Map<String, dynamic>? _detailedAnalysis;
  Map<String, dynamic>? get detailedAnalysis => _detailedAnalysis;

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
  
  Future<void> init(String userId) async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      final localAnalysis = await _localDataSource.getDetailedAnalysis(userId);
      if (localAnalysis != null) {
        _detailedAnalysis = localAnalysis;
        _fileName = localAnalysis['original_file_name'] ?? 'documento_analizado.pdf';
        _fileSize = localAnalysis['original_file_size'] ?? 'Local';
        _state = ProjectState.detailedAnalysis;
        notifyListeners();
        return;
      }

      final status = await _dataSource.getAnalysisStatus(userId);
      final phase = (status['phase'] as num?)?.toInt() ?? 0;
      
      if (phase >= 5 && phase <= 8) {
        _state = ProjectState.analyzing;
        _serverPhase = phase;
        _serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, null);
        notifyListeners();
        return;
      } else if (phase == 9) {
        final result = await _dataSource.getAnalysisResult(userId);
        if (result['status'] != 'pending' && result['status'] != 'error') {
          await _applyAnalysisResult(userId, result, null);
          return;
        }
      }

      final draft = await _dataSource.checkDraft(userId);
      if (draft.isNotEmpty && draft['status'] != 'not_found') {
        _quickAnalysis = draft;
        _fileName = 'borrador_guardado.pdf';
        _fileSize = 'Local';
        _state = ProjectState.preValidated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error inicializando MyProjectProvider: $e");
    }
  }

  Future<void> pickFile(String userId, AppLocalizations l10n) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        
        final bytes = await _selectedFile!.length();
        _fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        
        _state = ProjectState.uploading;
        notifyListeners();

        await _preValidate(userId, l10n);
      }
    } catch (e) {
      _errorMessage = 'Error seleccionando archivo: ${e.toString().replaceAll('Exception: ', '')}';
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> _preValidate(String userId, AppLocalizations l10n) async {
    try {
      if (_selectedFile == null) return;
      
      await _notificationService.showIndeterminateProgressNotification(
        title: l10n.notifUploadTitle, 
        message: l10n.notifUploadBody
      );

      final response = await _dataSource.preValidateProposal(_selectedFile!.path, userId);
      
      _quickAnalysis = response;
      _state = ProjectState.preValidated;
      
      await _notificationService.showResultNotification(l10n.notifPreValidReadyTitle, l10n.notifPreValidReadyBody);
      notifyListeners();
      
    } catch (e) {
      String errorStr = e.toString().replaceAll('Exception: ', '').replaceAll('Exception ', '');
      
      try {
        final decoded = jsonDecode(errorStr);
        if (decoded is Map && decoded.containsKey('detail')) {
          errorStr = decoded['detail'];
        }
      } catch (_) {}
      
      if (errorStr.contains('no parece ser') || errorStr.contains('Tu propuesta es válida') || errorStr.contains('Faltan secciones obligatorias')) {
        _documentTypeError = errorStr;
        await _notificationService.showResultNotification(l10n.notifErrorTitle, errorStr);
      } else {
        _errorMessage = 'Error en validación rápida: $errorStr';
        await _notificationService.showResultNotification(l10n.notifErrorTitle, l10n.notifPreValidFailed);
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

  Future<void> submitForReview(String userId, AppLocalizations l10n) async {
    _state = ProjectState.analyzing;
    _serverPhase = 5;
    _serverPhaseMessage = '';
    notifyListeners();

    try {
      await _notificationService.showAnalysisProgressNotification(
        title: l10n.notifAnalysisProgressTitle,
        message: l10n.notifAnalysisProgressBody,
        phase: l10n.notifAnalysisStartBody
      );

      await _dataSource.analyzeDraftDetailed(userId);
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

    _startPolling(userId, l10n);
  }

  void _startPolling(String userId, AppLocalizations? l10n) {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_state != ProjectState.analyzing) {
        _statusTimer?.cancel();
        return;
      }

      final status = await _dataSource.getAnalysisStatus(userId);
      
      if (_state != ProjectState.analyzing) return;
      
      final phase = (status['phase'] as num?)?.toInt() ?? 5;
      _serverPhase = phase;
      _serverPhaseMessage = status['message'] ?? '';
      
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
      }
      
      notifyListeners();

      if (phase == 9) {
        _statusTimer?.cancel();
        final result = await _dataSource.getAnalysisResult(userId);
        if (_state != ProjectState.analyzing) return;

        if (result['status'] == 'pending') {
          await Future.delayed(const Duration(seconds: 2));
          if (_state != ProjectState.analyzing) return;
          final retryResult = await _dataSource.getAnalysisResult(userId);
          _applyAnalysisResult(userId, retryResult, l10n);
        } else {
          _applyAnalysisResult(userId, result, l10n);
        }
      }

      if (phase == -1) {
        _statusTimer?.cancel();
        _notificationService.cancelAnalysisNotification();
        final errMsg = status['message'] ?? l10n?.notifAnalysisFailedBody ?? 'Error en el servidor';
        await _notificationService.showResultNotification(
            l10n?.notifAnalysisFailedTitle ?? 'Error', errMsg);
        _errorMessage = errMsg.replaceAll('Error en el análisis: ', '');
        _state = ProjectState.preValidated;
        notifyListeners();
      }
    });
  }

  Future<void> _applyAnalysisResult(String userId, Map<String, dynamic> result, AppLocalizations? l10n) async {
    _notificationService.cancelAnalysisNotification();
    
    if (result['status'] == 'error' || result['status'] == 'warning') {
      final msg = result['message'] ?? l10n?.notifAnalysisFailedBody ?? 'Error desconocido';
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
    _state = ProjectState.detailedAnalysis;
    await _localDataSource.saveDetailedAnalysis(userId, result);
    await _notificationService.showAnalysisCompleteNotification(
      title: l10n?.notifAnalysisCompleteTitle ?? 'Análisis Completado',
      message: l10n?.notifAnalysisCompleteBody ?? 'Tu propuesta ha sido validada por la IA',
    );
    notifyListeners();
  }

  Future<void> cancelAnalysis(String userId) async {
    _statusTimer?.cancel();
    await _notificationService.cancelAnalysisNotification();
    await _notificationService.cancelSyncNotification();
    await _dataSource.cancelAnalysis(userId);
    reset(userId);
  }
  
  void reset(String userId) {
    _statusTimer?.cancel();
    _state = ProjectState.initial;
    _selectedFile = null;
    _fileName = null;
    _fileSize = null;
    _quickAnalysis = null;
    _detailedAnalysis = null;
    _errorMessage = null;
    _documentTypeError = null;
    _localDataSource.clearDetailedAnalysis(userId);
    notifyListeners();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
