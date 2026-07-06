import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class RequestClassroomScopesUseCase {
  final AuthRepository repository;

  RequestClassroomScopesUseCase(this.repository);

  Future<bool> call(String jwtToken) async {
    return await repository.requestClassroomScopes(jwtToken);
  }
}
