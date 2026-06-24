import 'package:mobile/features/inspiration/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.id,
    required super.category,
    required super.categoryIcon,
    required super.title,
    required super.description,
    required super.status,
    required super.userAvatars,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      category: json['category'],
      categoryIcon: json['categoryIcon'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      userAvatars: List<String>.from(json['userAvatars']),
    );
  }
}
