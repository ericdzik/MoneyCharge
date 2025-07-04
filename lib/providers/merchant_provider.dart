import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/models/merchant_model.dart'; // Assurez-vous que ce modèle est à jour

class MerchantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Merchant> _allLoadedMerchants = []; // For user view
  List<Merchant> _filteredMerchants = []; // For user view

  List<MerchantAuthModel> _adminMerchantList = []; // For admin view

  bool _isLoading = false;
  String? _error;

  // Variables d'état pour les filtres actifs
  String? _activeMerchantTypeFilter; // null signifie 'Tous'
  List<String> _activeServiceFilters = [];
  String? _activeStockServiceFilter;
  bool _onlyShowAvailableStockForService = false;
  String _searchQuery = '';

  // Getters publics
  List<Merchant> get merchants => _filteredMerchants; // For user-facing filtered list
<<<<<<< HEAD
  List<Merchant> get allLoadedMerchantsForAdminView => List.unmodifiable(_allLoadedMerchants); // For admin view (unfiltered by default)
=======
  // List<Merchant> get allLoadedMerchantsForAdminView => List.unmodifiable(_allLoadedMerchants); // Old getter, to be replaced or removed if not used elsewhere for this exact type
  List<MerchantAuthModel> get adminMerchants => List.unmodifiable(_adminMerchantList); // New getter for admin
>>>>>>> 9dbdb7f1d84b71da4fe25a7536678d32cad6017f
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

    // If _allLoadedMerchants is not empty and we are not forcing a refresh,
    // it means we might have already loaded data (e.g., for admin).
    // We should just apply user filters and notify.
    if (_allLoadedMerchants.isNotEmpty && !forceRefresh) {
        _applyInternalFilters(); // Apply user-facing filters
        notifyListeners();
        return;
    }

    _setLoading(true);
    _error = null;

    try {
      // This query is for user-facing views: verified merchants only
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          .where('isVerified', isEqualTo: true) // Users typically see only verified merchants
          .get();

      _allLoadedMerchants = querySnapshot.docs.map((doc) {
        try {
          return Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant ${doc.id}: $e');
          return null;
        }
      }).whereType<Merchant>().toList();

      _applyInternalFilters(); // Apply user-facing filters to the loaded verified merchants

    } catch (e) {
      _error = "Erreur lors du chargement des marchands: ${e.toString()}";
      _allLoadedMerchants = [];
      _filteredMerchants = [];
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllMerchantsForAdmin({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

<<<<<<< HEAD
    // If _allLoadedMerchants is not empty and we are not forcing a refresh,
    // it means we might have already loaded data.
    // For admin, we don't apply user filters by default to _allLoadedMerchants.
    // So, if it's already populated, we might not need to do anything unless forceRefresh is true.
    if (_allLoadedMerchants.isNotEmpty && !forceRefresh) {
        // For admin, we usually want the full list, so no filters applied here by default.
        // If filters were ever applied to _allLoadedMerchants directly, this would be an issue.
        // The getter `allLoadedMerchantsForAdminView` ensures an unmodifiable list.
        // We also need to ensure _filteredMerchants is up-to-date if it's used by admin view,
        // but typically admin view would use `allLoadedMerchantsForAdminView`.
        // For safety, let's assume admin view will use a direct, unfiltered list.
        notifyListeners(); // Notify if there's a listener for isLoading or error states.
=======
    // This method will now populate _adminMerchantList with MerchantAuthModel
    if (_isLoading && !forceRefresh) return;

    if (_adminMerchantList.isNotEmpty && !forceRefresh) {
        notifyListeners();
>>>>>>> 9dbdb7f1d84b71da4fe25a7536678d32cad6017f
        return;
    }

    _setLoading(true);
    _error = null;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
<<<<<<< HEAD
          // No 'isVerified' filter for admin
          .get();

      _allLoadedMerchants = querySnapshot.docs.map((doc) {
        try {
          return Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant for admin ${doc.id}: $e');
          return null;
        }
      }).whereType<Merchant>().toList();

      // For admin, we typically don't filter _allLoadedMerchants by default.
      // If the admin screen needs a filtered view, it should apply its own filters
      // or use a separate filtered list.
      // The user-facing `_filteredMerchants` should be updated based on user filters.
      // If admin also uses `merchants` getter, then filters might apply.
      // Let's ensure _filteredMerchants is also updated, perhaps with no filters initially for admin.
      _filteredMerchants = List.from(_allLoadedMerchants); // Admin sees all by default if using 'merchants' getter

    } catch (e) {
      _error = "Erreur lors du chargement des marchands pour admin: ${e.toString()}";
      _allLoadedMerchants = [];
      _filteredMerchants = [];
=======
          .get();

      // Import MerchantAuthModel if not already imported
      // Assumes 'package:locacharge/features/merchant/models/merchant_auth_model.dart'
      _adminMerchantList = querySnapshot.docs.map((doc) {
        try {
          // Directly create MerchantAuthModel from the Firestore document
          return MerchantAuthModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant for admin MerchantAuthModel ${doc.id}: $e');
          return null;
        }
      }).whereType<MerchantAuthModel>().toList();

      // _allLoadedMerchants and _filteredMerchants (type Merchant) are not affected by this method directly.
      // This keeps user-facing merchant list separate.

    } catch (e) {
      _error = "Erreur lors du chargement des marchands pour admin: ${e.toString()}";
      _adminMerchantList = []; // Clear on error
>>>>>>> 9dbdb7f1d84b71da4fe25a7536678d32cad6017f
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

  void _applyInternalFilters() { // This applies to _allLoadedMerchants (type Merchant) for user view
    List<Merchant> tempList = List.from(_allLoadedMerchants);

    // Filtre par Type de Marchand
    if (_activeMerchantTypeFilter != null && _activeMerchantTypeFilter!.isNotEmpty) {
      tempList.retainWhere((m) => m.merchantType == _activeMerchantTypeFilter);
    }

    // Filtre par Services Proposés (AU MOINS UN des services sélectionnés)
    if (_activeServiceFilters.isNotEmpty) {
      tempList.retainWhere((m) {
        // Merchant model might use 'services' or 'servicesOffered'. Ensure consistency.
        // The Merchant model uses 'services'.
        if (m.services.isEmpty) return false;
        return _activeServiceFilters.any((sf) => m.services.contains(sf));
      });
    }

    // Filtre par Statut de Stock pour un Service Spécifique
    if (_activeStockServiceFilter != null &&
        _activeStockServiceFilter!.isNotEmpty &&
        _onlyShowAvailableStockForService) {
      tempList.retainWhere((m) =>
          m.serviceStockStatus != null &&
          m.serviceStockStatus![_activeStockServiceFilter!]?.toLowerCase() == 'disponible');
    }

    // Filtre par recherche textuelle
    if (_searchQuery.isNotEmpty) {
      tempList.retainWhere((m) =>
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (m.address.toLowerCase().contains(_searchQuery.toLowerCase())));
    }
    _filteredMerchants = tempList;
  }

  void applyFilters({ // This applies to user-facing filters
    String? merchantType,
    List<String>? services,
    String? stockService,
    bool? onlyAvailableStock,
    String? searchQuery,
    bool clearAll = false,
    bool clearServiceAndStockFilters = false,
    bool merchantTypeIsSet = false,
    bool servicesIsSet = false,
    bool stockServiceIsSet = false,
    bool onlyAvailableStockIsSet = false,
    bool searchQueryIsSet = false,
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
      if (merchantTypeIsSet) {
        _activeMerchantTypeFilter = merchantType;
      }
      if (servicesIsSet && services != null) {
        _activeServiceFilters = List.from(services);
      } else if (servicesIsSet && services == null) {
        _activeServiceFilters = [];
      }

      if (stockServiceIsSet) {
         _activeStockServiceFilter = (stockService == null || stockService.isEmpty) ? null : stockService;
         if (_activeStockServiceFilter == null && !onlyAvailableStockIsSet) {
            _onlyShowAvailableStockForService = false;
         }
      }
      if (onlyAvailableStockIsSet && onlyAvailableStock != null) {
        _onlyShowAvailableStockForService = onlyAvailableStock;
        if (_activeStockServiceFilter == null) {
            _onlyShowAvailableStockForService = false;
        }
      }

      if (searchQueryIsSet && searchQuery != null) {
        _searchQuery = searchQuery;
      } else if (searchQueryIsSet && searchQuery == null) {
        _searchQuery = '';
      }
    }

    _applyInternalFilters();
    notifyListeners();
  }

  Future<void> refreshMerchants() async { // Refreshes user-facing merchants
    await loadMerchants(forceRefresh: true);
  }

  Future<void> refreshAdminMerchants() async { // Refreshes admin-facing merchants
    await loadAllMerchantsForAdmin(forceRefresh: true);
  }


  Merchant? getMerchantById(String id) { // Gets from user-facing list
    try {
      return _allLoadedMerchants.firstWhere((merchant) => merchant.id == id);
    } catch (e) {
      return null;
    }
  }

  // It might be useful to have a similar getter for admin if needed by ID elsewhere.
  // MerchantAuthModel? getAdminMerchantById(String id) {
  //   try {
  //     return _adminMerchantList.firstWhere((merchant) => merchant.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
// Ensure MerchantAuthModel is imported if not already via other files
// import '../features/merchant/models/merchant_auth_model.dart';