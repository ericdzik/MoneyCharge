import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import 'map_view_screen.dart'; // Peut-être plus nécessaire si on ne navigue plus vers elle
import 'package:provider/provider.dart'; // Pour LocationProvider
import '../../../providers/location_provider.dart'; // Pour obtenir la position utilisateur

class MerchantDetailScreen extends StatefulWidget { // Changé en StatefulWidget
  final Merchant merchant;

  const MerchantDetailScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  @override
  _MerchantDetailScreenState createState() => _MerchantDetailScreenState(); // Changé
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> { // Nouvelle classe State
  String _walkingTime = 'Calcul...';
  String _drivingTime = 'Calcul...';
  final LocationService _locationService = LocationService(); // Instance de LocationService

  @override
  void initState() {
    super.initState();
    _calculateTravelTimes();
  }

  Future<void> _calculateTravelTimes() async {
    // Utiliser LocationProvider pour obtenir la position actuelle de manière cohérente avec le reste de l'app
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // S'assurer que la localisation est initialisée et disponible
    if (locationProvider.currentPosition == null) {
      await locationProvider.initialize(); // S'assurer que la position est chargée
    }

    if (!mounted) return; // Vérifier si le widget est toujours monté

    if (locationProvider.currentPosition != null) {
      final distance = _locationService.calculateDistance(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
        widget.merchant.latitude,
        widget.merchant.longitude,
      );

      if (mounted) {
        setState(() {
          _walkingTime = _locationService.calculateWalkingTime(distance);
          _drivingTime = _locationService.calculateDrivingTime(distance);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _walkingTime = 'Position?'; // Erreur si la position n'est pas trouvée
          _drivingTime = 'Position?';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // merchant est accessible via widget.merchant dans un StatefulWidget
    return Scaffold(
      appBar: CustomAppBar(
        title: merchant.name,
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Ajouter aux favoris
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Partager
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec image et statut
            LayoutBuilder( // Use LayoutBuilder to make height responsive
              builder: (BuildContext context, BoxConstraints constraints) { // Added BuildContext type
                double headerHeight = constraints.maxWidth * 0.5; // Example: 2:1 aspect ratio
                if (headerHeight < 150) headerHeight = 150; // Min height
                if (headerHeight > 300) headerHeight = 300; // Max height

                return Container(
                  width: double.infinity,
                  height: headerHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.store,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
                      Positioned(
                        top: AppDimensions.paddingM,
                        right: AppDimensions.paddingM,
                        child: StatusBadge(status: _getStatusType()),
                      ),
                    ],
                  ),
                ); // Correctly closes Container
              }, // Correctly closes builder
            ), // Correctly closes LayoutBuilder
            
            // Informations principales
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  
                  _buildInfoSection(
                    Icons.location_on,
                    'Adresse',
                    merchant.address,
                  ),
                  
                  _buildInfoSection(
                    Icons.phone,
                    'Téléphone',
                    merchant.phone,
                  ),
                  
                  _buildInfoSection(
                    Icons.access_time,
                    'Horaires',
                    '${merchant.hours}\n${merchant.isOpen ? "🟢 Ouvert maintenant" : "🔴 Fermé"}',
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
                          Icons.directions_walk,
                          'À pied',
                          _walkingTime, // Utiliser la variable d'état
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child:_buildTimeCard(
                          Icons.directions_car,
                          'En voiture',
                          _drivingTime, // Utiliser la variable d'état
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingL),
                  
                  Text(
                    'Services disponibles',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Wrap(
                    spacing: AppDimensions.paddingS,
                    runSpacing: AppDimensions.paddingS,
                    children: merchant.services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          service,
                          style: AppTextStyles.body2,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useColumnLayout = constraints.maxWidth < 360;

            if (useColumnLayout) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    text: 'Appeler',
                    type: ButtonType.outline,
                    icon: const Icon(Icons.phone, size: 20),
                    onPressed: () {
                      // Lancer l'appel
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  CustomButton(
                    text: 'Itinéraire',
                    icon: const Icon(Icons.directions, size: 20),
                    onPressed: () async {
                      final locationService = LocationService();
                      final success = await locationService.openNavigation(
                        merchant.latitude,
                        merchant.longitude,
                        merchant.name,
                      );
                      if (!success && mounted) { // mounted check in case widget is disposed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Impossible de lancer la navigation externe.')),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Appeler',
                      type: ButtonType.outline,
                      icon: const Icon(Icons.phone, size: 20),
                      onPressed: () async { // Assuming makePhoneCall is in LocationService
                        final locationService = LocationService();
                        await locationService.makePhoneCall(merchant.phone);
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: CustomButton(
                      text: 'Itinéraire',
                      icon: const Icon(Icons.directions, size: 20),
                      onPressed: () async {
                        final locationService = LocationService();
                        final success = await locationService.openNavigation(
                          merchant.latitude,
                          merchant.longitude,
                          merchant.name,
                        );
                        if (!success && mounted) { // mounted check
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Impossible de lancer la navigation externe.')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          }
        ),
      ),
    );
  }

  Widget _buildInfoSection(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(IconData icon, String label, String time) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          Text(
            time,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType() {
    switch (merchant.status) {
      case MerchantStatus.available:
        return StatusType.available;
      case MerchantStatus.lowStock:
        return StatusType.lowStock;
      case MerchantStatus.outOfStock:
        return StatusType.outOfStock;
    }
  }
}