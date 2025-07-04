import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/admin_model.dart';
import '../widgets/admin_stats_widget.dart';
import '../widgets/merchant_table_widget.dart';
import '../../merchant/models/merchant_auth_model.dart';
import '../services/admin_mock_data_service.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/merchant_provider.dart'; // Import MerchantProvider
import '../../../core/constants/app_routes.dart'; // Import AppRoutes

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminMockDataService _mockDataService = AdminMockDataService(); // Keep for some mock stats initially
  AdminModel? _admin;
  List<MerchantAuthModel> _merchants = []; // Will hold real merchant data
  Map<String, dynamic> _platformStats = {};
  bool _isLoading = true;
  bool _isMounted = false;
  String? _dataError; // To store any error messages during data loading


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Delay fetching data until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) { // Check if still mounted before proceeding
        _loadAllAdminData();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is disposed
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    if (!_isMounted) return; // Don't do anything if not mounted

    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
      _dataError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    // Step 1: Get Real Admin Profile
    _admin = authProvider.adminProfile;

    try {
      // Step 2: Load Real Merchants (MerchantProvider now returns List<MerchantAuthModel> via adminMerchants getter)
      await merchantProvider.loadAllMerchantsForAdmin(forceRefresh: true);
      if (!_isMounted) return;

      _merchants = merchantProvider.adminMerchants; // Directly use the list of MerchantAuthModel

      // Step 3: Calculate some stats from real merchants and merge with remaining mock stats
      Map<String, dynamic> initialMockStats = _mockDataService.getMockPlatformStats(); // For totalUsers, totalRevenue, etc.

      int actualTotalMerchants = _merchants.length;
      int actualPendingVerifications = _merchants.where((m) => !m.isVerified).length;
      int actualActiveMerchants = _merchants.where((m) => m.isVerified).length;

      // Update _platformStats: start with mock, then override with real data where available
      _platformStats = {
        ...initialMockStats, // Start with all mock stats
        'totalMerchants': actualTotalMerchants,
        'pendingVerifications': actualPendingVerifications,
        'activeMerchants': actualActiveMerchants,
        // totalUsers, totalRevenue, totalTransactions will remain from initialMockStats for now
      };

    } catch (e) {
      if (!_isMounted) return;
      print("Error loading admin data: $e");
      _dataError = "Erreur de chargement des données: ${e.toString()}";
    } finally {
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Administrateur'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: _loadAllAdminData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _handleLogout(context)),
        ],
      ),
      body: _buildBody(),
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
              Text(_dataError!, textAlign: TextAlign.center, style: AppTextStyles.body1.copyWith(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadAllAdminData, child: const Text('Réessayer'))
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
          Text('Statistiques de la plateforme', style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          AdminStatsWidget(
            totalUsers: _platformStats['totalUsers']?.toInt() ?? 0, // Still mock
            totalMerchants: _platformStats['totalMerchants']?.toInt() ?? 0, // Now real
            activeMerchants: _platformStats['activeMerchants']?.toInt() ?? 0, // Now real
            totalRevenue: _platformStats['totalRevenue']?.toDouble() ?? 0.0, // Still mock
            totalTransactions: _platformStats['totalTransactions']?.toInt() ?? 0, // Still mock
            pendingVerifications: _platformStats['pendingVerifications']?.toInt() ?? 0, // Now real
          ),
          const SizedBox(height: 32),
          Text('Actions rapides', style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 32),
          Text('Gestion des marchands', style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          MerchantTableWidget(
            merchants: _merchants, // Now uses real data (after mapping)
            onVerify: _verifyMerchant,
            onSuspend: _suspendMerchant,
            onViewDetails: _viewMerchantDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    if (_admin == null && !_isLoading) { // If not loading and admin is still null, show error/placeholder
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
    } else if (_admin == null && _isLoading) { // If loading and admin is null
       return Container( // Placeholder while loading specifically for admin header
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
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            ),
            const SizedBox(width: 16),
            Text(
              'Chargement...',
              style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary, fontSize: 18),
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
    final pendingVerifications = _platformStats['pendingVerifications']?.toInt() ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2, // Adjust if necessary for content
      children: [
        _buildActionCard(
          title: 'Vérifications',
          subtitle: '$pendingVerifications en attente', // Will be updated with real data later
          icon: Icons.verified_user,
          color: Colors.orange,
          onTap: _showPendingVerifications,
        ),
        _buildActionCard(
          title: 'Rapports',
          subtitle: 'Générer des rapports', // Placeholder
          icon: Icons.assessment,
          color: Colors.blue,
          onTap: _generateReports,
        ),
        _buildActionCard(
          title: 'Utilisateurs',
          subtitle: 'Gérer les utilisateurs', // Placeholder
          icon: Icons.people,
          color: AppColors.primary,
          onTap: _manageUsers,
        ),
        _buildActionCard(
          title: 'Support',
          subtitle: 'Tickets support', // Placeholder
          icon: Icons.support_agent,
          color: Colors.green,
          onTap: _showSupportTickets,
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

  void _verifyMerchant(MerchantAuthModel merchant) {
    // TODO: Implement actual Firestore update for verification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérifier le marchand'),
        content: Text('Voulez-vous vérifier ${merchant.businessName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Simulate update for now, then reload data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${merchant.businessName} a été marqué comme vérifié (simulé).'),
                  backgroundColor: Colors.green,
                ),
              );
              // In a real app, you'd call a service method to update Firestore,
              // then reload data or update local state optimistically.
              // For now, we can reload all data to see the change if it were real.
              // Or, update locally:
              if(_isMounted) {
                setState(() {
                  final index = _merchants.indexWhere((m) => m.id == merchant.id);
                  if (index != -1) {
                    // This is a local update, actual verification needs Firestore call
                    // _merchants[index] = merchant.copyWith(isVerified: true);
                  }
                  // To reflect a real change, you'd typically call _loadAllAdminData()
                  // or a more specific data refresh method after a Firestore update.
                });
              }
            },
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );
  }

  void _suspendMerchant(MerchantAuthModel merchant) {
    // TODO: Implement actual Firestore update for suspension
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspendre le marchand'),
        content: Text('Voulez-vous suspendre ${merchant.businessName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${merchant.businessName} a été suspendu (simulé).'),
                  backgroundColor: Colors.red,
                ),
              );
              // Similar to verify, update Firestore then refresh or update locally.
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspendre'),
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
              SelectableText('ID: ${merchant.id}'), // Make IDs selectable for easy copying
              SelectableText('Email: ${merchant.email}'),
              Text('Téléphone: ${merchant.phone}'),
              Text('Adresse: ${merchant.address}'),
              Text('Type: ${merchant.merchantType}'),
              Text('Horaires: ${merchant.openingHours ?? 'Non spécifié'}'),
              Text('Services: ${merchant.services?.join(', ') ?? 'Non spécifiés'}'),
              Text('Statut: ${merchant.isVerified ? "Vérifié" : "En attente de vérification"}'),
              Text('Inscrit le: ${_formatDate(merchant.createdAt)}'),
              Text('Dernière connexion: ${_formatDate(merchant.lastLoginAt)}'),
              if (merchant.latitude != null && merchant.longitude != null)
                Text('Coordonnées: ${merchant.latitude}, ${merchant.longitude}'),
              if (merchant.serviceStockStatus != null && merchant.serviceStockStatus!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Statut du stock des services:', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                ...merchant.serviceStockStatus!.entries.map((entry) => Text(' - ${entry.key}: ${entry.value}')),
              ]
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
        const SnackBar(content: Text('Affichage des notifications (simulé)')));
  }

  void _handleLogout(BuildContext navContext) async { // navContext for Navigator
    final authProvider = Provider.of<AuthProvider>(navContext, listen: false);
    bool? confirmLogout = await showDialog<bool>(
      context: navContext, // Use navContext for dialog
      builder: (dialogContext) => AlertDialog( // Use dialogContext for builder
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false), // Use dialogContext
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true), // Use dialogContext
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Affichage des vérifications en attente (simulé)')));
  }

  void _generateReports() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Génération de rapports (simulé)')));
  }

  void _manageUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gestion des utilisateurs (simulé)')));
  }

  void _showSupportTickets() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Affichage des tickets de support (simulé)')));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
           'à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
