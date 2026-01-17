#!/bin/bash

# Ajouter l'import du Logger dans tous les fichiers qui contiennent print()
for file in $(find lib -name "*.dart" -type f -exec grep -l "print(" {} \;); do
    # Vérifier si l'import est déjà présent
    if ! grep -q "import 'package:locacharge/core/services/logger.dart'" "$file"; then
        # Ajouter l'import après le premier import
        sed -i "/^import/a import 'package:locacharge/core/services/logger.dart';" "$file"
    fi
done

# Remplacer print( par Logger.info(
for file in $(find lib -name "*.dart" -type f -exec grep -l "print(" {} \;); do
    sed -i "s/print(/Logger.info(/g" "$file"
done

# Remplacer debugPrint( par Logger.debug(
for file in $(find lib -name "*.dart" -type f -exec grep -l "debugPrint(" {} \;); do
    sed -i "s/debugPrint(/Logger.debug(/g" "$file"
done

echo "Tous les print() ont été remplacés par Logger.info()"
