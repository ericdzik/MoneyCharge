import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';

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
    // Déterminer si on utilise PopupMenuButton en fonction de la largeur de l'écran
    final screenWidth = MediaQuery.of(context).size.width;
    final bool usePopupMenu = screenWidth < 450; // Seuil pour petits écrans

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
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Note')),
                DataColumn(label: Text('Avis')),
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
                    DataCell(SizedBox(width: 120, child: Text(merchant.merchantType, overflow: TextOverflow.ellipsis))),
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(merchant.averageRating.toStringAsFixed(1)),
                        ],
                      ),
                    ),
                    DataCell(Text(merchant.reviewCount.toString())),
                    DataCell(_buildStatusChip(merchant)),
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
                      Builder( // Utilisation de Builder pour obtenir un context frais si MediaQuery est utilisé intensivement
                        builder: (context) { // Le context ici est celui de la cellule
                          List<Widget> actionWidgets = [
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 18, color: AppColors.primary),
                              tooltip: 'Voir détails',
                              onPressed: () => onViewDetails(merchant),
                            ),
                          ];

                          if (usePopupMenu) { // usePopupMenu est défini au début de la méthode build du widget parent
                            List<PopupMenuEntry<String>> popupItems = [];
                            // Si le marchand est suspendu, la seule action est de le réactiver.
                            if (merchant.isSuspended) {
                               popupItems.add(
                                const PopupMenuItem(value: 'suspend', child: Text('Réactiver')),
                              );
                            } else {
                               if (!merchant.isVerified) {
                                popupItems.add(
                                  const PopupMenuItem(value: 'verify', child: Text('Vérifier')),
                                );
                              }
                              popupItems.add(
                                const PopupMenuItem(value: 'suspend', child: Text('Suspendre')),
                              );
                            }

                            if (popupItems.isNotEmpty) {
                              actionWidgets.add(
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  tooltip: 'Plus d\'actions',
                                  onSelected: (value) {
                                    if (value == 'verify') {
                                      onVerify(merchant);
                                    } else if (value == 'suspend') {
                                      onSuspend(merchant);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => popupItems,
                                ),
                              );
                            }
                          } else {
                            // Actions pour écrans plus larges
                            if (merchant.isSuspended) {
                               actionWidgets.add(IconButton(
                                icon: const Icon(Icons.play_circle_outline, size: 18, color: AppColors.success),
                                tooltip: 'Réactiver',
                                onPressed: () => onSuspend(merchant),
                              ));
                            } else {
                               actionWidgets.add(
                                Tooltip(
                                  message: merchant.isVerified ? 'Annuler la vérification' : 'Vérifier',
                                  child: Switch(
                                    value: merchant.isVerified,
                                    onChanged: (newValue) {
                                      onVerify(merchant);
                                    },
                                    activeColor: AppColors.success,
                                  ),
                                ),
                              );
                              actionWidgets.add(IconButton(
                                icon: const Icon(Icons.block, size: 18, color: Colors.red),
                                tooltip: 'Suspendre',
                                onPressed: () => onSuspend(merchant),
                              ));
                            }
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actionWidgets,
                          );
                        },
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

  Widget _buildStatusChip(MerchantAuthModel merchant) {
    String text;
    Color color;
    Color backgroundColor;

    if (merchant.isSuspended) {
      text = 'Suspendu';
      color = Colors.white;
      backgroundColor = Colors.red;
    } else if (merchant.isVerified) {
      text = 'Vérifié';
      color = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    } else {
      text = 'En attente';
      color = Colors.orange;
      backgroundColor = Colors.orange.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format plus complet pour la date
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }
}
