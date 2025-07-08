import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_colors.dart'; // Assurer l'import de AppColors

enum StatusType { available, lowStock, outOfStock, pending }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customText;

  const StatusBadge({super.key, required this.status, this.customText});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case StatusType.available:
        backgroundColor = AppColors.success.withOpacity(0.15); // Vert clair
        textColor = AppColors.success; // Vert
        text = customText ?? 'Disponible';
        break;
      case StatusType.lowStock:
        backgroundColor = AppColors.warning.withOpacity(0.15); // Orange/Jaune clair
        textColor = AppColors.warning; // Orange/Jaune (texte pourrait avoir besoin d'être plus foncé si warning est trop clair)
                                     // Si AppColors.warning est FBC02D (jaune), un textPrimary ou un orange foncé serait mieux.
                                     // Pour l'instant, on garde AppColors.warning.
        break;
      case StatusType.outOfStock:
        backgroundColor = AppColors.error.withOpacity(0.15); // Rouge clair
        textColor = AppColors.error; // Rouge
        text = customText ?? 'Épuisé';
        break;
      case StatusType.pending:
        // Si une couleur "info" ou "pending" n'est pas dans AppColors, utilisons AppColors.secondary.
        // Idéalement, ajouter une couleur dédiée comme AppColors.info ou AppColors.pending.
        backgroundColor = AppColors.secondary.withOpacity(0.15); // Orange clair
        textColor = AppColors.secondary; // Orange
        text = customText ?? 'En attente';
        break;
    }
     // Fallback pour le texte si non assigné dans le switch (ex: lowStock)
    text = text ?? (status == StatusType.lowStock ? (customText ?? 'Stock faible') : '');


    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500, // Conserver le poids si différent du style de base de caption
        ),
      ),
    );
  }
}
