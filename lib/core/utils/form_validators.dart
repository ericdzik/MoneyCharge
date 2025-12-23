/// Validateurs de formulaires réutilisables pour toute l'application
/// 
/// Centralise toutes les logiques de validation pour garantir
/// une cohérence et éviter la duplication de code.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   validator: FormValidators.email,
/// )
/// 
/// TextFormField(
///   validator: FormValidators.required('Nom'),
/// )
/// 
/// TextFormField(
///   validator: FormValidators.combine([
///     FormValidators.required('Email'),
///     FormValidators.email,
///   ]),
/// )
/// ```
class FormValidators {
  // Expression régulières
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^(\+?228)?[0-9]{8}$', // Format Togo: +228 ou sans préfixe, 8 chiffres
  );

  static final RegExp _passwordStrongRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-zA-Z\d@$!%*?&]{8,}$',
  );

  static final RegExp _alphaNumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  static final RegExp _numericRegex = RegExp(r'^[0-9]+$');
  static final RegExp _alphaRegex = RegExp(r'^[a-zA-Z\s]+$');

  // ==================== VALIDATEURS BASIQUES ====================

  /// Valide qu'un champ n'est pas vide
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName est requis';
      }
      return null;
    };
  }

  /// Valide une adresse email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email est requis';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valide un numéro de téléphone (format Togo)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Numéro invalide (ex: 90123456 ou +22890123456)';
    }
    return null;
  }

  /// Valide un mot de passe (longueur minimale)
  static String? Function(String?) password({int minLength = 6}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Mot de passe requis';
      }
      if (value.length < minLength) {
        return 'Minimum $minLength caractères';
      }
      return null;
    };
  }

  /// Valide un mot de passe fort (avec majuscule, minuscule, chiffre, caractère spécial)
  static String? passwordStrong(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    if (!_passwordStrongRegex.hasMatch(value)) {
      return 'Doit contenir majuscule, minuscule, chiffre et caractère spécial';
    }
    return null;
  }

  /// Valide que deux mots de passe correspondent
  static String? Function(String?) passwordMatch(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirmation requise';
      }
      if (value != password) {
        return 'Les mots de passe ne correspondent pas';
      }
      return null;
    };
  }

  // ==================== VALIDATEURS DE LONGUEUR ====================

  /// Valide une longueur minimale
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'Ce champ'} est requis';
      }
      if (value.length < min) {
        return '${fieldName ?? 'Ce champ'} doit contenir au moins $min caractères';
      }
      return null;
    };
  }

  /// Valide une longueur maximale
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value != null && value.length > max) {
        return '${fieldName ?? 'Ce champ'} ne peut pas dépasser $max caractères';
      }
      return null;
    };
  }

  /// Valide une longueur exacte
  static String? Function(String?) exactLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'Ce champ'} est requis';
      }
      if (value.length != length) {
        return '${fieldName ?? 'Ce champ'} doit contenir exactement $length caractères';
      }
      return null;
    };
  }

  /// Valide une plage de longueur
  static String? Function(String?) lengthRange(
    int min,
    int max, [
    String? fieldName,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'Ce champ'} est requis';
      }
      if (value.length < min || value.length > max) {
        return '${fieldName ?? 'Ce champ'} doit contenir entre $min et $max caractères';
      }
      return null;
    };
  }

  // ==================== VALIDATEURS NUMÉRIQUES ====================

  /// Valide un nombre entier
  static String? integer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    if (int.tryParse(value) == null) {
      return 'Doit être un nombre entier';
    }
    return null;
  }

  /// Valide un nombre décimal
  static String? decimal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    if (double.tryParse(value) == null) {
      return 'Doit être un nombre';
    }
    return null;
  }

  /// Valide un nombre dans une plage
  static String? Function(String?) numberRange(num min, num max) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Valeur requise';
      }
      final number = num.tryParse(value);
      if (number == null) {
        return 'Doit être un nombre';
      }
      if (number < min || number > max) {
        return 'Doit être entre $min et $max';
      }
      return null;
    };
  }

  /// Valide un nombre positif
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Doit être un nombre';
    }
    if (number <= 0) {
      return 'Doit être un nombre positif';
    }
    return null;
  }

  /// Valide un montant (prix)
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Montant requis';
    }
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Montant invalide';
    }
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    if (amount > 10000000) {
      return 'Montant trop élevé';
    }
    return null;
  }

  // ==================== VALIDATEURS DE FORMAT ====================

  /// Valide que la valeur contient uniquement des lettres et chiffres
  static String? alphaNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    if (!_alphaNumericRegex.hasMatch(value)) {
      return 'Seuls les lettres et chiffres sont autorisés';
    }
    return null;
  }

  /// Valide que la valeur contient uniquement des chiffres
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    if (!_numericRegex.hasMatch(value)) {
      return 'Seuls les chiffres sont autorisés';
    }
    return null;
  }

  /// Valide que la valeur contient uniquement des lettres
  static String? alpha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valeur requise';
    }
    if (!_alphaRegex.hasMatch(value)) {
      return 'Seules les lettres sont autorisées';
    }
    return null;
  }

  /// Valide une URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL requise';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
      return 'URL invalide';
    }
    return null;
  }

  // ==================== VALIDATEURS MÉTIER ====================

  /// Valide un nom complet (prénom + nom)
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nom complet requis';
    }
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'Entrez prénom et nom';
    }
    if (parts.any((part) => part.length < 2)) {
      return 'Prénom et nom doivent contenir au moins 2 caractères';
    }
    return null;
  }

  /// Valide une description (minimum et maximum de caractères)
  static String? Function(String?) description({
    int minLength = 10,
    int maxLength = 500,
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Description requise';
      }
      if (value.trim().length < minLength) {
        return 'Description trop courte (minimum $minLength caractères)';
      }
      if (value.length > maxLength) {
        return 'Description trop longue (maximum $maxLength caractères)';
      }
      return null;
    };
  }

  /// Valide un code postal/ZIP
  static String? zipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code postal requis';
    }
    if (!_numericRegex.hasMatch(value) || value.length < 4 || value.length > 10) {
      return 'Code postal invalide';
    }
    return null;
  }

  // ==================== VALIDATEURS PERSONNALISÉS ====================

  /// Valide avec une expression régulière personnalisée
  static String? Function(String?) regex(
    RegExp pattern,
    String errorMessage,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Valeur requise';
      }
      if (!pattern.hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Valide avec une fonction personnalisée
  static String? Function(String?) custom(
    bool Function(String?) validator,
    String errorMessage,
  ) {
    return (String? value) {
      if (!validator(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  // ==================== COMBINATEURS ====================

  /// Combine plusieurs validateurs
  /// 
  /// Usage:
  /// ```dart
  /// validator: FormValidators.combine([
  ///   FormValidators.required('Email'),
  ///   FormValidators.email,
  ///   FormValidators.maxLength(100, 'Email'),
  /// ])
  /// ```
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  /// Valide seulement si la condition est vraie
  static String? Function(String?) conditional(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }

  // ==================== HELPERS ====================

  /// Nettoie un numéro de téléphone (retire espaces, tirets, parenthèses)
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Formate un numéro de téléphone (ajoute +228 si nécessaire)
  static String formatPhone(String phone) {
    final cleaned = cleanPhone(phone);
    if (cleaned.startsWith('+228')) {
      return cleaned;
    }
    if (cleaned.startsWith('228')) {
      return '+$cleaned';
    }
    return '+228$cleaned';
  }

  /// Valide si une chaîne est un email valide (sans message d'erreur)
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Valide si une chaîne est un téléphone valide (sans message d'erreur)
  static bool isValidPhone(String phone) {
    return _phoneRegex.hasMatch(cleanPhone(phone));
  }
}
