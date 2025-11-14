import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Utilitaires pour la gestion des couleurs avec alpha
class ColorUtils {
  /// Remplace withOpacity par withValues pour éviter les dépréciations
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  /// Couleurs avec alpha prédéfinies
  static Color blackWithAlpha(double alpha) {
    return Colors.black.withValues(alpha: alpha);
  }

  static Color whiteWithAlpha(double alpha) {
    return Colors.white.withValues(alpha: alpha);
  }

  static Color primaryWithAlpha(double alpha) {
    return const Color(0xFFDC2626).withValues(alpha: alpha);
  }

  static Color greenWithAlpha(double alpha) {
    return AppColors.primary.withAlpha((255 * alpha).round());
  }

  static Color orangeWithAlpha(double alpha) {
    return Colors.orange.withValues(alpha: alpha);
  }
}
