import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/services/navigation_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.appUserProfile;
              final merchant = authProvider.merchantProfile;
              final isMerchant = authProvider.userType == UserType.merchant;

              return Column(
                children: [
                  // Header avec profil
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      children: [
                        // Avatar avec bouton d'édition
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, AppRoutes.userProfile);
                              },
                              child: CircleAvatar(
                                radius: 40.0,
                                backgroundImage: (isMerchant
                                        ? merchant?.profileImageUrl
                                        : user?.profileImageUrl) != null
                                    ? NetworkImage(isMerchant
                                        ? merchant!.profileImageUrl!
                                        : user!.profileImageUrl!)
                                    : null,
                                child: (isMerchant
                                            ? merchant?.profileImageUrl
                                            : user?.profileImageUrl) ==
                                        null
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            // Bouton d'édition
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, AppRoutes.editProfile);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingM),

                        // Nom
                        Text(
                          isMerchant
                              ? merchant?.businessName ?? 'Marchand'
                              : user?.name ?? 'Utilisateur',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),

                        // Email
                        Text(
                          isMerchant
                              ? merchant?.email ?? ''
                              : user?.email ?? '',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Téléphone
                        if ((isMerchant ? merchant?.phone : user?.phone) != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimensions.paddingXS,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isMerchant
                                      ? merchant?.phone ?? ''
                                      : user?.phone ?? '',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white30, thickness: 1),

                  // Menu items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          context,
                          icon: Icons.home,
                          title: 'Accueil',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.home);
                          },
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.person,
                          title: 'Mon Profil',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.userProfile);
                          },
                        ),
                        if (!isMerchant)
                          _buildDrawerItem(
                            context,
                            icon: Icons.favorite,
                            title: 'Mes Favoris',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, AppRoutes.favorites);
                            },
                          ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.help,
                          title: 'Aide & Support',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.help);
                          },
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.privacy_tip,
                          title: 'Confidentialité',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.privacy);
                          },
                        ),
                        _buildDrawerItem(
                          context,
                          icon: Icons.info,
                          title: 'À propos',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.about);
                          },
                        ),

                        const Divider(color: Colors.white30, thickness: 1),
                      ],
                    ),
                  ),

                  // Déconnexion
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final confirmed = await DialogHelper.showLogoutConfirmation(context);
                        if (confirmed == true) {
                          await authProvider.logout();
                          final navigator = NavigationService.navigatorKey.currentState;
                          navigator?.pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Déconnexion',
                        style: AppTextStyles.button.copyWith(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.2),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                          horizontal: AppDimensions.paddingL,
                        ),
                        backgroundColor: Colors.white10,
                      ).merge(
                        ButtonStyle(
                          overlayColor: WidgetStateProperty.all(Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white12,
    );
  }
}
