import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/balance_model.dart';

class TransactionCardWidget extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône du type de transaction
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(transaction.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(transaction.type),
                      color: _getTypeColor(transaction.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),

                  // Informations principales
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.type.typeText,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.customerPhone,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Montant
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.netAmount.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.balanceType == BalanceType.credit
                              ? AppColors.success
                              : AppColors.outOfStock,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: transaction.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.statusText,
                          style: AppTextStyles.caption.copyWith(
                            color: transaction.statusColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.paddingS),

              // Détails supplémentaires
              Row(
                children: [
                  if (transaction.operator != null) ...[
                    Icon(
                      Icons.business,
                      size: 12,
                      color: AppColors.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.operator!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                  ],
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(transaction.createdAt),
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.rechargeCredit:
        return AppColors.primary;
      case TransactionType.dataPackage:
        return AppColors.success;
      case TransactionType.simCard:
        return AppColors.secondary;
      case TransactionType.moneyTransfer:
        return AppColors.primary;
      case TransactionType.billPayment:
        return AppColors.secondary;
      case TransactionType.other:
        return AppColors.onSurface;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.rechargeCredit:
        return Icons.phone_android;
      case TransactionType.dataPackage:
        return Icons.wifi;
      case TransactionType.simCard:
        return Icons.sim_card;
      case TransactionType.moneyTransfer:
        return Icons.account_balance_wallet;
      case TransactionType.billPayment:
        return Icons.receipt;
      case TransactionType.other:
        return Icons.more_horiz;
    }
  }

  String _formatTime(DateTime dateTime) {
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
