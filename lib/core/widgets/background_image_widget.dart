import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Color? overlayColor;
  final double overlayOpacity;

  const BackgroundImage({
    super.key,
    this.imagePath = 'assets/splash/33.png',
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
          ),
        ),
        if (overlayColor != null)
          Container(
            color: overlayColor!.withOpacity(overlayOpacity),
          ),
      ],
    );
  }
}