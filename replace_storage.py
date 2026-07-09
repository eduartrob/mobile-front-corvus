import os
import glob

files_to_update = [
    "lib/features/search/data/data_source/search_remote_data_source.dart",
    "lib/features/notifications/data/notifications_local_data_source.dart",
    "lib/features/notifications/data/notifications_remote_data_source.dart",
    "lib/features/notifications/presentation/provider/notifications_provider.dart",
    "lib/features/prof_rules/data/data_source/prof_rules_remote_data_source.dart",
    "lib/features/inspiration/data/data_source/inspiration_remote_data_source.dart",
    "lib/features/auth/presentation/provider/auth_provider.dart",
    "lib/features/prof_profile/presentation/provider/linked_folders_provider.dart",
    "lib/features/my_project/data/my_project_local_data_source.dart",
    "lib/features/my_project/data/my_project_remote_data_source.dart"
]

for filepath in files_to_update:
    if not os.path.exists(filepath):
        print(f"Not found: {filepath}")
        continue
    
    with open(filepath, 'r') as f:
        content = f.read()
        
    content = content.replace("import 'package:flutter_secure_storage/flutter_secure_storage.dart';", "import 'package:mobile/core/services/secure_storage_service.dart';")
    content = content.replace("FlutterSecureStorage", "SecureStorageService")
    
    with open(filepath, 'w') as f:
        f.write(content)

print("Replacement complete")
