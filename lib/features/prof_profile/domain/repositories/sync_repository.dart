abstract class SyncRepository {
  Future<bool> processFolder(String folderId, String accessToken, String jwtToken);
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken);
}
