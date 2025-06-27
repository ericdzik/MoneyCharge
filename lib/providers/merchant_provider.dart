import 'package:flutter/foundation.dart';
import '../features/user/models/merchant_model.dart';
import '../services/api_service.dart';

class MerchantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Merchant> _merchants = [];
  bool _isLoading = false;
  String? _error;

  List<Merchant> get merchants => _merchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMerchants() async {
    _setLoading(true);
    try {
      _merchants = await _apiService.getMerchants();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _merchants = _getDemoMerchants(); // Fallback avec données de demo
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<Merchant> _getDemoMerchants() {
    return [
      Merchant(
        id: '1',
        name: 'Boutique Télécoms Lomé',
        address: '123 Rue du Commerce, Lomé',
        phone: '+228 22 61 23 45',
        hours: '8h00 - 20h00',
        isOpen: true,
        status: MerchantStatus.available,
        latitude: 6.1319,
        longitude: 1.2228,
        distance: 0.5,
        walkingTime: '6 min',
        drivingTime: '2 min',
        services: ['Recharge crédit', 'Cartes SIM', 'Forfaits data'],
      ),
      Merchant(
        id: '2',
        name: 'Cyber Café Digital',
        address: '45 Avenue de la Paix, Lomé',
        phone: '+228 22 45 67 89',
        hours: '7h00 - 22h00',
        isOpen: true,
        status: MerchantStatus.lowStock,
        latitude: 6.1375,
        longitude: 1.2123,
        distance: 1.2,
        walkingTime: '15 min',
        drivingTime: '4 min',
        services: ['Recharge crédit', 'Internet', 'Impression'],
      ),
      Merchant(
        id: '3',
        name: 'Shop Mobile Plus',
        address: '78 Boulevard du 13 Janvier, Lomé',
        phone: '+228 22 78 90 12',
        hours: '9h00 - 19h00',
        isOpen: false,
        status: MerchantStatus.outOfStock,
        latitude: 6.1284,
        longitude: 1.2350,
        distance: 2.1,
        walkingTime: '25 min',
        drivingTime: '7 min',
        services: ['Recharge crédit', 'Réparation mobile', 'Accessoires'],
      ),
    ];
  }
}