import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ajout de Provider
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'status_badge.dart';
import 'custom_button.dart';
import '../../features/user/models/merchant_model.dart';
import '../../providers/favorite_merchant_provider.dart'; // Ajout du FavoriteMerchantProvider

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

    return Card(
      // La couleur de la carte (AppColors.surface) est gérée par CardTheme
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusM,
        ), // Correspond au CardTheme
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            // Le borderRadius ici est pour la bordure, Card gère le clip du contenu
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
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
                      style: AppTextStyles.h3,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Row(
                    // Row pour StatusBadge et IconButton
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        status: statusType,
                      ), // Utilise les couleurs de AppColors via StatusBadge
                      const SizedBox(
                        width: AppDimensions.paddingXS,
                      ), // Petit espace
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors
                                    .textSecondary, // Rouge si favori, gris sinon
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            favoriteProvider.removeFavorite(merchant.id);
                          } else {
                            favoriteProvider.addFavorite(merchant.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildInfoRow(Icons.location_on, merchant.address),
              _buildInfoRow(Icons.phone, merchant.phone),
              _buildInfoRow(
                Icons.access_time,
                '${merchant.hours} • ${merchant.isOpen ? "Ouvert" : "Fermé"}',
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
                            color: AppColors.primary.withValues(
                              alpha: 0.1,
                            ), // Vert très clair
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS,
                            ),
                          ),
                          child: Text(
                            '🚶 ${merchant.walkingTime}',
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  AppColors.primary, // Texte en vert primaire
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        CustomButton(
                          text: 'Itinéraire',
                          type: ButtonType.primary, // Vert avec texte blanc
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
                              color: AppColors.primary.withValues(
                                alpha: 0.1,
                              ), // Vert très clair
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusS,
                              ),
                            ),
                            child: Text(
                              '🚶 ${merchant.walkingTime}',
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    AppColors.primary, // Texte en vert primaire
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Flexible(
                          child: CustomButton(
                            text: 'Itinéraire',
                            type: ButtonType.primary, // Vert avec texte blanc
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ), // Gris pour l'icône
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ), // Texte en gris (via AppTextStyles.body2)
        ],
      ),
    );
  }
}

// Fonctions helper pour mapper MerchantStatus à des couleurs/types pour ce widget.
// Peuvent être statiques ou déplacées dans un fichier utilitaire si utilisées ailleurs.
Color _getMerchantStatusColor(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return AppColors.available; // Vert
    case MerchantStatus.lowStock:
      return AppColors.lowStock; // Orange/Jaune
    case MerchantStatus.outOfStock:
      return AppColors.outOfStock; // Rouge
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
