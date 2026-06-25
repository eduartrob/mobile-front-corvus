import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';

class SyncDriveFolderUseCase {
  final SyncRepository repository;

  SyncDriveFolderUseCase(this.repository);

  Future<Map<String, dynamic>> call(String folderId, String accessToken, String jwtToken, String userId) async {
    return await repository.processFolder(folderId, accessToken, jwtToken, userId);
  }
}
