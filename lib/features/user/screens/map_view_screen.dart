import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/map_widget.dart';
import '../widgets/filter_bar_widget.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  List<Merchant> _merchants = [];
  Merchant? _selectedMerchant;
  bool _isLoading = true;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    // Simuler le chargement des données
    await Future.delayed(const Duration(seconds: 1));

    // Données de test
    final merchants = [
      Merchant(
        id: '1',
        name: 'Station Total Lomé',
        address: 'Avenue de la Paix, Lomé',
        phone: '+228 22 21 21 21',
        hours: '24h/24',
        isOpen: true,
        status: MerchantStatus.available,
        latitude: 6.1319,
        longitude: 1.2228,
        distance: 0.5,
        walkingTime: '6 min',
        drivingTime: '2 min',
        services: ['Recharge', 'Paiement', 'Transfert'],
      ),
      Merchant(
        id: '2',
        name: 'Boutique Mobile Money',
        address: 'Rue du Commerce, Lomé',
        phone: '+228 22 22 22 22',
        hours: '7h-22h',
        isOpen: true,
        status: MerchantStatus.lowStock,
        latitude: 6.1350,
        longitude: 1.2250,
        distance: 1.2,
        walkingTime: '15 min',
        drivingTime: '4 min',
        services: ['Recharge', 'Paiement'],
      ),
      Merchant(
        id: '3',
        name: 'Kiosque Central',
        address: 'Place de l\'Indépendance, Lomé',
        phone: '+228 22 23 23 23',
        hours: '6h-23h',
        isOpen: false,
        status: MerchantStatus.outOfStock,
        latitude: 6.1280,
        longitude: 1.2200,
        distance: 2.1,
        walkingTime: '25 min',
        drivingTime: '6 min',
        services: ['Recharge'],
      ),
    ];

    setState(() {
      _merchants = merchants;
      _isLoading = false;
    });
  }

  void _onMerchantSelected(Merchant merchant) {
    setState(() {
      _selectedMerchant = merchant;
    });

    // Afficher les détails du marchand
    _showMerchantDetails(merchant);
  }

  void _showMerchantDetails(Merchant merchant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchant.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                merchant.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(merchant.status),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Informations
                    _buildInfoRow(
                      Icons.access_time,
                      'Horaires',
                      merchant.hours,
                    ),
                    _buildInfoRow(Icons.phone, 'Téléphone', merchant.phone),
                    _buildInfoRow(
                      Icons.directions_walk,
                      'Distance',
                      '${merchant.distance} km',
                    ),
                    _buildInfoRow(
                      Icons.directions_car,
                      'Temps de trajet',
                      merchant.drivingTime,
                    ),

                    const SizedBox(height: 16),

                    // Services
                    const Text(
                      'Services disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: merchant.services
                          .map(
                            (service) => Chip(
                              label: Text(service),
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              labelStyle: TextStyle(color: AppColors.primary),
                            ),
                          )
                          .toList(),
                    ),

                    const Spacer(),

                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callMerchant(merchant.phone),
                            icon: const Icon(Icons.phone),
                            label: const Text('Appeler'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToMerchant(merchant),
                            icon: const Icon(Icons.directions),
                            label: const Text('Itinéraire'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(MerchantStatus status) {
    Color color;
    String text;

    switch (status) {
      case MerchantStatus.available:
        color = Colors.green;
        text = 'Disponible';
        break;
      case MerchantStatus.lowStock:
        color = Colors.orange;
        text = 'Stock faible';
        break;
      case MerchantStatus.outOfStock:
        color = Colors.red;
        text = 'Rupture';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _callMerchant(String phone) async {
    final success = await _locationService.makePhoneCall(phone);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'effectuer l\'appel'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToMerchant(Merchant merchant) async {
    final success = await _locationService.openNavigation(
      merchant.latitude,
      merchant.longitude,
      merchant.name,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la navigation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Carte',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, '/list'),
          ),
        ],
      ),
      body: Column(
        children: [
          const FilterBarWidget(),
          Expanded(
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MapWidget(
                        merchants: _merchants,
                        onMerchantSelected: _onMerchantSelected,
                        showUserLocation: true,
                        initialZoom: 13.0,
                      ),
                // Panneau d'informations en bas
                if (!_isLoading)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_merchants.length} points de service trouvés',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_selectedMerchant != null)
                                Text(
                                  'Sélectionné: ${_selectedMerchant!.name}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/list');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: const Color(0xFF92400E),
                              minimumSize: const Size(80, 32),
                            ),
                            child: const Text('Vue Liste'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
