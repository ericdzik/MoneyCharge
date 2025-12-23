import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locacharge/features/user/models/merchant_model.dart';

class FavoriteMerchantProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorite_merchant_ids';
  List<String> _favoriteMerchantIds = [];
  List<Merchant> _favoriteMerchants = [];
  bool _isLoading = false;

  List<String> get favoriteMerchantIds => _favoriteMerchantIds;
  List<Merchant> get favoriteMerchants => _favoriteMerchants;
  bool get isLoading => _isLoading;

  FavoriteMerchantProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _favoriteMerchantIds = prefs.getStringList(_favoritesKey) ?? [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(String merchantId) async {
    if (!_favoriteMerchantIds.contains(merchantId)) {
      _favoriteMerchantIds.add(merchantId);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String merchantId) async {
    if (_favoriteMerchantIds.contains(merchantId)) {
      _favoriteMerchantIds.remove(merchantId);
      await _saveFavorites();
      notifyListeners();
    }
  }

  bool isFavorite(String merchantId) {
    return _favoriteMerchantIds.contains(merchantId);
  }

  Future<void> fetchFavoriteMerchants(String userId) async {
    await loadFavorites();
    if (_favoriteMerchantIds.isEmpty) {
      _favoriteMerchants = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final merchantsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: _favoriteMerchantIds)
          .get();
      _favoriteMerchants = merchantsSnapshot.docs
          .map((doc) => Merchant.fromFirestoreUserDoc(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print("Error in fetchFavoriteMerchants: $e");
      _favoriteMerchants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteMerchantIds);
  }
}
