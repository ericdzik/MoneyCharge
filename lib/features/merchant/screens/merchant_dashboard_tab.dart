import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/widgets/loading_widgets.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_drawer.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/features/merchant/screens/merchant_reviews_screen.dart';
import 'package:locacharge/models/transaction_model.dart';
import 'package:locacharge/providers/transaction_provider.dart';

class MerchantDashboardTab extends StatefulWidget {
  const MerchantDashboardTab({super.key});

  @override
  State<MerchantDashboardTab> createState() => _MerchantDashboardTabState();
}

class _MerchantDashboardTabState extends State<MerchantDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final transactionProvider = context.read<TransactionProvider>();
    final authProvider = context.read<AuthProvider>();
    transactionProvider.fetchMerchantTransactions(authProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final merchant = authProvider.merchantProfile;

    if (merchant == null) {
      return const Center(child: Text("Profil marchand introuvable"));
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(
        title: 'Espace Marchand',
        showLogo: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(merchant),
            const SizedBox(height: AppDimensions.paddingL),
            Text('Actions Rapides', style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.paddingM),
            _buildQuickActions(context, merchant),
            const SizedBox(height: AppDimensions.paddingM),
            _buildPeriodSalesStats(),
            const SizedBox(height: AppDimensions.paddingM),
            Text('Activité Récente', style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.paddingM),
            _buildRecentActivity(),
            // Extra spacing for bottom nav if needed, though Scaffold handles it.
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MerchantAuthModel merchant) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage:
                (merchant.profileImageUrl != null &&
                    merchant.profileImageUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(merchant.profileImageUrl!)
                : null,
            child:
                (merchant.profileImageUrl == null ||
                    merchant.profileImageUrl!.isEmpty)
                ? Text(
                    merchant.businessName.isNotEmpty
                        ? merchant.businessName[0].toUpperCase()
                        : 'M',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.businessName,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                Text(
                  "Tableau de bord",
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (merchant.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    "PRO",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, MerchantAuthModel merchant) {
    final actions = [
      _buildActionCard(
        context,
        title: 'Nouvelle Facture',
        subtitle: null,
        icon: Icons.receipt_long,
        color: Colors.green,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.createInvoice);
        },
      ),
      _buildActionCard(
        context,
        title: 'Vente Rapide',
        subtitle: null,
        icon: Icons.point_of_sale,
        color: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.salesScreen);
        },
      ),
      _buildActionCard(
        context,
        title: 'Gestion Stock',
        subtitle: null,
        icon: Icons.inventory_2,
        color: Colors.purple,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.stockManagement);
        },
      ),
      _buildActionCard(
        context,
        title: 'Avis Clients',
        subtitle: null,
        icon: Icons.reviews,
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MerchantReviewsScreen(merchantId: merchant.id),
            ),
          );
        },
      ),
      if (!merchant.isPremium)
        _buildActionCard(
          context,
          title: 'Devenir Premium',
          subtitle: null,
          icon: Icons.star,
          color: Colors.amber,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.premiumSubscription);
          },
        ),
    ];

    return SizedBox(
      height: 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(width: 96, child: card),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSalesStats() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final double revenueToday = transactionProvider.revenueToday;
    final double revenueWeek = transactionProvider.revenueThisWeek;
    final double revenueMonth = transactionProvider.revenueThisMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ventes', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12;
            final double threeColWidth =
                (constraints.maxWidth - spacing * 2) / 3;
            final double twoColWidth =
                (constraints.maxWidth - spacing) / 2;
            final double itemWidth =
                threeColWidth < 110 ? twoColWidth : threeColWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildPeriodStatCard(
                    label: 'Jour',
                    value: '${revenueToday.toStringAsFixed(0)} FCFA',
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildPeriodStatCard(
                    label: 'Semaine',
                    value: '${revenueWeek.toStringAsFixed(0)} FCFA',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildPeriodStatCard(
                    label: 'Mois',
                    value: '${revenueMonth.toStringAsFixed(0)} FCFA',
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPeriodStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.h3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    if (transactionProvider.isLoadingTransactions &&
        transactionProvider.recentTransactions.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (transactionProvider.recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Aucune activité récente',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: transactionProvider.recentTransactions.map((transaction) {
        return _buildTransactionItem(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    Color statusColor;
    switch (transaction.status) {
      case TransactionStatus.completed:
        statusColor = AppColors.success;
        break;
      case TransactionStatus.pending:
        statusColor = Colors.orange;
        break;
      case TransactionStatus.failed:
        statusColor = AppColors.error;
        break;
      case TransactionStatus.cancelled:
        statusColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${transaction.typeDisplay} - ${transaction.amount.toStringAsFixed(0)} FCFA",
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction.serviceName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              transaction.statusDisplay,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
