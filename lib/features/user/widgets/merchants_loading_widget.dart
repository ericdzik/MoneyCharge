import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';

class MerchantsLoadingWidget extends StatelessWidget {
  final String? message;
  final bool showLocationIcon;

  const MerchantsLoadingWidget({
    Key? key,
    this.message,
    this.showLocationIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          if (showLocationIcon) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_searching,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ] else ...[
            const LoadingIndicator(),
          ],
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            message ?? 'Recherche de marchands à proximité...',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Nous recherchons les services disponibles dans un rayon de 3km',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.near_me,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Rayon de recherche: 3km',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}