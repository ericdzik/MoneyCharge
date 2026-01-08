/// Configuration pour la gestion des numéros de téléphone
class PhoneConfig {
  // Indicatif international par défaut (Togo)
  static const String defaultCountryCode = '+228';
  
  // Longueur attendue des numéros locaux
  static const int localNumberLength = 8;
  
  // Faut-il ajouter automatiquement l'indicatif international ?
  static const bool autoAddCountryCode = false; // Changez à true si vous voulez l'ajouter automatiquement
  
  /// Nettoie et formate un numéro de téléphone
  static String cleanPhoneNumber(String phoneNumber) {
    // Enlever tous les caractères non numériques sauf le +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro est vide après nettoyage, retourner tel quel
    if (cleaned.isEmpty) {
      return phoneNumber;
    }
    
    // Si on doit ajouter automatiquement l'indicatif et que le numéro est local
    if (autoAddCountryCode && 
        !cleaned.startsWith('+') && 
        cleaned.length == localNumberLength) {
      return '$defaultCountryCode$cleaned';
    }
    
    return cleaned;
  }
  
  /// Obtient les variantes d'un numéro de téléphone à essayer
  static List<String> getPhoneNumberVariants(String phoneNumber) {
    String cleaned = cleanPhoneNumber(phoneNumber);
    List<String> variants = [];
    
    // Ajouter le numéro nettoyé tel quel
    variants.add(cleaned);
    
    // Si le numéro commence par l'indicatif, ajouter aussi la version locale
    if (cleaned.startsWith(defaultCountryCode)) {
      String localNumber = cleaned.substring(defaultCountryCode.length);
      if (localNumber.isNotEmpty) {
        variants.add(localNumber);
      }
    }
    
    // Si le numéro est local et qu'on n'ajoute pas automatiquement l'indicatif,
    // ajouter quand même la version avec indicatif comme alternative
    if (!autoAddCountryCode && 
        !cleaned.startsWith('+') && 
        cleaned.length == localNumberLength) {
      variants.add('$defaultCountryCode$cleaned');
    }
    
    // Enlever les doublons tout en préservant l'ordre
    return variants.toSet().toList();
  }
}