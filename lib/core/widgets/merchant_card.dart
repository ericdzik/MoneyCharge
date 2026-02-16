import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/responsive_helper.dart';
import 'status_badge.dart';
import '../../features/user/models/merchant_model.dart';
import '../../providers/favorite_merchant_provider.dart';
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

    // Calcul de la distance
    final double distanceMeters = Geolocator.distanceBetween(
      locationProvider.effectiveLatitude,
      locationProvider.effectiveLongitude,
      merchant.latitude,
      merchant.longitude,
    );
    final double distanceKm = distanceMeters / 1000;

    final horizontalMargin = ResponsiveHelper.getHorizontalMargin(context);
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      baseRadius: 16,
    );
    final verticalMargin = context.isExtraSmall ? 4.0 : 6.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getPadding(context, extraSmall: 10, medium: 12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Grande Image (90x90)
                Hero(
                  tag: 'merchant_list_img_${merchant.id}',
                  child: _buildMerchantImage(),
                ),
                const SizedBox(width: 12),

                // 2. Colonne d'informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Nom + Favori
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant.name,
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      baseSize: 16,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (merchant.isVerified == true) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: ResponsiveHelper.getIconSize(
                                          context,
                                          baseSize: 14,
                                        ),
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Vérifié",
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                              ResponsiveHelper.getFontSize(
                                                context,
                                                baseSize: 11,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
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

                      const SizedBox(height: 8),

                      // Statuts (Chips)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Badge de stock/dispo
                          Transform.scale(
                            scale: 0.9,
                            alignment: Alignment.centerLeft,
                            child: StatusBadge(
                              status: _computeStatus(statusType, merchant),
                            ),
                          ),
                          // Badge Ouvert/Fermé
                          _CompactStatusPill(isOpen: merchant.isOpen),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Footer: Distance + Action
                      Row(
                        children: [
                          // Distance Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: ResponsiveHelper.getIconSize(
                                    context,
                                    baseSize: 12,
                                  ),
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${distanceKm.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      baseSize: 11,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Petit bouton itinéraire
                          InkWell(
                            onTap: () async {
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
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions,
                                size: ResponsiveHelper.getIconSize(
                                  context,
                                  baseSize: 20,
                                ),
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantImage() {
    return Builder(
      builder: (context) {
        final imageSize = ResponsiveHelper.getResponsiveValue(
          context,
          extraSmall: 75.0,
          small: 80.0,
          medium: 90.0,
          large: 95.0,
          tablet: 100.0,
        );
        final borderRadius = ResponsiveHelper.getBorderRadius(
          context,
          baseRadius: 12,
        );

        return Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.gray200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child:
                (merchant.imageUrls != null && merchant.imageUrls!.isNotEmpty)
                ? Image.network(
                    merchant.imageUrls!.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultImage(context);
                    },
                  )
                : _buildDefaultImage(context),
          ),
        );
      },
    );
  }

  Widget _buildDefaultImage(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          color: AppColors.primary.withValues(alpha: 0.5),
          size: ResponsiveHelper.getIconSize(context, baseSize: 32),
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
        const SnackBar(
          content: Text("Impossible d'ouvrir l'itineraire."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CompactStatusPill extends StatelessWidget {
  final bool isOpen;

  const _CompactStatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOpen
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        isOpen ? 'Ouvert' : 'Fermé',
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, baseSize: 10),
          fontWeight: FontWeight.w600,
          color: isOpen ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteButton({required this.isFavorite, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        // decoration: BoxDecoration(
        //   color: isFavorite
        //       ? AppColors.error.withValues(alpha: 0.1)
        //       : Colors.transparent,
        //   shape: BoxShape.circle,
        // ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: isFavorite ? AppColors.error : AppColors.gray400,
          size: ResponsiveHelper.getIconSize(context, baseSize: 22),
        ),
      ),
    );
  }
}

StatusType _computeStatus(StatusType baseStatus, Merchant merchant) {
  final stock = merchant.serviceStockStatus;
  if (stock != null && stock.isNotEmpty) {
    final hasOut = stock.values.any(
      (v) =>
          v.toLowerCase().contains('rupture') ||
          v.toLowerCase().contains('epuise'),
    );
    final hasLow = stock.values.any(
      (v) =>
          v.toLowerCase().contains('faible') ||
          v.toLowerCase().contains('bientot'),
    );
    if (hasOut && !hasLow) return StatusType.outOfStock;
    if (hasLow) return StatusType.lowStock;
    return StatusType.available;
  }
  return baseStatus;
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
