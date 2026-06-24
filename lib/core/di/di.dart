import 'package:get_it/get_it.dart';
import 'package:mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/use_cases/sign_in_with_google_usecase.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // DataSources
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));

  // UseCases
  getIt.registerLazySingleton(() => SignInWithGoogleUseCase(repository: getIt()));
}
