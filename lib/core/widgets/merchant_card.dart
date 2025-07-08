import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'status_badge.dart'; // Import StatusBadge
import 'custom_button.dart'; // Import CustomButton
import '../../features/user/models/merchant_model.dart'; // Assurer que cet import est correct

class MerchantCard extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback? onTap;
  final VoidCallback? onDirectionsPressed;

  // Remettre le const si Merchant et les callbacks sont immuables et que _getStatusColor/_getStatusType sont statiques ou déplacés
  const MerchantCard({
    super.key,
    required this.merchant,
    this.onTap,
    this.onDirectionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(merchant.status);
    final statusType = _getStatusType(merchant.status);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      // La couleur de la carte est gérée par CardTheme (AppColors.surface)
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
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
                  StatusBadge(status: statusType),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              _buildInfoRow(Icons.location_on, merchant.address, context),
              _buildInfoRow(Icons.phone, merchant.phone, context),
              _buildInfoRow(
                Icons.access_time,
                '${merchant.hours} • ${merchant.isOpen ? "Ouvert" : "Fermé"}',
                context
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
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
                    type: ButtonType.primary, // Sera vert avec texte blanc
                    onPressed: onDirectionsPressed,
                    icon: const Icon(Icons.directions, size: 16, color: AppColors.onPrimary), // Icône blanche
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(child: Text(text, style: AppTextStyles.body2)), // AppColors.textSecondary est déjà dans body2
        ],
      ),
    );
  }
}

// Fonctions utilitaires déplacées hors de la classe ou rendues statiques si possible
// pour permettre au constructeur de MerchantCard d'être const.
// Ici, on les passe en tant que fonctions au niveau du fichier ou statiques dans une classe utilitaire.
// Pour cet exemple, je les laisse comme méthodes privées et retire le const du constructeur MerchantCard.
// Si MerchantStatus est un enum défini ailleurs, c'est bien.
Color _getStatusColor(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return AppColors.available; // Vert (via success)
    case MerchantStatus.lowStock:
      return AppColors.lowStock; // Orange/Jaune (via warning)
    case MerchantStatus.outOfStock:
      return AppColors.outOfStock; // Rouge (via error)
  }
}

StatusType _getStatusType(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return StatusType.available;
    case MerchantStatus.lowStock:
      return StatusType.lowStock;
    case MerchantStatus.outOfStock:
      return StatusType.outOfStock;
  }
}
