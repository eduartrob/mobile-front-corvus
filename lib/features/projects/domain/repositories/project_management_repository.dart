/// Contrato de dominio para la gestión de proyectos (crear, unirse, listar, etc.).
/// La capa de presentación solo conoce esta interfaz, nunca el DataSource.
abstract class ProjectManagementRepository {
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
    int teamSize = 4,
    required String token,
    String? themeColor,
    String? themePattern,
  });

  Future<Map<String, dynamic>> joinProject({
    required String code,
    required String token,
  });

  Future<Map<String, dynamic>> getMyProjects({required String token});
  Future<Map<String, dynamic>> getArchivedProjects({required String token});
  Future<bool> archiveProjects({required List<String> projectIds, required String token});

  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String name,
    required String token,
    String? themeColor,
    String? themePattern,
  });

  Future<void> deleteProject({
    required String projectId,
    required String token,
  });

  Future<List<dynamic>> getProjectStudents({
    required String projectId,
    required String token,
  });

  Future<bool> acceptInvitation({
    required String projectId,
    required String token,
  });

  Future<bool> rejectInvitation({
    required String projectId,
    required String token,
  });
}