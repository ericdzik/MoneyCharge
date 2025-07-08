import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background, // Ajouté pour complétude, bien que scaffoldBackgroundColor soit souvent utilisé
        onBackground: AppColors.textPrimary, // Texte sur la couleur de fond
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary, // Vert
        foregroundColor: AppColors.onPrimary, // Blanc
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Vert
          foregroundColor: AppColors.onPrimary, // Blanc
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, // Vert pour le texte/icône du bouton
          side: const BorderSide(color: AppColors.primary, width: 2), // Bordure verte
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border), // Gris
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border), // Gris
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2), // Vert
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2), // Rouge
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface, // Beige clair
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: AppColors.surface, // Pour éviter le changement de couleur avec Material 3
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface, // Beige clair
        selectedItemColor: AppColors.primary, // Vert
        unselectedItemColor: AppColors.textSecondary, // Gris
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        labelStyle: TextStyle(color: AppColors.textPrimary), // Couleur du texte pour les chips non sélectionnés
        secondaryLabelStyle: TextStyle(color: AppColors.onPrimary), // Couleur du texte pour les chips sélectionnés
        shape: StadiumBorder(side: BorderSide(color: AppColors.border)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary, // Orange
        foregroundColor: AppColors.onSecondary, // Noir
      ),
      // Vous pouvez ajouter d'autres thèmes de widgets ici si nécessaire
      // par exemple : textTheme, dialogTheme, etc.
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.headline5.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.headline6.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimary), // Pour les textes sur les boutons Elevates
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
