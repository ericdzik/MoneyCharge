import 'package:flutter/material.dart';

class AppColors {
  // Fond principal et surfaces
  static const Color background = Color(0xFFE8F5E9); // Vert très clair (nature)
  static const Color surface = Color(0xFFF1F8E9); // Surface plus claire

  // Couleurs principales (rasta)
  static const Color primary = Color(0xFF388E3C); // Vert (espoir, nature)
  static const Color onPrimary = Color(0xFFFFFFFF); // Texte blanc sur primaire

  static const Color secondary = Color(0xFFFFEB3B); // Jaune (soleil, richesse)
  static const Color onSecondary = Color(
    0xFF000000,
  ); // Texte noir sur secondaire

  static const Color accent = Color(0xFFD32F2F); // Rouge (force, lutte)
  static const Color onAccent = Color(0xFFFFFFFF); // Texte blanc sur accent

  // Erreur et états spécifiques
  static const Color error = Color(0xFFB71C1C); // Rouge sombre (erreur)
  static const Color onError = Color(0xFFFFFFFF);

  // Harmonisation : tous les verts métier pointent sur primary
  static const Color success = primary; // Vert succès harmonisé
  static const Color warning = Color(
    0xFFFFC107,
  ); // Jaune orangé (avertissement)

  // Texte
  static const Color textPrimary = Color(0xFF1B1B1B); // Presque noir
  static const Color textSecondary = Color(0xFF616161); // Gris
  static const Color textDisabled = Color(0xFFBDBDBD); // Gris clair

  // Bordures et séparateurs
  static const Color border = Color(0xFF9E9E9E); // Gris
  static const Color divider = Color(0xFFEEEEEE); // Gris très clair

  // Alias métier (stock)
  static const Color available = primary; // Vert succès harmonisé
  static const Color lowStock = warning; // Jaune avertissement
  static const Color outOfStock = error; // Rouge erreur/rupture

  // UI
  static const Color onSurface = textPrimary; // Texte sur surface
}
