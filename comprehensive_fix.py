import os
import re

dart_files = []
for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            dart_files.append(os.path.join(root, file))

for filepath in dart_files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # 1. Remplacer withOpacity par withValues
    content = re.sub(r'\.withOpacity\(([\d.]+)\)', r'.withValues(alpha: \1)', content)
    
    # 2. Remplacer BitmapDescriptor.fromBytes par .bytes
    content = content.replace('BitmapDescriptor.fromBytes(', 'BitmapDescriptor.bytes(')
    
    # 3. Supprimer les print() en commentant ou en les remplaçant
    # Pour les print en debug, on les commente
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'print(' in line and not 'println' in line:
            # Commenter la ligne au lieu de la supprimer
            if line.strip().startswith('print('):
                new_lines.append('      // ' + line.strip())
            else:
                new_lines.append(line.replace('print(', '// print('))
        else:
            new_lines.append(line)
    content = '\n'.join(new_lines)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ {filepath}")

print("Fixage complet terminé!")
