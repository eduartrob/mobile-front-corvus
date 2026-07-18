/// Entidad de dominio que representa el estado del análisis de un proyecto.
/// Totalmente independiente de la capa de datos y presentación.
class ProjectAnalysisEntity {
  final String? fileName;
  final String? fileSize;
  final Map<String, dynamic>? quickAnalysis;
  final Map<String, dynamic>? detailedAnalysis;
  final bool hasPassedDefense;
  final List<Map<String, String>> defenseChatHistory;
  final int serverPhase;
  final String serverPhaseMessage;
  final String? errorMessage;
  final String? documentTypeError;
  final List<String> allowedExtensions;
  final List<String> exclusionRules;
  final List<Map<String, dynamic>> projectSections;
  final int maxTeamMembers;

  const ProjectAnalysisEntity({
    this.fileName,
    this.fileSize,
    this.quickAnalysis,
    this.detailedAnalysis,
    this.hasPassedDefense = false,
    this.defenseChatHistory = const [],
    this.serverPhase = 0,
    this.serverPhaseMessage = '',
    this.errorMessage,
    this.documentTypeError,
    this.allowedExtensions = const ['pdf', 'md', 'txt'],
    this.exclusionRules = const [],
    this.projectSections = const [],
    this.maxTeamMembers = 3,
  });

  ProjectAnalysisEntity copyWith({
    String? fileName,
    String? fileSize,
    Map<String, dynamic>? quickAnalysis,
    Map<String, dynamic>? detailedAnalysis,
    bool? hasPassedDefense,
    List<Map<String, String>>? defenseChatHistory,
    int? serverPhase,
    String? serverPhaseMessage,
    String? errorMessage,
    String? documentTypeError,
    List<String>? allowedExtensions,
    List<String>? exclusionRules,
    List<Map<String, dynamic>>? projectSections,
    int? maxTeamMembers,
  }) {
    return ProjectAnalysisEntity(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      quickAnalysis: quickAnalysis ?? this.quickAnalysis,
      detailedAnalysis: detailedAnalysis ?? this.detailedAnalysis,
      hasPassedDefense: hasPassedDefense ?? this.hasPassedDefense,
      defenseChatHistory: defenseChatHistory ?? this.defenseChatHistory,
      serverPhase: serverPhase ?? this.serverPhase,
      serverPhaseMessage: serverPhaseMessage ?? this.serverPhaseMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      documentTypeError: documentTypeError ?? this.documentTypeError,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      exclusionRules: exclusionRules ?? this.exclusionRules,
      projectSections: projectSections ?? this.projectSections,
      maxTeamMembers: maxTeamMembers ?? this.maxTeamMembers,
    );
  }
}