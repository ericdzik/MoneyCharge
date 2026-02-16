import 'package:flutter/material.dart';

/// Helper pour gérer la responsivité sur tous les types d'écrans
/// Catégories: Très petit, Petit, Moyen, Grand, Tablette, Desktop
class ResponsiveHelper {
  /// Breakpoints pour différentes tailles d'écran
 ///  static const double _extraSmallBreakpoint = 320.0; // Très petits téléphones
  static const double _smallBreakpoint = 360.0; // Petits téléphones
  static const double _mediumBreakpoint = 400.0; // Téléphones moyens
  static const double _largeBreakpoint = 600.0; // Grands téléphones
  static const double _tabletBreakpoint = 768.0; // Tablettes
  static const double _desktopBreakpoint = 1024.0; // Desktop

  /// Obtenir la largeur de l'écran
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtenir la hauteur de l'écran
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Vérifier si c'est un très petit écran (< 360px)
  static bool isExtraSmallScreen(BuildContext context) {
    return screenWidth(context) < _smallBreakpoint;
  }

  /// Vérifier si c'est un petit écran (360-400px)
  static bool isSmallScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= _smallBreakpoint && width < _mediumBreakpoint;
  }

  /// Vérifier si c'est un écran moyen (400-600px)
  static bool isMediumScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= _mediumBreakpoint && width < _largeBreakpoint;
  }

  /// Vérifier si c'est un grand écran (600-768px)
  static bool isLargeScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= _largeBreakpoint && width < _tabletBreakpoint;
  }

  /// Vérifier si c'est une tablette (768-1024px)
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= _tabletBreakpoint && width < _desktopBreakpoint;
  }

  /// Vérifier si c'est un desktop (>= 1024px)
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= _desktopBreakpoint;
  }

  /// Vérifier si c'est un appareil mobile (< 768px)
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < _tabletBreakpoint;
  }

  /// Obtenir une valeur responsive basée sur la taille de l'écran
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T extraSmall,
    T? small,
    T? medium,
    T? large,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context))
      return desktop ?? tablet ?? large ?? medium ?? small ?? extraSmall;
    if (isTablet(context))
      return tablet ?? large ?? medium ?? small ?? extraSmall;
    if (isLargeScreen(context)) return large ?? medium ?? small ?? extraSmall;
    if (isMediumScreen(context)) return medium ?? small ?? extraSmall;
    if (isSmallScreen(context)) return small ?? extraSmall;
    return extraSmall;
  }

  /// Obtenir un padding responsive
  static double getPadding(
    BuildContext context, {
    double extraSmall = 12.0,
    double? small,
    double? medium,
    double? large,
    double? tablet,
  }) {
    return getResponsiveValue(
      context,
      extraSmall: extraSmall,
      small: small ?? extraSmall,
      medium: medium ?? small ?? extraSmall,
      large: large ?? medium ?? small ?? extraSmall,
      tablet: tablet ?? large ?? medium ?? small ?? extraSmall,
    );
  }

  /// Obtenir une taille de police responsive
  static double getFontSize(
    BuildContext context, {
    required double baseSize,
    double scaleFactor = 1.0,
  }) {
    if (isExtraSmallScreen(context)) return baseSize * 0.85 * scaleFactor;
    if (isSmallScreen(context)) return baseSize * 0.9 * scaleFactor;
    if (isMediumScreen(context)) return baseSize * scaleFactor;
    if (isLargeScreen(context)) return baseSize * 1.05 * scaleFactor;
    if (isTablet(context)) return baseSize * 1.1 * scaleFactor;
    return baseSize * 1.15 * scaleFactor; // Desktop
  }

  /// Obtenir une hauteur responsive pour les images
  static double getImageHeight(
    BuildContext context, {
    double extraSmall = 150.0,
    double? small,
    double? medium,
    double? large,
    double? tablet,
  }) {
    return getResponsiveValue(
      context,
      extraSmall: extraSmall,
      small: small ?? extraSmall * 1.1,
      medium: medium ?? extraSmall * 1.2,
      large: large ?? extraSmall * 1.3,
      tablet: tablet ?? extraSmall * 1.5,
    );
  }

  /// Obtenir une largeur responsive pour les cartes
  static double getCardWidth(BuildContext context, {double? maxWidth}) {
    final width = screenWidth(context);
    if (isTablet(context) || isDesktop(context)) {
      return maxWidth ?? 600.0;
    }
    return width;
  }

  /// Obtenir le nombre de colonnes pour une grille
  static int getGridColumns(
    BuildContext context, {
    int extraSmall = 1,
    int? small,
    int? medium,
    int? large,
    int? tablet,
    int? desktop,
  }) {
    return getResponsiveValue(
      context,
      extraSmall: extraSmall,
      small: small ?? extraSmall,
      medium: medium ?? small ?? extraSmall,
      large: large ?? medium ?? small ?? extraSmall,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
    );
  }

  /// Obtenir un spacing responsive pour les grilles
  static double getGridSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      extraSmall: 8.0,
      small: 10.0,
      medium: 12.0,
      large: 14.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }

  /// Obtenir une taille d'icône responsive
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    if (isExtraSmallScreen(context)) return baseSize * 0.85;
    if (isSmallScreen(context)) return baseSize * 0.9;
    if (isTablet(context)) return baseSize * 1.1;
    if (isDesktop(context)) return baseSize * 1.2;
    return baseSize;
  }

  /// Obtenir une hauteur de bouton responsive
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      extraSmall: 44.0,
      small: 46.0,
      medium: 48.0,
      large: 50.0,
      tablet: 52.0,
    );
  }

  /// Obtenir un radius responsive
  static double getBorderRadius(
    BuildContext context, {
    double baseRadius = 12.0,
  }) {
    if (isExtraSmallScreen(context)) return baseRadius * 0.85;
    if (isTablet(context)) return baseRadius * 1.1;
    if (isDesktop(context)) return baseRadius * 1.2;
    return baseRadius;
  }

  /// Obtenir une marge horizontale responsive pour le contenu
  static double getHorizontalMargin(BuildContext context) {
    return getResponsiveValue(
      context,
      extraSmall: 12.0,
      small: 14.0,
      medium: 16.0,
      large: 18.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  /// Obtenir une hauteur d'AppBar responsive
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      extraSmall: 52.0,
      small: 54.0,
      medium: 56.0,
      tablet: 60.0,
      desktop: 64.0,
    );
  }

  /// Obtenir une hauteur de BottomNavigationBar responsive
  static double getBottomNavHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      extraSmall: 60.0,
      small: 65.0,
      medium: 70.0,
      tablet: 75.0,
    );
  }

  /// Calculer un pourcentage de la largeur de l'écran
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Calculer un pourcentage de la hauteur de l'écran
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Obtenir l'orientation de l'écran
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Obtenir l'orientation de l'écran
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Obtenir le type d'écran sous forme de string (pour debug)
  static String getScreenType(BuildContext context) {
    if (isExtraSmallScreen(context)) return 'Extra Small';
    if (isSmallScreen(context)) return 'Small';
    if (isMediumScreen(context)) return 'Medium';
    if (isLargeScreen(context)) return 'Large';
    if (isTablet(context)) return 'Tablet';
    return 'Desktop';
  }
}

/// Extension pour faciliter l'accès aux méthodes responsive
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper();

  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);

  bool get isExtraSmall => ResponsiveHelper.isExtraSmallScreen(this);
  bool get isSmall => ResponsiveHelper.isSmallScreen(this);
  bool get isMedium => ResponsiveHelper.isMediumScreen(this);
  bool get isLarge => ResponsiveHelper.isLargeScreen(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);

  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);

  String get screenType => ResponsiveHelper.getScreenType(this);
}
