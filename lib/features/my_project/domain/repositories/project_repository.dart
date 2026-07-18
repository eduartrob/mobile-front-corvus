import 'package:mobile/features/my_project/domain/entities/project_analysis_entity.dart';

/// Contrato de dominio para operaciones de proyecto.
/// La capa de presentación solo conoce esta interfaz, nunca el DataSource.
abstract class ProjectRepository {
  /// Obtiene la configuración del admin panel (extensiones, secciones, etc.)
  Future<ProjectAnalysisEntity> fetchConfig({String? projectId});

  /// Obtiene el análisis guardado localmente para un usuario.
  Future<Map<String, dynamic>?> getLocalAnalysis(String userId);

  /// Guarda el análisis detallado localmente.
  Future<void> saveLocalAnalysis(String userId, Map<String, dynamic> result);

  /// Elimina el análisis local de un usuario.
  Future<void> clearLocalAnalysis(String userId);

  /// Obtiene el estado del análisis en el servidor.
  Future<Map<String, dynamic>> getAnalysisStatus(String teamId);

  /// Obtiene el resultado del análisis.
  Future<Map<String, dynamic>> getAnalysisResult(String teamId);

  /// Verifica si hay un borrador guardado.
  Future<Map<String, dynamic>> checkDraft(String teamId);

  /// Pre-valida una propuesta (sube archivo).
  Future<Map<String, dynamic>> preValidateProposal(
    String filePath,
    String teamId,
    String userId,
    String userName, {
    String? universityId,
    String? careerId,
  });

  /// Inicia el análisis detallado de un borrador.
  Future<void> analyzeDraftDetailed(String teamId);

  /// Cancela el análisis en curso.
  Future<void> cancelAnalysis(String teamId);

  /// Envía la revisión final al profesor.
  Future<Map<String, dynamic>> sendFinalReview(
    String teamId,
    Map<String, dynamic> proposalData,
  );

  /// Obtiene el estado de la revisión final.
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId);
}