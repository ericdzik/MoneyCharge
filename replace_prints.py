import os
import re

# Pattern pour trouver les print() et debugPrint()
print_pattern = r"print\((.*?)\);"
debug_print_pattern = r"debugPrint\((.*?)\);"

dart_files = []

# Chercher tous les fichiers .dart
for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            dart_files.append(os.path.join(root, file))

replaced_count = 0

for file_path in dart_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Vérifier si le fichier contient print ou debugPrint
    if 'print(' in content or 'debugPrint(' in content:
        # Ajouter l'import si absent
        if "import 'package:locacharge/core/services/logger.dart';" not in content:
            # Trouver la première ligne qui commence par 'import'
            lines = content.split('\n')
            import_line_idx = 0
            for i, line in enumerate(lines):
                if line.startswith('import'):
                    import_line_idx = i
                    break
            
            # Insérer l'import
            if import_line_idx > 0:
                lines.insert(import_line_idx + 1, "import 'package:locacharge/core/services/logger.dart';")
                content = '\n'.join(lines)
        
        # Remplacer les print() par Logger.info()
        content = re.sub(r"print\((.*?)\);", r"Logger.info(\1);", content)
        
        # Remplacer les debugPrint() par Logger.debug()
        content = re.sub(r"debugPrint\((.*?)\);", r"Logger.debug(\1);", content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            replaced_count += 1
            print(f"✓ {file_path}")

print(f"\n✓ {replaced_count} fichiers modifiés")
