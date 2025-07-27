import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/features/user/models/user_model.dart';
import 'package:locacharge/providers/favorite_merchant_provider.dart';
import 'package:locacharge/providers/theme_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';
//intl is not used yet, but good for future date formatting
// import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.userId != null) {
        Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions(authProvider.userId!);
        Provider.of<FavoriteMerchantProvider>(context, listen: false)
            .fetchFavoriteMerchants(authProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          Consumer3<AuthProvider, TransactionProvider, FavoriteMerchantProvider>(
            builder: (context, authProvider, transactionProvider,
                favoriteMerchantProvider, child) {
              final user = authProvider.appUserProfile;

              if (authProvider.isLoading && user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (user == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.paddingL),
                    child: Text(
                      "Profil utilisateur non disponible ou type d'utilisateur incorrect.",
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
                    // En-tête du profil
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
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
                            backgroundImage: user.profileImageUrl != null
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                            child: user.profileImageUrl == null
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 36,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          Text(
                            user.name,
                            style: AppTextStyles.h2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            user.email,
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
                              Navigator.pushNamed(context, AppRoutes.editProfile);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Informations personnelles
                    _buildSection(
                      title: 'Informations personnelles',
                      children: [
                        _buildInfoTile(
                          icon: Icons.person_outline,
                          title: 'Nom complet',
                          value: user.name,
                        ),
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: user.email,
                        ),
                        _buildInfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Téléphone',
                          value: user.phone ?? 'Non renseigné',
                        ),
                        // _buildInfoTile(
                        //   icon: Icons.calendar_today_outlined,
                        //   title: 'Membre depuis',
                        //   value: _formatDate(user.createdAt),
                        // ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Statistiques
                    _buildSection(
                      title: 'Mes statistiques',
                      children: [
                        _buildStatTile(
                          icon: Icons.location_on_outlined,
                          title: 'Locations effectuées',
                          value: transactionProvider.transactions.length.toString(),
                          color: AppColors.primary,
                        ),
                        _buildStatTile(
                          icon: Icons.star_outline,
                          title: 'Note moyenne',
                          value: 'N/A', // TODO: Implement rating system
                          color: AppColors.secondary,
                        ),
                        _buildStatTile(
                          icon: Icons.favorite_border_outlined,
                          title: 'Favoris',
                          value: favoriteMerchantProvider.favoriteMerchants.length.toString(),
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Actions
                    _buildSection(
                      title: 'Actions',
                      children: [
                        SwitchListTile(
                          title: const Text('Mode sombre'),
                          value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.history_outlined,
                          title: 'Historique des locations',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.rentalHistory,
                            );
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.favorite_border_outlined,
                          title: 'Mes favoris',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.favorites);
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.help_outline,
                          title: 'Aide et support',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.help);
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Confidentialité',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.privacy);
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.info_outline,
                          title: 'À propos',
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.about);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    CustomButton(
                      text: 'Se déconnecter',
                      onPressed: () => _showLogoutDialog(context),
                      // No explicit color parameter needed, type: ButtonType.primary is default
                      // and will use ElevatedButtonThemeData from app_theme.dart
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    Center(
                      child: TextButton(
                        onPressed: () => _showDeleteAccountDialog(context),
                        child: Text(
                          'Supprimer mon compte',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.outOfStock,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                  ],
                ),
              );
            },
          ),
        ],
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
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) Flexible(child: trailing),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: AppDimensions.paddingM,
            endIndent: AppDimensions.paddingM,
            color: AppColors.border,
          ),
          ...children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXS,
                  ),
                  child: child,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppDimensions.paddingM),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTextStyles.body1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body2,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.h3.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body1,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    // Using a more robust date formatting. Consider intl package for localization.
    // For DD/MM/YYYY format:
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
              backgroundColor:
                  AppColors.primary, // This will be applied by the theme
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement full account deletion:
              // 1. User Re-authentication: Securely re-authenticate the user (Firebase requires this for account deletion).
              // 2. Firebase Auth Deletion: Call a method in AuthService/AuthProvider to delete the user from Firebase Authentication.
              // 3. Backend Data Deletion: Trigger a Cloud Function (or other backend mechanism) to:
              //    a. Delete the user's document from the 'users' collection in Firestore.
              //    b. Delete any other user-associated data (e.g., rental history, favorites, specific settings) from Firestore or other storage.
              //    c. Handle any cascading deletes or cleanup tasks.
              // 4. Client-side Navigation: Navigate the user to the login screen or splash screen.
              // 5. User Feedback: Provide clear feedback to the user about the process and success/failure.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La fonctionnalité de suppression de compte nécessite une implémentation backend et une gestion de la réauthentification.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.outOfStock, // Destructive action color
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              textStyle: AppTextStyles.button,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
