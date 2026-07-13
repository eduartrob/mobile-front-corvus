import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:mobile/features/my_project/data/datasources/cloudinary_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/network/api_config.dart';

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
      : _dataSource = MyProjectRemoteDataSource(client: apiClient),
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
  bool _isScreenVisible = false;
  bool get isScreenVisible => _isScreenVisible;
  void setScreenVisible(bool value) {
    _isScreenVisible = value;
  }
  
  List<String> _allowedExtensions = ['pdf', 'md', 'txt'];
  List<String> get allowedExtensions => _allowedExtensions;
  
  String get allowedExtensionsString => _allowedExtensions.join(', ');

  Future<void> _fetchConfig() async {
    try {
      // Intentamos obtener la configuración del admin panel
      final response = await apiClient.get(Uri.parse('${ApiConfig.apiGatewayUrl}/clustering/integrator/admin/config'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['allowed_extensions'] != null) {
          final List<dynamic> exts = data['allowed_extensions'];
          _allowedExtensions = exts
              .map((e) => e.toString().replaceAll('.', '').trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching config, using defaults: $e");
    }
  }
  
  Future<void> init(String userId) async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      await _fetchConfig();

      final localAnalysis = await _localDataSource.getDetailedAnalysis(userId);
      if (localAnalysis != null) {
        _detailedAnalysis = localAnalysis;
        _fileName = localAnalysis['original_file_name'] ?? 'documento_analizado.pdf';
        _fileSize = localAnalysis['original_file_size'] ?? 'Local';
        // Clear any previous validation errors
        _documentTypeError = null;
        _errorMessage = null;
        _state = ProjectState.detailedAnalysis;
        notifyListeners();
        return;
      }

      final status = await _dataSource.getAnalysisStatus(userId);
      final phase = (status['phase'] as num?)?.toInt() ?? 0;
      
      if (phase >= 1 && phase < 5) {
        _state = ProjectState.uploading;
        _serverPhase = phase;
        _serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, null);
        notifyListeners();
        return;
      } else if (phase >= 5 && phase <= 8) {
        _state = ProjectState.analyzing;
        _serverPhase = phase;
        _serverPhaseMessage = status['message'] ?? '';
        _startPolling(userId, null);
        notifyListeners();
        return;
      } else if (phase == 9) {
        final result = await _dataSource.getAnalysisResult(userId);
        if (result['status'] != 'pending' && result['status'] != 'error') {
          // If it's detailed analysis result
          if (result.containsKey('general_feedback') || result.containsKey('innovation_index') || result.containsKey('semantic_collision_risk')) {
              await _applyAnalysisResult(userId, result, null);
          } else {
              _quickAnalysis = result;
              _state = ProjectState.preValidated;
              notifyListeners();
          }
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
      } else {
        // No local analysis, no draft, no server analysis → user needs to upload
        _state = ProjectState.error;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error inicializando MyProjectProvider: $e");
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> pickFile(String userId, AppLocalizations l10n) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions.isNotEmpty ? _allowedExtensions : ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.length();
        
        if (bytes > 10 * 1024 * 1024) {
          _errorMessage = 'El archivo supera el tamaño máximo permitido de 10 MB.';
          _state = ProjectState.error;
          notifyListeners();
          return;
        }

        _selectedFile = file;
        _fileName = result.files.single.name;
        
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
      
      if (!_isScreenVisible) {
        await _notificationService.showIndeterminateProgressNotification(
          title: l10n.notifUploadTitle, 
          message: l10n.notifUploadBody
        );
      }

      final response = await _dataSource.preValidateProposal(_selectedFile!.path, userId);
      
      if (response['status'] == 'pending') {
          _serverPhase = 1;
          _serverPhaseMessage = response['message'] ?? '';
          _startPolling(userId, l10n);
          notifyListeners();
      } else {
          _quickAnalysis = response;
          _state = ProjectState.preValidated;
          if (!_isScreenVisible) {
             await _notificationService.showResultNotification(l10n.notifPreValidReadyTitle, l10n.notifPreValidReadyBody);
          }
          notifyListeners();
      }
      
    } catch (e) {
      String errorStr = e.toString().replaceAll('Exception: ', '').replaceAll('Exception ', '');
      
      try {
        final decoded = jsonDecode(errorStr);
        if (decoded is Map && decoded.containsKey('detail')) {
          errorStr = decoded['detail'];
        }
      } catch (_) {}
      
      _documentTypeError = errorStr;
      if (!_isScreenVisible) {
         await _notificationService.showResultNotification(l10n.notifErrorTitle, errorStr);
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
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_state != ProjectState.analyzing && _state != ProjectState.uploading) {
        _statusTimer?.cancel();
        return;
      }

      final status = await _dataSource.getAnalysisStatus(userId);
      
      if (_state != ProjectState.analyzing && _state != ProjectState.uploading) return;
      
      final phase = (status['phase'] as num?)?.toInt() ?? 5;
      _serverPhase = phase;
      _serverPhaseMessage = status['message'] ?? '';
      
      if (!_isScreenVisible) {
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
      
      notifyListeners();

      if (phase == 9) {
        _statusTimer?.cancel();
        final result = await _dataSource.getAnalysisResult(userId);
        if (_state != ProjectState.analyzing && _state != ProjectState.uploading) return;

        if (result['status'] == 'pending') {
          await Future.delayed(const Duration(seconds: 2));
          if (_state != ProjectState.analyzing && _state != ProjectState.uploading) return;
          final retryResult = await _dataSource.getAnalysisResult(userId);
          
          if (_state == ProjectState.analyzing) {
              if (retryResult['status'] != 'pending') {
                  _applyAnalysisResult(userId, retryResult, l10n);
              }
          } else {
              if (retryResult['status'] != 'pending') {
                  _quickAnalysis = retryResult;
              } else if (_quickAnalysis == null || _quickAnalysis!.isEmpty || _quickAnalysis?['status'] == 'pending') {
                  final draft = await _dataSource.checkDraft(userId);
                  if (draft.isNotEmpty && draft['status'] != 'not_found') {
                      _quickAnalysis = draft;
                  }
              }
              _state = ProjectState.preValidated;
              _notificationService.cancelAnalysisNotification();
              if (!_isScreenVisible) {
                 _notificationService.showResultNotification(l10n?.notifPreValidReadyTitle ?? '¡Validación Lista!', l10n?.notifPreValidReadyBody ?? 'Tu proyecto cumple con el formato inicial.');
              }
              notifyListeners();
          }
        } else {
          if (_state == ProjectState.analyzing) {
              _applyAnalysisResult(userId, result, l10n);
          } else {
              _quickAnalysis = result;
              _state = ProjectState.preValidated;
              _notificationService.cancelAnalysisNotification();
              if (!_isScreenVisible) {
                 _notificationService.showResultNotification(l10n?.notifPreValidReadyTitle ?? '¡Validación Lista!', l10n?.notifPreValidReadyBody ?? 'Tu proyecto cumple con el formato inicial.');
              }
              notifyListeners();
          }
        }
      }

      if (phase == -1) {
        _statusTimer?.cancel();
        _notificationService.cancelAnalysisNotification();
        final errMsg = status['message'] ?? l10n?.notifAnalysisFailedBody ?? 'Error en el servidor';
        
        if (!_isScreenVisible) {
           await _notificationService.showResultNotification(
              l10n?.notifAnalysisFailedTitle ?? 'Error', errMsg);
        }
        
        if (_state == ProjectState.uploading) {
            _documentTypeError = errMsg.replaceAll('Error en el análisis: ', '');
        } else {
            _errorMessage = errMsg.replaceAll('Error en el análisis: ', '');
        }
        _state = ProjectState.error; // En lugar de volver a preValidated, ir a error para subir de nuevo
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
    // Clear any lingering validation errors — analysis succeeded
    _documentTypeError = null;
    _errorMessage = null;
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
      await _dataSource.cancelAnalysis(userId);
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
    _errorMessage = null;
    _documentTypeError = null;
    _localDataSource.clearDetailedAnalysis(userId);
    
    // Set to error state so the UploadZoneWidget is shown
    _state = ProjectState.error;
    notifyListeners();
  }

  Future<bool> sendFinalReview({
    required String teamId,
    required String teamName,
    required List<String> memberNames,
  }) async {
    if (_detailedAnalysis == null) {
       _errorMessage = 'No hay análisis disponible para enviar.';
       notifyListeners();
       return false;
    }

    try {
      String? uploadedFileUrl;
      
      // Attempt to upload the file to Cloudinary if we have it locally
      if (_selectedFile != null) {
        await _notificationService.showIndeterminateProgressNotification(
          title: 'Subiendo documento...', 
          message: 'Guardando el documento en la nube de forma segura'
        );
        uploadedFileUrl = await CloudinaryService.uploadFile(_selectedFile!.path);
      }

      // Build an enriched proposal_data with all required context for teachers
      final enrichedProposalData = {
        'team_info': {
          'name': teamName,
          'members': memberNames,
        },
        'file_name': _fileName ?? 'propuesta.pdf',
        if (uploadedFileUrl != null) 'file_url': uploadedFileUrl,
        'file_size': _fileSize,
        'ai_analysis': _detailedAnalysis,
      };

      await _dataSource.sendFinalReview(teamId, enrichedProposalData);
      await _notificationService.showResultNotification(
        '✅ Enviado con éxito', 
        'Tu propuesta ha sido enviada a revisión final con el equipo y el análisis.'
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      await _notificationService.showResultNotification(
        'Error al enviar', 
        _errorMessage ?? 'Hubo un error al enviar la revisión final.'
      );
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
