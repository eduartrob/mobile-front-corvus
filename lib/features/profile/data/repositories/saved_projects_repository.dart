import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/inspiration/data/models/project_model.dart';

class SavedProjectsRepository {
  static const String _savedProjectsKey = 'saved_projects_v1';
  final SharedPreferences _prefs;

  SavedProjectsRepository(this._prefs);

  List<ProjectEntity> getSavedProjects() {
    final String? projectsJson = _prefs.getString(_savedProjectsKey);
    if (projectsJson == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(projectsJson);
      return decodedList.map((json) => ProjectModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error decoding saved projects: $e');
      return [];
    }
  }

  Future<void> saveProject(ProjectEntity project) async {
    final projects = getSavedProjects();
    
    // Evitar duplicados
    if (projects.any((p) => p.id == project.id)) return;
    
    // Crear el modelo para poder serializarlo
    final model = ProjectModel(
      id: project.id,
      category: project.category,
      categoryIcon: project.categoryIcon,
      title: project.title,
      description: project.description,
      status: project.status,
      userAvatars: project.userAvatars,
      viewCount: project.viewCount,
      recentViewers: project.recentViewers,
      analysisStatus: project.analysisStatus,
      analysisData: project.analysisData,
    );

    projects.add(model);
    await _saveToPrefs(projects);
  }

  Future<void> removeProject(String id) async {
    final projects = getSavedProjects();
    projects.removeWhere((p) => p.id == id);
    await _saveToPrefs(projects);
  }

  bool isSaved(String id) {
    final projects = getSavedProjects();
    return projects.any((p) => p.id == id);
  }

  Future<void> _saveToPrefs(List<ProjectEntity> projects) async {
    final List<Map<String, dynamic>> jsonList = projects.map((p) {
      final model = ProjectModel(
        id: p.id,
        category: p.category,
        categoryIcon: p.categoryIcon,
        title: p.title,
        description: p.description,
        status: p.status,
        userAvatars: p.userAvatars,
        viewCount: p.viewCount,
        recentViewers: p.recentViewers,
        analysisStatus: p.analysisStatus,
        analysisData: p.analysisData,
      );
      return model.toJson();
    }).toList();
    
    await _prefs.setString(_savedProjectsKey, jsonEncode(jsonList));
  }
}
