import 'package:flutter/material.dart';
import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';

class ProfRulesProvider extends ChangeNotifier {
  final ProfRulesRemoteDataSource remoteDataSource;

  ProfRulesProvider({required this.remoteDataSource});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isModified = false;
  bool get isModified => _isModified;

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

  int _minTeamMembers = 1;
  int get minTeamMembers => _minTeamMembers;

  int _maxTeamMembers = 5;
  int get maxTeamMembers => _maxTeamMembers;

  List<dynamic> _clusterStats = [];
  List<dynamic> get clusterStats => _clusterStats;

  String? _lastProjectId;
  String? get lastProjectId => _lastProjectId;
  
  // In-memory cache for instantaneous project switching
  final Map<String, Map<String, dynamic>> _memoryConfigCache = {};
  final Map<String, Map<String, dynamic>> _memoryStatsCache = {};

  Future<void> fetchData({String? projectId}) async {
    final pId = projectId ?? 'default';
    
    if (projectId != null && projectId != _lastProjectId) {
      if (_memoryConfigCache.containsKey(pId) && _memoryStatsCache.containsKey(pId)) {
        // Synchronously load from memory cache so first frame is correct
        _updateState(_memoryConfigCache[pId]!, _memoryStatsCache[pId]!);
        _lastProjectId = projectId;
      } else {
        // Clear UI and show skeleton only if we have NO memory cache
        _projectSections = [];
        _clusterStats = [];
        _exclusionRules = [];
        _lastProjectId = projectId;
        notifyListeners();
      }
    }

    // 1. Intentar cargar desde el caché rápido de disco
    try {
      final config = await remoteDataSource.getConfig(forceRefresh: false, projectId: projectId);
      final statsData = await remoteDataSource.getClusterStats(forceRefresh: false, projectId: projectId);
      
      // Guardar en memoria
      _memoryConfigCache[pId] = config;
      _memoryStatsCache[pId] = statsData;
      
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
      final config = await remoteDataSource.getConfig(forceRefresh: true, projectId: projectId);
      final statsData = await remoteDataSource.getClusterStats(forceRefresh: true, projectId: projectId);
      
      // Guardar en memoria
      _memoryConfigCache[pId] = config;
      _memoryStatsCache[pId] = statsData;
      
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
    _isModified = false;
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

    _minTeamMembers = config['min_team_members'] ?? 1;
    _maxTeamMembers = config['max_team_members'] ?? 5;

    _clusterStats = statsData['clusters_detail'] ?? [];
    notifyListeners();
  }

  void toggleExclusionRule(String clusterName) {
    if (_exclusionRules.contains(clusterName)) {
      _exclusionRules.remove(clusterName);
    } else {
      _exclusionRules.add(clusterName);
    }
    _isModified = true;
    notifyListeners();
  }

  Future<void> toggleExclusionRuleAndSave(
    String clusterName, 
    {String? projectId, String? authorName, String? authorPhotoUrl, String? authorId}
  ) async {
    if (_exclusionRules.contains(clusterName)) {
      _exclusionRules.remove(clusterName);
    } else {
      _exclusionRules.add(clusterName);
    }
    notifyListeners();
    await saveConfig(
      projectId: projectId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      authorId: authorId,
    );
  }
  
  void addExclusionRule(String rule) {
    if (rule.isNotEmpty && !_exclusionRules.contains(rule)) {
      _exclusionRules.add(rule);
      _isModified = true;
      notifyListeners();
    }
  }
  
  void removeExclusionRule(String rule) {
    _exclusionRules.remove(rule);
    _isModified = true;
    notifyListeners();
  }

  void addSection(String name, List<String> keywords, bool isObligatory, {String? descripcion}) {
    final newSection = <String, dynamic>{
      "nombre": name,
      "keywords": keywords,
      "obligatoria": isObligatory,
    };
    if (descripcion != null && descripcion.isNotEmpty) {
      newSection["descripcion"] = descripcion;
    }
    _projectSections.add(newSection);
    _isModified = true;
    notifyListeners();
  }

  void removeSection(int index) {
    if (index >= 0 && index < _projectSections.length) {
      _projectSections.removeAt(index);
      _isModified = true;
      notifyListeners();
    }
  }
  
  void updateSection(int index, Map<String, dynamic> updatedSection) {
    if (index >= 0 && index < _projectSections.length) {
      _projectSections[index] = updatedSection;
      _isModified = true;
      notifyListeners();
    }
  }
  
  void updateTeamLimits(int min, int max) {
    if (_minTeamMembers != min || _maxTeamMembers != max) {
      _minTeamMembers = min;
      _maxTeamMembers = max;
      _isModified = true;
      notifyListeners();
    }
  }

  Future<void> saveConfig({String? projectId, String? authorName, String? authorPhotoUrl, String? authorId}) async {
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
        _minTeamMembers,
        _maxTeamMembers,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        authorId: authorId,
        projectId: projectId,
      );
      _isModified = false;
      await remoteDataSource.notifyRulesUpdate(projectId: projectId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
