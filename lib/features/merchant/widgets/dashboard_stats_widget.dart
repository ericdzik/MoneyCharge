import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DashboardStatsWidget extends StatelessWidget {
  final int totalServices;
  final int activeServices;
  final double totalRevenue;
  final int totalTransactions;

  const DashboardStatsWidget({
    super.key,
    required this.totalServices,
    required this.activeServices,
    required this.totalRevenue,
    required this.totalTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Services',
          value: '$totalServices',
          subtitle: '$activeServices actifs',
          icon: Icons.inventory,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Revenus',
          value: '${totalRevenue.toStringAsFixed(0)} FCFA',
          subtitle: 'Total',
          icon: Icons.monetization_on,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Transactions',
          value: '$totalTransactions',
          subtitle: 'Aujourd\'hui',
          icon: Icons.receipt_long,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Performance',
          value: '${_calculatePerformance()}%',
          subtitle: 'Taux de satisfaction',
          icon: Icons.trending_up,
          color: Colors.blue,
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
    return ((activeServices / totalServices) * 100).round();
  }
}
