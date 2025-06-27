import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/color_utils.dart';

/// Widget d'erreur réutilisable
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool showRetry;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.outOfStock.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: AppColors.outOfStock,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              title,
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Boutons d'action
            if (showRetry || actionText != null)
              Column(
                children: [
                  if (showRetry)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ),
                  if (showRetry && actionText != null)
                    const SizedBox(height: 12),
                  if (actionText != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onAction,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(actionText!),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget d'erreur de réseau
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Erreur de connexion',
      message: 'Vérifiez votre connexion internet et réessayez.',
      onAction: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

/// Widget d'erreur de chargement
class LoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const LoadingErrorWidget({
    super.key,
    this.message = 'Impossible de charger les données.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Erreur de chargement',
      message: message,
      onAction: onRetry,
      icon: Icons.cloud_off,
    );
  }
}

/// Widget d'erreur d'authentification
class AuthErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const AuthErrorWidget({super.key, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Session expirée',
      message: 'Votre session a expiré. Veuillez vous reconnecter.',
      actionText: 'Se connecter',
      onAction: onLogin,
      icon: Icons.lock_outline,
      showRetry: false,
    );
  }
}

/// Widget d'erreur de permission
class PermissionErrorWidget extends StatelessWidget {
  final String permission;
  final VoidCallback? onGrant;

  const PermissionErrorWidget({
    super.key,
    required this.permission,
    this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Permission requise',
      message: 'Cette fonctionnalité nécessite l\'accès à $permission.',
      actionText: 'Accorder la permission',
      onAction: onGrant,
      icon: Icons.security,
      showRetry: false,
    );
  }
}

/// Widget d'erreur générique
class GenericErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const GenericErrorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Une erreur s\'est produite',
      message: error,
      onAction: onRetry,
      icon: Icons.error_outline,
    );
  }
}
