import os
import glob

repo_dir = "/home/eduartrob/Documentos/modelos/repos_externos"
md_files = glob.glob(os.path.join(repo_dir, "**", "*.md"), recursive=True)

print(f"Found {len(md_files)} markdown files.")
# Let's count how many files per directory
counts = {}
for f in md_files:
    folder = f.split(repo_dir)[1].split('/')[1]
    counts[folder] = counts.get(folder, 0) + 1

for folder, count in counts.items():
    print(f"- {folder}: {count} files")
