import 'package:get_it/get_it.dart';
import 'package:mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';
import 'package:mobile/features/auth/domain/use_cases/request_drive_scope_usecase.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

void setupDependencies() {
  // 1. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // 3. Use Cases
  sl.registerLazySingleton(
    () => SignInWithGoogleUseCase(repository: sl()),
  );
  sl.registerLazySingleton(
    () => RequestDriveScopeUseCase(sl()),
  );

  // 4. Providers
  sl.registerFactory(
    () => AuthProvider(
      signInWithGoogleUseCase: sl(),
      requestDriveScopeUseCase: sl(),
    ),
  );
}
