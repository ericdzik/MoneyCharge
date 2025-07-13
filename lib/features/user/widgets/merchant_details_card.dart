import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';

class MerchantDetailsCard extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback? onClose;
  final VoidCallback? onCall;
  final VoidCallback? onNavigate;

  const MerchantDetailsCard({
    super.key,
    required this.merchant,
    this.onClose,
    this.onCall,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec image et statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen = constraints.maxWidth < 350;

                if (isSmallScreen) {
                  // Disposition en colonne pour les petits écrans
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar du marchand
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Informations principales
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant.name,
                                  style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  merchant.address,
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(merchant.status),
                          if (onClose != null)
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Disposition horizontale pour les écrans plus larges
                  return Row(
                    children: [
                      // Avatar du marchand
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Informations principales
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              merchant.name,
                              style: AppTextStyles.h3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              merchant.address,
                              style: AppTextStyles.body2.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Statut et bouton fermer
                      Column(
                        children: [
                          _buildStatusChip(merchant.status),
                          if (onClose != null) ...[
                            const SizedBox(height: 8),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de contact et horaires
                _buildInfoSection([
                  _buildInfoRow(Icons.access_time, 'Horaires', merchant.hours),
                  _buildInfoRow(Icons.phone, 'Téléphone', merchant.phone),
                  _buildInfoRow(
                    Icons.directions_walk,
                    'Distance',
                    '${merchant.distance} km',
                  ),
                  _buildInfoRow(
                    Icons.directions_car,
                    'Temps de trajet',
                    merchant.drivingTime ?? 'Indisponible',
                  ),
                ]),

                const SizedBox(height: 16),

                // Services disponibles
                Text(
                  'Services disponibles',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 300) {
                      // Disposition en colonne pour les très petits écrans
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: merchant.services.map((service) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              service,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      // Disposition Wrap pour les écrans plus larges
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: merchant.services.map((service) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.4,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                service,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Boutons d'action
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 300) {
                      // Disposition en colonne pour les très petits écrans
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onCall ?? () => _callMerchant(context),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Appeler'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  onNavigate ??
                                  () => _navigateToMerchant(context),
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Itinéraire'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Disposition horizontale pour les écrans plus larges
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onCall ?? () => _callMerchant(context),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Appeler'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  onNavigate ??
                                  () => _navigateToMerchant(context),
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Itinéraire'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(MerchantStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case MerchantStatus.available:
        color = Colors.green;
        text = 'Disponible';
        icon = Icons.check_circle;
        break;
      case MerchantStatus.lowStock:
        color = Colors.orange;
        text = 'Stock faible';
        icon = Icons.warning;
        break;
      case MerchantStatus.outOfStock:
        color = Colors.red;
        text = 'Rupture';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: ',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callMerchant(BuildContext context) async {
    final locationService = LocationService();
    final success = await locationService.makePhoneCall(merchant.phone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'effectuer l\'appel'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToMerchant(BuildContext context) async {
    final locationService = LocationService();
    final success = await locationService.openNavigation(
      merchant.latitude,
      merchant.longitude,
      merchant.name,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la navigation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
