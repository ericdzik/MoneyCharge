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

      _merchants = querySnapshot.docs
          .map((doc) => Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

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