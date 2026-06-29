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
    super.viewCount = 0,
    super.recentViewers = const [],
    super.analysisStatus = 'pending',
    super.analysisData,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      category: json['category'] ?? '',
      categoryIcon: json['categoryIcon'] ?? 'auto_awesome',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      userAvatars: List<String>.from(json['userAvatars'] ?? []),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      recentViewers: List<String>.from(json['recent_viewers'] ?? []),
      analysisStatus: json['analysis_status'] ?? 'pending',
      analysisData: json['analysis_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'categoryIcon': categoryIcon,
      'title': title,
      'description': description,
      'status': status,
      'userAvatars': userAvatars,
      'view_count': viewCount,
      'recent_viewers': recentViewers,
      'analysis_status': analysisStatus,
      'analysis_data': analysisData,
    };
  }
}
