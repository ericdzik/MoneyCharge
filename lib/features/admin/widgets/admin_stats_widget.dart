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
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) { // Small screens (most phones portrait)
      crossAxisCount = 1;
      childAspectRatio = 5.0; // Further increase to give maximum reasonable height
    } else if (screenWidth < 900) { // Medium screens (large phones landscape, small tablets)
      crossAxisCount = 2;
      childAspectRatio = 1.3; // Original aspect ratio
    } else if (screenWidth < 1200) { // Large screens (tablets landscape)
      crossAxisCount = 3;
      childAspectRatio = 1.4; // Adjust for potentially wider layout
    } else { // Extra large screens (desktop-like)
      crossAxisCount = 4;
      childAspectRatio = 1.5;
    }

    // For single column layout, ensure cards can expand horizontally
    // and text inside them wraps appropriately.
    // The _buildStatCard might need adjustments if text overflows in single column.

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 8 : 16, // Conditional vertical padding
      ),
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
          Flexible( // Wrap the top Row in Flexible
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 8), // Conditional padding for icon container
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                  child: Icon(icon, color: color, size: isSmallScreen ? 16 : 20), // Conditional icon size
              ),
              const Spacer(),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isSmallScreen ? 10 : null, // Conditional title font size
                ),
              ),
            ],
          ),
          // SizedBox(height: isSmallScreen ? 8 : 12), // Drastic: Remove one SizedBox for small screen
          Flexible( // Allow value to shrink or wrap if necessary
            child: Text(
              value,
              style: AppTextStyles.h2.copyWith(
                fontSize: isSmallScreen ? 16 : 20, // Conditional font size for value
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: isSmallScreen ? 1 : 2, // Allow less lines for value on small screens
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4), // Conditional spacing
          Flexible( // Allow subtitle to shrink or wrap
            child: Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: isSmallScreen ? 10 : null, // Conditionally smaller subtitle font
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
