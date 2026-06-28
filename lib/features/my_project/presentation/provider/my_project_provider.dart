import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/services/notification_service.dart';

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
  
  bool _initialized = false;
  
  Future<void> init(String userId) async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      // 1. Primero intentar cargar el análisis final de memoria local
      final localAnalysis = await _localDataSource.getDetailedAnalysis(userId);
      if (localAnalysis != null) {
        _detailedAnalysis = localAnalysis;
        _state = ProjectState.detailedAnalysis;
        notifyListeners();
        return; // Si ya hay análisis final, no buscamos el borrador rápido
      }

      // 2. Si no hay análisis final, buscar el borrador rápido
      final draft = await _dataSource.checkDraft(userId);
      if (draft.isNotEmpty && draft['status'] != 'not_found') {
        _quickAnalysis = draft;
        _fileName = 'borrador_guardado.pdf';
        _fileSize = 'Local';
        _state = ProjectState.preValidated;
        notifyListeners();
      }
    } catch (e) {
      print("Error inicializando: $e");
    }
  }

  Future<void> pickFile(String userId) async {
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

        await _preValidate(userId);
      }
    } catch (e) {
      _errorMessage = 'Error seleccionando archivo: $e';
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> _preValidate(String userId) async {
    try {
      if (_selectedFile == null) return;
      
      await _notificationService.showIndeterminateProgressNotification(
        title: 'Subiendo propuesta', 
        message: 'Analizando estructura RAG rápida...'
      );

      final response = await _dataSource.preValidateProposal(_selectedFile!.path, userId);
      
      _quickAnalysis = response;
      _state = ProjectState.preValidated;
      
      await _notificationService.showResultNotification('Pre-validación lista', 'Puedes revisar las heurísticas iniciales.');
      notifyListeners();
      
    } catch (e) {
      await _notificationService.showResultNotification('Error', 'Falló la pre-validación.');
      _errorMessage = 'Error en validación rápida: $e';
      _state = ProjectState.error;
      notifyListeners();
    }
  }

  Future<void> submitForReview(String userId) async {
    _state = ProjectState.analyzing;
    notifyListeners();

    try {
      await _notificationService.showIndeterminateProgressNotification(
        title: 'Análisis Detallado', 
        message: 'Ollama está evaluando rigurosidad y originalidad...'
      );
      
      final response = await _dataSource.analyzeDraftDetailed(userId);
      
      if (response['status'] == 'warning') {
        throw Exception(response['message'] ?? 'Error de IA (Ollama no disponible)');
      }
      
      _detailedAnalysis = response;
      _state = ProjectState.detailedAnalysis;
      
      // Guardar localmente para persistencia
      await _localDataSource.saveDetailedAnalysis(userId, response);
      
      await _notificationService.showResultNotification('Análisis Finalizado', 'Los resultados de Ollama están listos.');
      notifyListeners();
      
    } catch (e) {
      await _notificationService.showResultNotification('Error', 'Falló el análisis de Ollama.');
      _errorMessage = 'Error en análisis detallado: $e';
      _state = ProjectState.error;
      notifyListeners();
    }
  }
  
  void reset(String userId) {
    _state = ProjectState.initial;
    _selectedFile = null;
    _fileName = null;
    _fileSize = null;
    _quickAnalysis = null;
    _detailedAnalysis = null;
    _errorMessage = null;
    _localDataSource.clearDetailedAnalysis(userId);
    notifyListeners();
  }
}
