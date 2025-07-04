import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../merchant/models/merchant_auth_model.dart';

class MerchantTableWidget extends StatelessWidget {
  final List<MerchantAuthModel> merchants;
  final Function(MerchantAuthModel) onVerify;
  final Function(MerchantAuthModel) onSuspend;
  final Function(MerchantAuthModel) onViewDetails;

  const MerchantTableWidget({
    super.key,
    required this.merchants,
    required this.onVerify,
    required this.onSuspend,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: AppColors.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Marchands (${merchants.length})',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Tableau
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingTextStyle: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              dataTextStyle: AppTextStyles.body2,
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Type')), // Nouvelle colonne
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Date d\'inscription')),
                DataColumn(label: Text('Actions')),
              ],
              rows: merchants.map((merchant) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 150, // Donner une largeur pour éviter le débordement du nom
                        child: Text(
                          merchant.businessName,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(SizedBox(width: 180, child: Text(merchant.email, overflow: TextOverflow.ellipsis))),
                    DataCell(SizedBox(width: 120, child: Text(merchant.merchantType, overflow: TextOverflow.ellipsis))), // Affichage du type
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: merchant.isVerified
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          merchant.isVerified ? 'Vérifié' : 'En attente',
                          style: AppTextStyles.caption.copyWith(
                            color: merchant.isVerified
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          _formatDate(merchant.createdAt),
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox( // Encapsuler la Row dans un SizedBox pour potentiellement contrôler la largeur
                        width: 150, // Ajuster cette largeur au besoin
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Important pour que la Row ne prenne que l'espace nécessaire
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Voir détails',
                              onPressed: () => onViewDetails(merchant),
                            ),
                            if (!merchant.isVerified)
                              IconButton(
                                icon: const Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                tooltip: 'Vérifier',
                                onPressed: () => onVerify(merchant),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.block,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Suspendre',
                              onPressed: () => onSuspend(merchant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format plus complet pour la date
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }
}
