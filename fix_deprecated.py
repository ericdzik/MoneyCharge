import os
import re

# Remplacer .withOpacity(x) par .withValues(alpha: x)
pattern_opacity = r'\.withOpacity\(([\d.]+)\)'
replacement_opacity = r'.withValues(alpha: \1)'

# Remplacer BitmapDescriptor.fromBytes par BitmapDescriptor.bytes
pattern_bytes = r'BitmapDescriptor\.fromBytes\('
replacement_bytes = 'BitmapDescriptor.bytes('

dart_files = []
for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            dart_files.append(os.path.join(root, file))

count = 0
for filepath in dart_files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Remplacer withOpacity
        content = re.sub(pattern_opacity, replacement_opacity, content)
        
        # Remplacer fromBytes
        content = content.replace(pattern_bytes, replacement_bytes)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
            print(f"✓ {filepath}")
    except Exception as e:
        print(f"✗ {filepath}: {e}")

print(f"\n✓ {count} fichiers modifiés")
