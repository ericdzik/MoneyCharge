import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/models/merchant_model.dart';
// import '../services/api_service.dart'; // ApiService n'est plus utilisé ici pour charger les marchands

class MerchantProvider with ChangeNotifier {
  // final ApiService _apiService = ApiService(); // Supprimé
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Merchant> _allLoadedMerchants = []; // Stocke tous les marchands chargés depuis Firestore
  List<Merchant> _filteredMerchants = []; // Stocke les marchands après filtrage

  bool _isLoading = false;
  String? _error;

  // Variables d'état pour les filtres actifs
  String? _activeMerchantTypeFilter;
  List<String> _activeServiceFilters = [];
  String? _activeStockServiceFilter;
  bool _onlyShowAvailableStockForService = false;

  // Le getter public 'merchants' retournera la liste filtrée.
  // La logique de filtrage sera ajoutée dans une étape ultérieure (Sous-tâche 1.4)
  List<Merchant> get merchants => _filteredMerchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters pour les filtres actifs (utiles pour l'UI de FilterBarWidget)
  String? get activeMerchantTypeFilter => _activeMerchantTypeFilter;
  List<String> get activeServiceFilters => _activeServiceFilters;
  String? get activeStockServiceFilter => _activeStockServiceFilter;
  bool get onlyShowAvailableStockForService => _onlyShowAvailableStockForService;


  Future<void> loadMerchants({bool forceRefresh = false}) async {
    if (_allLoadedMerchants.isNotEmpty && !forceRefresh && !_isLoading) {
      // Si les marchands sont déjà chargés et qu'on ne force pas,
      // on pourrait juste réappliquer les filtres existants et notifier.
      // Cependant, pour l'instant, loadMerchants recharge toujours depuis Firestore si appelé.
      // Une amélioration future pourrait être de ne pas re-fetch si les données sont "fraîches".
      // Pour l'instant, on s'assure juste de ne pas faire de fetch multiple en parallèle.
      // _applyCurrentFilters(); // Méthode à créer si on ne re-fetch pas
      // return;
    }

    if (_isLoading) return; // Eviter les chargements multiples en parallèle

    _setLoading(true);
    _error = null;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          .where('isVerified', isEqualTo: true)
          .get();

      final rawDocs = querySnapshot.docs;
      print('[MerchantProvider] Fetched ${rawDocs.length} raw merchant documents.');

      _allLoadedMerchants = rawDocs.map((doc) {
        try {
          return Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant ${doc.id}: $e');
          return null;
        }
      }).whereType<Merchant>().toList();

      print('[MerchantProvider] Successfully parsed ${_allLoadedMerchants.length} merchants.');

      // Après avoir chargé tous les marchands, appliquer les filtres courants
      // La logique de _applyCurrentFilters sera définie dans le getter `merchants` ou une méthode dédiée.
      // Pour l'instant, on assigne directement à _filteredMerchants, qui sera ensuite filtré par le getter.
      // À la Sous-tâche 1.4, le getter `merchants` fera le filtrage.
      // Pour l'instant, pour que l'UI se mette à jour avec la liste complète (avant filtrage):
      _applyInternalFilters(); // Applique les filtres actuels sur _allLoadedMerchants et met à jour _filteredMerchants

    } catch (e) {
      _error = "Erreur lors du chargement des marchands: ${e.toString()}";
      _allLoadedMerchants = [];
      _filteredMerchants = [];
      print(_error);
    } finally {
      _setLoading(false); // Cela va appeler notifyListeners()
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  // Méthode interne pour appliquer les filtres et mettre à jour _filteredMerchants
  // Cette méthode sera appelée par loadMerchants et applyFilters.
  void _applyInternalFilters() {
    List<Merchant> tempList = List.from(_allLoadedMerchants);

    if (_activeMerchantTypeFilter != null && _activeMerchantTypeFilter != 'Tous') { // Supposant que 'Tous' est une option pour ne pas filtrer
      tempList.retainWhere((m) => m.merchantType == _activeMerchantTypeFilter);
    }

    if (_activeServiceFilters.isNotEmpty) {
      tempList.retainWhere((m) =>
          m.services != null &&
          _activeServiceFilters.any((sf) => m.services!.contains(sf)));
    }

    if (_activeStockServiceFilter != null && _activeStockServiceFilter!.isNotEmpty && _onlyShowAvailableStockForService) {
      tempList.retainWhere((m) =>
          m.serviceStockStatus != null &&
          m.serviceStockStatus![_activeStockServiceFilter!] == 'disponible');
    }

    _filteredMerchants = tempList;
    // notifyListeners(); // Notifié par setLoading(false) dans loadMerchants ou par applyFilters
  }


  // Méthode publique pour mettre à jour les filtres depuis l'UI
  void applyFilters({
    String? merchantType,
    List<String>? services,
    String? stockService, // Le service spécifique pour lequel on vérifie le stock
    bool? onlyAvailableStock, // Si true, ne montrer que stock "disponible" pour stockService
    bool clearAll = false,
  }) {
    if (clearAll) {
      _activeMerchantTypeFilter = null;
      _activeServiceFilters = [];
      _activeStockServiceFilter = null;
      _onlyShowAvailableStockForService = false;
    } else {
      // Mettre à jour les filtres individuellement s'ils sont fournis
      if (merchantType != null) _activeMerchantTypeFilter = merchantType == 'Tous' ? null : merchantType;
      if (services != null) _activeServiceFilters = List.from(services); // Créer une nouvelle liste
      if (stockService != null) _activeStockServiceFilter = stockService.isEmpty ? null : stockService;
      if (onlyAvailableStock != null) _onlyShowAvailableStockForService = onlyAvailableStock;
    }

    _applyInternalFilters(); // Appliquer les filtres pour mettre à jour _filteredMerchants
    notifyListeners(); // Notifier l'UI que la liste des marchands (filtrée) a potentiellement changé
  }


  Future<void> refreshMerchants() async {
    await loadMerchants(forceRefresh: true);
  }

  Merchant? getMerchantById(String id) {
    // Devrait chercher dans _filteredMerchants ou _allLoadedMerchants selon le besoin
    try {
      return _allLoadedMerchants.firstWhere((merchant) => merchant.id == id);
    } catch (e) {
      return null;
    }
  }
}