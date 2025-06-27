import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/balance_model.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final BalanceModel? balance;

  const BalanceSummaryWidget({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    if (balance == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        margin: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde actuel',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '${balance!.currentBalance.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Statistiques détaillées
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total crédits',
                  '${balance!.totalCredits.toStringAsFixed(0)} FCFA',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildStatItem(
                  'Total débits',
                  '${balance!.totalDebits.toStringAsFixed(0)} FCFA',
                  Icons.trending_down,
                  AppColors.outOfStock,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Dernière mise à jour
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.onPrimary.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Dernière mise à jour: ${_formatDateTime(balance!.lastUpdated)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
