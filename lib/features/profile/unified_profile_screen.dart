import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/core/security/access_control_widget.dart';
import 'package:locacharge/core/security/rbac_constants.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/features/user/screens/cgu_screen.dart';

class UnifiedProfileScreen extends StatefulWidget {
  const UnifiedProfileScreen({super.key});

  @override
  State<UnifiedProfileScreen> createState() => _UnifiedProfileScreenState();
}

class _UnifiedProfileScreenState extends State<UnifiedProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Profil',
        showLogo: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [Icon(Icons.person, color: Colors.white)],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) return const LoadingIndicator();

          // Determine type and available profiles
          final user = authProvider.appUserProfile;
          final merchant = authProvider.merchantProfile;
          final userType = authProvider.userType;

          // If no profile available, show error
          if (user == null && merchant == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Text(
                  'Profil non disponible.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1,
                ),
              ),
            );
          }

          // Render appropriate content
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              if (userType == UserType.user) _buildUserProfile(user!),
              if (userType == UserType.merchant) _buildMerchantProfile(merchant!),
              if (userType == UserType.admin) _buildAdminProfile(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfile(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? 'Utilisateur', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(user.email ?? '', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _ActionsSection(),
      ],
    );
  }

  Widget _buildMerchantProfile(dynamic merchant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: merchant.profileImageUrl != null ? NetworkImage(merchant.profileImageUrl) : null,
                child: merchant.profileImageUrl == null
                    ? Text(
                        merchant.businessName.isNotEmpty ? merchant.businessName[0].toUpperCase() : 'M',
                        style: AppTextStyles.h1.copyWith(fontSize: 36, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(merchant.businessName, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(merchant.email, style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.paddingS),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier le profil'),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editMerchantProfile, arguments: merchant),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        _buildSection(title: 'Informations du Commerce', children: [
          _buildInfoTile(icon: Icons.store, title: 'Nom du commerce', value: merchant.businessName),
          _buildInfoTile(icon: Icons.email_outlined, title: 'Email', value: merchant.email),
          _buildInfoTile(icon: Icons.phone_outlined, title: 'Téléphone', value: merchant.phone ?? ''),
          _buildInfoTile(icon: Icons.location_on_outlined, title: 'Adresse', value: merchant.address ?? ''),
        ]),
        const SizedBox(height: AppDimensions.paddingXL),
        CustomButton(text: 'Se déconnecter', onPressed: () => _showLogoutDialog(context)),
      ],
    );
  }

  Widget _buildAdminProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.paddingM),
        Text('Espace Administrateur', style: AppTextStyles.h2),
        const SizedBox(height: AppDimensions.paddingM),
        CustomButton(text: 'Accéder au dashboard admin', onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard)),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.paddingM, AppDimensions.paddingM, AppDimensions.paddingM, AppDimensions.paddingS),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600)),
            if (trailing != null) trailing,
          ]),
        ),
        const Divider(height: 1, indent: AppDimensions.paddingM, endIndent: AppDimensions.paddingM, color: AppColors.border),
        ...children,
      ]),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)), subtitle: Text(value, style: AppTextStyles.body1));
  }

  void _showLogoutDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await DialogHelper.showLogoutConfirmation(context);
    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }
}

// --- Actions and helper widgets (copied/adapted from user profile) ---
class _ActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Actions'),
          const SizedBox(height: AppDimensions.paddingM),
          // === ACCÈS MARCHAND (Protégé par Permission) ===
          AccessControl(
            permission: AppPermission.accessMerchantDashboard,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: _ActionCard(
                icon: Icons.store_rounded,
                title: 'Espace Marchand',
                subtitle: 'Accéder à votre tableau de bord marchand',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.merchantDashboard);
                },
              ),
            ),
          ),

          // === ACCÈS ADMIN (Protégé par Permission) ===
          AccessControl(
            permission: AppPermission.accessAdminDashboard,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: _ActionCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Espace Admin',
                subtitle: 'Accéder à l\'administration système',
                color: Colors.red,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.adminDashboard);
                },
              ),
            ),
          ),

          _ActionCard(
            icon: Icons.article_rounded,
            title: 'Conditions d\'Utilisation',
            subtitle: 'Lire les CGU de l\'application',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CguScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Text(title, style: AppTextStyles.h2),
      ],
    );
  }
}
