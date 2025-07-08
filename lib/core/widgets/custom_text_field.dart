import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // La plupart des styles (bordures, fillColor, labelStyle, hintStyle)
    // sont maintenant hérités de InputDecorationTheme dans AppTheme.
    // Nous pouvons surcharger ici si un comportement spécifique est nécessaire pour ce widget.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: AppTextStyles.body1.copyWith(color: enabled ? AppColors.textPrimary : AppColors.textDisabled), // Style du texte entré
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        // fillColor est géré par le thème, mais peut être ajusté ici si nécessaire pour l'état désactivé
        fillColor: enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5),
        // Les styles de bordure, label et hint sont principalement pris du thème
        // mais on peut les surcharger si besoin.
        // Par exemple, si le thème ne couvre pas l'état 'disabled' pour fillColor comme souhaité:
        // enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder?.copyWith(
        //   borderSide: BorderSide(color: AppColors.border, width: 2),
        // ),
        errorBorder: OutlineInputBorder( // Assurez-vous que AppColors.error est utilisé
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric( // Peut être conservé ou hérité
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
      ),
    );
  }
}
