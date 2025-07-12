import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp
import '../../merchant/models/merchant_auth_model.dart';
import '../models/admin_model.dart'; // For AdminModel if needed, or other shared enums

class AdminMockDataService {
  final Random _random = Random();

  // Simulate fetching the current Admin's profile
  AdminModel getMockAdminProfile() {
    return AdminModel(
      id: 'admin_user_001',
      email: 'admin@locacharge.com',
      name: 'Admin Principal',
      role: AdminRole.superAdmin,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      permissions: ['all_access'],
    );
  }

  // Simulate fetching a list of merchants
  List<MerchantAuthModel> getMockMerchants(int count) {
    final List<MerchantAuthModel> merchants = [];
    final List<String> businessTypes = ['Alimentation Générale', 'Cyber Café', 'Pharmacie', 'Boutique de Mode', 'Services de Réparation', 'Restaurant', 'Cosmétique', 'Papeterie'];
    final List<String> cities = ['Abidjan', 'Bouaké', 'Daloa', 'Yamoussoukro', 'San-Pédro', 'Korhogo'];
    final List<String> commonServices = ['Recharge téléphone', 'Paiement facture', 'Transfert d\'argent', 'Vente de cartes SIM', 'Photocopie'];
    final List<String> stockStatusOptions = ['available', 'low', 'unavailable'];

    for (int i = 0; i < count; i++) {
      String businessName = 'Entreprise ${String.fromCharCode(65 + _random.nextInt(26))}${_random.nextInt(1000)}';
      String city = cities[_random.nextInt(cities.length)];
      String merchantType = businessTypes[_random.nextInt(businessTypes.length)];

      // Generate a list of 2-3 random services
      List<String> currentServices = List.from(commonServices)..shuffle(_random);
      currentServices = currentServices.take(_random.nextInt(3) + 2).toList();

      // Generate stock status for these services
      Map<String, String> serviceStock = {};
      for (String service in currentServices) {
        serviceStock[service] = stockStatusOptions[_random.nextInt(stockStatusOptions.length)];
      }

      merchants.add(
        MerchantAuthModel(
          id: 'merchant_id_${i.toString().padLeft(3, '0')}',
          email: 'merchant${i + 1}@example.com',
          businessName: businessName,
          phone: '+225 01 ${_random.nextInt(90000000) + 10000000}',
          address: '${_random.nextInt(500) + 1} Rue Principale, Quartier ${_random.nextInt(10) + 1}, $city',
          openingHours: '08:00 - 18:00',
          services: currentServices,
          isVerified: _random.nextBool(),
          createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(730))),
          lastLoginAt: _random.nextBool() ? DateTime.now().subtract(Duration(hours: _random.nextInt(168))) : null,
          latitude: (5.2 + _random.nextDouble() * 0.4), // Approximate for Abidjan area
          longitude: (-4.1 + _random.nextDouble() * 0.4), // Approximate for Abidjan area
          merchantType: merchantType,
          serviceStockStatus: serviceStock,
        ),
      );
    }
    return merchants;
  }

  // Simulate fetching platform statistics
  Map<String, dynamic> getMockPlatformStats({int? totalMerchants}) {
    int actualTotalMerchants = totalMerchants ?? _random.nextInt(150) + 50; // Use provided or generate
    int activeMerchants = (actualTotalMerchants * (_random.nextDouble() * 0.3 + 0.6)).round(); // 60-90% active

    return {
      'totalUsers': _random.nextInt(2000) + 500, // Standard users
      'totalMerchants': actualTotalMerchants,
      'activeMerchants': activeMerchants,
      'totalRevenue': (_random.nextDouble() * 5000000) + 1000000, // In FCFA
      'totalTransactions': _random.nextInt(10000) + 2000,
      'pendingVerifications': (actualTotalMerchants * (_random.nextDouble() * 0.15 + 0.05)).round(), // 5-20% pending
      'averageTransactionsPerDay': _random.nextInt(300) + 50,
      'customerSatisfaction': (_random.nextDouble() * 0.3) + 0.65, // 65-95%
      'totalChargerRentals': _random.nextInt(5000) + 1000, // Assuming charger rental is a key metric
    };
  }

  // Simulate data for charts if needed later
  // List<ChartData> getRevenueOverTime() { ... }
  // List<ChartData> getUserGrowth() { ... }
}

// Example helper for chart data if you add charts
// class ChartData {
//   ChartData(this.x, this.y);
//   final String x; // Or DateTime
//   final double y;
// }
