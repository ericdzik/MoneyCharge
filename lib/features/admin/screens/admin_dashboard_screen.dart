import 'package:flutter/material.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import 'package:provider/provider.dart'; // Added for Provider
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart'; // Added for AppRoutes.login
import '../models/admin_model.dart';
import '../widgets/admin_stats_widget.dart';
import '../widgets/merchant_table_widget.dart';
import '../../merchant/models/merchant_auth_model.dart';
import '../services/admin_firestore_service.dart'; // Added
import '../../../providers/auth_provider.dart'; // Added
import '../../../providers/merchant_provider.dart'; // Added
import '../../../core/widgets/custom_app_bar.dart';
// Removed AdminMockDataService import as it's being replaced for primary data
// import '../services/admin_mock_data_service.dart';

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
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Dashboard Admin',
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            tooltip: 'Rafraîchir',
            onPressed: _loadAllAdminData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.white),
            tooltip: 'Notifications',
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            tooltip: 'Déconnexion',
            onPressed: () => _handleLogout(context),
          ),
        ],
        showLogo: false,
      ),
      body: Stack(
        children: [
          // Image de fond qui s'étend sous l'AppBar
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          // Contenu principal avec padding pour l'AppBar
          SafeArea(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminHeader(),
          const SizedBox(height: 24),
          Text(
            'Statistiques de la plateforme',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Décommentons AdminStatsWidget
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
          // const Text("AdminStatsWidget a été commenté temporairement", style: TextStyle(color: Colors.orange)), // On enlève le message temporaire
          const SizedBox(height: 32),
          Text(
            'Actions rapides',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 32),
          Text(
            'Gestion des marchands',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Décommentons MerchantTableWidget
          MerchantTableWidget(
            merchants: _merchants,
            onVerify: _verifyMerchant,
            onSuspend: _suspendMerchant,
            onViewDetails: _viewMerchantDetails,
          ),
          // const Text("MerchantTableWidget a été commenté temporairement", style: TextStyle(color: Colors.orange)), // On enlève le message temporaire
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    if (_admin == null && !_isLoading) {
      // If not loading and admin is still null, show error/placeholder
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.onPrimary,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Text(
              'Profil Admin non disponible',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.onPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    } else if (_admin == null && _isLoading) {
      // If loading and admin is null
      return Container(
        // Placeholder while loading specifically for admin header
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.onPrimary,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Chargement...',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.onPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }
    // If _admin is not null
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.onPrimary,
            child: Text(
              _admin!.name.isNotEmpty ? _admin!.name[0] : 'A',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _admin!.name,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _admin!.roleText,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dernière connexion: ${_formatDate(_admin!.lastLoginAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final pendingVerifications =
        _platformStats['pendingVerifications']?.toInt() ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double childAspectRatio;

        if (screenWidth < 360) {
          // Very small screens
          crossAxisCount = 1;
          childAspectRatio = 2.8;
        } else if (screenWidth < 600) {
          // Small screens (typical phones portrait)
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else if (screenWidth < 900) {
          // Medium screens (tablets portrait, large phones landscape)
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        } else if (screenWidth < 1200) {
          // Large screens (tablets landscape)
          crossAxisCount = 4;
          childAspectRatio = 1.3;
        } else {
          // Extra large screens
          crossAxisCount = 5;
          childAspectRatio = 1.3;
        }

        // Ajustement pour éviter que les cartes ne soient trop larges sur les écrans très larges
        // en limitant le nombre de colonnes si nécessaire, ou en ajustant l'aspect ratio.
        // Par exemple, si crossAxisCount devient trop élevé, les cartes peuvent devenir trop minces.
        // Pour cet exemple, nous allons garder les valeurs ci-dessus.

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildActionCard(
              title: 'Vérifications',
              subtitle: '$pendingVerifications en attente',
              icon: Icons.verified_user,
              color: Colors.orange,
              onTap: _showPendingVerifications,
            ),
            _buildActionCard(
              title: 'Publicités',
              subtitle: 'Gérer les publicités',
              icon: Icons.campaign,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminAds),
            ),
            // _buildActionCard(
            //   title: 'Rapports',
            //   subtitle: 'Générer des rapports',
            //   icon: Icons.assessment,
            //   color: Colors.blue,
            //   onTap: _generateReports,
            // ),
            // _buildActionCard(
            //   title: 'Utilisateurs',
            //   subtitle: 'Gérer les utilisateurs',
            //   icon: Icons.people,
            //   color: AppColors.primary,
            //   onTap: _manageUsers,
            // ),
            // _buildActionCard(
            //   title: 'Support',
            //   subtitle: 'Tickets support',
            //   icon: Icons.support_agent,
            //   color: Colors.green,
            //   onTap: _showSupportTickets,
            // ),
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
          color: AppColors.surface,
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
                color: color.withOpacity(0.1),
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
                    color: AppColors.textSecondary,
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

  void _verifyMerchant(MerchantAuthModel merchant) {
    final newStatus = !merchant.isVerified;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${newStatus ? "Vérifier" : "Annuler la vérification de"} ce marchand ?',
        ),
        content: Text(
          'Voulez-vous vraiment changer le statut de ${merchant.businessName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final merchantProvider = Provider.of<MerchantProvider>(
                context,
                listen: false,
              );
              await merchantProvider.updateMerchantVerification(
                merchant.id,
                newStatus,
              );
            },
            child: Text(newStatus ? 'Vérifier' : 'Confirmer'),
          ),
        ],
      ),
    );
  }

  void _suspendMerchant(MerchantAuthModel merchant) {
    final newStatus = !(merchant.isSuspended ?? false);
    final actionText = newStatus ? 'Suspendre' : 'Réactiver';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText le marchand ?'),
        content: Text(
          'Voulez-vous vraiment ${actionText.toLowerCase()} ${merchant.businessName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${merchant.businessName} a été ${newStatus ? "suspendu" : "réactivé"}.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.red : AppColors.success,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
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
              Text(
                'Services: ${merchant.services?.join(', ') ?? 'Non spécifiés'}',
              ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Affichage des notifications (simulé)')),
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

  void _generateReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération de rapports (simulé)')),
    );
  }

  void _manageUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion des utilisateurs (simulé)')),
    );
  }

  void _showSupportTickets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affichage des tickets de support (simulé)'),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        'à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
