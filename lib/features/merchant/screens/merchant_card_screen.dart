import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/utils/render_helper.dart';
import 'package:locacharge/features/user/widgets/map_widget.dart';
import 'package:locacharge/features/user/widgets/search_bar_widget.dart';
import 'package:locacharge/features/user/widgets/filter_widget.dart';
import 'package:locacharge/features/user/widgets/merchant_details_card.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/providers/location_provider.dart';

import 'package:locacharge/services/location_service.dart';
import 'package:locacharge/core/common.dart';

class MerchantCardScreen extends StatefulWidget {
  const MerchantCardScreen({super.key});


  @override
  State<MerchantCardScreen> createState() => _MerchantCardScreenState();
}

class _MerchantCardScreenState extends State<MerchantCardScreen> {
  GoogleMapController? _mapController;
  Merchant? _selectedMerchant;
  bool _isInitialized = false;
  bool _showInfoMessage = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadMerchants();
        _isInitialized = true;
      }
    });
  }

  void _loadMerchants() {
    try {
      final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
      
      // Utiliser listenToMerchants au lieu de fetchMerchants
      merchantProvider.listenToMerchants();
    } catch (e) {
      debugPrint('Erreur lors du chargement des marchands: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Carte des Marchands',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            RenderHelper.safePop(context);
          },
        ),
      ),
      body: Consumer2<MerchantProvider, LocationProvider>(
        builder: (context, merchantProvider, locationProvider, child) {
          return Stack(
            children: [
              // Carte en plein écran
              Positioned.fill(
                child: _buildMapWidget(merchantProvider, locationProvider),
              ),

              // Barre de recherche en haut
              const Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SearchBarWidget(),
              ),

              // Filtres toujours visibles
              Positioned(
                top: 80,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const FilterWidget(),
                ),
              ),

              // Détails du marchand sélectionné
              if (_selectedMerchant != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: MerchantDetailsCard(
                    merchant: _selectedMerchant!,
                    onClose: () {
                      RenderHelper.safeSetState(this, () {
                        _selectedMerchant = null;
                      });
                    },
                    onNavigate: () {
                      if (_selectedMerchant != null) {
                        _navigateToMerchant(_selectedMerchant!);
                      }
                    },
                  ),
                ),

              // Bouton de recentrage
              Positioned(
                bottom: _selectedMerchant != null ? 200 : 100,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.primary,
                  onPressed: () {
                    _recenterMap(locationProvider);
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Indicateur de chargement
              if (merchantProvider.isLoading)
                const Positioned.fill(
                  child: Center(
                    child: LoadingIndicator(),
                  ),
                ),

              // Message d'information pour les marchands
              if (_showInfoMessage) _buildInfoMessage(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToMerchant(Merchant merchant) async {
    final locationService = LocationService();
    final success = await locationService.openNavigation(
      merchant.latitude,
      merchant.longitude,
      merchant.name,
    );

    if (!success && mounted) {
      SnackBarHelper.showError(
        context,
        'Impossible de lancer la navigation',
      );
    }
  }

  Widget _buildMapWidget(MerchantProvider merchantProvider, LocationProvider locationProvider) {
    return MapWidget(
      merchants: merchantProvider.merchants,
      onMerchantSelected: (merchant) {
        if (mounted) {
          setState(() {
            _selectedMerchant = merchant;
          });
        }
      },
      onMapCreated: (controller) {
        if (mounted) {
          _mapController = controller;
        }
      },
      showUserLocation: true,
      initialPosition: locationProvider.latitude != null && locationProvider.longitude != null
          ? LatLng(
              locationProvider.effectiveLatitude,
              locationProvider.effectiveLongitude,
            )
          : null,
    );
  }

  Widget _buildInfoMessage() {
    return Positioned(
      top: 140,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Découvrez les autres marchands autour de vous',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                RenderHelper.safeSetState(this, () {
                  _showInfoMessage = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _recenterMap(LocationProvider locationProvider) {
    if (_mapController != null && 
        locationProvider.latitude != null && 
        locationProvider.longitude != null &&
        mounted) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            locationProvider.effectiveLatitude,
            locationProvider.effectiveLongitude,
          ),
          15.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Nettoyer le contrôleur de carte de manière sécurisée
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }
}