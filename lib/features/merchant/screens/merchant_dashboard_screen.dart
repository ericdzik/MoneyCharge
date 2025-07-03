import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/merchant_auth_model.dart';
import '../widgets/merchant_header_widget.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../../../core/constants/app_routes.dart';
import 'edit_merchant_profile_screen.dart';
import '../../../providers/transaction_provider.dart'; // Ajout de l'import pour TransactionProvider
import '../../../models/transaction_model.dart'; // Ajout de l'import pour TransactionModel et enums

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.merchantProfile != null) {
          Provider.of<TransactionProvider>(context, listen: false)
              .fetchMerchantTransactions(authProvider);
        } else {
          print("[MerchantDashboardScreen] initState: merchantProfile est null, impossible de fetch les transactions.");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final MerchantAuthModel? currentMerchant = authProvider.merchantProfile;

    if ((authProvider.isLoading || transactionProvider.isLoadingTransactions) && currentMerchant == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentMerchant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur Profil Marchand")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Text(
              "Profil marchand non disponible. Veuillez vous reconnecter ou contacter le support.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator( // Ajout du RefreshIndicator
          onRefresh: () async {
            // Mettre à jour le profil et les transactions
            // On suppose que fetchUserProfile dans AuthProvider est appelé si nécessaire
            // ou que le profil est déjà à jour.
             if (authProvider.merchantProfile != null) {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .fetchMerchantTransactions(authProvider);
             }
          },
          child: Column(
            children: [
              MerchantHeaderWidget(merchant: currentMerchant, onLogout: () => _handleLogout(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aperçu',
                        style: AppTextStyles.h2.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final int totalServicesCount = currentMerchant.services?.length ?? 0;
                          final int activeServicesCount = currentMerchant.serviceStockStatus?.entries
                              .where((entry) => entry.value.toLowerCase() == 'disponible')
                              .length ?? 0;

                          return DashboardStatsWidget(
                            totalServices: totalServicesCount,
                            activeServices: activeServicesCount,
                            totalRevenue: transactionProvider.totalRevenue,
                            totalTransactions: transactionProvider.totalSalesTransactionsCount,
                          );
                        }
                      ),
                      const SizedBox(height: 32),
                      if (transactionProvider.transactionsError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                          child: Text(
                            "Erreur de chargement des transactions: ${transactionProvider.transactionsError}",
                            style: AppTextStyles.body2.copyWith(color: Colors.red),
                          ),
                        ),
                      Text(
                        'Actions rapides',
                        style: AppTextStyles.h2.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(currentMerchant),
                      const SizedBox(height: 32),
                      Text(
                        'Activité récente',
                        style: AppTextStyles.h2.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivity(), // Sera mis à jour pour utiliser TransactionProvider
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(MerchantAuthModel merchant) {
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
             // TODO: Naviguer vers un écran d'historique complet des transactions
             // Pour l'instant, peut-être juste un SnackBar ou rien
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers l\'historique des transactions (TODO)'))
             );
          },
        ),
        _buildActionCard(
          title: 'Profil',
          subtitle: 'Modifier les informations',
          icon: Icons.person,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditMerchantProfileScreen(merchant: merchant),
              ),
            );
          },
        ),
        _buildActionCard(
          title: 'Support',
          subtitle: 'Contacter l\'assistance',
          icon: Icons.support_agent,
          color: Colors.orange,
          onTap: () {
            // TODO: Navigation vers le support
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers le support (TODO)'))
             );
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
        // ... (contenu de _buildActionCard inchangé) ...
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
    final transactionProvider = Provider.of<TransactionProvider>(context);

    if (transactionProvider.isLoadingTransactions && transactionProvider.recentTransactions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (transactionProvider.transactionsError != null && transactionProvider.recentTransactions.isEmpty) {
        return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
            "Erreur: ${transactionProvider.transactionsError}",
            style: AppTextStyles.body1.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
        ),
        ));
    }

    if (transactionProvider.recentTransactions.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Aucune activité récente.'),
      ));
    }

    return Column(
      children: transactionProvider.recentTransactions.map<Widget>((transaction) { // Explicitement Widget
        String description = '${transaction.typeDisplay}: ${transaction.serviceName} - ${transaction.amount.toStringAsFixed(0)} FCFA';
        if (transaction.userId != null && transaction.userId!.isNotEmpty) {
          description += ' (Client: ${transaction.userId!.substring(0,5)}...)';
        }

        final timeAgo = DateTime.now().difference(transaction.timestamp.toDate());
        String timeDisplay;
        if (timeAgo.inMinutes < 1) {
          timeDisplay = 'À l\'instant';
        } else if (timeAgo.inMinutes < 60) {
          timeDisplay = 'Il y a ${timeAgo.inMinutes} min';
        } else if (timeAgo.inHours < 24) {
          timeDisplay = 'Il y a ${timeAgo.inHours} h';
        } else {
          timeDisplay = 'Il y a ${timeAgo.inDays} j';
        }

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
                  color: _getTransactionActivityColor(transaction.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTransactionActivityIcon(transaction.type),
                  color: _getTransactionActivityColor(transaction.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(description, style: AppTextStyles.body2),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeDisplay,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          transaction.statusDisplay,
                          style: AppTextStyles.caption.copyWith(
                            color: _getTransactionStatusColor(transaction.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(), // .cast<Widget>() n'est plus nécessaire si map retourne explicitement Widget
    );
  }

  Color _getTransactionActivityColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.stockPurchase:
        return Colors.blue;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.withdrawal:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionActivityIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.shopping_cart_checkout_rounded;
      case TransactionType.stockPurchase:
        return Icons.inventory_2_outlined;
      case TransactionType.refund:
        return Icons.undo_rounded;
      case TransactionType.withdrawal:
        return Icons.savings_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getTransactionStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleLogout(BuildContext dialogContext) {
    final authProvider = Provider.of<AuthProvider>(dialogContext, listen: false);
    showDialog(
      context: dialogContext,
      builder: (BuildContext alertContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(alertContext);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(dialogContext, AppRoutes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
