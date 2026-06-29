import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';

class GetDriveFoldersUseCase {
  final SyncRepository repository;

  GetDriveFoldersUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(String accessToken) async {
    return await repository.getDriveFolders(accessToken);
  }
}
