import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_colors.dart';

enum StatusType { available, lowStock, outOfStock, pending }

class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customText;

  const StatusBadge({super.key, required this.status, this.customText});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String textValue; // Renommée pour éviter la confusion avec le widget Text

    switch (status) {
      case StatusType.available:
        backgroundColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        textValue = customText ?? 'Disponible';
        break;
      case StatusType.lowStock:
        backgroundColor = AppColors.warning.withOpacity(0.15);
        textColor = AppColors.warning;
        // Correction: s'assurer que textValue est assigné ici aussi.
        // Si AppColors.warning est un jaune clair, un texte plus foncé pourrait être nécessaire pour le contraste.
        // Par exemple: textColor = AppColors.textPrimary; ou une nuance d'orange foncé.
        // Pour l'instant, on garde AppColors.warning et on s'assure de l'assignation de textValue.
        textValue = customText ?? 'Stock faible';
        break;
      case StatusType.outOfStock:
        backgroundColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        textValue = customText ?? 'Épuisé';
        break;
      case StatusType.pending:
        backgroundColor = AppColors.secondary.withOpacity(0.15);
        textColor = AppColors.secondary;
        textValue = customText ?? 'En attente';
        break;
      // default: // Au cas où, bien que StatusType soit un enum
      //   backgroundColor = Colors.grey.withOpacity(0.15);
      //   textColor = Colors.grey;
      //   textValue = customText ?? status.toString().split('.').last; // Nom de l'enum par défaut
      //   break;
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
        textValue,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
