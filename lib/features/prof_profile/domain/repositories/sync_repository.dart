abstract class SyncRepository {
  Future<Map<String, dynamic>> processFolder(String folderId, String accessToken, String jwtToken);
  Future<List<Map<String, dynamic>>> getDriveFolders(String accessToken);
}
