import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/network/auth_interceptor_client.dart';
import 'package:mobile/core/router/appRouter.dart';
import 'package:mobile/core/services/secure_storage_service.dart';
import 'package:mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_drive_scope_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/get_drive_access_token_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_classroom_scopes_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_out_from_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/login_with_email_usecase.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/features/auth/presentation/provider/registration_provider.dart';

import 'package:mobile/features/prof_profile/data/data_source/sync_remote_data_source.dart';
import 'package:mobile/features/prof_profile/data/repositories/sync_repository_impl.dart';
import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/sync_drive_folder_usecase.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/get_drive_folders_usecase.dart';
import 'package:mobile/features/prof_profile/presentation/provider/linked_folders_provider.dart';

import 'package:mobile/features/search/data/data_source/search_remote_data_source.dart';
import 'package:mobile/features/search/data/repositories/search_repository_impl.dart';
import 'package:mobile/features/search/domain/repositories/search_repository.dart';
import 'package:mobile/features/search/domain/use_cases/smart_search_usecase.dart';
import 'package:mobile/features/search/presentation/provider/search_provider.dart';

import 'package:mobile/features/my_project/data/my_project_remote_data_source.dart';
import 'package:mobile/features/my_project/data/my_project_local_data_source.dart';
import 'package:mobile/features/my_project/data/repositories/project_repository_impl.dart';
import 'package:mobile/features/my_project/domain/repositories/project_repository.dart';
import 'package:mobile/features/my_project/presentation/provider/my_project_provider.dart';

import 'package:mobile/features/teams/data/data_source/teams_remote_data_source.dart';
import 'package:mobile/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:mobile/features/teams/domain/repositories/teams_repository.dart';
import 'package:mobile/features/teams/presentation/provider/teams_provider.dart';

import 'package:mobile/features/projects/data/repositories/project_management_repository_impl.dart';
import 'package:mobile/features/projects/domain/repositories/project_management_repository.dart';
import 'package:mobile/features/projects/presentation/provider/project_provider.dart';

import 'package:mobile/features/prof_dash/data/data_source/dashboard_remote_data_source.dart';
import 'package:mobile/features/prof_dash/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/prof_dash/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/prof_dash/presentation/provider/prof_dash_provider.dart';

import 'package:mobile/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart';
import 'package:mobile/features/prof_rules/presentation/provider/prof_rules_provider.dart';

import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/notifications/presentation/provider/notifications_provider.dart';
import 'package:mobile/features/profile/presentation/provider/profile_provider.dart';
import 'package:mobile/features/profile/presentation/provider/activity_history_provider.dart';
import 'package:mobile/features/profile/data/repositories/saved_projects_repository.dart';
import 'package:mobile/features/profile/presentation/providers/saved_projects_provider.dart';
import 'package:mobile/features/prof_reviews/presentation/provider/prof_reviews_provider.dart';
import 'package:mobile/features/prof_history/presentation/provider/prof_history_provider.dart';
import 'package:mobile/features/student_directory/presentation/provider/clustering_provider.dart';
import 'package:mobile/core/theme/theme_provider.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ── HTTP Client (ApiClient) ───────────────────────────────────────────
  sl.registerLazySingleton<AuthInterceptorClient>(() => AuthInterceptorClient(
    storage: SecureStorageService(),
    onUnauthenticated: () {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.sessionExpired ?? 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      context.go('/login');
      try { Provider.of<AuthProvider>(context, listen: false).logout(); } catch (_) {}
      try { sl<AuthProvider>().logout(); } catch (_) {}
    },
    onMitMDetected: () {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alerta de Seguridad: Conexión insegura detectada. Por tu seguridad, la operación fue bloqueada.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 8),
        ),
      );
    },
  ));

  // ── Auth ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(repository: sl()));
  sl.registerLazySingleton(() => RequestDriveScopeUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RequestClassroomScopesUseCase(sl()));
  sl.registerLazySingleton(() => GetDriveAccessTokenUseCase(sl()));
  sl.registerLazySingleton(() => SignOutFromGoogleUseCase(sl()));
  sl.registerFactory(() => AuthProvider(
    signInWithGoogleUseCase: sl(),
    loginWithEmailUseCase: sl(),
    requestDriveScopeUseCase: sl(),
    requestClassroomScopesUseCase: sl(),
    getDriveAccessTokenUseCase: sl(),
    signOutFromGoogleUseCase: sl(),
  ));

  // ── Sync / Prof Profile ──────────────────────────────────────────────
  sl.registerLazySingleton<SyncRemoteDataSource>(
    () => SyncRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SyncDriveFolderUseCase(sl()));
  sl.registerLazySingleton(() => GetDriveFoldersUseCase(sl()));

  // ── Search ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(client: sl<AuthInterceptorClient>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SmartSearchUseCase(sl()));
  sl.registerFactory(() => SearchProvider(sl()));

  // ── MyProject ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<MyProjectRemoteDataSource>(
    () => MyProjectRemoteDataSource(client: sl<AuthInterceptorClient>()),
  );
  sl.registerLazySingleton<MyProjectLocalDataSource>(
    () => MyProjectLocalDataSource(),
  );
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerFactory(() => MyProjectProvider(repository: sl()));

  // ── Teams ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TeamsRemoteDataSource>(
    () => TeamsRemoteDataSource(client: sl<AuthInterceptorClient>()),
  );
  sl.registerLazySingleton<TeamsRepository>(
    () => TeamsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => TeamsProvider(repository: sl()));

  // ── Projects (gestión) ───────────────────────────────────────────────
  sl.registerLazySingleton<ProjectManagementRepository>(
    () => ProjectManagementRepositoryImpl(),
  );
  sl.registerFactory(() => ProjectProvider(repository: sl()));

  // ── Prof Dashboard ───────────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(client: sl<AuthInterceptorClient>()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => ProfDashboardProvider(
    authProvider: sl(),
    repository: sl(),
  ));

  // ── Prof Rules ───────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfRulesRemoteDataSource>(
    () => ProfRulesRemoteDataSource(client: sl<AuthInterceptorClient>()),
  );
  sl.registerFactory(() => ProfRulesProvider(remoteDataSource: sl()));

  // ── Providers simples (sin dependencias complejas) ───────────────────
  sl.registerFactory(() => LinkedFoldersProvider());
  sl.registerFactory(() => ThemeProvider());
  sl.registerFactory(() => InspirationProvider());
  sl.registerFactory(() => NotificationsProvider());
  sl.registerFactory(() => ProfileProvider());
  sl.registerFactory(() => ProfReviewsProvider());
  sl.registerFactory(() => ProfHistoryProvider(client: sl<AuthInterceptorClient>()));
  sl.registerFactory(() => ActivityHistoryProvider(client: sl<AuthInterceptorClient>()));
  sl.registerFactory(() => ClusteringProvider());
  sl.registerFactory(() => RegistrationProvider());

  // ── SavedProjects (requiere SharedPreferences async) ─────────────────
  // Se registra como lazy singleton porque SharedPreferences es async
  // y se inicializa en main() antes de usarlo.
  sl.registerLazySingleton<SavedProjectsRepository>(
    () => SavedProjectsRepository(sl<SharedPreferences>()),
  );
  sl.registerFactory(() => SavedProjectsProvider(sl()));
}

/// Inicializa las dependencias que requieren async (SharedPreferences).
/// Debe llamarse después de `SharedPreferences.getInstance()` en main().
void setupAsyncDependencies(SharedPreferences prefs) {
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
}