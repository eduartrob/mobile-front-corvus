import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/data/data_source/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<bool> requestDriveScope() async {
    return await remoteDataSource.requestDriveScope();
  }

  @override
  Future<bool> requestClassroomScopes(String jwtToken) async {
    return await remoteDataSource.requestClassroomScopes(jwtToken);
  }

  @override
  Future<String?> getDriveAccessToken() async {
    return await remoteDataSource.getDriveAccessToken();
  }

  @override
  Future<void> signOutFromGoogle() async {
    await remoteDataSource.signOutFromGoogle();
  }
}
