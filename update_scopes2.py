import re

with open("lib/features/auth/data/data_source/auth_remote_data_source.dart", "r") as f:
    content = f.read()

# Remove the scopes from the constructor
old_scopes = r"""        scopes: \[
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly'
    \],"""

content = re.sub(old_scopes, "    scopes: ['email', 'profile'],", content)

# Update getDriveAccessToken
old_get_token = r"""  Future<String\?> getDriveAccessToken\(\) async \{
    try \{
      final user = await _googleSignIn\.signInSilently\(reAuthenticate: true\) \?\? await _googleSignIn\.signInSilently\(\);
      final GoogleSignInAuthentication\? auth = await user\?\.authentication;
      return auth\?\.accessToken;
    \} catch \(e\) \{
      print\('Error getting drive token: \$e'\);
      return null;
    \}
  \}"""

new_get_token = """  Future<String?> getDriveAccessToken() async {
    try {
      final user = _googleSignIn.currentUser;
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (e) {
      print('Error getting drive token: $e');
      return null;
    }
  }"""

content = re.sub(old_get_token, new_get_token, content)

with open("lib/features/auth/data/data_source/auth_remote_data_source.dart", "w") as f:
    f.write(content)
