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

  MerchantCard({ // Retrait du const ici
    super.key,
    required this.merchant,
    this.onTap,
    this.onDirectionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border(
              left: BorderSide(color: _getStatusColor(), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(merchant.name, style: AppTextStyles.h3)),
                  StatusBadge(status: _getStatusType()),
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
              Wrap( // Use Wrap for better responsiveness of this row
                alignment: WrapAlignment.spaceBetween, // Try to keep elements spaced out
                crossAxisAlignment: WrapCrossAlignment.center, // Align items nicely if they wrap
                spacing: AppDimensions.paddingM, // Horizontal spacing between items
                runSpacing: AppDimensions.paddingS, // Vertical spacing if items wrap to next line
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Consider using AppColors if available
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Text(
                      '🚶 ${merchant.walkingTime}',
                      style: const TextStyle( // Consider using AppTextStyles if a similar style exists
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D4ED8), // Consider using AppColors
                      ),
                    ),
                  ),
                  // Ensure CustomButton is also responsive or has a reasonable minimum size
                  CustomButton(
                    text: 'Itinéraire',
                    type: ButtonType.primary,
                    onPressed: onDirectionsPressed,
                    icon: const Icon(Icons.directions, size: 16),
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
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(child: Text(text, style: AppTextStyles.body2)),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (merchant.status) {
      case MerchantStatus.available:
        return AppColors.available;
      case MerchantStatus.lowStock:
        return AppColors.lowStock;
      case MerchantStatus.outOfStock:
        return AppColors.outOfStock;
    }
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
