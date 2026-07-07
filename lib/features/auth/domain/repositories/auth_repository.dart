import 'package:mobile/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();
  Future<bool> requestDriveScope();
  Future<bool> requestClassroomScopes(String jwtToken);
  Future<String?> getDriveAccessToken();
  Future<void> signOutFromGoogle();
}
