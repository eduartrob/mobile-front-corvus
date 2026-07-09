import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.loginWithEmail(email, password);
  }
}
