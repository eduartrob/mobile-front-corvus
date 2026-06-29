class ProjectEntity {
  final String id;
  final String category;
  final String categoryIcon;
  final String title;
  final String description;
  final String status;
  final List<String> userAvatars;
  final int viewCount;
  final List<String> recentViewers;
  final String analysisStatus;
  final Map<String, dynamic>? analysisData;

  ProjectEntity({
    required this.id,
    required this.category,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.status,
    required this.userAvatars,
    this.viewCount = 0,
    this.recentViewers = const [],
    this.analysisStatus = 'pending',
    this.analysisData,
  });

  bool get isTrending => viewCount >= 50;
}
