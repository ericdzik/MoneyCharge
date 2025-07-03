import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/admin_model.dart';
import '../widgets/admin_stats_widget.dart';
import '../widgets/merchant_table_widget.dart';
import '../../merchant/models/merchant_auth_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminModel _admin;
  List<MerchantAuthModel> _merchants = [];
  bool _isLoading = true;

  // Statistiques simulées
  final int _totalUsers = 1250;
  final int _totalMerchants = 85;
  final int _activeMerchants = 72;
  final double _totalRevenue = 2500000;
  final int _totalTransactions = 156;
  final int _pendingVerifications = 8;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadMerchants();
  }

  void _loadAdminData() {
    _admin = AdminModel(
      id: '1',
      email: 'admin@locacharge.com',
      name: 'Administrateur Principal',
      role: AdminRole.superAdmin,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
      permissions: ['all'],
    );
  }

  void _loadMerchants() {
    // Simulation de données marchands
    _merchants = [
      MerchantAuthModel(
        id: '1',
        email: 'boutique1@example.com',
        businessName: 'Boutique Express',
        phone: '+225 0123456789',
        address: '123 Rue du Commerce, Abidjan',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MerchantAuthModel(
        id: '2',
        email: 'boutique2@example.com',
        businessName: 'Cyber Café Central',
        phone: '+225 0123456790',
        address: '456 Avenue de la Paix, Abidjan',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MerchantAuthModel(
        id: '3',
        email: 'boutique3@example.com',
        businessName: 'Point Service Plus',
        phone: '+225 0123456791',
        address: '789 Boulevard des Martyrs, Abidjan',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      MerchantAuthModel(
        id: '4',
        email: 'boutique4@example.com',
        businessName: 'E-Services',
        phone: '+225 0123456792',
        address: '321 Rue des Banques, Abidjan',
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastLoginAt: null,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
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
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête admin
                  _buildAdminHeader(),
                  const SizedBox(height: 24),

                  // Statistiques
                  Text(
                    'Statistiques de la plateforme',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  AdminStatsWidget(
                    totalUsers: _totalUsers,
                    totalMerchants: _totalMerchants,
                    activeMerchants: _activeMerchants,
                    totalRevenue: _totalRevenue,
                    totalTransactions: _totalTransactions,
                    pendingVerifications: _pendingVerifications,
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

                  // Gestion des marchands
                  Text(
                    'Gestion des marchands',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  MerchantTableWidget(
                    merchants: _merchants,
                    onVerify: _verifyMerchant,
                    onSuspend: _suspendMerchant,
                    onViewDetails: _viewMerchantDetails,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAdminHeader() {
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
              _admin.name[0],
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
                  _admin.name,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _admin.roleText,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dernière connexion: ${_formatDate(_admin.lastLoginAt)}',
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          title: 'Vérifications',
          subtitle: '$_pendingVerifications en attente',
          icon: Icons.verified_user,
          color: Colors.orange,
          onTap: _showPendingVerifications,
        ),
        _buildActionCard(
          title: 'Rapports',
          subtitle: 'Générer des rapports',
          icon: Icons.assessment,
          color: Colors.blue,
          onTap: _generateReports,
        ),
        _buildActionCard(
          title: 'Utilisateurs',
          subtitle: 'Gérer les utilisateurs',
          icon: Icons.people,
          color: AppColors.primary,
          onTap: _manageUsers,
        ),
        _buildActionCard(
          title: 'Support',
          subtitle: 'Tickets support',
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
            onPressed: () {
              // Logique de vérification
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${merchant.businessName} a été vérifié'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );
  }

  void _suspendMerchant(MerchantAuthModel merchant) {
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
              // Logique de suspension
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${merchant.businessName} a été suspendu'),
                  backgroundColor: Colors.red,
                ),
              );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${merchant.email}'),
            Text('Téléphone: ${merchant.phone}'),
            Text('Adresse: ${merchant.address}'),
            Text('Statut: ${merchant.isVerified ? "Vérifié" : "En attente"}'),
            Text('Inscrit le: ${_formatDate(merchant.createdAt)}'),
          ],
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notifications')));
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
              Navigator.pushReplacementNamed(context, '/admin/login');
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showPendingVerifications() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vérifications en attente')));
  }

  void _generateReports() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Génération de rapports')));
  }

  void _manageUsers() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gestion des utilisateurs')));
  }

  void _showSupportTickets() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tickets de support')));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute}';
  }
}
