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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;
        bool isSmallScreen = false; // Pour ajuster le contenu des cartes si nécessaire

        if (screenWidth < 360) { // Very small screens
          crossAxisCount = 1;
          childAspectRatio = 3.5; // Cartes plus hautes
          isSmallScreen = true;
        } else if (screenWidth < 600) { // Small screens (typical phones portrait)
          crossAxisCount = 2;
          childAspectRatio = 1.6; // Légèrement ajusté
        } else if (screenWidth < 900) { // Medium screens
          crossAxisCount = 2; // Peut rester à 2 ou passer à 3 si le design le permet
          childAspectRatio = 1.8; // Plus d'espace horizontal par carte
        } else { // Large screens
          crossAxisCount = 4; // Ou 3 si on veut des cartes plus larges
          childAspectRatio = 1.5;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12, // Réduit pour les petits écrans
          mainAxisSpacing: 12,  // Réduit pour les petits écrans
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              isSmallScreen: isSmallScreen,
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
    required bool isSmallScreen, // Ajout du paramètre
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    // isSmallScreen est déterminé par le LayoutBuilder parent
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Répartir l'espace
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
              ),
            ),
          ),
          Flexible(
            child: Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: isSmallScreen ? 9 : 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: isSmallScreen ? 2 : 1,
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
