import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';

/// Widget header utilisé sur le dashboard marchand.
/// Design axé sur : lisibilité, accessibilité, réutilisabilité.
class MerchantHeaderWidget extends StatelessWidget {
  final MerchantAuthModel merchant;
  final VoidCallback? onLogout;
  final VoidCallback? onNotificationsTapped;
  final VoidCallback? onProfileTap;

  const MerchantHeaderWidget({
    super.key,
    required this.merchant,
    this.onLogout,
    this.onNotificationsTapped,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left margin kept for visual balance
          const SizedBox(width: 4),

          // Info principale
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: AppTextStyles.body1.copyWith(color: AppColors.onPrimary.withOpacity(0.95)),
                ),
                const SizedBox(height: 4),
                Text(
                  merchant.businessName.isNotEmpty ? merchant.businessName : 'Mon commerce',
                  style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary, fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        merchant.address.isNotEmpty ? merchant.address : 'Adresse non définie',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onNotificationsTapped != null)
                    IconButton(
                      onPressed: onNotificationsTapped,
                      icon: const Icon(Icons.notifications_none),
                      color: Colors.white,
                      tooltip: 'Notifications',
                    ),
                  if (onLogout != null)
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout),
                      color: Colors.white,
                      tooltip: 'Se déconnecter',
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
