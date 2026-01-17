import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/transaction_model.dart';

class AdvancedMetricsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<String> services;

  const AdvancedMetricsWidget({
    super.key,
    required this.transactions,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> slides = [
      _buildServiceDistribution(),
      _buildHourlyActivity(),
    ];

    return SizedBox(
      height: 350,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: slides[index],
          );
        },
        itemCount: slides.length,
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey,
            activeColor: AppColors.primary,
          ),
        ),
        control: const SwiperControl(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildServiceDistribution() {
    final serviceStats = _getServiceStats();
    
    if (serviceStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
            'Répartition par service',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: serviceStats.entries.map((entry) {
                  final index = serviceStats.keys.toList().indexOf(entry.key);
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    color: _getServiceColor(index),
                    radius: 60,
                    titleStyle: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: serviceStats.entries.map((entry) {
              final index = serviceStats.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getServiceColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.key,
                    style: AppTextStyles.caption,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyActivity() {
    final hourlyStats = _getHourlyStats();
    
    if (hourlyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
            'Activité par heure',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: hourlyStats.values.reduce((a, b) => a > b ? a : b).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: hourlyStats.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getServiceStats() {
    final stats = <String, int>{};
    
    for (final transaction in transactions) {
      if (transaction.status == TransactionStatus.completed) {
        final service = transaction.serviceName;
        stats[service] = (stats[service] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  Map<int, int> _getHourlyStats() {
    final stats = <int, int>{};
    
    // Initialiser toutes les heures à 0
    for (int i = 0; i < 24; i++) {
      stats[i] = 0;
    }
    
    for (final transaction in transactions) {
      if (transaction.status == TransactionStatus.completed) {
        final hour = transaction.timestamp.toDate().hour;
        stats[hour] = (stats[hour] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  Color _getServiceColor(int index) {
    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
