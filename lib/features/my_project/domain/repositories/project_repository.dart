import 'package:mobile/features/my_project/domain/entities/project_analysis_entity.dart';

/// contrato de dominio para operaciones de proyecto 
/// la capa de presentación solo conoce esta interfaz nunca el datasource 
abstract class ProjectRepository {
  /// obtiene la configuración del admin panel extensiones secciones etc 
  Future<ProjectAnalysisEntity> fetchConfig({String? projectId});

  /// obtiene el análisis guardado localmente para un usuario 
  Future<Map<String, dynamic>?> getLocalAnalysis(String userId);

  /// guarda el análisis detallado localmente 
  Future<void> saveLocalAnalysis(String userId, Map<String, dynamic> result);

  /// elimina el análisis local de un usuario 
  Future<void> clearLocalAnalysis(String userId);

  /// obtiene el estado del análisis en el servidor 
  Future<Map<String, dynamic>> getAnalysisStatus(String teamId);

  /// obtiene el resultado del análisis 
  Future<Map<String, dynamic>> getAnalysisResult(String teamId);

  /// verifica si hay un borrador guardado 
  Future<Map<String, dynamic>> checkDraft(String teamId);

  /// obtiene un resumen consolidado bff con configuración estatus resultado y borrador en 1 sola llamada 
  Future<Map<String, dynamic>> getProjectSummary(String teamId, {String? projectId});

  /// pre valida una propuesta sube archivo 
  Future<Map<String, dynamic>> preValidateProposal(
    String filePath,
    String teamId,
    String userId,
    String userName, {
    String? universityId,
    String? careerId,
    String? projectId,
  });

  /// inicia el análisis detallado de un borrador 
  Future<void> analyzeDraftDetailed(String teamId);

  /// cancela el análisis en curso 
  Future<void> cancelAnalysis(String teamId);

  /// envía la revisión final al profesor 
  Future<Map<String, dynamic>> sendFinalReview(
    String teamId,
    Map<String, dynamic> proposalData,
  );

  /// obtiene el estado de la revisión final 
  Future<Map<String, dynamic>?> getFinalReviewStatus(String teamId);
}