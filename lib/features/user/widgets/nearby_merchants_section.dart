import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/widgets/merchant_card.dart';
import 'package:locacharge/features/user/widgets/merchants_loading_widget.dart';

class NearbyMerchantsSection extends StatelessWidget {
  final List<MerchantContentItem> merchants;
  final Function(MerchantContentItem) onMerchantTap;
  final double radiusKm;
  final bool isLoading;

  const NearbyMerchantsSection({
    Key? key,
    required this.merchants,
    required this.onMerchantTap,
    this.radiusKm = 3.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Afficher l'état de chargement si nécessaire
    if (isLoading) {
      return const MerchantsLoadingWidget();
    }

    // Si aucun marchand n'est fourni, afficher l'état de recherche
    if (merchants.isEmpty) {
      return _buildEmptyState();
    }

    // Filtrer les marchands dans un rayon de 3km avec validation
    final nearbyMerchants = merchants
        .where((merchant) {
          if (merchant.distanceKm == null) {
            return false;
          }
          return merchant.distanceKm! <= radiusKm;
        })
        .toList();

    // Trier par distance (plus proche en premier)
    nearbyMerchants.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    if (nearbyMerchants.isEmpty) {
      return _buildNoNearbyMerchantsState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(nearbyMerchants.length),
          const SizedBox(height: AppDimensions.paddingM),
          ...nearbyMerchants.map((merchant) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
            child: MerchantCard(
              merchantId: merchant.merchantId,
              name: merchant.name,
              services: merchant.services,
              rating: merchant.rating,
              distanceKm: merchant.distanceKm,
              imageUrl: merchant.imageUrl,
              address: merchant.address,
              isVerified: merchant.isVerified,
              onTap: () => onMerchantTap(merchant),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marchands à proximité',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count marchand${count > 1 ? 's' : ''} dans un rayon de ${radiusKm.toStringAsFixed(0)}km',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.near_me,
                size: 12,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                'Proche',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_searching,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Recherche de marchands...',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Nous recherchons les services disponibles près de chez vous',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoNearbyMerchantsState() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Aucun marchand à proximité',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Aucun service trouvé dans un rayon de ${radiusKm.toStringAsFixed(0)}km',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          OutlinedButton.icon(
            onPressed: () {
              // Navigation vers la carte ou liste complète
            },
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Voir sur la carte'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
          ),
        ],
      ),
    );
  }
}