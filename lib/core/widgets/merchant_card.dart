import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ajout de Provider
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'status_badge.dart';
import 'custom_button.dart';
import '../../features/user/models/merchant_model.dart';
import '../../providers/favorite_merchant_provider.dart'; // Ajout du FavoriteMerchantProvider
import '../../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final statusType = _getMerchantStatusType(merchant.status);
    final favoriteProvider = Provider.of<FavoriteMerchantProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(merchant.id);

    final locationProvider = Provider.of<LocationProvider>(context);
    final double distanceMeters = Geolocator.distanceBetween(
      locationProvider.effectiveLatitude,
      locationProvider.effectiveLongitude,
      merchant.latitude,
      merchant.longitude,
    );
    // double distanceKm = distanceMeters / 1000; // Non utilisé dans ce design
    // Distance disponible si besoin: `${distanceKm.toStringAsFixed(1)} km` ou `${distanceMeters.round()} m`
    final String walkingTimeText =
        locationProvider.calculateWalkingTime(distanceMeters);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.name,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Row(
                          children: [
                            StatusBadge(status: _computeStatus(statusType, merchant)),
                            const SizedBox(width: AppDimensions.paddingS),
                            _Pill(
                              icon: Icons.access_time,
                              label: merchant.isOpen ? 'Ouvert' : 'Ferme',
                              color: merchant.isOpen
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.textSecondary.withOpacity(0.12),
                              textColor:
                                  merchant.isOpen ? AppColors.success : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  _FavoriteButton(
                    isFavorite: isFavorite,
                    onToggle: () {
                      if (isFavorite) {
                        favoriteProvider.removeFavorite(merchant.id);
                      } else {
                        favoriteProvider.addFavorite(merchant.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _InfoLine(
                icon: Icons.place_rounded,
                text: merchant.address,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Wrap(
                spacing: AppDimensions.paddingS,
                runSpacing: AppDimensions.paddingS,
                children: [
                  _Pill(
                    icon: Icons.directions_walk_rounded,
                    label: walkingTimeText,
                    color: AppColors.primary.withOpacity(0.08),
                    textColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              CustomButton(
                text: 'Itineraire',
                type: ButtonType.primary,
                onPressed: () async {
                  if (onDirectionsPressed != null) {
                    onDirectionsPressed!();
                  } else {
                    await _launchExternalDirections(
                      context,
                      merchant.latitude,
                      merchant.longitude,
                    );
                  }
                },
                icon: const Icon(Icons.directions_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchExternalDirections(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Impossible d'ouvrir l'itineraire."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.error.withOpacity(0.12)
              : AppColors.textSecondary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.error : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

StatusType _computeStatus(StatusType baseStatus, Merchant merchant) {
  final stock = merchant.serviceStockStatus;
  if (stock != null && stock.isNotEmpty) {
    final hasOut = stock.values.any(
      (v) => v.toLowerCase().contains('rupture') || v.toLowerCase().contains('epuise'),
    );
    final hasLow = stock.values.any(
      (v) => v.toLowerCase().contains('faible') || v.toLowerCase().contains('bientot'),
    );
    if (hasOut && !hasLow) return StatusType.outOfStock;
    if (hasLow) return StatusType.lowStock;
    return StatusType.available;
  }
  return baseStatus;
}

// Fonctions helper pour mapper MerchantStatus à des types pour ce widget.

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
