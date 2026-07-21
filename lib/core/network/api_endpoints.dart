class ApiEndpoints {
  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authDeleteAccount = '/auth/delete-account';
  static const String authCompleteProfile = '/auth/complete-student-profile';
  static const String authProfilePicture = '/auth/profile-picture';
  static const String authUniversities = '/auth/universities';
  static const String authUniversitiesValidate = '/auth/universities/validate';
  static const String authCareers = '/auth/careers';
  static const String authFolders = '/auth/folders';

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS
  // ---------------------------------------------------------------------------
  static const String notificationsDevice = '/notifications/device';

  // ---------------------------------------------------------------------------
  // PROJECTS
  // ---------------------------------------------------------------------------
  static const String projects = '/projects';
  static const String projectsJoin = '/projects/join';
  static const String projectsMyProjects = '/projects/my-projects';
  static const String projectsArchived = '/projects/archived';
  static const String projectsArchive = '/projects/archive';
  static const String projectsUnarchive = '/projects/unarchive';
  static String projectById(String id) => '/projects/$id';
  static String projectStudents(String id) => '/projects/$id/students';
  static String projectCollaborators(String id) => '/projects/$id/collaborators';
  static String projectCollaboratorsAccept(String id) => '/projects/$id/collaborators/accept';
  static String projectCollaboratorsReject(String id) => '/projects/$id/collaborators/reject';

  // ---------------------------------------------------------------------------
  // TEAMS
  // ---------------------------------------------------------------------------
  static const String teamsMyTeam = '/teams/my-team';
  static const String teamsMyTeamLeave = '/teams/my-team/leave';
  static String teamMemberById(String id) => '/teams/my-team/members/$id';
  
  static const String teamsSuggestions = '/teams/suggestions';
  static const String teamsStudents = '/teams/students';
  
  static const String teamsRequests = '/teams/requests';
  static String teamRequestById(String id) => '/teams/requests/$id';
  static String teamRequestAccept(String id) => '/teams/requests/$id/accept';

  static const String teamsProfDirectory = '/teams/prof/directory';

  // ---------------------------------------------------------------------------
  // FINAL REVIEWS
  // ---------------------------------------------------------------------------
  static const String finalReviews = '/final-reviews';
  static String finalReviewByTeam(String teamId) => '/final-reviews/team/$teamId';

  // ---------------------------------------------------------------------------
  // PROFESSORS
  // ---------------------------------------------------------------------------
  static const String professorsDashboard = '/professors/dashboard';
  static const String professorsHistory = '/professors/history';
  static const String professorsSearch = '/professors/search';

  // ---------------------------------------------------------------------------
  // CLUSTERING / INTEGRATOR
  // ---------------------------------------------------------------------------
  static const String clusteringSubjectSearchSmart = '/clustering/subject/search-smart';
  static const String clusteringSubjectIngest = '/clustering/subject/ingest';
  
  static String integratorSyncStatus(String id) => '/clustering/integrator/sync-status/$id';
  static const String integratorProcessFolder = '/clustering/integrator/process-folder';
  static const String integratorPreValidateProposal = '/clustering/integrator/pre-validate-proposal';
  static const String integratorAnalyzeDraftProposal = '/clustering/integrator/analyze-draft-proposal';
  static const String integratorAdminConfig = '/clustering/integrator/admin/config';
  
  static String integratorDraftProposal(String teamId) => '/clustering/integrator/draft-proposal/$teamId';
  static String integratorAnalysisStatus(String teamId) => '/clustering/integrator/analysis-status/$teamId';
  static String integratorAnalysisResult(String teamId) => '/clustering/integrator/analysis-result/$teamId';
  static String integratorCancelAnalysis(String teamId) => '/clustering/integrator/cancel-analysis/$teamId';

  // Clustering / Groups
  static const String clusteringGroupsLogin = '/clustering/groups/login';
  static const String clusteringGroupsCourses = '/clustering/groups/courses';
  static const String clusteringGroupsSyncPerfil = '/clustering/groups/sync-perfil';
  static const String clusteringGroupsMiPerfilCompleto = '/clustering/groups/mi-perfil/completo';
  static String clusteringGroupsCluster(String courseId) => '/clustering/groups/cluster/$courseId';
  static String clusteringGroupsClusterSummary(String courseId) => '/clustering/groups/cluster/$courseId/summary';

  // ---------------------------------------------------------------------------
  // LLM / CHAT
  // ---------------------------------------------------------------------------
  static const String llmSessionStart = '/llm/session/start';
  static const String llmSessionMessage = '/llm/session/message';
  static String llmSessionMessages(String sessionId) => '/llm/session/$sessionId/messages';
}
