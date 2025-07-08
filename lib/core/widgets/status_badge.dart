import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

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

    // Utiliser les couleurs de AppColors pour la cohérence
    // Il faudra peut-être ajouter des couleurs spécifiques pour les fonds de badge dans AppColors
    // ou utiliser .withOpacity() sur les couleurs existantes.
    // Pour l'instant, on adapte avec les couleurs existantes.

    switch (status) {
      case StatusType.available:
        backgroundColor = AppColors.success.withOpacity(0.15); // Vert clair
        textColor = AppColors.success; // Vert
        text = customText ?? 'Disponible';
        break;
      case StatusType.lowStock:
        backgroundColor = AppColors.warning.withOpacity(0.15); // Orange/Jaune clair
        textColor = AppColors.warning; // Orange/Jaune (plus foncé si besoin pour contraste)
        text = customText ?? 'Stock faible';
        break;
      case StatusType.outOfStock:
        backgroundColor = AppColors.error.withOpacity(0.15); // Rouge clair
        textColor = AppColors.error; // Rouge
        text = customText ?? 'Épuisé';
        break;
      case StatusType.pending:
        // Si pas de couleur "info" ou "pending" dans AppColors, on peut utiliser secondary ou une nuance de gris.
        // Pour l'exemple, utilisons AppColors.secondary (Orange) avec opacité.
        // Idéalement, définir une couleur "info" dans AppColors.
        backgroundColor = AppColors.secondary.withOpacity(0.15);
        textColor = AppColors.secondary;
        text = customText ?? 'En attente';
        break;
    }

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
        style: AppTextStyles.caption.copyWith( // Utiliser un style de texte défini
          color: textColor,
          fontWeight: FontWeight.w500, // Conserver le poids si différent du style de base
        )
      ),
    );
  }
}
