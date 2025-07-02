import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage des nombres
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DashboardStatsWidget extends StatelessWidget {
  final double? currentBalance;
  final double? todayRevenue;
  final double? todayProfit;
  final int? todayTransactionCount;

  const DashboardStatsWidget({
    super.key,
    this.currentBalance,
    this.todayRevenue,
    this.todayProfit,
    this.todayTransactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5, // Ajusté pour une meilleure lisibilité potentielle
      children: [
        _buildStatCard(
          title: 'Solde Actuel',
          value: currentBalance != null ? currencyFormatter.format(currentBalance) : 'N/A',
          subtitle: 'Disponible',
          icon: Icons.account_balance_wallet,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Revenu (Jour)',
          value: todayRevenue != null ? currencyFormatter.format(todayRevenue) : 'N/A',
          subtitle: 'Dernières 24h',
          icon: Icons.trending_up,
          color: AppColors.success, // Vert
        ),
        _buildStatCard(
          title: 'Transactions (Jour)',
          value: todayTransactionCount != null ? todayTransactionCount.toString() : 'N/A',
          subtitle: 'Aujourd\'hui',
          icon: Icons.receipt_long,
          color: Colors.orange, // Gardons orange pour transactions
        ),
        _buildStatCard(
          title: 'Bénéfice (Jour)',
          value: todayProfit != null ? currencyFormatter.format(todayProfit) : 'N/A',
          subtitle: 'Dernières 24h',
          icon: Icons.attach_money, // ou Icons.savings
          color: todayProfit == null ? Colors.grey : (todayProfit! >= 0 ? AppColors.primary : AppColors.outOfStock),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value, // La valeur est maintenant une String formatée
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Icon(icon, color: color, size: 28), // Icône un peu plus grande
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18, // Taille ajustée pour la valeur
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title, // Titre sous la valeur
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textOnSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle, // Sous-titre en dessous
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// _calculatePerformance n'est plus nécessaire car les données sont externes.
