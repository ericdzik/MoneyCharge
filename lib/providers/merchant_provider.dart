import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/models/merchant_model.dart'; // Assurez-vous que ce modèle est à jour

class MerchantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Merchant> _allLoadedMerchants = [];
  List<Merchant> _filteredMerchants = [];

  bool _isLoading = false;
  String? _error;

  // Variables d'état pour les filtres actifs
  String? _activeMerchantTypeFilter; // null signifie 'Tous'
  List<String> _activeServiceFilters = [];
  String? _activeStockServiceFilter;
  bool _onlyShowAvailableStockForService = false;
  String _searchQuery = '';

  // Getters publics
  List<Merchant> get merchants => _filteredMerchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters pour l'état actuel des filtres
  String? get activeMerchantTypeFilter => _activeMerchantTypeFilter;
  List<String> get activeServiceFilters => List.unmodifiable(_activeServiceFilters);
  String? get activeStockServiceFilter => _activeStockServiceFilter;
  bool get onlyShowAvailableStockForService => _onlyShowAvailableStockForService;
  String get searchQuery => _searchQuery;

  Future<void> loadMerchants({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    if (_allLoadedMerchants.isNotEmpty && !forceRefresh) {
        _applyInternalFilters();
        notifyListeners();
        return;
    }

    _setLoading(true);
    _error = null;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          .where('isVerified', isEqualTo: true)
          .get();

      _allLoadedMerchants = querySnapshot.docs.map((doc) {
        try {
          return Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant ${doc.id}: $e');
          return null;
        }
      }).whereType<Merchant>().toList();

      _applyInternalFilters();

    } catch (e) {
      _error = "Erreur lors du chargement des marchands: ${e.toString()}";
      _allLoadedMerchants = [];
      _filteredMerchants = [];
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _applyInternalFilters() {
    List<Merchant> tempList = List.from(_allLoadedMerchants);

    // Filtre par Type de Marchand
    if (_activeMerchantTypeFilter != null && _activeMerchantTypeFilter!.isNotEmpty) {
      tempList.retainWhere((m) => m.merchantType == _activeMerchantTypeFilter);
    }

    // Filtre par Services Proposés (AU MOINS UN des services sélectionnés)
    if (_activeServiceFilters.isNotEmpty) {
      tempList.retainWhere((m) {
        if (m.services == null || m.services!.isEmpty) return false;
        return _activeServiceFilters.any((sf) => m.services!.contains(sf));
      });
    }

    // Filtre par Statut de Stock pour un Service Spécifique
    if (_activeStockServiceFilter != null &&
        _activeStockServiceFilter!.isNotEmpty &&
        _onlyShowAvailableStockForService) {
      tempList.retainWhere((m) =>
          m.serviceStockStatus != null &&
          m.serviceStockStatus![_activeStockServiceFilter!] == 'disponible');
    }

    // Filtre par recherche textuelle
    if (_searchQuery.isNotEmpty) {
      tempList.retainWhere((m) =>
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (m.address.toLowerCase().contains(_searchQuery.toLowerCase())));
    }
    _filteredMerchants = tempList;
  }

  void applyFilters({
    String? merchantType,
    List<String>? services, // Liste des services à filtrer
    String? stockService, // Le service unique pour lequel on vérifie le stock
    bool? onlyAvailableStock, // true si on ne veut que le stock disponible pour stockService
    String? searchQuery,
    bool clearAll = false,
    bool clearServiceAndStockFilters = false, // Pour réinitialiser uniquement les filtres du dialogue
    // Indicateur pour savoir si le filtre merchantType a été explicitement passé
    // Cela aide à distinguer un appel où merchantType n'est pas pertinent (et ne doit pas être changé)
    // d'un appel où merchantType est explicitement mis à null (pour "Tous").
    bool merchantTypeIsSet = false,
  }) {
    if (clearAll) {
      _activeMerchantTypeFilter = null;
      _activeServiceFilters = [];
      _activeStockServiceFilter = null;
      _onlyShowAvailableStockForService = false;
      _searchQuery = '';
    } else if (clearServiceAndStockFilters) {
      _activeServiceFilters = [];
      _activeStockServiceFilter = null;
      _onlyShowAvailableStockForService = false;
    } else {
      if (merchantTypeIsSet) { // Mettre à jour _activeMerchantTypeFilter seulement s'il est explicitement fourni
        _activeMerchantTypeFilter = merchantType; // `null` ici signifie "Tous"
      }
      if (services != null) {
        _activeServiceFilters = List.from(services);
      }

      // Gérer stockService et onlyAvailableStock
      // Si stockService est fourni (même vide pour effacer), on le met à jour.
      // Si onlyAvailableStock est fourni, on le met à jour.
      // Si stockService devient null/vide, on s'assure que onlyAvailableStock est false.
      if (stockService != null || (services != null && services.isEmpty)) { // Si services est vidé, stockService doit l'être aussi
         _activeStockServiceFilter = (stockService == null || stockService.isEmpty) ? null : stockService;
         if (_activeStockServiceFilter == null) {
            _onlyShowAvailableStockForService = false;
         }
      }
      if (onlyAvailableStock != null) {
        _onlyShowAvailableStockForService = onlyAvailableStock;
      }

      if (searchQuery != null) {
        _searchQuery = searchQuery;
      }
    }

    _applyInternalFilters();
    notifyListeners();
  }

  Future<void> refreshMerchants() async {
    await loadMerchants(forceRefresh: true);
  }

  Merchant? getMerchantById(String id) {
    try {
      return _allLoadedMerchants.firstWhere((merchant) => merchant.id == id);
    } catch (e) {
      return null;
    }
  }
}