import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/features/auth/models/admin_model.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AdminModel? admin;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  const AdminAppBar({
    super.key,
    required this.admin,
    required this.isLoading,
    required this.onRefresh,
    required this.onNotifications,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Première ligne : Titre et actions
              SizedBox(
                height: 46,
                child: Row(
                  children: [
                    Text(
                      'Dashboard Admin',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 21),
                      tooltip: 'Rafraîchir',
                      onPressed: onRefresh,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white, size: 21),
                      tooltip: 'Notifications',
                      onPressed: onNotifications,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 21),
                      tooltip: 'Déconnexion',
                      onPressed: onLogout,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Deuxième ligne : Informations admin
              SizedBox(
                height: 44,
                child: _buildAdminInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminInfo() {
    if (isLoading) {
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement...',
            style: AppTextStyles.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
        ],
      );
    }

    if (admin == null) {
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Profil non disponible',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Avatar plus grand
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              admin!.name.isNotEmpty ? admin!.name[0].toUpperCase() : 'A',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Informations admin
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Première ligne : Nom + Badge
              Row(
                children: [
                  Flexible(
                    child: Text(
                      admin!.name,
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      admin!.roleText,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Deuxième ligne : Dernière connexion
              Text(
                'Connexion: ${_formatDate(admin!.lastLoginAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Indicateur de statut plus grand
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Jamais';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(114); // Ajusté pour correspondre au contenu réel
}