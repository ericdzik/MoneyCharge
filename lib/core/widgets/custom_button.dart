import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart'; // Assurer l'import

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
    // Le style du texte du bouton sera hérité des thèmes ElevatedButtonThemeData ou OutlinedButtonThemeData
    // où AppTextStyles.button est déjà appliqué.

    Color progressIndicatorColor;
    TextStyle buttonTextStyle;

    switch (type) {
      case ButtonType.primary:
        progressIndicatorColor = AppColors.onPrimary; // Blanc sur fond Vert
        buttonTextStyle = Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}) ?? AppTextStyles.button.copyWith(color: AppColors.onPrimary);
        break;
      case ButtonType.secondary:
        // Pour le bouton secondaire, on utilise une couleur de fond beige (AppColors.background)
        // et une couleur de texte principale (AppColors.textPrimary).
        // Le spinner devrait donc contraster avec le beige, par exemple AppColors.primary (Vert).
        progressIndicatorColor = AppColors.primary;
        buttonTextStyle = AppTextStyles.button.copyWith(color: AppColors.textPrimary);
        break;
      case ButtonType.outline:
        progressIndicatorColor = AppColors.primary; // Vert sur fond transparent avec bordure verte
        buttonTextStyle = Theme.of(context).outlinedButtonTheme.style?.textStyle?.resolve({}) ?? AppTextStyles.button.copyWith(color: AppColors.primary);
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
                icon!,
                const SizedBox(width: AppDimensions.paddingS),
              ],
              Text(text, style: buttonTextStyle), // Appliquer le style de texte ici si nécessaire ou s'assurer qu'il est hérité
            ],
          );

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface, // Changé pour AppColors.surface (Beige clair) pour meilleur contraste
              foregroundColor: AppColors.textPrimary, // Noir doux
              textStyle: buttonTextStyle, // Assurer que le style de texte est appliqué
            ).copyWith(
              elevation: MaterialStateProperty.all(0), // Peut-être pas d'élévation pour ce type
            ),
            child: buttonContent,
          ),
        );
      case ButtonType.outline:
        return SizedBox(
          width: width,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          ),
        );
    }
  }
}