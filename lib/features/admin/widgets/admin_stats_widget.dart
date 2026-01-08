import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminStatsWidget extends StatefulWidget {
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
  State<AdminStatsWidget> createState() => _AdminStatsWidgetState();
}

class _AdminStatsWidgetState extends State<AdminStatsWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Statistiques principales en haut
        _buildMainStats(),
        const SizedBox(height: 24),
        
        // Graphiques et métriques détaillées
        _buildDetailedMetrics(),
      ],
    );
  }

  Widget _buildMainStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre principal
          Text(
            'Vue d\'ensemble de la plateforme',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Statistiques principales en ligne
          Row(
            children: [
              Expanded(
                child: _buildMainStatItem(
                  title: 'Utilisateurs',
                  value: widget.totalUsers.toString(),
                  icon: Icons.people_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildMainStatItem(
                  title: 'Marchands',
                  value: widget.totalMerchants.toString(),
                  icon: Icons.store_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildMainStatItem(
                  title: 'Revenus',
                  value: '${(widget.totalRevenue / 1000).toStringAsFixed(0)}K',
                  icon: Icons.monetization_on_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h1.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        
        if (isWideScreen) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graphique à gauche
              Expanded(
                flex: 2,
                child: _buildMerchantChart(),
              ),
              const SizedBox(width: 16),
              // Métriques à droite
              Expanded(
                flex: 1,
                child: _buildMetricsCards(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildMerchantChart(),
              const SizedBox(height: 16),
              _buildMetricsCards(),
            ],
          );
        }
      },
    );
  }

  Widget _buildMerchantChart() {
    final activePercentage = widget.totalMerchants > 0 ? (widget.activeMerchants / widget.totalMerchants) * 100 : 0.0;
    final inactivePercentage = 100 - activePercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition des marchands',
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Graphique en secteurs
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.success,
                          value: activePercentage,
                          title: '${activePercentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.gray300,
                          value: inactivePercentage,
                          title: '${inactivePercentage.toStringAsFixed(0)}%',
                          radius: 45,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Légende
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      color: AppColors.success,
                      label: 'Actifs',
                      value: widget.activeMerchants.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                      color: AppColors.gray300,
                      label: 'Inactifs',
                      value: (widget.totalMerchants - widget.activeMerchants).toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsCards() {
    final metrics = [
      {
        'title': 'Transactions',
        'value': widget.totalTransactions.toString(),
        'subtitle': 'Aujourd\'hui',
        'icon': Icons.receipt_long_outlined,
        'color': AppColors.info,
        'trend': '+12%',
        'isPositive': true,
      },
      {
        'title': 'En attente',
        'value': widget.pendingVerifications.toString(),
        'subtitle': 'Vérifications',
        'icon': Icons.pending_actions_outlined,
        'color': AppColors.warning,
        'trend': widget.pendingVerifications > 5 ? 'Élevé' : 'Normal',
        'isPositive': widget.pendingVerifications <= 5,
      },
      {
        'title': 'Performance',
        'value': '${_calculatePerformance()}%',
        'subtitle': 'Taux d\'activité',
        'icon': Icons.trending_up_outlined,
        'color': AppColors.success,
        'trend': _calculatePerformance() > 70 ? 'Excellent' : 'Moyen',
        'isPositive': _calculatePerformance() > 70,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre avec indicateurs de pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Métriques détaillées',
              style: AppTextStyles.h3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            // Indicateurs de pagination
            Row(
              children: List.generate(
                metrics.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 4),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? AppColors.primary 
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Carrousel de cartes métriques
        SizedBox(
          height: 120, // Hauteur fixe pour les cartes
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: _buildMetricCard(
                  title: metric['title'] as String,
                  value: metric['value'] as String,
                  subtitle: metric['subtitle'] as String,
                  icon: metric['icon'] as IconData,
                  color: metric['color'] as Color,
                  trend: metric['trend'] as String,
                  isPositive: metric['isPositive'] as bool,
                ),
              );
            },
          ),
        ),
        
        // Indicateur textuel de la page actuelle
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${_currentPage + 1} / ${metrics.length}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isPositive ? AppColors.success : AppColors.warning).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePerformance() {
    if (widget.totalTransactions == 0) return 0;
    if (widget.totalMerchants == 0) return 0;
    return ((widget.activeMerchants / widget.totalMerchants) * 100).round();
  }
}
