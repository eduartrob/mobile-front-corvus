import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class RequestDriveScopeUseCase {
  final AuthRepository repository;

  RequestDriveScopeUseCase(this.repository);

  Future<bool> call() async {
    return await repository.requestDriveScope();
  }
}
