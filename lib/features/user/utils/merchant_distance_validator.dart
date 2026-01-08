import 'package:locacharge/features/user/models/content_item_model.dart';

/// Utilitaire pour valider les distances des marchands
class MerchantDistanceValidator {
  
  /// Valide qu'un marchand a une distance valide pour le filtre de 3km
  static bool isValidForRadius(MerchantContentItem merchant, double radiusKm) {
    // Si pas de distance, le marchand ne peut pas être filtré
    if (merchant.distanceKm == null) {
      return false;
    }
    
    // Vérifier que la distance est positive
    if (merchant.distanceKm! < 0) {
      return false;
    }
    
    // Vérifier que la distance est dans le rayon
    return merchant.distanceKm! <= radiusKm;
  }
  
  /// Filtre une liste de marchands selon un rayon donné
  static List<MerchantContentItem> filterByRadius(
    List<MerchantContentItem> merchants, 
    double radiusKm
  ) {
    return merchants
        .where((merchant) => isValidForRadius(merchant, radiusKm))
        .toList();
  }
  
  /// Trie les marchands par distance (plus proche en premier)
  static List<MerchantContentItem> sortByDistance(List<MerchantContentItem> merchants) {
    final sortedMerchants = List<MerchantContentItem>.from(merchants);
    sortedMerchants.sort((a, b) {
      // Les marchands sans distance vont à la fin
      if (a.distanceKm == null && b.distanceKm == null) return 0;
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      
      return a.distanceKm!.compareTo(b.distanceKm!);
    });
    return sortedMerchants;
  }
  
  /// Filtre et trie les marchands dans un rayon de 3km
  static List<MerchantContentItem> getMerchantsWithin3Km(List<MerchantContentItem> merchants) {
    final filtered = filterByRadius(merchants, 3.0);
    return sortByDistance(filtered);
  }
  
  /// Valide qu'une liste de marchands respecte le filtre de 3km
  static bool validateMerchantList(List<MerchantContentItem> merchants, double radiusKm) {
    for (final merchant in merchants) {
      if (!isValidForRadius(merchant, radiusKm)) {
        print('Validation failed for merchant: ${merchant.name} (distance: ${merchant.distanceKm})');
        return false;
      }
    }
    return true;
  }
  
  /// Affiche un résumé des distances des marchands
  static void printDistanceSummary(List<MerchantContentItem> merchants) {
    print('\n=== Résumé des distances des marchands ===');
    print('Nombre total de marchands: ${merchants.length}');
    
    final withDistance = merchants.where((m) => m.distanceKm != null).toList();
    final withoutDistance = merchants.where((m) => m.distanceKm == null).toList();
    
    print('Marchands avec distance: ${withDistance.length}');
    print('Marchands sans distance: ${withoutDistance.length}');
    
    if (withDistance.isNotEmpty) {
      final distances = withDistance.map((m) => m.distanceKm!).toList();
      distances.sort();
      
      print('Distance minimale: ${distances.first.toStringAsFixed(2)}km');
      print('Distance maximale: ${distances.last.toStringAsFixed(2)}km');
      print('Distance moyenne: ${(distances.reduce((a, b) => a + b) / distances.length).toStringAsFixed(2)}km');
    }
    
    print('\nDétail par marchand:');
    for (final merchant in merchants) {
      final distanceStr = merchant.distanceKm?.toStringAsFixed(2) ?? 'N/A';
      print('  - ${merchant.name}: ${distanceStr}km');
    }
    print('==========================================\n');
  }
}