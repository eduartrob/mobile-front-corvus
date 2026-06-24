class ProjectEntity {
  final String id;
  final String category;
  final String categoryIcon;
  final String title;
  final String description;
  final String status;
  final List<String> userAvatars;

  ProjectEntity({
    required this.id,
    required this.category,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.status,
    required this.userAvatars,
  });
}
