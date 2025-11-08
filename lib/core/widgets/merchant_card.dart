import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'status_badge.dart';
import 'custom_button.dart';
import '../../features/user/models/merchant_model.dart';
import '../../providers/favorite_merchant_provider.dart';
import '../../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

class MerchantCard extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback? onTap;
  final VoidCallback? onDirectionsPressed;

  const MerchantCard({
    super.key,
    required this.merchant,
    this.onTap,
    this.onDirectionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getMerchantStatusColor(merchant.status);
    final statusType = _getMerchantStatusType(merchant.status);
    final favoriteProvider = Provider.of<FavoriteMerchantProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(merchant.id);

    // Calcul dynamique distance et temps de marche
    final locationProvider = Provider.of<LocationProvider>(context);
    final double distanceMeters = Geolocator.distanceBetween(
      locationProvider.effectiveLatitude,
      locationProvider.effectiveLongitude,
      merchant.latitude,
      merchant.longitude,
    );
    final String walkingTimeText =
    locationProvider.calculateWalkingTime(distanceMeters);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: statusColor,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        merchant.name,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge de disponibilité dynamique basé sur serviceStockStatus
                        Builder(builder: (context) {
                          final stock = merchant.serviceStockStatus;
                          StatusType computedStatus = statusType;
                          if (stock != null && stock.isNotEmpty) {
                            final hasOut = stock.values.any((v) =>
                            v.toLowerCase().contains('rupture') ||
                                v.toLowerCase().contains('epuise'));
                            final hasLow = stock.values.any((v) =>
                            v.toLowerCase().contains('faible') ||
                                v.toLowerCase().contains('bientot'));
                            if (hasOut && !hasLow) {
                              computedStatus = StatusType.outOfStock;
                            } else if (hasLow) {
                              computedStatus = StatusType.lowStock;
                            } else {
                              computedStatus = StatusType.available;
                            }
                          }
                          return StatusBadge(status: computedStatus);
                        }),
                        const SizedBox(width: AppDimensions.paddingXS),
                        Container(
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? AppColors.error.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              if (isFavorite) {
                                favoriteProvider.removeFavorite(merchant.id);
                              } else {
                                favoriteProvider.addFavorite(merchant.id);
                              }
                            },
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                _buildInfoRow(Icons.location_on, merchant.address),
                const SizedBox(height: AppDimensions.paddingXS),
                _buildInfoRow(Icons.phone, merchant.phone),
                const SizedBox(height: AppDimensions.paddingXS),
                _buildInfoRow(
                  Icons.access_time,
                  '${merchant.hours} • ${merchant.isOpen ? "Ouvert" : "Fermé"}',
                  isOpen: merchant.isOpen,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Si l'écran est trop petit, utiliser une disposition en colonne
                    if (constraints.maxWidth < 300) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  walkingTimeText,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          CustomButton(
                            text: 'Itinéraire',
                            type: ButtonType.primary,
                            onPressed: onDirectionsPressed,
                            icon: const Icon(Icons.directions, size: 16),
                          ),
                        ],
                      );
                    } else {
                      // Disposition horizontale pour les écrans plus larges
                      return Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingS,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.15),
                                    AppColors.primary.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    walkingTimeText,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Flexible(
                            child: CustomButton(
                              text: 'Itinéraire',
                              type: ButtonType.primary,
                              onPressed: onDirectionsPressed,
                              icon: const Icon(Icons.directions, size: 16),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool? isOpen}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: isOpen != null
                  ? (isOpen ? Colors.green : AppColors.error)
                  : AppColors.textPrimary,
              fontWeight: isOpen != null ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

// Fonctions helper pour mapper MerchantStatus à des couleurs/types pour ce widget.
Color _getMerchantStatusColor(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return AppColors.available;
    case MerchantStatus.lowStock:
      return AppColors.lowStock;
    case MerchantStatus.outOfStock:
      return AppColors.outOfStock;
  }
}

StatusType _getMerchantStatusType(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return StatusType.available;
    case MerchantStatus.lowStock:
      return StatusType.lowStock;
    case MerchantStatus.outOfStock:
      return StatusType.outOfStock;
  }
}