import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profil Commerçant',
        showLogo: false,
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final merchant = authProvider.merchantProfile;

          if (authProvider.isLoading && merchant == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (merchant == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Text(
                  "Profil commerçant non disponible ou type d'utilisateur incorrect.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
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
                        backgroundImage: merchant.profileImageUrl != null
                            ? NetworkImage(merchant.profileImageUrl!)
                            : null,
                        child: merchant.profileImageUrl == null
                            ? Text(
                                merchant.businessName.isNotEmpty
                                    ? merchant.businessName[0].toUpperCase()
                                    : 'M',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 36,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        merchant.businessName,
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        merchant.email,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier le profil'),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editMerchantProfile,
                            arguments: merchant,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),

                // Business Info
                _buildSection(
                  title: 'Informations du Commerce',
                  children: [
                    _buildInfoTile(
                      icon: Icons.store,
                      title: 'Nom du commerce',
                      value: merchant.businessName,
                    ),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: merchant.email,
                    ),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Téléphone',
                      value: merchant.phone,
                    ),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Adresse',
                      value: merchant.address,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXL),

                // Actions
                _buildSection(
                  title: 'Actions',
                  children: [
                    _buildActionTile(
                      icon: Icons.history_outlined,
                      title: 'Historique des locations',
                      onTap: () {
                        // TODO: Implement navigation
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.bar_chart_outlined,
                      title: 'Statistiques',
                      onTap: () {
                        // TODO: Implement navigation
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXL),

                CustomButton(
                  text: 'Se déconnecter',
                  onPressed: () => _showLogoutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingM,
              AppDimensions.paddingM,
              AppDimensions.paddingM,
              AppDimensions.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: AppDimensions.paddingM,
            endIndent: AppDimensions.paddingM,
            color: AppColors.border,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: AppTextStyles.body1),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              textStyle: AppTextStyles.button,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
