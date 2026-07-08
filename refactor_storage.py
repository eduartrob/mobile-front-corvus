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
    content = re.sub(r"import 'package:flutter_secure_storage/flutter_secure_storage\.dart';\n?", "", content)

    # Remove storage fields and constructor parameters
    content = re.sub(r"final FlutterSecureStorage _storage;", "", content)
    content = re.sub(r"FlutterSecureStorage\?\s*storage", "", content)
    content = re.sub(r":\s*_storage\s*=\s*storage\s*\?\?\s*const\s*FlutterSecureStorage\(\),?", "", content)
    # Remove _storage instantiation inside SearchRemoteDataSourceImpl
    content = re.sub(r"final FlutterSecureStorage _storage = const FlutterSecureStorage\(\);", "", content)

    # Remove _getToken method
    content = re.sub(r"Future<String> _getToken\(\) async \{.*?\n\s*\}\n", "", content, flags=re.DOTALL)

    # Remove _getHeaders method
    content = re.sub(r"Map<String,\s*String>\s*_getHeaders\(String\s*token\)\s*\{.*?\n\s*\}\n", "", content, flags=re.DOTALL)

    # Remove token calls inside methods
    content = re.sub(r"final token = await _getToken\(\);\n?", "", content)
    content = re.sub(r"final token = await _storage\.read\(key:\s*'auth_token'\);\n?", "", content)
    content = re.sub(r"if\s*\(token\s*==\s*null\)\s*\{.*?\n\s*\}\n?", "", content, flags=re.DOTALL)
    content = re.sub(r"final\s*headers\s*=\s*Map<String,\s*String>\.from\(ApiConfig\.defaultHeaders\);\n?", "", content)
    content = re.sub(r"if\s*\(token\s*!=\s*null\)\s*\{\s*headers\['Authorization'\]\s*=\s*'Bearer\s*\$token';\s*\}\n?", "", content)

    # Replace headers: _getHeaders(token) with headers: ApiConfig.defaultHeaders
    content = re.sub(r"headers:\s*_getHeaders\(token\)", "headers: ApiConfig.defaultHeaders", content)
    # Replace headers: headers with headers: ApiConfig.defaultHeaders if headers var was removed
    # Actually if they passed `headers`, just let's see. For my_project we removed `request.headers['Authorization'] = 'Bearer $token';`
    content = re.sub(r"request\.headers\['Authorization'\]\s*=\s*'Bearer\s*\$token';\n?", "", content)

    # Simplify comments
    # To simplify comments, we can find any comment // and lowercase it, and remove weird chars. 
    # But let's do it safely to avoid destroying code URLs or similar. Let's just lowercase the block comments manually if possible or leave them.
    # The user asked: "ademas a esto puedes reducir los textos o comentarios a comentarios mas generales y no tan especificos todo en minuscula sin signos raros"
    # We will use a regex to find all // comments and lowercase them, stripping punctuation.
    def simplify_comment(match):
        text = match.group(1)
        # remove punctuation
        text = re.sub(r'[^\w\s]', '', text).lower().strip()
        # if the comment is a flutter/dart specific comment or a url, ignore
        if "http" in text or "todo" in text:
            return match.group(0)
        return f"// {text}"
    
    # We'll use lookarounds to not touch // http or // TODO
    content = re.sub(r"//\s*(.*)", simplify_comment, content)
    
    # remove trailing commas in constructors that became empty
    content = re.sub(r"\{\s*,\s*\}", "{}", content)
    content = re.sub(r"\(\s*,\s*\)", "()", content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done")
