import 'package:flutter/material.dart';

/// Widget pour afficher une image de fond avec overlay optionnel
///
/// Ce widget gère intelligemment l'affichage d'images de fond avec :
/// - Gestion d'erreurs robuste
/// - Support des overlays colorés
/// - Optimisation du cache pour les performances
/// - Fallback vers une couleur unie si l'image n'existe pas
class BackgroundImage extends StatelessWidget {
  /// Chemin de l'image à afficher (optionnel)
  /// Si null ou vide, affiche une couleur de fond unie
  final String? imagePath;

  /// Mode d'ajustement de l'image
  final BoxFit fit;

  /// Couleur de l'overlay (optionnel)
  final Color? overlayColor;

  /// Opacité de l'overlay (0.0 à 1.0)
  final double overlayOpacity;

  /// Si true, applique un overlay vert spécifique au projet
  final bool applyGreenOverlay;

  /// Active le cache des images pour améliorer les performances
  final bool enableCache;

  /// Couleur de fond de secours si l'image ne charge pas
  final Color fallbackColor;

  const BackgroundImage({
    super.key,
    this.imagePath,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.applyGreenOverlay = false,
    this.enableCache = true,
    this.fallbackColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Si pas d'image spécifiée, afficher uniquement la couleur de fond
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildFallback();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond avec gestion d'erreur
        Image.asset(
          imagePath!,
          fit: fit,
          cacheWidth: enableCache ? size.width.toInt() : null,
          cacheHeight: enableCache ? size.height.toInt() : null,
          errorBuilder: (context, error, stackTrace) {
            // En cas d'erreur, afficher le fallback
            return _buildFallback();
          },
        ),

        // Overlay coloré (si spécifié)
        if (overlayColor != null || applyGreenOverlay)
          Container(decoration: BoxDecoration(color: _getOverlayColor())),
      ],
    );
  }

  /// Construit le widget de secours (couleur unie)
  Widget _buildFallback() {
    return Container(
      color: fallbackColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Overlay si spécifié
          if (overlayColor != null || applyGreenOverlay)
            Container(decoration: BoxDecoration(color: _getOverlayColor())),
        ],
      ),
    );
  }

  /// Calcule la couleur de l'overlay
  Color _getOverlayColor() {
    if (applyGreenOverlay) {
      // Overlay vert spécifique au projet
      return const Color.fromRGBO(0, 91, 55, 0.7);
    }

    if (overlayColor != null) {
      return overlayColor!.withValues(alpha: overlayOpacity);
    }

    return Colors.transparent;
  }
}
