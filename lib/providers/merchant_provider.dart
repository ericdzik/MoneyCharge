import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/models/merchant_model.dart';
// import '../services/api_service.dart'; // ApiService n'est plus utilisé ici pour charger les marchands

class MerchantProvider with ChangeNotifier {
  // final ApiService _apiService = ApiService(); // Supprimé
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Merchant> _merchants = [];
  bool _isLoading = false;
  String? _error;

  List<Merchant> get merchants => _merchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMerchants({bool forceRefresh = false}) async {
    // Option pour forcer le rafraîchissement, sinon on peut ajouter une logique de cache simple ici si besoin
    if (_merchants.isNotEmpty && !forceRefresh && !_isLoading) {
       // Ne rien faire si les marchands sont déjà chargés et qu'on ne force pas le refresh
       // Ou implémenter une logique de cache avec expiration si nécessaire.
      // Pour l'instant, on recharge à chaque appel à loadMerchants si pas déjà en chargement.
    }

    _setLoading(true);
    _error = null;

    try {
      // Interroger la collection 'users' pour les documents où role == 'merchant' et isVerified == true
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          .where('isVerified', isEqualTo: true)
          // Pourrait aussi ajouter .where('isActive', isEqualTo: true) si ce champ est pertinent
          .get();

      final rawDocs = querySnapshot.docs;
      print('[MerchantProvider] Fetched ${rawDocs.length} raw merchant documents.');

      _merchants = rawDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // print('[MerchantProvider] Parsing merchant: ${doc.id}, data: $data');
        try {
          Merchant merchant = Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
          // print('[MerchantProvider] Parsed ${merchant.name} at ${merchant.latitude}, ${merchant.longitude}');
          return merchant;
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant ${doc.id}: $e');
          return null; // Return null for merchants that fail to parse
        }
      }).whereType<Merchant>().toList(); // Filter out any nulls from parsing errors

      print('[MerchantProvider] Successfully parsed ${_merchants.length} merchants.');
      if (_merchants.isNotEmpty) {
        print('[MerchantProvider] First merchant: ${_merchants.first.name} at Lat: ${_merchants.first.latitude}, Lng: ${_merchants.first.longitude}');
        if (_merchants.length > 1 && _merchants.length >=2) {
           print('[MerchantProvider] Second merchant: ${_merchants[1].name} at Lat: ${_merchants[1].latitude}, Lng: ${_merchants[1].longitude}');
        }
      }

    } catch (e) {
      _error = "Erreur lors du chargement des marchands: ${e.toString()}";
      _merchants = []; // Vider la liste en cas d'erreur
      print(_error); // Pour le débogage
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return; // Éviter les notifications inutiles
    _isLoading = loading;
    notifyListeners();
  }

  // _getDemoMerchants() n'est plus nécessaire car nous chargeons depuis Firestore.
  // List<Merchant> _getDemoMerchants() { ... }

  // Optionnel: Méthode pour rafraîchir la liste explicitement
  Future<void> refreshMerchants() async {
    await loadMerchants(forceRefresh: true);
  }

  // Optionnel: Méthode pour trouver un marchand par ID si nécessaire
  Merchant? getMerchantById(String id) {
    try {
      return _merchants.firstWhere((merchant) => merchant.id == id);
    } catch (e) {
      return null; // Non trouvé
    }
  }
}