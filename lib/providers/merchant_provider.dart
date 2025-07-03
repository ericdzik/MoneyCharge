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
    bool clearServiceAndStockFilters = false,
    bool merchantTypeIsSet = false,
    bool servicesIsSet = false,
    bool stockServiceIsSet = false, // Ajouté pour la cohérence
    bool onlyAvailableStockIsSet = false, // Ajouté pour la cohérence
    bool searchQueryIsSet = false, // Renommé depuis updateSearchQuery
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
      // Ne pas toucher aux autres filtres comme merchantType ou searchQuery
    } else {
      if (merchantTypeIsSet) {
        _activeMerchantTypeFilter = merchantType;
      }
      if (servicesIsSet && services != null) {
        _activeServiceFilters = List.from(services);
      } else if (servicesIsSet && services == null) { // Explicitly clearing service filters
        _activeServiceFilters = [];
      }

      if (stockServiceIsSet) {
         _activeStockServiceFilter = (stockService == null || stockService.isEmpty) ? null : stockService;
         // Si stockService est explicitement mis à null/vide, et onlyAvailableStockIsSet n'est pas true,
         // alors onlyShowAvailableStockForService doit être false.
         if (_activeStockServiceFilter == null && !onlyAvailableStockIsSet) {
            _onlyShowAvailableStockForService = false;
         }
      }
      if (onlyAvailableStockIsSet && onlyAvailableStock != null) {
        _onlyShowAvailableStockForService = onlyAvailableStock;
        // Si on met à jour onlyAvailableStock, et que _activeStockServiceFilter est null,
        // cela n'a pas de sens, donc on s'assure que _onlyShowAvailableStockForService est false.
        if (_activeStockServiceFilter == null) {
            _onlyShowAvailableStockForService = false;
        }
      }

      if (searchQueryIsSet && searchQuery != null) {
        _searchQuery = searchQuery;
      } else if (searchQueryIsSet && searchQuery == null) { // Explicitly clearing search query
        _searchQuery = '';
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