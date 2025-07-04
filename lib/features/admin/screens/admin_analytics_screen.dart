import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = '7j';
  final List<String> _periods = ['7j', '30j', '90j', '1an'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(value: period, child: Text(period));
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques principales
            _buildMainStats(),
            const SizedBox(height: 24),

            // Graphiques
            _buildCharts(),
            const SizedBox(height: 24),

            // Top marchands
            _buildTopMerchants(),
            const SizedBox(height: 24),

            // Activité récente
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) { // Small screens
      crossAxisCount = 1;
      childAspectRatio = 2.8; // Adjust for taller items
    } else if (screenWidth < 900) { // Medium screens
      crossAxisCount = 2;
      childAspectRatio = 1.5; // Original aspect ratio
    } else { // Large screens
      crossAxisCount = 3; // Or 4 if cards are made more compact
      childAspectRatio = 1.6;
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
          title: 'Utilisateurs',
          value: '1,234',
          change: '+12%',
          isPositive: true,
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Marchands',
          value: '89',
          change: '+5%',
          isPositive: true,
          icon: Icons.store,
          color: AppColors.secondary,
        ),
        _buildStatCard(
          title: 'Locations',
          value: '5,678',
          change: '+23%',
          isPositive: true,
          icon: Icons.phone_android,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Revenus',
          value: '2.5M FCFA',
          change: '+18%',
          isPositive: true,
          icon: Icons.monetization_on,
          color: AppColors.outOfStock,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.outOfStock.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: AppTextStyles.caption.copyWith(
                    color: isPositive
                        ? AppColors.success
                        : AppColors.outOfStock,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Évolution des locations', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        LayoutBuilder( // Use LayoutBuilder to get available width
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            double chartHeight;

            if (screenWidth < 600) {
              chartHeight = 180; // Slightly smaller on very narrow screens
            } else if (screenWidth < 900) {
              chartHeight = 200;
            } else {
              chartHeight = 220; // Slightly taller on wider screens
            }

            return Container(
              height: chartHeight,
              width: constraints.maxWidth, // Take full available width
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Graphique des locations\n(À implémenter avec une librairie de graphiques)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
          }
        ),
      
      ],
    
    );
  }

  Widget _buildTopMerchants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top 5 des marchands', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final merchants = [
                {'name': 'Café Central', 'locations': 156, 'revenue': 78000},
                {
                  'name': 'Restaurant Le Gourmet',
                  'locations': 134,
                  'revenue': 67000,
                },
                {
                  'name': 'Bibliothèque Municipale',
                  'locations': 98,
                  'revenue': 49000,
                },
                {
                  'name': 'Centre Commercial',
                  'locations': 87,
                  'revenue': 43500,
                },
                {'name': 'Station Service', 'locations': 76, 'revenue': 38000},
              ];

              final merchant = merchants[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (index + 1).toString(),
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Expanded( // Allow merchant name to take available space and wrap
                  child: Text(
                    merchant['name'] as String,
                    style: AppTextStyles.body1,
                    overflow: TextOverflow.ellipsis, // Add ellipsis for very long names
                    maxLines: 2, // Allow up to 2 lines for name
                  ),
                ),
                subtitle: Text(
                  '${merchant['locations']} locations',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: SizedBox( // Constrain width of trailing text
                  width: 100, // Adjust as needed
                  child: Text(
                    '${merchant['revenue']} FCFA',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité récente', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activities = [
                {
                  'type': 'Nouveau marchand',
                  'message': 'Café Central s\'est inscrit',
                  'time': 'Il y a 2h',
                },
                {
                  'type': 'Location',
                  'message': 'Location effectuée chez Le Gourmet',
                  'time': 'Il y a 3h',
                },
                {
                  'type': 'Paiement',
                  'message': 'Paiement reçu de 500 FCFA',
                  'time': 'Il y a 4h',
                },
                {
                  'type': 'Nouveau utilisateur',
                  'message': 'Jean Dupont s\'est inscrit',
                  'time': 'Il y a 5h',
                },
                {
                  'type': 'Support',
                  'message': 'Ticket de support créé',
                  'time': 'Il y a 6h',
                },
              ];

              final activity = activities[index];

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(
                      activity['type'] as String,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(activity['type'] as String),
                    color: _getActivityColor(activity['type'] as String),
                    size: 20,
                  ),
                ),
                title: Expanded( // Allow activity message to take available space and wrap
                  child: Text(
                    activity['message'] as String,
                    style: AppTextStyles.body2,
                    overflow: TextOverflow.ellipsis, // Add ellipsis for very long messages
                    maxLines: 2, // Allow up to 2 lines
                  ),
                ),
                subtitle: Text(
                  activity['time'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Nouveau marchand':
        return AppColors.primary;
      case 'Location':
        return AppColors.success;
      case 'Paiement':
        return AppColors.secondary;
      case 'Nouveau utilisateur':
        return AppColors.success;
      case 'Support':
        return AppColors.outOfStock;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Nouveau marchand':
        return Icons.store;
      case 'Location':
        return Icons.phone_android;
      case 'Paiement':
        return Icons.payment;
      case 'Nouveau utilisateur':
        return Icons.person_add;
      case 'Support':
        return Icons.support_agent;
      default:
        return Icons.info;
    }
  }
}
