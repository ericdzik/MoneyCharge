import 'package:flutter/material.dart';

/// Chemin de l'image de fond par défaut de l'application
const String kDefaultBackgroundImage = 'assets/splash/33.png';

class BackgroundImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Color? overlayColor;
  final double overlayOpacity;
  final bool applyGreenOverlay;
  final bool enableCache;

  const BackgroundImage({
    super.key,
    this.imagePath = kDefaultBackgroundImage,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.applyGreenOverlay = false,
    this.enableCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond avec optimisation du cache
        Image.asset(
          imagePath,
          fit: fit,
          cacheWidth: enableCache ? size.width.toInt() : null,
          cacheHeight: enableCache ? size.height.toInt() : null,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error_outline, size: 48, color: Colors.grey),
            ),
          ),
        ),
        
        // Overlay vert transparent
        if (overlayColor != null || applyGreenOverlay)
          Container(
            decoration: BoxDecoration(
              color: _getOverlayColor(),
            ),
          ),
      ],
    );
  }

  Color _getOverlayColor() {
    if (applyGreenOverlay) {
      return const Color.fromRGBO(0, 91, 55, 0.7);
    }
    
    if (overlayColor != null) {
      return overlayColor!.withValues(alpha: overlayOpacity);
    }
    
    return Colors.transparent;
  }
}