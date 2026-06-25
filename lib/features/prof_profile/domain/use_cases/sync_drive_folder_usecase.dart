import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';

class SyncDriveFolderUseCase {
  final SyncRepository repository;

  SyncDriveFolderUseCase(this.repository);

  Future<bool> call(String folderId, String accessToken, String jwtToken) async {
    return await repository.processFolder(folderId, accessToken, jwtToken);
  }
}
