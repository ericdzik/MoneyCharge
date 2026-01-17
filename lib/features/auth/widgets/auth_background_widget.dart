import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';

/// Widget de fond pour les écrans d'authentification.
/// Affiche une image avec un overlay vert semi-transparent pour améliorer la lisibilité.
class AuthBackgroundWidget extends StatelessWidget {
  final Widget child;

  const AuthBackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond optimisée avec cache
          Image.asset(
            'assets/images/auth-background-image.png',
            fit: BoxFit.cover,
            cacheWidth: 1080,
            cacheHeight: 1920,
            errorBuilder: (context, error, stackTrace) {
              // Fallback: fond uni si l'image ne charge pas
              return Container(color: AppColors.primary);
            },
          ),

          // Overlay vert semi-transparent pour améliorer la lisibilité du contenu
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),

          // Contenu principal
          child,
        ],
      ),
    );
  }
}
