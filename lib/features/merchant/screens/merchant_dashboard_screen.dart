import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/features/admin/screens/notification_screen.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/features/merchant/screens/edit_merchant_profile_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_reviews_screen.dart';
import 'package:locacharge/features/merchant/widgets/dashboard_stats_widget.dart';
import 'package:locacharge/features/merchant/widgets/merchant_header_widget.dart';
import 'package:locacharge/models/transaction_model.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';
import 'package:locacharge/services/notification_service.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  bool _isTrackingPosition = false;
  Timer? _positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.merchantProfile != null) {
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).fetchMerchantTransactions(authProvider);
        } else {
          print(
            "[MerchantDashboardScreen] initState: merchantProfile est null, impossible de fetch les transactions.",
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final MerchantAuthModel? currentMerchant = authProvider.merchantProfile;

    if ((authProvider.isLoading || transactionProvider.isLoadingTransactions) &&
        currentMerchant == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (currentMerchant == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Erreur Profil Marchand',
          showLogo: false,
        ),
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

    return ScaffoldWithBackground(
      backgroundConfig: const BackgroundConfig(),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendTestNotification,
        tooltip: 'Envoyer une notification de test',
        child: const Icon(Icons.notification_add),
      ),
      body: Column(
            children: [
              // Header sans SafeArea supplémentaire
              MerchantHeaderWidget(
                merchant: currentMerchant,
                onLogout: () => _handleLogout(context),
                onNotificationsTapped: _showNotifications,
              ),

              // Contenu scrollable
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (authProvider.merchantProfile != null) {
                      await Provider.of<TransactionProvider>(
                        context,
                        listen: false,
                      ).fetchMerchantTransactions(authProvider);
                    }
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aperçu',
                          style: AppTextStyles.h2
                              .copyWith(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final int totalServicesCount =
                                currentMerchant.services?.length ?? 0;
                            final int activeServicesCount =
                                currentMerchant.serviceStockStatus?.entries
                                    .where(
                                      (entry) =>
                                  entry.value.toLowerCase() ==
                                      'disponible',
                                )
                                    .length ??
                                    0;

                            return DashboardStatsWidget(
                              totalServices: totalServicesCount,
                              activeServices: activeServicesCount,
                              totalRevenue: transactionProvider.totalRevenue,
                              totalTransactions: transactionProvider
                                  .totalSalesTransactionsCount,
                              averageRating: currentMerchant.averageRating,
                              reviewCount: currentMerchant.reviewCount,
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        if (transactionProvider.transactionsError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingM,
                            ),
                            child: Text(
                              "Erreur de chargement des transactions: ${transactionProvider.transactionsError}",
                              style: AppTextStyles.body2
                                  .copyWith(color: Colors.redAccent),
                            ),
                          ),
                        Text(
                          'Actions rapides',
                          style: AppTextStyles.h2
                              .copyWith(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActions(currentMerchant),
                        const SizedBox(height: 32),
                        if (currentMerchant.profileType == 'mobile')
                          _buildLiveLocationCard(),
                        Text(
                          'Activité récente',
                          style: AppTextStyles.h2
                              .copyWith(fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _sendTestNotification() {
    NotificationService.showNotification(
      id: Random().nextInt(1000),
      title: 'Notification de test (Marchand)',
      body: 'Ceci est une notification de test pour le marchand.',
    );
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  Widget _buildQuickActions(MerchantAuthModel merchant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (screenWidth < 360) {
          crossAxisCount = 1;
          childAspectRatio = 2.8;
        } else if (screenWidth < 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.3;
        } else if (screenWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 1.2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildActionCard(
              title: 'Profil',
              subtitle: 'Modifier les informations',
              icon: Icons.person,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditMerchantProfileScreen(merchant: merchant),
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
                SnackBarHelper.showInfo(
                  context,
                  'Navigation vers le support (TODO)',
                );
              },
            ),
            _buildActionCard(
              title: 'Avis Clients',
              subtitle: 'Voir les retours',
              icon: Icons.reviews,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MerchantReviewsScreen(
                      merchantId: merchant.id,
                    ),
                  ),
                );
              },
            ),
            if (!merchant.isPremium)
              _buildActionCard(
                title: 'Devenir Premium',
                subtitle: 'Accès exclusif',
                icon: Icons.star,
                color: Colors.amber,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.premiumSubscription);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isVerySmallScreen = MediaQuery.of(context).size.width < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: isVerySmallScreen ? 24 : 28,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 6 : 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: isVerySmallScreen ? 13 : 15,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 3 : 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.black54,
                    fontSize: isVerySmallScreen ? 10 : 11,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    if (transactionProvider.isLoadingTransactions &&
        transactionProvider.recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingIndicator(),
      );
    }

    if (transactionProvider.transactionsError != null &&
        transactionProvider.recentTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Erreur: ${transactionProvider.transactionsError}",
            style: AppTextStyles.body1.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (transactionProvider.recentTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucune activité récente.'),
        ),
      );
    }

    return Column(
      children: transactionProvider.recentTransactions.map<Widget>((
          transaction,
          ) {
        String description =
            '${transaction.typeDisplay}: ${transaction.serviceName} - ${transaction.amount.toStringAsFixed(0)} FCFA';
        if (transaction.userId != null && transaction.userId!.isNotEmpty) {
          description += ' (Client: ${transaction.userId!.substring(0, 5)}...)';
        }

        final timeAgo = DateTime.now().difference(
          transaction.timestamp.toDate(),
        );
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
                  color: _getTransactionActivityColor(
                    transaction.type,
                  ).withOpacity(0.1),
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
                            color: _getTransactionStatusColor(
                              transaction.status,
                            ),
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
        return AppColors.primary;
      case TransactionType.stockPurchase:
        return Colors.blue;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.withdrawal:
        return AppColors.primary;

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
    }
  }

  Color _getTransactionStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.primary;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildLiveLocationCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 32),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suivi de la Position', style: AppTextStyles.h3),
                  SizedBox(height: 4),
                  Text('Activez pour être visible par les clients.', style: AppTextStyles.body2),
                ],
              ),
            ),
            Switch(
              value: _isTrackingPosition,
              onChanged: (value) {
                _togglePositionTracking(value);
              },
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  void _togglePositionTracking(bool value) async {
    if (value) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        SnackBarHelper.showWarning(
          context,
          'La permission de localisation est requise pour activer le suivi.',
        );
        return;
      }

      setState(() {
        _isTrackingPosition = true;
      });
      _positionUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _updatePositionInFirestore();
      });
    } else {
      setState(() {
        _isTrackingPosition = false;
      });
      _positionUpdateTimer?.cancel();
    }
  }

  Future<void> _updatePositionInFirestore() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(authProvider.userId).update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    } catch (e) {
      print("Erreur lors de la mise à jour de la position: $e");
    }
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    super.dispose();
  }

  void _handleLogout(BuildContext dialogContext) async {
    if (_isTrackingPosition) {
      _togglePositionTracking(false);
    }
    final authProvider = Provider.of<AuthProvider>(
      dialogContext,
      listen: false,
    );
    
    final confirmed = await DialogHelper.showLogoutConfirmation(dialogContext);
    
    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          dialogContext,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}