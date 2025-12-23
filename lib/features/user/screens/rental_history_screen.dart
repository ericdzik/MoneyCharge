import 'package:flutter/material.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/status_badge.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  final List<RentalHistoryItem> _rentals = [
    RentalHistoryItem(
      id: '1',
      merchantName: 'Café Central',
      merchantAddress: '123 Rue de la Paix, Abidjan',
      startTime: DateTime.now().subtract(const Duration(days: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 2, hours: -2)),
      duration: const Duration(hours: 2),
      cost: 500,
      status: RentalStatus.completed,
    ),
    RentalHistoryItem(
      id: '2',
      merchantName: 'Restaurant Le Gourmet',
      merchantAddress: '456 Avenue des Champs, Abidjan',
      startTime: DateTime.now().subtract(const Duration(days: 5)),
      endTime: DateTime.now().subtract(const Duration(days: 5, hours: -1)),
      duration: const Duration(hours: 1),
      cost: 300,
      status: RentalStatus.completed,
    ),
    RentalHistoryItem(
      id: '3',
      merchantName: 'Bibliothèque Municipale',
      merchantAddress: '789 Boulevard de la Culture, Abidjan',
      startTime: DateTime.now().subtract(const Duration(days: 10)),
      endTime: DateTime.now().subtract(const Duration(days: 10, hours: -3)),
      duration: const Duration(hours: 3),
      cost: 750,
      status: RentalStatus.completed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      backgroundConfig: const BackgroundConfig(),
      appBar: CustomAppBar(title: 'Historique des locations', showLogo: false),
      body: _rentals.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Statistiques
                    _buildStats(),
                    const SizedBox(height: 16),

                    // Liste des locations
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        itemCount: _rentals.length,
                        itemBuilder: (context, index) {
                          return _buildRentalCard(_rentals[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Aucune location',
            style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore effectué de location.',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Trouver un chargeur'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalRentals = _rentals.length;
    final totalCost = _rentals.fold<int>(0, (sum, rental) => sum + rental.cost);
    final totalDuration = _rentals.fold<Duration>(
      Duration.zero,
      (sum, rental) => sum + rental.duration,
    );

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        // Use Wrap for responsive stats layout
        alignment: WrapAlignment.spaceAround, // Distribute items evenly
        spacing: AppDimensions.paddingM, // Horizontal space between items
        runSpacing: AppDimensions.paddingM, // Vertical space if items wrap
        children: [
          _buildStatItem(
            icon: Icons.history,
            title: 'Total',
            value: '$totalRentals',
            color: AppColors.primary,
          ),
          _buildStatItem(
            icon: Icons.access_time,
            title: 'Durée',
            value: '${totalDuration.inHours}h',
            color: AppColors.secondary,
          ),
          _buildStatItem(
            icon: Icons.monetization_on,
            title: 'Coût',
            value: '$totalCost FCFA',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRentalCard(RentalHistoryItem rental) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rental.merchantName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        rental.merchantAddress,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  status: rental.status == RentalStatus.completed
                      ? StatusType.available
                      : StatusType.pending,
                  customText: rental.status == RentalStatus.completed
                      ? 'Terminé'
                      : 'En cours',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Détails
            Wrap(
              // Use Wrap for responsive detail items
              alignment: WrapAlignment.spaceBetween, // Distribute items
              spacing: AppDimensions.paddingS, // Horizontal space
              runSpacing:
                  AppDimensions.paddingM, // Vertical space if items wrap
              children: [
                _buildDetailItem(
                  icon: Icons.access_time,
                  title: 'Durée',
                  value: '${rental.duration.inHours}h',
                ),
                _buildDetailItem(
                  icon: Icons.monetization_on,
                  title: 'Coût',
                  value: '${rental.cost} FCFA',
                ),
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  title: 'Date',
                  value: _formatDate(rental.startTime),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            LayoutBuilder(
              builder: (context, constraints) {
                bool useColumnLayout =
                    constraints.maxWidth < 300; // Threshold for small screens

                if (useColumnLayout) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Voir les détails
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Détails'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ), // Adjusted padding
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Relouer
                        },
                        icon: const Icon(Icons.replay, size: 16),
                        label: const Text('Relouer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ), // Adjusted padding
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Voir les détails
                          },
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Détails'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Relouer
                          },
                          icon: const Icon(Icons.replay, size: 16),
                          label: const Text('Relouer'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum RentalStatus { completed, inProgress, cancelled }

class RentalHistoryItem {
  final String id;
  final String merchantName;
  final String merchantAddress;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int cost;
  final RentalStatus status;

  RentalHistoryItem({
    required this.id,
    required this.merchantName,
    required this.merchantAddress,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.cost,
    required this.status,
  });
}
