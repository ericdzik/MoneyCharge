import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Accéder au profil utilisateur spécifique pour les utilisateurs standards
          final user = authProvider.appUserProfile;

          if (authProvider.isLoading && user == null) { // Afficher le chargement si user est null et qu'on charge encore
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            // Gérer le cas où l'utilisateur n'est pas un 'user' ou profil non trouvé
            // Peut-être rediriger ou afficher un message d'erreur plus spécifique
            return const Center(
              child: Text("Profil utilisateur non disponible ou type d'utilisateur incorrect."),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête du profil
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nom et email
                      Text(
                        user.name,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Statut du compte
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Compte vérifié',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations personnelles
                _buildSection(
                  title: 'Informations personnelles',
                  children: [
                    _buildInfoTile(
                      icon: Icons.person,
                      title: 'Nom complet',
                      value: user.name,
                    ),
                    _buildInfoTile(
                      icon: Icons.email,
                      title: 'Email',
                      value: user.email,
                    ),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: 'Téléphone',
                      value: user.phone ?? 'Non renseigné',
                    ),
                    _buildInfoTile(
                      icon: Icons.calendar_today,
                      title: 'Membre depuis',
                      value: _formatDate(user.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistiques
                _buildSection(
                  title: 'Mes statistiques',
                  children: [
                    _buildStatTile(
                      icon: Icons.location_on,
                      title: 'Locations effectuées',
                      value: '12',
                      color: AppColors.primary,
                    ),
                    _buildStatTile(
                      icon: Icons.star,
                      title: 'Note moyenne',
                      value: '4.8/5',
                      color: AppColors.secondary,
                    ),
                    _buildStatTile(
                      icon: Icons.favorite,
                      title: 'Favoris',
                      value: '8',
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                _buildSection(
                  title: 'Actions',
                  children: [
                    _buildActionTile(
                      icon: Icons.history,
                      title: 'Historique des locations',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.rentalHistory);
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.favorite,
                      title: 'Mes favoris',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.favorites);
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.help,
                      title: 'Aide et support',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.help);
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.privacy_tip,
                      title: 'Confidentialité',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.privacy);
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.info,
                      title: 'À propos',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.about);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Bouton de déconnexion
                CustomButton(
                  text: 'Se déconnecter',
                  onPressed: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 16),

                // Supprimer le compte
                TextButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  child: Text(
                    'Supprimer mon compte',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.outOfStock,
                    ),
                  ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: AppTextStyles.h3),
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
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        title,
        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      ),
      subtitle: Text(value, style: AppTextStyles.body1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body2),
      subtitle: Text(value, style: AppTextStyles.h3.copyWith(color: color)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression du compte
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.outOfStock),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
