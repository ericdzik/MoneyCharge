import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';

class MapWidget extends StatefulWidget {
  final List<Merchant> merchants;
  final Function(Merchant)? onMerchantSelected;
  final bool showUserLocation;
  final double initialZoom;
  final LatLng? initialPosition;
  final Function(GoogleMapController)? onMapCreated;

  const MapWidget({
    super.key,
    required this.merchants,
    this.onMerchantSelected,
    this.showUserLocation = true,
    this.initialZoom = 12.0,
    this.initialPosition,
    this.onMapCreated,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isLoading = true;
  String _selectedMerchantId = '';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Obtenir la position actuelle
      if (widget.showUserLocation) {
        await _getCurrentLocation();
      }

      // Créer les marqueurs
      _createMarkers();

      // Créer le cercle de recherche
      _createSearchCircle();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur d\'initialisation de la carte: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        await _locationService.requestPermission();
      }

      _currentPosition = await _locationService.getCurrentPosition();
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (final merchant in widget.merchants) {
      final marker = Marker(
        markerId: MarkerId(merchant.id),
        position: LatLng(merchant.latitude, merchant.longitude),
        infoWindow: InfoWindow(
          title: merchant.name,
          snippet: merchant.address,
          onTap: () => _onMarkerTapped(merchant),
        ),
        icon: _getMarkerIcon(merchant.status),
        onTap: () => _onMarkerTapped(merchant),
      );

      _markers.add(marker);
    }
  }

  void _createSearchCircle() {
    if (_currentPosition != null) {
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          radius: 5000, // 5km de rayon
          fillColor: AppColors.primary.withOpacity(0.1),
          strokeColor: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerIcon(MerchantStatus status) {
    switch (status) {
      case MerchantStatus.available:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ); // Google Maps constraint
      case MerchantStatus.lowStock:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case MerchantStatus.outOfStock:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _onMarkerTapped(Merchant merchant) {
    setState(() {
      _selectedMerchantId = merchant.id;
    });

    // Animer vers le marqueur
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(merchant.latitude, merchant.longitude),
        16.0,
      ),
    );

    // Appeler le callback
    widget.onMerchantSelected?.call(merchant);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call(controller);

    // Centrer la carte sur la position initiale ou la position actuelle
    if (widget.initialPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(widget.initialPosition!, widget.initialZoom),
      );
    } else if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          widget.initialZoom,
        ),
      );
    }
  }

  void _goToCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    } else {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            15.0,
          ),
        );
      }
    }
  }

  void _showAllMerchants() {
    if (widget.merchants.isEmpty) return;

    final bounds = _calculateBounds();
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }

  LatLngBounds _calculateBounds() {
    if (widget.merchants.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(6.0, 1.0),
        northeast: const LatLng(6.2, 1.3),
      );
    }

    double minLat = widget.merchants.first.latitude;
    double maxLat = widget.merchants.first.latitude;
    double minLng = widget.merchants.first.longitude;
    double maxLng = widget.merchants.first.longitude;

    for (final merchant in widget.merchants) {
      minLat = min(minLat, merchant.latitude);
      maxLat = max(maxLat, merchant.latitude);
      minLng = min(minLng, merchant.longitude);
      maxLng = max(maxLng, merchant.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    widget.initialPosition ??
                    (_currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : const LatLng(
                            6.1319,
                            1.2228,
                          )), // Lomé, Togo par défaut
                zoom: widget.initialZoom,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              circles: _circles,
              myLocationEnabled: widget.showUserLocation,
              myLocationButtonEnabled: false, // On utilise notre propre bouton
              zoomControlsEnabled: false, // On utilise nos propres contrôles
              mapToolbarEnabled: false,
              compassEnabled: true,
              onCameraMove: (position) {
                // Optionnel: Mettre à jour la position de la carte
              },
            ),
            // Boutons de contrôle personnalisés
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: null, // Disable Hero animation for this FAB
                    onPressed: _goToCurrentLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: null, // Disable Hero animation for this FAB
                    onPressed: _showAllMerchants,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.zoom_out_map),
                  ),
                ],
              ),
            ),
            // Légende des marqueurs
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem('Disponible', AppColors.primary),
                    const SizedBox(width: 8),
                    _buildLegendItem('Stock faible', Colors.orange),
                    const SizedBox(width: 8),
                    _buildLegendItem('Rupture', Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildStatusChip(MerchantStatus status) {
    Color color;
    String text;

    switch (status) {
      case MerchantStatus.available:
        color = AppColors.primary;
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
}

class MapMarker extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const MapMarker({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
