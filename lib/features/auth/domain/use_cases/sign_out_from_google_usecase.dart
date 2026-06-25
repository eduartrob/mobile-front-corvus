import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class SignOutFromGoogleUseCase {
  final AuthRepository repository;

  SignOutFromGoogleUseCase(this.repository);

  Future<void> call() async {
    await repository.signOutFromGoogle();
  }
}
