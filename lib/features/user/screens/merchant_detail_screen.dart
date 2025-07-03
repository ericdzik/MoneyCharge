import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart'; // Conservé pour le bouton "Appeler"
import 'map_view_screen.dart'; // Ajout de l'import pour MapViewScreen

class MerchantDetailScreen extends StatelessWidget {
  final Merchant merchant;

  const MerchantDetailScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: double.infinity,
              height: 200,
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
            ),
            
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
                  
                  // Adresse
                  _buildInfoSection(
                    Icons.location_on,
                    'Adresse',
                    merchant.address,
                  ),
                  
                  // Téléphone
                  _buildInfoSection(
                    Icons.phone,
                    'Téléphone',
                    merchant.phone,
                  ),
                  
                  // Horaires
                  _buildInfoSection(
                    Icons.access_time,
                    'Horaires',
                    '${merchant.hours}\n${merchant.isOpen ? "🟢 Ouvert maintenant" : "🔴 Fermé"}',
                  ),
                  
                  // Distance et temps
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
  Icons.directions_walk,
  'À pied',
  merchant.walkingTime ?? 'Indisponible',
),

                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child:_buildTimeCard(
  Icons.directions_car,
  'En voiture',
  merchant.drivingTime ?? 'Indisponible',
),

                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingL),
                  
                  // Services
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
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Appeler',
                type: ButtonType.outline,
                icon: const Icon(Icons.phone, size: 20),
                onPressed: () {
                  // Lancer l'appel
                },
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: CustomButton(
                text: 'Itinéraire',
                icon: const Icon(Icons.directions, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapViewScreen(targetMerchant: merchant),
                    ),
                  );
                },
              ),
            ),
          ],
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