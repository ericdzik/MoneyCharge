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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    int crossAxisCount;
    double childAspectRatio;

    if (isSmallScreen) {
      // Small screens (most phones portrait)
      crossAxisCount = 1;
      childAspectRatio =
          5.0; // Keep it tall for now, can be adjusted if overflow is fixed
    } else if (screenWidth < 900) {
      // Medium screens
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else if (screenWidth < 1200) {
      // Large screens
      crossAxisCount = 3;
      childAspectRatio = 1.4;
    } else {
      // Extra large screens
      crossAxisCount = 4;
      childAspectRatio = 1.5;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
          title: 'Utilisateurs',
          value: '$totalUsers',
          subtitle: 'Total inscrits',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
          title: 'Marchands',
          value: '$totalMerchants',
          subtitle: '$activeMerchants actifs',
          icon: Icons.store,
          color: Colors.green,
        ),
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
          title: 'Revenus',
          value: '${(totalRevenue / 1000).toStringAsFixed(1)}K FCFA',
          subtitle: 'Total plateforme',
          icon: Icons.monetization_on,
          color: Colors.orange,
        ),
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
          title: 'Transactions',
          value: '$totalTransactions',
          subtitle: 'Aujourd\'hui',
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
          title: 'En attente',
          value: '$pendingVerifications',
          subtitle: 'Vérifications',
          icon: Icons.pending_actions,
          color: Colors.red,
        ),
        _buildStatCard(
          isSmallScreen: isSmallScreen, // Pass isSmallScreen
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
    required bool isSmallScreen, // Receive isSmallScreen
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 5 : 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 14 : 18),
              ),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 9 : 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontSize: isSmallScreen ? 14 : 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isSmallScreen ? 9 : 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePerformance() {
    if (totalTransactions == 0) return 0;
    // Ensure totalMerchants is not zero to avoid division by zero error
    if (totalMerchants == 0) return 0;
    return ((activeMerchants / totalMerchants) * 100).round();
  }
}
