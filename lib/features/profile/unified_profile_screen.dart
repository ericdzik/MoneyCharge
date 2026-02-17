import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/core/security/access_control_widget.dart';
import 'package:locacharge/core/security/rbac_constants.dart';
import 'package:locacharge/features/user/screens/cgu_screen.dart';
import 'package:locacharge/features/auth/widgets/delete_account_dialog.dart';

class UnifiedProfileScreen extends StatefulWidget {
  const UnifiedProfileScreen({super.key});

  @override
  State<UnifiedProfileScreen> createState() => _UnifiedProfileScreenState();
}

class _UnifiedProfileScreenState extends State<UnifiedProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTrackingPosition = false;
  Timer? _positionUpdateTimer;

  @override
  void dispose() {
    _scrollController.dispose();
    _positionUpdateTimer?.cancel();
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
        // Carte de profil avec photo
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
                backgroundColor: AppColors.primary,
                backgroundImage: user.profileImageUrl != null 
                    ? NetworkImage(user.profileImageUrl) 
                    : null,
                child: user.profileImageUrl == null
                    ? Text(
                        user.name != null && user.name.isNotEmpty 
                            ? user.name[0].toUpperCase() 
                            : 'U',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 36, 
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                user.name ?? 'Utilisateur',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                user.email ?? '',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (user.phone != null && user.phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      user.phone,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimensions.paddingS),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier le profil'),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editProfile,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _ActionsSection(),
        const SizedBox(height: AppDimensions.paddingXL),
        _buildDeleteAccountButton(),
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: merchant.profileImageUrl != null 
                        ? NetworkImage(merchant.profileImageUrl) 
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
                  // Badge vérifié
                  if (merchant.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      merchant.businessName,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (merchant.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                  if (merchant.isPremium) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                merchant.email,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              // Note moyenne et nombre d'avis
              if (merchant.reviewCount > 0) ...[
                const SizedBox(height: AppDimensions.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      merchant.averageRating.toStringAsFixed(1),
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${merchant.reviewCount} avis)',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimensions.paddingS),
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier le profil'),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editMerchantProfile,
                  arguments: merchant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _buildLiveLocationCard(),
        const SizedBox(height: AppDimensions.paddingL),
        
        // Services proposés
        if (merchant.services != null && merchant.services.isNotEmpty)
          _buildSection(
            title: 'Services Proposés',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: merchant.services.map<Widget>((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        
        if (merchant.services != null && merchant.services.isNotEmpty)
          const SizedBox(height: AppDimensions.paddingL),
        
        // Horaires d'ouverture
        if (merchant.openingHours != null && merchant.openingHours.isNotEmpty)
          _buildSection(
            title: 'Horaires d\'Ouverture',
            children: _buildOpeningHoursList(merchant.openingHours),
          ),
        
        if (merchant.openingHours != null && merchant.openingHours.isNotEmpty)
          const SizedBox(height: AppDimensions.paddingL),
        
        // Informations du commerce
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
              value: merchant.phone ?? '',
            ),
            _buildInfoTile(
              icon: Icons.location_on_outlined,
              title: 'Adresse',
              value: merchant.address ?? '',
            ),
            _buildInfoTile(
              icon: Icons.category_outlined,
              title: 'Type',
              value: merchant.merchantType ?? 'Boutique',
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        CustomButton(
          text: 'Se déconnecter',
          onPressed: () => _showLogoutDialog(context),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        _buildDeleteAccountButton(),
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
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: AppTextStyles.body1),
    );
  }

  Widget _buildLiveLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isTrackingPosition
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: _isTrackingPosition ? AppColors.success : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suivi de la Position', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    _isTrackingPosition
                        ? 'Activé - Visible par les clients'
                        : 'Désactivé - Invisible',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isTrackingPosition,
              onChanged: _togglePositionTracking,
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  void _togglePositionTracking(bool value) async {
    if (!mounted) return;

    if (value) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackBarHelper.showWarning(
            context,
            'La permission de localisation est requise pour activer le suivi.',
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isTrackingPosition = true;
        });
        _positionUpdateTimer = Timer.periodic(const Duration(seconds: 30), (
          timer,
        ) {
          if (mounted) {
            _updatePositionInFirestore();
          } else {
            timer.cancel();
          }
        });
        _updatePositionInFirestore();
      }
    } else {
      if (mounted) {
        setState(() {
          _isTrackingPosition = false;
        });
      }
      _positionUpdateTimer?.cancel();
    }
  }

  Future<void> _updatePositionInFirestore() async {
    if (!mounted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userId != null && mounted) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.userId)
            .update({
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
      }
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la position: $e");
    }
  }

  void _showLogoutDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await DialogHelper.showLogoutConfirmation(context);
    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  List<Widget> _buildOpeningHoursList(Map<String, dynamic> openingHours) {
    final days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return days.map((day) {
      if (openingHours.containsKey(day) && openingHours[day] is Map) {
        final hours = openingHours[day];
        final open = hours['open'] ?? '';
        final close = hours['close'] ?? '';
        
        return ListTile(
          leading: Icon(
            Icons.access_time,
            color: AppColors.primary,
            size: 20,
          ),
          title: Text(
            day,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            '$open - $close',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          dense: true,
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleDeleteAccount,
        icon: const Icon(Icons.delete_forever, size: 20),
        label: const Text('Supprimer mon compte'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Afficher le dialog de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DeleteAccountDialog(),
    );

    if (confirmed != true || !mounted) return;

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: LoadingIndicator()),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteAccount();

      if (!mounted) return;

      // Fermer le loader
      Navigator.of(context).pop();

      if (success) {
        // Afficher un message de succès
        SnackBarHelper.showSuccess(
          context,
          'Votre compte a été supprimé avec succès.',
        );

        // Rediriger vers la page de connexion
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } else {
        // Afficher l'erreur
        final error = authProvider.error ?? 'Une erreur est survenue.';
        SnackBarHelper.showError(context, error);
      }
    } catch (e) {
      if (!mounted) return;

      // Fermer le loader
      Navigator.of(context).pop();

      // Afficher l'erreur
      SnackBarHelper.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
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
