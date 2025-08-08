import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales fournies
  static const Color primary = Color(0xFF1E3A8A); // Bleu principal
  static const Color primaryLight = Color(0xFF1D4ED8); // Bleu royal (alternative)

  // Dégradé jaune/orange
  static const Color yellow = Color(0xFFFBBF24); // Jaune
  static const Color orange = Color(0xFFF59E0B); // Orange/jaune foncé

  // Blanc
  static const Color white = Color(0xFFFFFFFF);

  // Nuances modernes basées sur les couleurs principales
  static const Color primaryDark = Color(0xFF1E40AF); // Bleu plus foncé
  static const Color primaryLighter = Color(0xFF3B82F6); // Bleu plus clair
  static const Color primaryMuted = Color(0xFF1E3A8A); // Bleu avec opacité

  // Dégradé jaune/orange étendu
  static const Color yellowLight = Color(0xFFFCD34D); // Jaune plus clair
  static const Color orangeDark = Color(0xFFD97706); // Orange plus foncé

  // Gris et neutres
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Couleurs sémantiques
  static const Color success = Color(0xFF10B981); // Vert moderne
  static const Color error = Color(0xFFEF4444); // Rouge moderne
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color info = Color(0xFF3B82F6); // Bleu info

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF111827); // Gris très foncé
  static const Color textSecondary = Color(0xFF6B7280); // Gris moyen
  static const Color textTertiary = Color(0xFF9CA3AF); // Gris clair
  static const Color textInverse = Color(0xFFFFFFFF); // Blanc
  static const Color textDisabled = Color(
    0xFFBDBDBD,
  ); // Gris clair (pour compatibilité)

  // Couleurs de fond
  static const Color background = Color(0xFFF9FAFB); // Gris très clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gris très clair

  // Couleurs d'interface
  static const Color border = Color(0xFFE5E7EB); // Gris clair
  static const Color divider = Color(0xFFF3F4F6); // Gris très clair
  static const Color shadow = Color(0x1A000000); // Noir avec opacité

  // Couleurs d'état
  static const Color disabled = Color(0xFFD1D5DB); // Gris clair
  static const Color overlay = Color(0x80000000); // Noir avec opacité

  // Couleurs d'authentification spécifiques
  static const Color authBackground = primary; // Fond bleu pour l'auth
  static const Color authSurface = Color(
    0xFFFFFFFF,
  ); // Surface blanche pour les formulaires
  static const Color authText = Color(0xFF111827); // Texte foncé sur fond clair
  static const Color authAccent = yellow; // Accent jaune pour les boutons
  static const Color authAccentHover =
      orange; // Accent orange pour les états hover

  // === Couleurs de compatibilité pour l'ancien code ===
  static const Color onPrimary = white; // Texte blanc sur fond bleu
  static const Color secondary = yellow; // Jaune comme couleur secondaire
  static const Color onSecondary = textPrimary; // Texte foncé sur fond jaune
  static const Color accent = orange; // Orange comme accent
  static const Color onAccent = white; // Texte blanc sur accent
  static const Color onError = white; // Texte blanc sur erreur
  static const Color onSurface = textPrimary; // Texte foncé sur surface
  static const Color available = success; // Vert succès harmonisé
  static const Color lowStock = warning; // Jaune avertissement
  static const Color outOfStock = error; // Rouge erreur/rupture
}
