import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/common.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import '../../../core/utils/marker_utils.dart';

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
  bool _isLoading = true;

  static const LatLng _defaultLocation = LatLng(6.1319, 1.2228); // Lomé, Togo

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.merchants != widget.merchants) {
      _createMarkers();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      if (widget.showUserLocation) {
        await _getCurrentLocation();
      }
      await _createMarkers();
    } catch (e) {
      debugPrint('Erreur d\'initialisation de la carte: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      debugPrint('Erreur lors de l\'obtention de la position: $e');
    }
  }

  Future<void> _createMarkers() async {
    final newMarkers = <Marker>{};

    for (final merchant in widget.merchants) {
      final marker = Marker(
        markerId: MarkerId(merchant.id),
        position: LatLng(merchant.latitude, merchant.longitude),
        infoWindow: InfoWindow(
          title: merchant.name,
          snippet: merchant.address,
          onTap: () => _onMarkerTapped(merchant),
        ),
        icon: await MarkerUtils.getGeoMarkerDescriptor(size: 110),
        onTap: () => _onMarkerTapped(merchant),
      );
      newMarkers.add(marker);
    }

    if (mounted) {
      setState(() => _markers = newMarkers);
    }
  }

  void _onMarkerTapped(Merchant merchant) {

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(merchant.latitude, merchant.longitude),
        16.0,
      ),
    );

    widget.onMerchantSelected?.call(merchant);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call(controller);

    final target = widget.initialPosition ??
        (_currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : _defaultLocation);

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, widget.initialZoom),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  void _showAllMerchants() {
    if (widget.merchants.isEmpty || _mapController == null) return;

    final bounds = _calculateBounds();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
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
      return const _MapLoadingWidget();
    }

    return Stack(
      children: [
        // Carte Google Maps en plein écran
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition ??
                (_currentPosition != null
                    ? LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                )
                    : _defaultLocation),
            zoom: widget.initialZoom,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers,
          myLocationEnabled: widget.showUserLocation,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          mapType: MapType.normal,
        ),

        // Boutons de contrôle flottants
        _MapControlButtons(
          onLocationTap: _goToCurrentLocation,
          onZoomOutTap: _showAllMerchants,
        ),

        // Légende flottante
        const _MapLegend(),
      ],
    );
  }
}

class _MapLoadingWidget extends StatelessWidget {
  const _MapLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const LoadingIndicator(),
    );
  }
}

class _MapControlButtons extends StatelessWidget {
  final VoidCallback onLocationTap;
  final VoidCallback onZoomOutTap;

  const _MapControlButtons({
    required this.onLocationTap,
    required this.onZoomOutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 200, // En dessous du header
      right: AppDimensions.paddingS,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _MapControlButton(
              icon: Icons.my_location,
              onPressed: onLocationTap,
              tooltip: 'Ma position',
            ),
            const SizedBox(height: 8),
            _MapControlButton(
              icon: Icons.zoom_out_map,
              onPressed: onZoomOutTap,
              tooltip: 'Voir tous',
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 200,
      left: AppDimensions.paddingS,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Légende',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const _LegendItem(label: 'Disponible', color: AppColors.success),
            const SizedBox(height: 2),
            const _LegendItem(label: 'Stock faible', color: Colors.orange),
            const SizedBox(height: 2),
            const _LegendItem(label: 'Rupture', color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}