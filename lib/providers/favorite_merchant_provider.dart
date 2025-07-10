import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteMerchantProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorite_merchant_ids';
  List<String> _favoriteMerchantIds = [];
  bool _isLoading = false;

  List<String> get favoriteMerchantIds => _favoriteMerchantIds;
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

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteMerchantIds);
  }
}
