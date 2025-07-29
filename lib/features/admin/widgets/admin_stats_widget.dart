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
      childAspectRatio = 3.5; // Augmenté pour éviter le débordement
    } else if (screenWidth < 900) {
      // Medium screens
      crossAxisCount = 2;
      childAspectRatio = 2.0; // Augmenté pour plus d'espace
    } else if (screenWidth < 1200) {
      // Large screens
      crossAxisCount = 3;
      childAspectRatio = 2.2; // Augmenté pour plus d'espace
    } else {
      // Extra large screens
      crossAxisCount = 4;
      childAspectRatio = 2.5; // Augmenté pour plus d'espace
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
          color: AppColors.primary,
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
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Header avec icône et titre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 18 : 22),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),

          // Valeur principale
          Expanded(
            child: Center(
              child: Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontSize: isSmallScreen ? 20 : 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Sous-titre
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
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
