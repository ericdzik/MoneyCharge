import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/merchant_auth_model.dart';
import '../widgets/merchant_header_widget.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../../../core/constants/app_routes.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  // Données simulées pour le dashboard
  late MerchantAuthModel _merchant;
  int _totalServices = 8;
  int _activeServices = 6;
  double _totalRevenue = 125000;
  int _totalTransactions = 45;

  @override
  void initState() {
    super.initState();
    _loadMerchantData();
  }

  void _loadMerchantData() {
    // Simulation de données marchand
    _merchant = MerchantAuthModel(
      id: '1',
      email: 'marchand@example.com',
      businessName: 'Boutique Express',
      phone: '+225 0123456789',
      address: '123 Rue du Commerce, Abidjan',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header du marchand
            MerchantHeaderWidget(merchant: _merchant, onLogout: _handleLogout),

            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques
                    Text(
                      'Aperçu',
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    DashboardStatsWidget(
                      totalServices: _totalServices,
                      activeServices: _activeServices,
                      totalRevenue: _totalRevenue,
                      totalTransactions: _totalTransactions,
                    ),
                    const SizedBox(height: 32),

                    // Actions rapides
                    Text(
                      'Actions rapides',
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 32),

                    // Activité récente
                    Text(
                      'Activité récente',
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          title: 'Gérer le solde',
          subtitle: 'Transactions et inventaire',
          icon: Icons.account_balance_wallet,
          color: AppColors.primary,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.balanceManagement),
        ),
        _buildActionCard(
          title: 'Transactions',
          subtitle: 'Voir l\'historique',
          icon: Icons.receipt_long,
          color: Colors.green,
          onTap: () {
            // Navigation vers les transactions
          },
        ),
        _buildActionCard(
          title: 'Profil',
          subtitle: 'Modifier les informations',
          icon: Icons.person,
          color: Colors.blue,
          onTap: () {
            // Navigation vers le profil
          },
        ),
        _buildActionCard(
          title: 'Support',
          subtitle: 'Contacter l\'assistance',
          icon: Icons.support_agent,
          color: Colors.orange,
          onTap: () {
            // Navigation vers le support
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'type': 'Vente',
        'description': 'Recharge crédit MTN - 1000 FCFA',
        'time': 'Il y a 5 min',
      },
      {
        'type': 'Stock',
        'description': 'Ajout de 50 cartes Orange',
        'time': 'Il y a 1 heure',
      },
      {
        'type': 'Vente',
        'description': 'Impression document - 200 FCFA',
        'time': 'Il y a 2 heures',
      },
      {
        'type': 'Stock',
        'description': 'Mise à jour prix Moov',
        'time': 'Il y a 3 heures',
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActivityIcon(activity['type']!),
                  color: _getActivityColor(activity['type']!),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity['description']!, style: AppTextStyles.body2),
                    const SizedBox(height: 4),
                    Text(
                      activity['time']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Vente':
        return Colors.green;
      case 'Stock':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Vente':
        return Icons.shopping_cart;
      case 'Stock':
        return Icons.inventory;
      default:
        return Icons.info;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/merchant/login');
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
