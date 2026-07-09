import os
import re

files_to_refactor = [
    "lib/features/teams/data/data_source/teams_remote_data_source.dart",
    "lib/features/student_directory/data/data_source/clustering_remote_data_source.dart",
    "lib/features/search/data/data_source/search_remote_data_source.dart",
    "lib/features/search/presentation/provider/search_provider.dart",
    "lib/features/profile/data/data_source/profile_remote_data_source.dart",
    "lib/features/notifications/data/notifications_remote_data_source.dart",
    "lib/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart",
    "lib/features/inspiration/data/data_source/inspiration_remote_data_source.dart",
    "lib/features/prof_profile/presentation/provider/linked_folders_provider.dart",
    "lib/features/my_project/data/my_project_remote_data_source.dart",
    "lib/features/auth/data/data_source/auth_remote_data_source.dart"
]

for file_path in files_to_refactor:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove import
    content = re.sub(r"import 'package:flutter_secure_storage/flutter_secure_storage\.dart';\n", "", content)

    # Remove storage fields and constructor parameters
    content = re.sub(r"\s*final FlutterSecureStorage _storage;", "", content)
    content = re.sub(r"\s*final FlutterSecureStorage _storage = const FlutterSecureStorage\(\);", "", content)
    
    # Clean constructor. This replaces `, FlutterSecureStorage? storage` or `FlutterSecureStorage? storage`
    content = re.sub(r",\s*FlutterSecureStorage\?\s*storage", "", content)
    content = re.sub(r"FlutterSecureStorage\?\s*storage\s*", "", content)
    
    # Remove initializer list ` : _storage = storage ?? const FlutterSecureStorage();`
    content = re.sub(r"\s*:\s*_storage\s*=\s*storage\s*\?\?\s*const\s*FlutterSecureStorage\(\)", "", content)
    # Remove if there's a comma before it or after
    
    # Remove _getToken method specifically
    get_token_regex = r"\s*Future<String> _getToken\(\) async \{\s*final token = await _storage\.read\(key: 'auth_token'\);\s*if \(token == null\) \{\s*throw Exception\('[^']*'\);\s*\}\s*return token;\s*\}"
    content = re.sub(get_token_regex, "", content)
    
    # Remove _getHeaders method specifically
    get_headers_regex = r"\s*Map<String, String> _getHeaders\(String token\) \{\s*return \{\s*\.\.\.ApiConfig\.defaultHeaders,\s*'Authorization': 'Bearer \$token',\s*\};\s*\}"
    content = re.sub(get_headers_regex, "", content)

    # Remove inline token fetches
    content = re.sub(r"\s*final token = await _getToken\(\);\n", "\n", content)
    content = re.sub(r"\s*final token = await _storage\.read\(key: 'auth_token'\);\n", "\n", content)
    content = re.sub(r"\s*if \(token == null\) \{\s*throw Exception\('[^']*'\);\s*\}\n", "", content)
    content = re.sub(r"\s*final headers = Map<String, String>\.from\(ApiConfig\.defaultHeaders\);\s*if \(token != null\) \{\s*headers\['Authorization'\] = 'Bearer \$token';\s*\}\n", "", content)
    content = re.sub(r"\s*request\.headers\['Authorization'\] = 'Bearer \$token';\n", "\n", content)

    # Replace headers: _getHeaders(token) with headers: ApiConfig.defaultHeaders
    content = re.sub(r"headers:\s*_getHeaders\(token\)", "headers: ApiConfig.defaultHeaders", content)

    # Lowercase comments and remove special chars
    def simplify_comment(match):
        text = match.group(1)
        # ignore urls, api routes, and todos
        if "http" in text or "TODO" in text or "/" in text or "GET" in text or "POST" in text or "PUT" in text or "DELETE" in text:
            return match.group(0)
        
        # remove punctuation and lowercase
        cleaned = re.sub(r'[^\w\s]', '', text).lower().strip()
        return f"// {cleaned}"

    content = re.sub(r"//\s*(.*)", simplify_comment, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done")
