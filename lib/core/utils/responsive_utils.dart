import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints pour différents types d'écrans
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Vérifier si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Vérifier si l'écran est tablette
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint &&
        MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  // Vérifier si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Obtenir la largeur de l'écran
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Obtenir la hauteur de l'écran
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Obtenir le padding horizontal adaptatif
  static EdgeInsets adaptiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48.0);
    }
  }

  // Obtenir la taille de police adaptative
  static double adaptiveFontSize(
    BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  // Obtenir le nombre de colonnes adaptatif pour les grilles
  static int adaptiveGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Vérifier si l'écran est très petit (moins de 350px)
  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 350;
  }

  // Vérifier si l'écran est petit (moins de 400px)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 400;
  }

  // Vérifier si l'écran est moyen (entre 400px et 600px)
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 400 &&
        MediaQuery.of(context).size.width < 600;
  }

  // Obtenir la hauteur minimale pour les cartes
  static double adaptiveCardHeight(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 120.0;
    } else if (isSmallScreen(context)) {
      return 140.0;
    } else {
      return 160.0;
    }
  }

  // Obtenir la largeur maximale pour les conteneurs
  static double adaptiveMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600.0;
    } else {
      return 800.0;
    }
  }
}
