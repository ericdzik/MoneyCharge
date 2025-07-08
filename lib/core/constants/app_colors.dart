import 'package:flutter/material.dart';

class AppColors {
  // Nouvelle palette de couleurs
  // Beige comme couleur de fond principale, et pour les surfaces.
  static const Color background = Color(0xFFF5F5DC); // Beige
  static const Color surface = Color(0xFFFFF8E1); // Beige clair (pourrait être utilisé pour les cartes)

  // Vert comme couleur primaire pour les actions positives et la navigation.
  static const Color primary = Color(0xFF2E7D32); // Vert foncé (pour le branding, boutons primaires)
  static const Color onPrimary = Color(0xFFFFFFFF); // Texte sur couleur primaire

  // Orange comme couleur secondaire ou d'accentuation.
  static const Color secondary = Color(0xFFFFA726); // Orange
  static const Color onSecondary = Color(0xFF000000); // Texte sur couleur secondaire

  // Rouge pour les erreurs, alertes, et actions destructives.
  static const Color error = Color(0xFFD32F2F); // Rouge
  static const Color onError = Color(0xFFFFFFFF); // Texte sur couleur d'erreur

  // Autres couleurs utiles
  static const Color success = Color(0xFF388E3C); // Vert pour succès (peut être le même que primary ou une nuance)
  static const Color warning = Color(0xFFFBC02D); // Jaune/Orange pour avertissements (peut être secondary ou une nuance)

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121); // Noir doux pour le texte principal
  static const Color textSecondary = Color(0xFF757575); // Gris pour le texte secondaire
  static const Color textDisabled = Color(0xFFBDBDBD); // Gris clair pour le texte désactivé

  // Bordures et séparateurs
  static const Color border = Color(0xFFBDBDBD); // Gris pour les bordures
  static const Color divider = Color(0xFFE0E0E0); // Gris clair pour les séparateurs

  // Couleurs spécifiques aux états (si nécessaire, peuvent reprendre les couleurs ci-dessus)
  static const Color available = success; // Vert pour disponible
  static const Color lowStock = warning;  // Orange/Jaune pour stock bas
  static const Color outOfStock = error;  // Rouge pour hors stock

  // Couleurs pour l'interface utilisateur (onSurface, etc.)
  static const Color onSurface = Color(0xFF212121); // Texte sur les surfaces (comme `surface` ou `background`)
}