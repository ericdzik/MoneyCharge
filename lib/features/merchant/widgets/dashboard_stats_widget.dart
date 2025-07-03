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
      childAspectRatio: 1.2, // Modifié de 1.5 à 1.2 pour augmenter la hauteur des cartes
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Padding ajusté
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Ombre plus légère
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26), // Taille icône ajustée
          const SizedBox(height: 6), // Espacement ajusté
          Text(
            value,
            style: AppTextStyles.h2.copyWith( // Utiliser h3 ou un style plus petit si h2 est trop grand
              fontSize: 16, // Taille de police pour la valeur
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3), // Espacement ajusté
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textDisabled.withOpacity(0.9), // Légèrement plus visible
              fontWeight: FontWeight.w500,
              fontSize: 12, // Taille de police pour le titre
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Le sous-titre peut prendre un peu plus de place si nécessaire,
          // mais il faut être prudent avec la hauteur totale.
          // Si le sous-titre est court, le SizedBox suivant peut être minime.
          // const SizedBox(height: 1),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10, // Taille de police pour le sous-titre
            ),
            textAlign: TextAlign.center,
            maxLines: 1, // Forcer sur une ligne, ou 2 si absolument nécessaire et que ça rentre
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// _calculatePerformance n'est plus nécessaire car les données sont externes.
