import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/widgets/background_image_widget.dart';

/// Widget de fond pour les écrans d'authentification.
/// Affiche une image avec un overlay vert semi-transparent pour améliorer la lisibilité.
class AuthBackgroundWidget extends StatefulWidget {
  final Widget child;

  const AuthBackgroundWidget({super.key, required this.child});

  @override
  State<AuthBackgroundWidget> createState() => _AuthBackgroundWidgetState();
}

class _AuthBackgroundWidgetState extends State<AuthBackgroundWidget> {
  static const String _bgAsset = 'assets/images/auth-background-image.png';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précache pour éviter le clignotement et les chargements lents
    precacheImage(const AssetImage(_bgAsset), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond optimisée avec cache + overlay vert
          const BackgroundImage(
            imagePath: _bgAsset,
            fit: BoxFit.cover,
            applyGreenOverlay: true,
            fallbackColor: AppColors.primary,
          ),

          // Contenu principal
          widget.child,
        ],
      ),
    );
  }
}
