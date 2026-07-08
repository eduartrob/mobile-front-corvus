import re

with open("lib/features/auth/presentation/provider/auth_provider.dart", "r") as f:
    content = f.read()

replacement = """
  Future<void> updateProfilePicture(String base64Image) async {
    try {
      final response = await apiClient.put(
        '/profile-picture',
        body: {'imageBase64': base64Image},
      );
      if (response.statusCode == 200 && response.data['profile_picture'] != null) {
        final newUrl = response.data['profile_picture'];
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(photoUrl: newUrl);
          await _storage.write(key: 'auth_photo', value: newUrl);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
    }
  }

  Future<void> signOut() async {
"""

new_content = content.replace("  Future<void> signOut() async {", replacement)

with open("lib/features/auth/presentation/provider/auth_provider.dart", "w") as f:
    f.write(new_content)
