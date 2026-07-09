import os

def resolve_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    out_lines = []
    in_conflict = False
    keep = True
    
    for line in lines:
        if line.startswith('<<<<<<< Updated upstream'):
            in_conflict = True
            keep = False
        elif line.startswith('======='):
            if in_conflict:
                keep = True
            else:
                out_lines.append(line)
        elif line.startswith('>>>>>>> Stashed changes'):
            if in_conflict:
                in_conflict = False
            else:
                out_lines.append(line)
        else:
            if keep:
                out_lines.append(line)
                
    with open(filepath, 'w') as f:
        f.writelines(out_lines)

files = [
    'lib/features/auth/data/data_source/auth_remote_data_source.dart',
    'lib/features/auth/presentation/pages/register_page.dart',
    'lib/features/auth/presentation/provider/auth_provider.dart',
    'lib/features/auth/presentation/widgets/login_form.dart',
    'lib/features/profile/data/data_source/profile_remote_data_source.dart',
    'lib/features/profile/data/models/profile_completo_model.dart',
    'lib/features/profile/presentation/pages/profile_page.dart',
    'lib/features/profile/presentation/provider/profile_provider.dart',
    'lib/features/profile/presentation/widgets/student_header_info.dart',
    'lib/features/profile/presentation/widgets/technical_skills_section.dart',
    'lib/features/teams/data/data_source/teams_remote_data_source.dart',
    'lib/features/teams/presentation/widgets/sugerencias_tab.dart'
]

for f in files:
    if os.path.exists(f):
        resolve_file(f)
        print(f"Resolved {f}")
