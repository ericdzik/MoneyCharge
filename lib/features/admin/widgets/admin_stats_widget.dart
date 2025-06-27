import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminStatsWidget extends StatelessWidget {
  final int totalUsers;
  final int totalMerchants;
  final int activeMerchants;
  final double totalRevenue;
  final int totalTransactions;
  final int pendingVerifications;

  const AdminStatsWidget({
    super.key,
    required this.totalUsers,
    required this.totalMerchants,
    required this.activeMerchants,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.pendingVerifications,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Utilisateurs',
          value: '$totalUsers',
          subtitle: 'Total inscrits',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Marchands',
          value: '$totalMerchants',
          subtitle: '$activeMerchants actifs',
          icon: Icons.store,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Revenus',
          value: '${(totalRevenue / 1000).toStringAsFixed(1)}K FCFA',
          subtitle: 'Total plateforme',
          icon: Icons.monetization_on,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Transactions',
          value: '$totalTransactions',
          subtitle: 'Aujourd\'hui',
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'En attente',
          value: '$pendingVerifications',
          subtitle: 'Vérifications',
          icon: Icons.pending_actions,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'Performance',
          value: '${_calculatePerformance()}%',
          subtitle: 'Taux de satisfaction',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePerformance() {
    if (totalTransactions == 0) return 0;
    return ((activeMerchants / totalMerchants) * 100).round();
  }
}
