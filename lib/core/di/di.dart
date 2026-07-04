import 'package:get_it/get_it.dart';
import 'package:mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_drive_scope_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/get_drive_access_token_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_out_from_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_classroom_scopes_usecase.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

import 'package:mobile/features/prof_profile/data/data_source/sync_remote_data_source.dart';
import 'package:mobile/features/prof_profile/data/repositories/sync_repository_impl.dart';
import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/sync_drive_folder_usecase.dart';
import 'package:mobile/features/prof_profile/domain/use_cases/get_drive_folders_usecase.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<SyncRemoteDataSource>(
    () => SyncRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => SignInWithGoogleUseCase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => RequestDriveScopeUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => RequestClassroomScopesUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetDriveAccessTokenUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => SyncDriveFolderUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => SignOutFromGoogleUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetDriveFoldersUseCase(sl()),
  );

  sl.registerFactory(
    () => AuthProvider(
      signInWithGoogleUseCase: sl(),
      requestDriveScopeUseCase: sl(),
      requestClassroomScopesUseCase: sl(),
      getDriveAccessTokenUseCase: sl(),
      signOutFromGoogleUseCase: sl(),
    ),
  );
}
