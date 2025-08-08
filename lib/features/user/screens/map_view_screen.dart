import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/map_widget.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import 'package:provider/provider.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pour LatLngBounds
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';

class MapViewScreen extends StatefulWidget {
  final Merchant? targetMerchant; // Marchand optionnel à cibler

  const MapViewScreen({Key? key, this.targetMerchant}) : super(key: key);

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
        final merchantProvider = Provider.of<MerchantProvider>(
          context,
          listen: false,
        );
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );

        merchantProvider.listenToMerchants();
        locationProvider.initialize().then((_) {
          // Après l'initialisation de la localisation, vérifier si un marchand cible est fourni
          if (widget.targetMerchant != null &&
              locationProvider.currentPosition != null) {
            final destination = LatLng(
              widget.targetMerchant!.latitude,
              widget.targetMerchant!.longitude,
            );
            locationProvider.fetchAndSetRoute(destination).then((_) {
              if (locationProvider.routeBounds != null &&
                  _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    locationProvider.routeBounds!,
                    60.0,
                  ), // Increased padding
                );
              }
              // Optionnel: sélectionner le marchand et afficher ses détails
              // Cela peut être fait ici ou après que la carte soit construite
              // Pour l'instant, on se concentre sur l'affichage de l'itinéraire
              if (mounted) {
                // Vérifier si le widget est toujours monté avant setState
                setState(() {
                  _selectedMerchant = widget.targetMerchant;
                });
                // On peut aussi appeler _showMerchantDetails si c'est souhaité
                // _showMerchantDetails(widget.targetMerchant!);
              }
            });
          }
        });
        // Effacer tout itinéraire précédent lors de l'initialisation de l'écran (déjà fait ou à faire avant fetch)
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
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85, // Limite la hauteur à 85% de l'écran
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                // Disposition en colonne pour les petits écrans
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      merchant.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      merchant.address,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatusChip(merchant.status),
                                  ],
                                );
                              } else {
                                // Disposition horizontale pour les écrans plus larges
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            merchant.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            merchant.address,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusChip(merchant.status),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                // Disposition en colonne pour les petits écrans
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      Icons.access_time,
                                      'Horaires',
                                      _formatHours(merchant.hours),
                                    ),
                                    _buildInfoRow(
                                      Icons.phone,
                                      'Téléphone',
                                      merchant.phone,
                                    ),
                                    _buildInfoRow(
                                      Icons.directions_walk,
                                      'Distance',
                                      '${merchant.distance} km',
                                    ),
                                    _buildInfoRow(
                                      Icons.directions_car,
                                      'Temps de trajet',
                                      merchant.drivingTime ?? 'Non disponible',
                                    ),
                                  ],
                                );
                              } else {
                                // Disposition en grille pour les écrans plus larges
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoRow(
                                            Icons.access_time,
                                            'Horaires',
                                            _formatHours(merchant.hours),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildInfoRow(
                                            Icons.phone,
                                            'Téléphone',
                                            merchant.phone,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoRow(
                                            Icons.directions_walk,
                                            'Distance',
                                            '${merchant.distance} km',
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildInfoRow(
                                            Icons.directions_car,
                                            'Temps de trajet',
                                            merchant.drivingTime ??
                                                'Non disponible',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Services disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                // Disposition en colonne pour les petits écrans
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: merchant.services.map((service) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        service,
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                // Disposition Wrap pour les écrans plus larges
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: merchant.services.map((service) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * 0.4,
                                      ),
                                      child: Chip(
                                        label: Text(
                                          service,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        backgroundColor: AppColors.primary
                                            .withOpacity(0.1),
                                        labelStyle: TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Boutons d'action (déjà responsive)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      bool useColumnLayout = constraints.maxWidth < 360;
                      if (useColumnLayout) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _callMerchantPhoneNumber(merchant.phone),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text(
                                'Appeler',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                final locationProvider =
                                    Provider.of<LocationProvider>(
                                      context,
                                      listen: false,
                                    );
                                if (locationProvider.currentPosition != null) {
                                  final LatLng destination = LatLng(
                                    merchant.latitude,
                                    merchant.longitude,
                                  );
                                  await locationProvider.fetchAndSetRoute(
                                    destination,
                                  );
                                  if (locationProvider.routeBounds != null &&
                                      _mapController != null) {
                                    _mapController!.animateCamera(
                                      CameraUpdate.newLatLngBounds(
                                        locationProvider.routeBounds!,
                                        50,
                                      ),
                                    );
                                  }
                                  if (locationProvider.routeError != null &&
                                      mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          locationProvider.routeError!,
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Localisation utilisateur inconnue.',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: const Text(
                                'Voir Carte',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.8,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                final locationService = LocationService();
                                final success = await locationService
                                    .openNavigation(
                                      merchant.latitude,
                                      merchant.longitude,
                                      merchant.name,
                                    );
                                if (!success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Impossible de lancer la navigation externe.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.navigation_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Naviguer',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _callMerchantPhoneNumber(merchant.phone),
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text(
                                  'Appeler',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final locationProvider =
                                      Provider.of<LocationProvider>(
                                        context,
                                        listen: false,
                                      );
                                  if (locationProvider.currentPosition !=
                                      null) {
                                    final LatLng destination = LatLng(
                                      merchant.latitude,
                                      merchant.longitude,
                                    );
                                    await locationProvider.fetchAndSetRoute(
                                      destination,
                                    );
                                    if (locationProvider.routeBounds != null &&
                                        _mapController != null) {
                                      _mapController!.animateCamera(
                                        CameraUpdate.newLatLngBounds(
                                          locationProvider.routeBounds!,
                                          50,
                                        ),
                                      );
                                    }
                                    if (locationProvider.routeError != null &&
                                        mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            locationProvider.routeError!,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Localisation utilisateur inconnue.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: const Text(
                                  'Voir Carte',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final locationService = LocationService();
                                  final success = await locationService
                                      .openNavigation(
                                        merchant.latitude,
                                        merchant.longitude,
                                        merchant.name,
                                      );
                                  if (!success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Impossible de lancer la navigation externe.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.navigation_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Naviguer',
                                  style: TextStyle(fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
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

  String _formatHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) {
      return 'Non disponible';
    }
    // Pour simplifier, on affiche le premier jour disponible.
    // Une logique plus complexe pourrait formater tous les jours.
    final firstDay = hours.keys.first;
    final schedule = hours[firstDay] as Map<String, dynamic>;
    return '$firstDay: ${schedule['open']} - ${schedule['close']}';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    final locationProvider = Provider.of<LocationProvider>(
      context,
    ); // Écoute les changements

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
              icon: const Icon(
                Icons.clear_all_rounded,
              ), // Ou une autre icône appropriée
              tooltip: 'Effacer l\'itinéraire',
              onPressed: () {
                locationProvider.clearRoute();
              },
            ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Provider.of<LocationProvider>(
                context,
                listen: false,
              ).clearRoute();
              Navigator.pushNamed(context, AppRoutes.listView);
            },
          ),
        ],
      ),
      body: Consumer<MerchantProvider>(
        builder: (context, merchantProvider, child) {
          return Column(
            children: [
              // Afficher les informations sur l'itinéraire si disponibles
              if (locationProvider.polylineCoordinates.isNotEmpty &&
                  !locationProvider.isLoadingRoute)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.blue.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Route: ${locationProvider.routeDistance ?? ""} (${locationProvider.routeDuration ?? ""})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    if (merchantProvider.isLoading &&
                        merchantProvider.merchants.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (merchantProvider.error != null)
                      Center(child: Text("Erreur: ${merchantProvider.error}"))
                    else if (merchantProvider.merchants.isEmpty &&
                        !merchantProvider.isLoading)
                      const Center(
                        child: Text("Aucun point de service trouvé."),
                      )
                    else
                      GoogleMap(
                        // Remplacement de MapWidget par GoogleMap direct pour plus de contrôle
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.targetMerchant?.latitude ??
                                locationProvider.effectiveLatitude,
                            widget.targetMerchant?.longitude ??
                                locationProvider.effectiveLongitude,
                          ),
                          zoom: widget.targetMerchant != null
                              ? 15.0
                              : 13.0, // Zoom plus proche si marchand cible
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: merchantProvider.merchants.map((merchant) {
                          return Marker(
                            markerId: MarkerId(merchant.id),
                            position: LatLng(
                              merchant.latitude,
                              merchant.longitude,
                            ),
                            infoWindow: InfoWindow(
                              title: merchant.name,
                              snippet: merchant.address,
                              onTap: () => _onMerchantSelected(merchant),
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              merchant.profileType == 'mobile' ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
                            ), // Personnaliser
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
                        zoomControlsEnabled:
                            false, // Peut être réactivé si besoin
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
                    if (!merchantProvider.isLoading &&
                        merchantProvider.error == null &&
                        !locationProvider.isLoadingRoute)
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
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Align items vertically
                            children: [
                              Flexible(
                                // Allow column of text to take available space
                                child: Column(
                                  mainAxisSize: MainAxisSize
                                      .min, // Important for Flexible in Row
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${merchantProvider.merchants.length} points de service trouvés',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Handle long text
                                    ),
                                    if (_selectedMerchant != null)
                                      Text(
                                        'Sélectionné: ${_selectedMerchant!.name}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle long merchant name
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: AppDimensions.paddingS,
                              ), // Add some spacing
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.listView,
                                  );
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
