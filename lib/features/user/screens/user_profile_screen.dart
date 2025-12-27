import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/unified_sliver_app_bar.dart';
import 'package:locacharge/features/user/screens/cgu_screen.dart';
import 'package:locacharge/features/user/models/user_model.dart';
import 'package:locacharge/providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final bool showBackground;

  const UserProfileScreen({super.key, this.showBackground = true});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _headerOpacity = 0.0;

  Widget _buildUserAvatar(User user) {
    final imageUrl = user.profileImageUrl ?? '';

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.person,
          size: 50,
          color: AppColors.primary,
        ),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CachedNetworkImage(
            imageUrl: normalizeFirebaseStorageUrl(imageUrl),
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    setState(() {
      _headerOpacity = (_scrollController.offset / 120).clamp(0.0, 1.0);
    });
  }

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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.appUserProfile;

          if (authProvider.isLoading && user == null) {
            return const LoadingIndicator();
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

          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
              UnifiedSliverAppBar(
                opacity: _headerOpacity,
                title: 'Mon profil',
                subtitle: user.email,
                icon: Icons.person_rounded,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingL),
                    // Avatar utilisateur
                    _buildUserAvatar(user),
                    const SizedBox(height: AppDimensions.paddingM),
                    // Nom
                    Text(
                      user.name,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    // Email
                    Text(
                      user.email,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    // Bouton modifier profil
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      child: CustomButton(
                        text: 'Modifier le profil',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                            arguments: user,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    _ActionsSection(),
                    const SizedBox(height: AppDimensions.paddingL),
                    _DeleteAccountButton(
                      onDelete: () => _showDeleteAccountDialog(context),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await DialogHelper.showConfirmation(
      context,
      title: 'Supprimer le compte',
      message:
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
      confirmText: 'Supprimer',
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      SnackBarHelper.showWarning(
        context,
        'La fonctionnalité de suppression de compte nécessite une implémentation backend et une gestion de la réauthentification.',
      );
    }
  }
}

// ============================================================================
// MODERN UI WIDGETS
// ============================================================================

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
          _ActionCard(
            icon: Icons.article_rounded,
            title: 'Conditions d\'Utilisation',
            subtitle: 'Lire les CGU de l\'application',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CguScreen(),
                ),
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
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
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

class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteAccountButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: OutlinedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('Supprimer mon compte'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
      ),
    );
  }
}
