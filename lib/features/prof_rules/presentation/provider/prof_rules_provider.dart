import 'package:flutter/material.dart';
import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';

class ProfRulesProvider extends ChangeNotifier {
  final ProfRulesRemoteDataSource remoteDataSource;

  ProfRulesProvider({required this.remoteDataSource});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Backend state
  List<String> _allowedExtensions = ['.pdf', '.docx'];
  String _llmProvider = 'ollama';
  String _driveFolderId = '';
  
  List<String> _exclusionRules = [];
  List<String> get exclusionRules => _exclusionRules;

  List<Map<String, dynamic>> _projectSections = [];
  List<Map<String, dynamic>> get projectSections => _projectSections;

  List<dynamic> _clusterStats = [];
  List<dynamic> get clusterStats => _clusterStats;

  Future<void> fetchData() async {
    // 1. Intentar cargar desde el caché rápido (sin loader invasivo)
    try {
      final config = await remoteDataSource.getConfig(forceRefresh: false);
      final statsData = await remoteDataSource.getClusterStats(forceRefresh: false);
      _updateState(config, statsData);
    } catch (e) {
      // Ignoramos errores de caché
    }

    // Si no hay datos cacheados en absoluto, mostramos el Skeleton completo
    if (_projectSections.isEmpty && _clusterStats.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    // 2. Traer datos frescos de la red en segundo plano
    try {
      final config = await remoteDataSource.getConfig(forceRefresh: true);
      final statsData = await remoteDataSource.getClusterStats(forceRefresh: true);
      _updateState(config, statsData);
      _errorMessage = null;
    } catch (e) {
      if (_projectSections.isEmpty && _clusterStats.isEmpty) {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateState(Map<String, dynamic> config, Map<String, dynamic> statsData) {
    _allowedExtensions = List<String>.from(config['allowed_extensions'] ?? ['.pdf', '.docx']);
    _llmProvider = config['llm_provider'] ?? 'ollama';
    _driveFolderId = config['drive_folder_id'] ?? '';
    _exclusionRules = List<String>.from(config['exclusion_rules'] ?? []);
    
    final sectionsData = config['project_sections'] as List?;
    if (sectionsData != null) {
      _projectSections = sectionsData.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _projectSections = [];
    }

    _clusterStats = statsData['clusters_detail'] ?? [];
    notifyListeners();
  }

  void toggleExclusionRule(String clusterName) {
    if (_exclusionRules.contains(clusterName)) {
      _exclusionRules.remove(clusterName);
    } else {
      _exclusionRules.add(clusterName);
    }
    notifyListeners();
  }
  
  void addExclusionRule(String rule) {
    if (rule.isNotEmpty && !_exclusionRules.contains(rule)) {
      _exclusionRules.add(rule);
      notifyListeners();
    }
  }
  
  void removeExclusionRule(String rule) {
    _exclusionRules.remove(rule);
    notifyListeners();
  }

  void addSection(String name, List<String> keywords, bool isObligatory) {
    _projectSections.add({
      "nombre": name,
      "keywords": keywords,
      "obligatoria": isObligatory,
    });
    notifyListeners();
  }

  void removeSection(int index) {
    if (index >= 0 && index < _projectSections.length) {
      _projectSections.removeAt(index);
      notifyListeners();
    }
  }
  
  void updateSection(int index, Map<String, dynamic> updatedSection) {
    if (index >= 0 && index < _projectSections.length) {
      _projectSections[index] = updatedSection;
      notifyListeners();
    }
  }

  Future<void> generateSectionsWithAI() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generated = await remoteDataSource.generateSectionsWithAI();
      _projectSections = generated;
    } catch (e) {
      _errorMessage = 'Error generando con IA: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveConfig({String? authorName, String? authorPhotoUrl}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDataSource.updateConfig(
        _allowedExtensions,
        _llmProvider,
        _driveFolderId,
        _exclusionRules,
        _projectSections,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
