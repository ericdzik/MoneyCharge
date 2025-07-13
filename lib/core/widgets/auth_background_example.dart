import 'package:flutter/material.dart';
import 'auth_background_widget.dart';

/// Exemple d'utilisation du widget AuthBackgroundWidget
///
/// Ce fichier montre différentes façons d'utiliser le widget de background
/// pour les écrans d'authentification.
class AuthBackgroundExample extends StatelessWidget {
  const AuthBackgroundExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AlternativeAuthBackgroundWidget2(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple Auth Background'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Exemple d\'utilisation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Ce widget utilise l\'image 25.png\ncomme background pour tous les écrans d\'authentification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exemple avec personnalisation du gradient
class AuthBackgroundCustomExample extends StatelessWidget {
  const AuthBackgroundCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AlternativeAuthBackgroundWidget2(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple Personnalisé'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Background avec overlay personnalisé',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Exemple avec le widget CustomAuthBackgroundWidget
class CustomAuthBackgroundExample extends StatelessWidget {
  const CustomAuthBackgroundExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AlternativeAuthBackgroundWidget2(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple Custom'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Background avec options personnalisées',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
