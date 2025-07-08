import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'status_badge.dart';
import 'custom_button.dart';
import '../../features/user/models/merchant_model.dart';

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

    return Card(
      // La couleur de la carte (AppColors.surface) est gérée par CardTheme
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM), // Correspond au CardTheme
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            // Le borderRadius ici est pour la bordure, Card gère le clip du contenu
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border(
              left: BorderSide(color: statusColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(merchant.name, style: AppTextStyles.h3)),
                  StatusBadge(status: statusType), // Utilise les couleurs de AppColors via StatusBadge
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.paddingM,
                runSpacing: AppDimensions.paddingS,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1), // Vert très clair
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '🚶 ${merchant.walkingTime}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, // Texte en vert primaire
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Itinéraire',
                    type: ButtonType.primary, // Vert avec texte blanc
                    onPressed: onDirectionsPressed,
                    // L'icône dans CustomButton prendra la couleur du texte du bouton si elle est null
                    // ou on peut la spécifier explicitement ici si CustomButton ne le gère pas.
                    // CustomButton a été mis à jour pour tenter de colorer l'icône.
                    icon: const Icon(Icons.directions, size: 16 /*, color: AppColors.onPrimary */),
                  ),
                ],
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
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary), // Gris pour l'icône
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(child: Text(text, style: AppTextStyles.body2)), // Texte en gris (via AppTextStyles.body2)
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
