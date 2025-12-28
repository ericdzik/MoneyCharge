import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class DashboardStatsWidget extends StatelessWidget {
  final int totalServices;
  final int activeServices;
  final double totalRevenue;
  final double previousRevenue;
  final int totalTransactions;
  final int previousTransactions;
  final double averageRating;
  final int reviewCount;
  final List<double> revenueChart;
  final List<String> chartLabels;

  const DashboardStatsWidget({
    super.key,
    required this.totalServices,
    required this.activeServices,
    required this.totalRevenue,
    this.previousRevenue = 0.0,
    required this.totalTransactions,
    this.previousTransactions = 0,
    required this.averageRating,
    required this.reviewCount,
    this.revenueChart = const [],
    this.chartLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Graphique des revenus
        if (revenueChart.isNotEmpty) _buildRevenueChart(),
        const SizedBox(height: 16),
        
        // Métriques principales
        LayoutBuilder(
          builder: (context, constraints) {
            const double crossAxisSpacing = 12;
            const double mainAxisSpacing = 12;
            final double itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;
            const double itemHeight = 140;
            final double childAspectRatio = itemWidth / itemHeight;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
              children: [
                _buildStatCard(
                  isSmallScreen: false,
                  title: 'Services',
                  value: '$totalServices',
                  subtitle: '$activeServices actifs',
                  icon: Icons.inventory,
                  color: AppColors.primary,
                ),
                _buildStatCard(
                  isSmallScreen: false,
                  title: 'Revenus',
                  value: '${totalRevenue.toStringAsFixed(0)} FCFA',
                  subtitle: _getChangeText(totalRevenue, previousRevenue),
                  icon: Icons.monetization_on,
                  color: AppColors.primary,
                  trend: _getTrend(totalRevenue, previousRevenue),
                ),
                _buildStatCard(
                  isSmallScreen: false,
                  title: 'Transactions',
                  value: '$totalTransactions',
                  subtitle: _getChangeText(totalTransactions.toDouble(), previousTransactions.toDouble()),
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                  trend: _getTrend(totalTransactions.toDouble(), previousTransactions.toDouble()),
                ),
                _buildStatCard(
                  isSmallScreen: false,
                  title: 'Avis Clients',
                  value: '${averageRating.toStringAsFixed(1)} ★',
                  subtitle: '$reviewCount avis',
                  icon: Icons.star_half,
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isSmallScreen,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    TrendDirection? trend,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
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
              if (trend != null)
                Icon(
                  trend == TrendDirection.up ? Icons.trending_up : Icons.trending_down,
                  color: trend == TrendDirection.up ? Colors.green : Colors.red,
                  size: isSmallScreen ? 12 : 16,
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

  Widget _buildRevenueChart() {
    if (revenueChart.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution des revenus (7 derniers jours)',
            style: AppTextStyles.h3.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < chartLabels.length) {
                          return Text(
                            chartLabels[value.toInt()],
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueChart.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChangeText(double current, double previous) {
    if (previous == 0) return 'Nouveau';
    
    final change = ((current - previous) / previous * 100);
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  TrendDirection? _getTrend(double current, double previous) {
    if (previous == 0) return null;
    return current >= previous ? TrendDirection.up : TrendDirection.down;
  }
}

enum TrendDirection { up, down }
