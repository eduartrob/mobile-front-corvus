class ProjectEntity {
  final String id;
  final String category;
  final String categoryIcon;
  final String title;
  final String description;
  final String status;
  final List<String> userAvatars;
  /// Número de veces que se ha consultado este nicho
  final int viewCount;
  /// Avatares de los últimos usuarios que revisaron este proyecto
  final List<String> recentViewers;
  /// Estado del análisis: "pending" o "completed"
  final String analysisStatus;
  /// Datos del análisis (hallazgo_principal, sugerencias, metricas)
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

  /// Un nicho se considera "trending" si supera las 50 vistas.
  /// Estos se muestran con el badge 🔥 (son los que "rompieron" el océano azul).
  bool get isTrending => viewCount >= 50;
}
