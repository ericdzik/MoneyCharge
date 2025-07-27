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
        primary: AppColors.primary,       // Vert
        onPrimary: AppColors.onPrimary,   // Blanc
        secondary: AppColors.secondary,   // Jaune
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        background: AppColors.background, // Vert clair
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent, // Rouge rasta
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
        fillColor: AppColors.surface,
        filled: true,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent, // Rouge
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.accent,
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.onPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        titleMedium: AppTextStyles.body1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        titleSmall: AppTextStyles.body2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary, // Keep primary color
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary, // Keep secondary color
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        background: Colors.grey[900]!,
        onBackground: Colors.white,
        surface: Colors.grey[800]!,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
        hintStyle: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
        fillColor: Colors.grey[800],
        filled: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[800],
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[800],
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.accent,
        labelStyle: AppTextStyles.caption.copyWith(color: Colors.white),
        secondaryLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.onPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: Colors.white),
        displayMedium: AppTextStyles.h2.copyWith(color: Colors.white),
        displaySmall: AppTextStyles.h3.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.h3.copyWith(color: Colors.white),
        headlineSmall: AppTextStyles.h3.copyWith(color: Colors.white),
        titleLarge: AppTextStyles.h3.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.body1.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
        titleMedium: AppTextStyles.body1.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall: AppTextStyles.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
        bodySmall: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
        labelSmall: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}
