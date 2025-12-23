import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/background_image_widget.dart';

/// Configuration pour personnaliser l'apparence du fond dans ScaffoldWithBackground
class BackgroundConfig {
  /// Chemin de l'image de fond (défaut: image par défaut)
  final String imagePath;

  /// Couleur de l'overlay (défaut: transparent)
  final Color? overlayColor;

  /// Opacité de l'overlay (0.0 à 1.0, défaut: 0.0)
  final double overlayOpacity;

  /// Si true, applique un overlay vert personnalisé du projet
  final bool applyGreenOverlay;

  /// Activation du cache des images (améliore les performances)
  final bool enableCache;

  /// Ajustement du fit de l'image
  final BoxFit imageFit;

  const BackgroundConfig({
    this.imagePath = kDefaultBackgroundImage,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.applyGreenOverlay = false,
    this.enableCache = true,
    this.imageFit = BoxFit.cover,
  });

  /// Configuration avec overlay sombre (effet darkened)
  factory BackgroundConfig.darkened({
    String imagePath = kDefaultBackgroundImage,
    double opacity = 0.3,
  }) {
    return BackgroundConfig(
      imagePath: imagePath,
      overlayColor: Colors.black,
      overlayOpacity: opacity,
      enableCache: true,
    );
  }

  /// Configuration avec overlay vert du projet
  factory BackgroundConfig.withGreenOverlay({
    String imagePath = kDefaultBackgroundImage,
  }) {
    return BackgroundConfig(
      imagePath: imagePath,
      applyGreenOverlay: true,
      enableCache: true,
    );
  }

  /// Configuration sans fond (transparent)
  factory BackgroundConfig.none() {
    return const BackgroundConfig(
      imagePath: '',
      enableCache: false,
    );
  }

  /// Copier avec modifications
  BackgroundConfig copyWith({
    String? imagePath,
    Color? overlayColor,
    double? overlayOpacity,
    bool? applyGreenOverlay,
    bool? enableCache,
    BoxFit? imageFit,
  }) {
    return BackgroundConfig(
      imagePath: imagePath ?? this.imagePath,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      applyGreenOverlay: applyGreenOverlay ?? this.applyGreenOverlay,
      enableCache: enableCache ?? this.enableCache,
      imageFit: imageFit ?? this.imageFit,
    );
  }
}

/// Scaffold avec gestion professionnelle des images de fond
///
/// Encapsule la logique commune de Stack + BackgroundImage + ColorFiltered
/// pour éviter la duplication dans les écrans.
///
/// Exemple d'usage simple :
/// ```dart
/// ScaffoldWithBackground(
///   appBar: AppBar(title: Text('Screen')),
///   body: Center(child: Text('Contenu')),
/// )
/// ```
///
/// Exemple avec configuration avancée :
/// ```dart
/// ScaffoldWithBackground(
///   backgroundConfig: BackgroundConfig.darkened(opacity: 0.4),
///   appBar: CustomAppBar(title: 'Mon Écran'),
///   body: MyContent(),
/// )
/// ```
class ScaffoldWithBackground extends StatelessWidget {
  /// Configuration du fond (optionnel)
  final BackgroundConfig backgroundConfig;

  /// AppBar standard ou CustomAppBar
  final PreferredSizeWidget? appBar;

  /// Contenu principal du Scaffold
  final Widget body;

  /// Drawer (optionnel)
  final Widget? drawer;

  /// BottomNavigationBar (optionnel)
  final Widget? bottomNavigationBar;

  /// FloatingActionButton (optionnel)
  final FloatingActionButton? floatingActionButton;

  /// Couleur de fond du Scaffold (défaut: transparent si background affichée)
  final Color? backgroundColor;

  /// Comportement du Scaffold en cas d'action de l'utilisateur
  final bool resizeToAvoidBottomInset;

  const ScaffoldWithBackground({
    super.key,
    this.backgroundConfig = const BackgroundConfig(),
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  /// Version sans fond
  const ScaffoldWithBackground.noBackground({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : backgroundConfig = const BackgroundConfig(imagePath: '');

  /// Version avec overlay sombre (populaire pour les écrans clairs)
  ScaffoldWithBackground.darkened({
    super.key,
    double overlayOpacity = 0.3,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : backgroundConfig = BackgroundConfig.darkened(opacity: overlayOpacity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor ?? Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
          // Fond (uniquement si imagePath n'est pas vide)
          if (backgroundConfig.imagePath.isNotEmpty)
            Positioned.fill(
              child: BackgroundImage(
                imagePath: backgroundConfig.imagePath,
                fit: backgroundConfig.imageFit,
                overlayColor: backgroundConfig.overlayColor,
                overlayOpacity: backgroundConfig.overlayOpacity,
                applyGreenOverlay: backgroundConfig.applyGreenOverlay,
                enableCache: backgroundConfig.enableCache,
              ),
            ),
          // Contenu
          body,
        ],
      ),
    );
  }
}
