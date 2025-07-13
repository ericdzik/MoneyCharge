import 'package:flutter/material.dart';

// Version alternative avec Image.asset au lieu de DecorationImage
class AlternativeAuthBackgroundWidget2 extends StatelessWidget {
  final Widget child;

  const AlternativeAuthBackgroundWidget2({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond avec Image.asset
          Positioned.fill(
            child: Image.asset('assets/splash/25.png', fit: BoxFit.cover),
          ),
          // Contenu principal
          child,
        ],
      ),
    );
  }
}
