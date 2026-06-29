import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class GetDriveAccessTokenUseCase {
  final AuthRepository repository;

  GetDriveAccessTokenUseCase(this.repository);

  Future<String?> call() async {
    return await repository.getDriveAccessToken();
  }
}
