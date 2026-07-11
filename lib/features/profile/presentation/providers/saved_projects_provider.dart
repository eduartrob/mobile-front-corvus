import 'package:flutter/material.dart';
import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';
import 'package:mobile/features/profile/data/repositories/saved_projects_repository.dart';

class SavedProjectsProvider extends ChangeNotifier {
  final SavedProjectsRepository _repository;
  
  List<ProjectEntity> _savedProjects = [];

  SavedProjectsProvider(this._repository) {
    _loadProjects();
  }

  List<ProjectEntity> get savedProjects => _savedProjects;

  void _loadProjects() {
    _savedProjects = _repository.getSavedProjects();
    notifyListeners();
  }

  Future<void> saveProject(ProjectEntity project) async {
    await _repository.saveProject(project);
    _loadProjects();
  }

  Future<void> removeProject(String id) async {
    await _repository.removeProject(id);
    _loadProjects();
  }

  bool isSaved(String id) {
    return _repository.isSaved(id);
  }
  
  Future<void> toggleSave(ProjectEntity project) async {
    if (isSaved(project.id)) {
      await removeProject(project.id);
    } else {
      await saveProject(project);
    }
  }
}
