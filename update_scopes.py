import re

with open("lib/features/auth/data/data_source/auth_remote_data_source.dart", "r") as f:
    content = f.read()

new_scopes = """    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly'
    ],"""

content = re.sub(r"scopes:\s*\[[^\]]+\]\s*,", new_scopes, content)

with open("lib/features/auth/data/data_source/auth_remote_data_source.dart", "w") as f:
    f.write(content)
