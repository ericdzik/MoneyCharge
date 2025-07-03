import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/map_widget.dart';
import '../widgets/filter_bar_widget.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import 'package:provider/provider.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pour LatLngBounds

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Merchant? _selectedMerchant;
  // _locationService n'est plus nécessaire ici si toute la logique de navigation passe par LocationProvider
  // final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MerchantProvider>(context, listen: false).loadMerchants();
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        locationProvider.initialize();
        // Effacer tout itinéraire précédent lors de l'initialisation de l'écran
        locationProvider.clearRoute();
      }
    });
  }

  void _onMerchantSelected(Merchant merchant) {
    setState(() {
      _selectedMerchant = merchant;
    });
    // Effacer l'itinéraire précédent lorsqu'un nouveau marchand est sélectionné
    Provider.of<LocationProvider>(context, listen: false).clearRoute();
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
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                    _buildInfoRow(Icons.access_time, 'Horaires', merchant.hours),
                    _buildInfoRow(Icons.phone, 'Téléphone', merchant.phone),
                    _buildInfoRow(Icons.directions_walk, 'Distance', '${merchant.distance} km'),
                    _buildInfoRow(
  Icons.directions_car,
  'Temps de trajet',
  merchant.drivingTime ?? 'Non disponible',
),

                    const SizedBox(height: 16),
                    const Text(
                      'Services disponibles',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: merchant.services.map(
                        (service) => Chip(
                          label: Text(service),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: AppColors.primary),
                        ),
                      ).toList(),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callMerchantPhoneNumber(merchant.phone),
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
                            onPressed: () async { // Make async for potential delay
                              print("===================================================");
                              print("[MapViewScreen] DEBUG: 'Itinéraire' button pressed for ${merchant.name}. Timestamp: ${DateTime.now()}");
                              print("===================================================");
                              Navigator.pop(context); // Ferme le BottomSheet

                              final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                              if (locationProvider.currentPosition != null) {
                                final LatLng destination = LatLng(merchant.latitude, merchant.longitude);
                                await locationProvider.fetchAndSetRoute(destination);

                                if (locationProvider.routeBounds != null && _mapController != null) {
                                  _mapController!.animateCamera(
                                    CameraUpdate.newLatLngBounds(locationProvider.routeBounds!, 50),
                                  );
                                }
                                if (locationProvider.routeError != null && mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(locationProvider.routeError!),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Localisation de l'utilisateur inconnue pour calculer l\'itinéraire.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Afficher Itinéraire'), // Texte du bouton mis à jour
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

  Future<void> _callMerchantPhoneNumber(String phone) async {
    // S'assurer que LocationService est importé en haut du fichier
    // import '../../../services/location_service.dart';
    final locationService = LocationService();
    final success = await locationService.makePhoneCall(phone);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'effectuer l\'appel.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // _navigateToMerchant (ancienne version) est supprimée car la logique est gérée par LocationProvider.

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context); // Écoute les changements

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Carte',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Effacer l'itinéraire en quittant l'écran
            Provider.of<LocationProvider>(context, listen: false).clearRoute();
            Navigator.pop(context);
          },
        ),
        actions: [
          // Bouton pour effacer l'itinéraire affiché
          if (locationProvider.polylineCoordinates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded), // Ou une autre icône appropriée
              tooltip: 'Effacer l\'itinéraire',
              onPressed: () {
                locationProvider.clearRoute();
              },
            ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
               Provider.of<LocationProvider>(context, listen: false).clearRoute();
               Navigator.pushNamed(context, '/list');
            }
          ),
        ],
      ),
      body: Consumer<MerchantProvider>(
        builder: (context, merchantProvider, child) {
          return Column(
            children: [
              const FilterBarWidget(),
              // Afficher les informations sur l'itinéraire si disponibles
              if (locationProvider.polylineCoordinates.isNotEmpty && !locationProvider.isLoadingRoute)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Route: ${locationProvider.routeDistance ?? ""} (${locationProvider.routeDuration ?? ""})',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (merchantProvider.error != null)
                      Center(child: Text("Erreur: ${merchantProvider.error}"))
                    else if (merchantProvider.merchants.isEmpty && !merchantProvider.isLoading)
                      const Center(child: Text("Aucun point de service trouvé."))
                    else
                      GoogleMap( // Remplacement de MapWidget par GoogleMap direct pour plus de contrôle
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            locationProvider.effectiveLatitude,
                            locationProvider.effectiveLongitude,
                          ),
                          zoom: 13.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: merchantProvider.merchants.map((merchant) {
                          return Marker(
                            markerId: MarkerId(merchant.id),
                            position: LatLng(merchant.latitude, merchant.longitude),
                            infoWindow: InfoWindow(
                              title: merchant.name,
                              snippet: merchant.address,
                              onTap: () => _onMerchantSelected(merchant),
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Personnaliser
                          );
                        }).toSet(),
                        polylines: {
                          if (locationProvider.polylineCoordinates.isNotEmpty)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: locationProvider.polylineCoordinates,
                              color: Colors.blue,
                              width: 5,
                            ),
                        },
                        myLocationEnabled: locationProvider.hasPermission,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false, // Peut être réactivé si besoin
                      ),
                    if (locationProvider.isLoadingRoute)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text("Calcul de l'itinéraire..."),
                          ],
                        ),
                      ),
                    if (!merchantProvider.isLoading && merchantProvider.error == null && !locationProvider.isLoadingRoute)
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
                                    '${merchantProvider.merchants.length} points de service trouvés',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
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
          );
        },
      ),
    );
  }
}
