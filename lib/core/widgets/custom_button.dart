import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

enum ButtonType { primary, secondary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Widget? icon;
  final bool isLoading;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color progressIndicatorColor;
    TextStyle effectiveTextStyle;

    switch (type) {
      case ButtonType.primary:
        progressIndicatorColor = AppColors.onPrimary; // Blanc sur fond Vert
        // Le style de texte est hérité du ElevatedButtonTheme, qui utilise AppTextStyles.button (blanc)
        effectiveTextStyle = Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}) ?? AppTextStyles.button.copyWith(color: AppColors.onPrimary);
        break;
      case ButtonType.secondary:
        progressIndicatorColor = AppColors.primary; // Vert sur fond Beige clair (AppColors.surface)
        effectiveTextStyle = AppTextStyles.button.copyWith(color: AppColors.textPrimary); // Texte noir doux
        break;
      case ButtonType.outline:
        progressIndicatorColor = AppColors.primary; // Vert sur fond transparent avec bordure verte
        // Le style de texte est hérité du OutlinedButtonTheme, qui utilise AppTextStyles.button.copyWith(color: AppColors.primary) (vert)
        effectiveTextStyle = Theme.of(context).outlinedButtonTheme.style?.textStyle?.resolve({}) ?? AppTextStyles.button.copyWith(color: AppColors.primary);
        break;
    }

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(progressIndicatorColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                // Cloner l'icône si elle n'a pas déjà la bonne couleur
                (icon is Icon && (icon as Icon).color == null)
                  ? Icon((icon as Icon).icon, color: effectiveTextStyle.color, size: (icon as Icon).size ?? effectiveTextStyle.fontSize)
                  : icon!,
                const SizedBox(width: AppDimensions.paddingS),
              ],
              Text(text, style: effectiveTextStyle),
            ],
          );

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            // Le style du bouton (couleur de fond, etc.) est hérité du ElevatedButtonTheme
            child: buttonContent,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface, // Beige clair
              foregroundColor: AppColors.textPrimary, // Texte noir doux pour l'effet ripple et focus
              textStyle: effectiveTextStyle,
              elevation: 0, // Moins d'élévation pour un look "secondaire"
              side: BorderSide(color: AppColors.border, width: 1), // Légère bordure pour définition
            ),
            child: buttonContent,
          ),
        );
      case ButtonType.outline:
        return SizedBox(
          width: width,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            // Le style du bouton (couleur de bordure, etc.) est hérité du OutlinedButtonTheme
            child: buttonContent,
          ),
        );
    }
  }
}