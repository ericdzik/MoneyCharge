import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_auth_model.dart';

class MerchantHeaderWidget extends StatelessWidget {
  final MerchantAuthModel merchant;
  final VoidCallback? onLogout;
  final VoidCallback? onNotificationsTapped;

  const MerchantHeaderWidget({
    super.key,
    required this.merchant,
    this.onLogout,
    this.onNotificationsTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      merchant.businessName,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (onNotificationsTapped != null)
                    IconButton(
                      onPressed: onNotificationsTapped,
                      icon: const Icon(
                        Icons.notifications,
                        color: AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                  if (onLogout != null)
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.onPrimary.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  merchant.address,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: merchant.isVerified
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      merchant.isVerified ? Icons.verified : Icons.pending,
                      color: merchant.isVerified
                          ? AppColors.primary
                          : Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      merchant.isVerified ? 'Vérifié' : 'En attente',
                      style: AppTextStyles.caption.copyWith(
                        color: merchant.isVerified
                            ? AppColors.primary
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                child: Text(
                  'Dernière connexion:  A0${_formatDate(merchant.lastLoginAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute(s)';
    } else {
      return 'À l\'instant';
    }
  }
}
