import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../../providers/auth_provider.dart'; // Import AuthProvider
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/merchant_auth_model.dart';
import '../widgets/merchant_header_widget.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../../../core/constants/app_routes.dart';
import 'edit_merchant_profile_screen.dart'; // Ajout de l'import
import '../../../providers/transaction_provider.dart'; // Ajout de l'import pour TransactionProvider
import '../../../models/transaction_model.dart'; // Ajout de l'import pour TransactionModel et enums

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  // Remove simulated data
  // late MerchantAuthModel _merchant;
  int _totalServices = 8; // Keep for now, will be dynamic later
  int _activeServices = 6; // Keep for now, will be dynamic later
  double _totalRevenue = 125000; // Keep for now, will be dynamic later
  int _totalTransactions = 45; // Sera remplacé par transactionProvider.totalSalesTransactionsCount

  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour appeler les providers après la construction initiale du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Vérifier si le widget est toujours dans l'arbre
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.merchantProfile != null) {
          Provider.of<TransactionProvider>(context, listen: false)
              .fetchMerchantTransactions(authProvider); // Passer authProvider entier
        } else {
          // Gérer le cas où merchantProfile est null, peut-être après une déconnexion rapide
          // ou si l'utilisateur accède directement à cet écran sans être correctement authentifié comme marchand.
          // AuthProvider devrait déjà gérer la redirection si non authentifié/non marchand.
          print("[MerchantDashboardScreen] initState: merchantProfile est null, impossible de fetch les transactions.");
        }
      }
    });
  }

  // _loadMerchantData est supprimé car on utilise les Providers

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context); // Écouter les changements
    final MerchantAuthModel? currentMerchant = authProvider.merchantProfile;

    // Gérer l'état de chargement initial pour les deux providers
    if ((authProvider.isLoading || transactionProvider.isLoadingTransactions) && currentMerchant == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentMerchant == null) {
      // This case should ideally be handled by RouteGuards if a non-merchant tries to access
      // or if the profile somehow failed to load after auth.
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
        child: Column(
          children: [
            // Header du marchand
            MerchantHeaderWidget(merchant: currentMerchant, onLogout: () => _handleLogout(context)),

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
                    // Utiliser les données réelles des providers
                    Builder( // Utiliser un Builder pour obtenir un contexte à jour pour les providers si nécessaire
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

                    // Afficher une erreur de transaction si elle existe
                    if (transactionProvider.transactionsError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: Text(
                          "Erreur de chargement des transactions: ${transactionProvider.transactionsError}",
                          style: AppTextStyles.body2.copyWith(color: Colors.red),
                        ),
                      ),

                    // Actions rapides
                    Text(
                      'Actions rapides',
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(currentMerchant), // Passer currentMerchant
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

  Widget _buildQuickActions(MerchantAuthModel merchant) { // Accepter merchant
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
    // Consommer TransactionProvider pour obtenir les transactions récentes
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: true); // listen:true pour reconstruire si les transactions changent

    if (transactionProvider.isLoadingTransactions && transactionProvider.recentTransactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactionProvider.recentTransactions.isEmpty) {
      return const Center(child: Text('Aucune activité récente.'));
    }

    // Utiliser transactionProvider.recentTransactions
    return Column(
      children: transactionProvider.recentTransactions.map((transaction) {
        // Adapter l'affichage pour utiliser les champs de TransactionModel
        // Ceci est un exemple, vous devrez l'ajuster en fonction des champs de TransactionModel
        // et de la façon dont vous voulez afficher chaque type/statut de transaction.
        String description = '${transaction.typeDisplay}: ${transaction.serviceName} - ${transaction.amount.toStringAsFixed(0)} FCFA';
        if (transaction.userId != null && transaction.userId!.isNotEmpty) {
          description += ' (Client: ${transaction.userId!.substring(0,5)}...)'; // Exemple
        }

        // Calculer un temps relatif simple (pourrait être amélioré avec un package comme `timeago`)
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
                          transaction.statusDisplay, // Afficher le statut de la transaction
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
      }).toList(),
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
        return AppColors.primary; // Ou une autre couleur
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


  void _handleLogout(BuildContext dialogContext) { // Renamed context to avoid conflict
    final authProvider = Provider.of<AuthProvider>(dialogContext, listen: false);
    showDialog(
      context: dialogContext, // Use the passed context for the dialog
      builder: (BuildContext alertContext) => AlertDialog( // Use a different context for AlertDialog builder
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext), // Use alertContext to pop dialog
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(alertContext); // Dismiss dialog first
              await authProvider.logout();
              // Ensure context is still valid if there are other async operations before navigation
              if (mounted) { // Check if the main screen's state is still mounted
                 // Navigate to the main login screen, not merchant-specific one
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
