import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
// import '../models/balance_model.dart'; // Ne plus importer ceci pour TransactionModel
import '../../../models/transaction_model.dart'; // Importer le modèle centralisé

class TransactionCardWidget extends StatelessWidget {
  final TransactionModel
  transaction; // Doit maintenant utiliser le TransactionModel centralisé
  final VoidCallback? onTap;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
                          transaction.typeDisplay, // Utiliser le getter
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.customerPhone ??
                              'N/A', // Gérer la nullité
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
                          // Assurez-vous que BalanceType.credit est correctement importé/accessible
                          color: transaction.balanceType == BalanceType.credit
                              ? AppColors.primary
                              : AppColors.outOfStock,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            transaction.status,
                          ).withOpacity(0.1), // Utiliser une méthode helper
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.statusDisplay, // Utiliser le getter
                          style: AppTextStyles.caption.copyWith(
                            color: _getStatusColor(
                              transaction.status,
                            ), // Utiliser une méthode helper
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
                    _formatTime(
                      transaction.timestamp.toDate(),
                    ), // Utiliser timestamp.toDate()
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
      case TransactionType.sale:
        return AppColors.primary; // Vert harmonisé pour les ventes (crédits)
      case TransactionType.stockPurchase:
        return AppColors.primary; // Bleu pour achat de stock (débits)
      case TransactionType.refund:
        return Colors.orange; // Orange pour remboursements
      case TransactionType.withdrawal:
        return AppColors.secondary; // Autre couleur pour retraits
      default:
        return AppColors.onSurface; // Couleur par défaut
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.shopping_cart_checkout_rounded;
      case TransactionType.stockPurchase:
        return Icons.inventory_2_outlined;
      case TransactionType.refund:
        return Icons.undo_rounded;
      case TransactionType.withdrawal:
        return Icons.savings_outlined;
      default:
        return Icons.receipt_long_outlined; // Icône par défaut
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.primary;
      case TransactionStatus.pending:
        return Colors.orange; // Ou AppColors.warning si défini
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Colors.red; // Ou AppColors.error si défini
      default:
        return AppColors.textSecondary;
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
