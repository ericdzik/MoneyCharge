import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/models/merchant_model.dart'; // For user-facing merchant list
import '../features/merchant/models/merchant_auth_model.dart'; // For admin-facing merchant list
import '../services/notification_service.dart';
import 'dart:math';

import 'dart:async';
// For user-facing merchant list
// For admin-facing merchant list

class MerchantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _merchantsSubscription;

  List<Merchant> _allLoadedMerchants = []; // For user view (verified merchants, type Merchant)
  List<Merchant> _filteredMerchants = []; // For user view (filtered list of Merchant)

  List<MerchantAuthModel> _adminMerchantList = []; // For admin view (all merchants, type MerchantAuthModel)

  bool _isLoading = false;
  String? _error;

  // Variables d'état pour les filtres actifs (for user view)
  String? _activeMerchantTypeFilter;
  List<String> _activeServiceFilters = [];
  String? _activeStockServiceFilter;
  bool _onlyShowAvailableStockForService = false;
  String? _activeStockStatusFilter;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _filterOpen = false;

  // Getters publics
  List<Merchant> get merchants => _filteredMerchants; // For user-facing filtered list
  List<MerchantAuthModel> get adminMerchants => List.unmodifiable(_adminMerchantList); // For admin view

  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _merchantsSubscription?.cancel();
    super.dispose();
  }

  // Getters pour l'état actuel des filtres (for user view)
  String? get activeMerchantTypeFilter => _activeMerchantTypeFilter;
  List<String> get activeServiceFilters => List.unmodifiable(_activeServiceFilters);
  String? get activeStockServiceFilter => _activeStockServiceFilter;
  bool get onlyShowAvailableStockForService => _onlyShowAvailableStockForService;
  String? get activeStockStatusFilter => _activeStockStatusFilter;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get filterOpen => _filterOpen;

  List<String> get uniqueServiceCategories {
    return ["Recharge de crédit", "Transfert d'argent", "Achat de carte SIM"];
  }

  void listenToMerchants() {
    _setLoading(true);
    _merchantsSubscription?.cancel();
    _merchantsSubscription = _firestore
        .collection('users')
        .where('role', isEqualTo: 'merchant')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .listen((querySnapshot) {
      _allLoadedMerchants = querySnapshot.docs.map((doc) {
        try {
          return Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant ${doc.id}: $e');
          return null;
        }
      }).whereType<Merchant>().toList();
      _applyInternalFilters();
      _setLoading(false);
    }, onError: (e) {
      _error = "Erreur lors de l'écoute des marchands: ${e.toString()}";
      _allLoadedMerchants = [];
      _filteredMerchants = [];
      _setLoading(false);
      print(_error);
    });
  }

  Future<void> loadAllMerchantsForAdmin({bool forceRefresh = false}) async { // For admin view
    // This method populates _adminMerchantList with MerchantAuthModel
    if (_isLoading && !forceRefresh) return;

    if (_adminMerchantList.isNotEmpty && !forceRefresh) {
        notifyListeners();
        return;
    }

    _setLoading(true);
    _error = null;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          // No 'isVerified' filter for admin, they see all merchants
          .get();

      // Corrected: use the local querySnapshot variable
      final querySnapshotData = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'merchant')
          // No 'isVerified' filter for admin, they see all merchants
          .get();

      // Corrected: use the local querySnapshot variable from the .get() call above
      _adminMerchantList = querySnapshot.docs.map((doc) {
        try {
          return MerchantAuthModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        } catch (e) {
          print('[MerchantProvider] Error parsing merchant for admin (MerchantAuthModel) ${doc.id}: $e');
          return null;
        }
      }).whereType<MerchantAuthModel>().toList();

    } catch (e) {
      _error = "Erreur lors du chargement des marchands pour admin: ${e.toString()}";
      _adminMerchantList = [];
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

    if (_activeMerchantTypeFilter != null && _activeMerchantTypeFilter!.isNotEmpty) {
      tempList.retainWhere((m) => m.merchantType == _activeMerchantTypeFilter);
    }

    if (_activeServiceFilters.isNotEmpty) {
      tempList.retainWhere((m) {
        if (m.services.isEmpty) return false;
        return _activeServiceFilters.any((sf) => m.services.contains(sf));
      });
    }

    if (_activeStockServiceFilter != null &&
        _activeStockServiceFilter!.isNotEmpty &&
        _onlyShowAvailableStockForService) {
      tempList.retainWhere((m) =>
          m.serviceStockStatus != null &&
          m.serviceStockStatus![_activeStockServiceFilter!]?.toLowerCase() == 'disponible');
    }

    if (_activeStockStatusFilter != null && _activeStockStatusFilter!.isNotEmpty) {
      tempList.retainWhere((m) {
        if (m.serviceStockStatus == null) return false;
        // Check if any of the services has the desired stock status
        return m.serviceStockStatus!.values.any((status) => status.toLowerCase() == _activeStockStatusFilter!.toLowerCase());
      });
    }

    if (_searchQuery.isNotEmpty) {
      tempList.retainWhere((m) {
        final query = _searchQuery.toLowerCase();
        return m.name.toLowerCase().contains(query) ||
               m.address.toLowerCase().contains(query) ||
               m.services.any((service) => service.toLowerCase().contains(query));
      });
    }

    if (_selectedCategory != null) {
      tempList.retainWhere((m) => m.services.contains(_selectedCategory));
    }

    if (_filterOpen) {
      tempList.retainWhere((m) => m.isOpen);
    }

    _filteredMerchants = tempList;
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyInternalFilters();
    notifyListeners();
  }

  void toggleFilterOpen() {
    _filterOpen = !_filterOpen;
    _applyInternalFilters();
    notifyListeners();
  }

  void applyFilters({ // This applies to user-facing filters for the List<Merchant>
    String? merchantType,
    List<String>? services,
    String? stockService,
    bool? onlyAvailableStock,
    String? stockStatus,
    String? searchQuery,
    bool clearAll = false,
    bool clearServiceAndStockFilters = false,
    bool merchantTypeIsSet = false,
    bool servicesIsSet = false,
    bool stockServiceIsSet = false,
    bool onlyAvailableStockIsSet = false,
    bool stockStatusIsSet = false,
    bool searchQueryIsSet = false,
  }) {
    if (clearAll) {
      _activeMerchantTypeFilter = null;
      _activeServiceFilters = [];
      _activeStockServiceFilter = null;
      _onlyShowAvailableStockForService = false;
      _activeStockStatusFilter = null;
      _searchQuery = '';
    } else if (clearServiceAndStockFilters) {
      _activeServiceFilters = [];
      _activeStockServiceFilter = null;
      _onlyShowAvailableStockForService = false;
      _activeStockStatusFilter = null;
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

      if (stockStatusIsSet) {
        _activeStockStatusFilter = stockStatus;
      }
    }

    _applyInternalFilters();
    notifyListeners();
  }

  void refreshMerchants() { // Refreshes user-facing merchants
    listenToMerchants();
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

  // Optional: get admin merchant by ID if needed elsewhere
  // MerchantAuthModel? getAdminMerchantById(String id) {
  //   try {
  //     return _adminMerchantList.firstWhere((merchant) => merchant.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<void> updateMerchantVerification(String merchantId, bool isVerified) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestore.collection('users').doc(merchantId).update({
        'isVerified': isVerified,
      });

      if (isVerified) {
        await NotificationService.showNotification(
          id: Random().nextInt(1000),
          title: 'Marchand Approuvé',
          body: 'Le marchand a été approuvé avec succès.',
        );
      }

      // Refresh the list of merchants for the admin view
      await loadAllMerchantsForAdmin(forceRefresh: true);
    } catch (e) {
      _error = "Erreur lors de la mise à jour de la vérification: ${e.toString()}";
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMerchantSuspension(String merchantId, bool isSuspended) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestore.collection('users').doc(merchantId).update({
        'isSuspended': isSuspended,
      });
      // Refresh the list of merchants for the admin view
      await loadAllMerchantsForAdmin(forceRefresh: true);
    } catch (e) {
      _error = "Erreur lors de la mise à jour de la suspension: ${e.toString()}";
      print(_error);
    } finally {
      _setLoading(false);
    }
  }
}
