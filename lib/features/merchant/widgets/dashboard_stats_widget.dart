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
        bool isSmallScreen = false;

        if (screenWidth < 360) {
          crossAxisCount = 1;
          childAspectRatio = 2.6; // plus haut -> contenu plus grand
          isSmallScreen = true;
        } else if (screenWidth < 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.3; // plus haut -> contenu plus grand
        } else if (screenWidth < 900) {
          crossAxisCount = 2;
          childAspectRatio = 1.4; // un peu plus haut
        } else {
          crossAxisCount = 4;
          childAspectRatio = 1.3; // plus haut -> contenu plus grand
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              isSmallScreen: isSmallScreen,
              title: 'Services',
              value:
                  '$totalServices', // Assuré d'être un argument nommé correct
              subtitle: '$activeServices actifs',
              icon: Icons.inventory,
              color: AppColors.primary,
            ),
            _buildStatCard(
              isSmallScreen: isSmallScreen, // Ajout du paramètre manquant
              title: 'Revenus',
              value: '${totalRevenue.toStringAsFixed(0)} FCFA',
              subtitle: 'Total',
              icon: Icons.monetization_on,
              color: AppColors.primary,
            ),
            _buildStatCard(
              isSmallScreen: isSmallScreen, // Ajout du paramètre manquant
              title: 'Transactions',
              value: '$totalTransactions',
              subtitle: 'Aujourd\'hui',
              icon: Icons.receipt_long,
              color: Colors.orange,
            ),
            _buildStatCard(
              isSmallScreen: isSmallScreen, // Ajout du paramètre manquant
              title: 'Performance',
              value: '${_calculatePerformance()}%',
              subtitle: 'Taux de satisfaction',
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
          ],
        );
      }, // FIN DE LA FONCTION builder
    ); // FIN DU WIDGET LayoutBuilder
  } // FIN DE LA METHODE build

  Widget _buildStatCard({
    required bool isSmallScreen,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 18 : 22),
              ),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 11 : 13,
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
                  fontSize: isSmallScreen ? 20 : 26,
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
                  fontSize: isSmallScreen ? 11 : 12,
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
    if (totalServices == 0) {
      // CORRIGÉ: Vérification pour éviter la division par zéro
      return 0;
    }
    return ((activeServices / totalServices) * 100).round();
  }
}
