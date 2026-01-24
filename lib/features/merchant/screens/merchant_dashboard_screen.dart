import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/admin/screens/notification_screen.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';
import 'package:locacharge/features/merchant/screens/merchant_reviews_screen.dart';
import 'package:locacharge/models/transaction_model.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';
import 'package:locacharge/features/user/screens/home_feed_screen.dart';
import 'package:locacharge/features/user/screens/list_view_screen.dart';
import 'package:locacharge/features/user/screens/favorites_screen.dart';
import 'package:locacharge/features/user/screens/home_screen.dart'
    show MapViewContent;
import 'package:locacharge/core/security/access_control_widget.dart';
import 'package:locacharge/core/security/rbac_constants.dart';
import 'package:locacharge/core/widgets/adaptive_navigation.dart';
import 'package:locacharge/features/profile/unified_profile_screen.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  bool _isTrackingPosition = false;
  int _currentIndex = 0;
  Timer? _positionUpdateTimer;

  @override
  void initState() {
    super.initState();
    // nothing UI-related here; keep init lightweight
  }

  @override
  Widget build(BuildContext context) {
    // Les écrans accessibles aux marchands (incluant les écrans User grâce à l'héritage)
    final screens = [
      // Écran 0: Home Feed (hérité de User)
      AccessControl(
        permission: AppPermission.viewHome,
        child: const HomeFeedScreen(),
        fallback: const Center(child: Text('Accès refusé')),
      ),
      // Écran 1: Map View (hérité de User)
      AccessControl(
        permission: AppPermission.viewMarketplace,
        child: const MapViewContent(onMapCreated: null),
        fallback: const Center(child: Text('Accès refusé')),
      ),
      // Écran 2: List View (hérité de User)
      AccessControl(
        permission: AppPermission.viewMarketplace,
        child: const ListViewScreen(mapController: null),
        fallback: const Center(child: Text('Accès refusé')),
      ),
      // Écran 3: Favorites (hérité de User)
      AccessControl(
        permission: AppPermission.viewFavorites,
        child: const FavoritesScreen(),
        fallback: const Center(child: Text('Accès refusé')),
      ),
      // Écran 4: Merchant Profile (unifié)
      AccessControl(
        permission: AppPermission.manageBusinessProfile,
        child: const UnifiedProfileScreen(),
        fallback: const Center(child: Text('Accès refusé')),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: AdaptiveBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Augmenté de 70 à 80 pour plus d'espace
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Accueil',
                isActive: true,
                onTap: () {
                  // Déjà sur l'accueil
                },
              ),
              _buildNavBarItem(
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card,
                label: 'Carte',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.home);
                },
              ),
              _buildNavBarItem(
                icon: Icons.point_of_sale_outlined,
                activeIcon: Icons.point_of_sale,
                label: 'Ventes',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.salesScreen);
                },
              ),
              _buildNavBarItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Stock',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.stockManagement);
                },
              ),
              _buildNavBarItem(
                icon: Icons.more_horiz,
                activeIcon: Icons.more_horiz,
                label: 'Plus',
                isActive: false,
                onTap: () {
                  _showMoreOptions();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentMerchant = authProvider.merchantProfile;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Plus d\'options',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildMoreOption(
              icon: Icons.reviews_outlined,
              title: 'Avis clients',
              subtitle: 'Voir les retours clients',
              onTap: () {
                Navigator.pop(context);
                if (currentMerchant != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MerchantReviewsScreen(merchantId: currentMerchant.id),
                    ),
                  );
                }
              },
            ),
            _buildMoreOption(
              icon: Icons.support_agent_outlined,
              title: 'Support',
              subtitle: 'Contacter l\'assistance',
              onTap: () {
                Navigator.pop(context);
                SnackBarHelper.showInfo(
                  context,
                  'Navigation vers le support (TODO)',
                );
              },
            ),
            if (currentMerchant != null && !currentMerchant.isPremium)
              _buildMoreOption(
                icon: Icons.star_outline,
                title: 'Devenir Premium',
                subtitle: 'Accès aux fonctionnalités exclusives',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.premiumSubscription);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Removed unused test notification method

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  Widget _buildQuickActions(MerchantAuthModel merchant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For a 2-column layout, we can calculate a suitable aspect ratio.
        // Let's aim for a card height of around 120-140 pixels.
        // The width of each card will be (constraints.maxWidth - spacing) / 2.
        const double crossAxisSpacing = 16;
        const double mainAxisSpacing = 16;
        final double itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;
        const double itemHeight = 130;
        final double childAspectRatio = itemWidth / itemHeight;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            _buildActionCard(
              title: 'Nouvelle Facture',
              subtitle: 'Créer une facture',
              icon: Icons.receipt_long,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.createInvoice);
              },
            ),
            _buildActionCard(
              title: 'Mon Profil',
              subtitle: 'Gérer mon profil',
              icon: Icons.person,
              color: Colors.indigo,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.merchantProfile);
              },
            ),
            _buildActionCard(
              title: 'Vente Rapide',
              subtitle: 'Transaction directe',
              icon: Icons.point_of_sale,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.salesScreen);
              },
            ),
            _buildActionCard(
              title: 'Gestion Stock',
              subtitle: 'Gérer disponibilité',
              icon: Icons.inventory_2,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.stockManagement);
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
                    builder: (_) =>
                        MerchantReviewsScreen(merchantId: merchant.id),
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
                  Text(
                    'Activez pour être visible par les clients.',
                    style: AppTextStyles.body2,
                  ),
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
    if (!mounted) return;

    if (value) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackBarHelper.showWarning(
            context,
            'La permission de localisation est requise pour activer le suivi.',
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isTrackingPosition = true;
        });
        _positionUpdateTimer = Timer.periodic(const Duration(seconds: 30), (
          timer,
        ) {
          if (mounted) {
            _updatePositionInFirestore();
          } else {
            timer.cancel();
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isTrackingPosition = false;
        });
      }
      _positionUpdateTimer?.cancel();
    }
  }

  Future<void> _updatePositionInFirestore() async {
    if (!mounted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId != null && mounted) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.userId)
            .update({
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
    // Annuler le timer de position de manière sécurisée
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = null;
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
