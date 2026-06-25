import 'package:mobile/features/prof_profile/domain/repositories/sync_repository.dart';
import 'package:mobile/features/prof_profile/data/data_source/sync_remote_data_source.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncRemoteDataSource remoteDataSource;

  SyncRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> processFolder(String folderId, String accessToken, String jwtToken) async {
    return await remoteDataSource.processFolder(folderId, accessToken, jwtToken);
  }

  @override
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken) async {
    return await remoteDataSource.getDriveFolders(accessToken);
  }
}
