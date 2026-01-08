import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/features/admin/models/admin_model.dart';
import 'package:locacharge/features/admin/screens/notification_screen.dart';
import 'package:locacharge/features/admin/services/admin_firestore_service.dart';
import 'package:locacharge/features/admin/widgets/admin_app_bar.dart';
import 'package:locacharge/features/admin/widgets/admin_stats_widget.dart';
import 'package:locacharge/features/admin/widgets/merchant_table_widget.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/services/notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // final AdminMockDataService _mockDataService = AdminMockDataService(); // Will be removed
  final AdminFirestoreService _adminFirestoreService =
      AdminFirestoreService(); // Added
  AdminModel? _admin;
  List<MerchantAuthModel> _merchants = [];
  Map<String, dynamic> _platformStats = {};
  bool _isLoading = true;
  bool _isMounted = false;
  String? _dataError;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        _loadAllAdminData();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
      _dataError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantProvider = Provider.of<MerchantProvider>(
        context,
        listen: false,
      );

      String? adminId = authProvider.userId;
      if (adminId == null) {
        throw Exception(
          "Admin ID not found. User may not be logged in or not an admin.",
        );
      }

      // Fetch admin profile
      final adminProfileFuture = _adminFirestoreService.getAdminProfile(
        adminId,
      );
      // Fetch platform statistics
      final platformStatsFuture = _adminFirestoreService
          .getPlatformStatistics();
      // Load merchants via provider (this will also set its internal loading state)
      final merchantLoadFuture = merchantProvider.loadAllMerchantsForAdmin(
        forceRefresh: true,
      );

      // Await all futures
      final results = await Future.wait([
        adminProfileFuture,
        platformStatsFuture,
        merchantLoadFuture.then(
          (_) => merchantProvider.adminMerchants,
        ), // Ensure provider is done, then get merchants
      ]);

      if (!_isMounted) return;

      final AdminModel? fetchedAdmin = results[0] as AdminModel?;
      final Map<String, dynamic> fetchedStats =
          results[1] as Map<String, dynamic>;
      // Merchants are already updated in the provider, now get them for local state if needed
      // or rely on Consumer/Selector for MerchantTableWidget. For simplicity here, we get them.
      final List<MerchantAuthModel> fetchedMerchants =
          merchantProvider.adminMerchants;

      if (fetchedAdmin == null) {
        // If admin profile is null, it could mean the user is not a valid admin in Firestore
        // or their role is not 'admin'
        throw Exception("Profil administrateur non trouvé ou invalide.");
      }

      setState(() {
        _admin = fetchedAdmin;
        _platformStats = fetchedStats;
        _merchants = fetchedMerchants; // Update local merchants list
        _isLoading = false;
      });
    } catch (e) {
      if (!_isMounted) return;
      print("Error loading admin data: $e");
      setState(() {
        _dataError = "Erreur lors du chargement des données: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AdminAppBar(
        admin: _admin,
        isLoading: _isLoading,
        onRefresh: _loadAllAdminData,
        onNotifications: _showNotifications,
        onLogout: () => _handleLogout(context),
      ),
      body: Container(
        color: Colors.white, // Fond blanc propre
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    if (_dataError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _dataError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllAdminData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques de la plateforme
            _buildSectionHeader(
              title: 'Statistiques de la plateforme',
              subtitle: 'Vue d\'ensemble des performances',
              icon: Icons.analytics_outlined,
            ),
            const SizedBox(height: 16),
            AdminStatsWidget(
              totalUsers: _platformStats['totalUsers']?.toInt() ?? 0,
              totalMerchants: _platformStats['totalMerchants']?.toInt() ?? 0,
              activeMerchants: _platformStats['activeMerchants']?.toInt() ?? 0,
              totalRevenue: _platformStats['totalRevenue']?.toDouble() ?? 0.0,
              totalTransactions:
                  _platformStats['totalTransactions']?.toInt() ?? 0,
              pendingVerifications:
                  _platformStats['pendingVerifications']?.toInt() ?? 0,
            ),
            const SizedBox(height: 32),
            
            // Actions rapides avec nouveau design
            _buildSectionHeader(
              title: 'Actions rapides',
              subtitle: 'Accès direct aux fonctions principales',
              icon: Icons.flash_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 32),
            
            // Gestion des marchands
            _buildSectionHeader(
              title: 'Gestion des marchands',
              subtitle: 'Supervision et validation des comptes',
              icon: Icons.store_mall_directory_outlined,
            ),
            const SizedBox(height: 16),
            MerchantTableWidget(
              merchants: _merchants,
              onVerify: _verifyMerchant,
              onSuspend: _suspendMerchant,
              onViewDetails: _viewMerchantDetails,
            ),
            
            // Padding en bas pour éviter que le contenu soit masqué par la nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final pendingVerifications =
        _platformStats['pendingVerifications']?.toInt() ?? 0;

    final actions = [
      {
        'title': 'Vérifications',
        'subtitle': '$pendingVerifications en attente',
        'icon': Icons.verified_user,
        'color': Colors.orange,
        'onTap': _showPendingVerifications,
      },
      {
        'title': 'Publicités',
        'subtitle': 'Gérer les publicités',
        'icon': Icons.campaign,
        'color': Colors.purple,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.adminAds),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // Calculer la largeur optimale pour chaque carte
        final cardSpacing = 16.0;
        final totalSpacing = cardSpacing * (actions.length - 1);
        final availableWidth = screenWidth - totalSpacing;
        final cardWidth = availableWidth / actions.length;

        // Pas de hauteur fixe - laisse le contenu déterminer la hauteur
        return Row(
          children: actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < actions.length - 1 ? cardSpacing : 0,
                ),
                child: _buildActionCard(
                  title: action['title'] as String,
                  subtitle: action['subtitle'] as String,
                  icon: action['icon'] as IconData,
                  color: action['color'] as Color,
                  onTap: action['onTap'] as VoidCallback,
                ),
              ),
            );
          }).toList(),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône en haut, centrée
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18, // Icône réduite
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Titre avec plus d'espace
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 6),
            
            // Sous-titre avec plus d'espace
            Text(
              subtitle,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Flèche en bas à droite
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyMerchant(MerchantAuthModel merchant) async {
    final newStatus = !merchant.isVerified;
    final confirmed = await DialogHelper.showConfirmation(
      context,
      title: '${newStatus ? "Vérifier" : "Annuler la vérification de"} ce marchand ?',
      message: 'Voulez-vous vraiment changer le statut de ${merchant.businessName} ?',
      confirmText: newStatus ? 'Vérifier' : 'Confirmer',
    );
    
    if (confirmed == true) {
      final merchantProvider = Provider.of<MerchantProvider>(
        context,
        listen: false,
      );
      await merchantProvider.updateMerchantVerification(
        merchant.id,
        newStatus,
      );
    }
  }

  void _suspendMerchant(MerchantAuthModel merchant) async {
    final newStatus = !merchant.isSuspended;
    final actionText = newStatus ? 'Suspendre' : 'Réactiver';

    final confirmed = await DialogHelper.showConfirmation(
      context,
      title: '$actionText le marchand ?',
      message: 'Voulez-vous vraiment ${actionText.toLowerCase()} ${merchant.businessName} ?',
      confirmText: actionText,
      isDangerous: newStatus,
    );
    
    if (confirmed == true) {
      final merchantProvider = Provider.of<MerchantProvider>(
        context,
        listen: false,
      );
      try {
        await merchantProvider.updateMerchantSuspension(
          merchant.id,
          newStatus,
        );
        if (mounted) {
          SnackBarHelper.showSuccess(
            context,
            '${merchant.businessName} a été ${newStatus ? "suspendu" : "réactivé"}.',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            'Erreur: ${e.toString()}',
          );
        }
      }
    }
  }

  void _viewMerchantDetails(MerchantAuthModel merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(merchant.businessName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                'ID: ${merchant.id}',
              ), // Make IDs selectable for easy copying
              SelectableText('Email: ${merchant.email}'),
              Text('Téléphone: ${merchant.phone}'),
              Text('Adresse: ${merchant.address}'),
              Text('Type: ${merchant.merchantType}'),
              Text('Horaires: ${merchant.openingHours ?? 'Non spécifié'}'),
              () {
                String servicesText = 'Non spécifiés';
                if (merchant.services != null && merchant.services!.isNotEmpty) {
                  servicesText = merchant.services!.join(', ');
                }
                return Text('Services: $servicesText');
              }(),
              Text(
                'Statut: ${merchant.isVerified ? "Vérifié" : "En attente de vérification"}',
              ),
              Text('Inscrit le: ${_formatDate(merchant.createdAt)}'),
              Text('Dernière connexion: ${_formatDate(merchant.lastLoginAt)}'),
              if (merchant.latitude != null && merchant.longitude != null)
                Text(
                  'Coordonnées: ${merchant.latitude}, ${merchant.longitude}',
                ),
              if (merchant.serviceStockStatus != null &&
                  merchant.serviceStockStatus!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Statut du stock des services:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...merchant.serviceStockStatus!.entries.map(
                  (entry) => Text(' - ${entry.key}: ${entry.value}'),
                ),
              ],
              const Divider(height: 20, thickness: 1),
              const Text(
                'Avis des clients:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200, // Hauteur fixe pour la liste d'avis
                width: double.maxFinite, // Prendre toute la largeur
                child: ReviewListWidget(merchantId: merchant.id),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  void _handleLogout(BuildContext navContext) async {
    // navContext for Navigator
    final authProvider = Provider.of<AuthProvider>(navContext, listen: false);
    bool? confirmLogout = await showDialog<bool>(
      context: navContext, // Use navContext for dialog
      builder: (dialogContext) => AlertDialog(
        // Use dialogContext for builder
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false), // Use dialogContext
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true), // Use dialogContext
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await authProvider.logout();
      // Ensure context is still valid before navigating
      if (mounted && navContext.mounted) {
        // Using pushReplacementNamed to clear the stack up to login
        Navigator.pushReplacementNamed(navContext, AppRoutes.login);
      }
    }
  }

  void _showPendingVerifications() {
    final pendingMerchants = _merchants.where((m) => !m.isVerified).toList();
    Navigator.pushNamed(
      context,
      AppRoutes.adminPendingVerifications,
      arguments: {'merchants': pendingMerchants},
    );
  }

  void _sendTestNotification() {
    NotificationService.showNotification(
      id: Random().nextInt(1000),
      title: 'Notification de test',
      body: 'Ceci est une notification de test pour vérifier le système.',
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        'à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                icon: Icons.verified_user_outlined,
                activeIcon: Icons.verified_user,
                label: 'Vérifications',
                isActive: false,
                onTap: () {
                  _showPendingVerifications();
                },
              ),
              _buildNavBarItem(
                icon: Icons.campaign_outlined,
                activeIcon: Icons.campaign,
                label: 'Publicités',
                isActive: false,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.adminAds);
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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? AppColors.primary : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
