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
    // sont hérités de InputDecorationTheme dans AppTheme.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: AppTextStyles.body1.copyWith(color: enabled ? AppColors.textPrimary : AppColors.textDisabled),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        // fillColor est géré par le thème (AppColors.surface).
        // Ajustement pour l'état désactivé si le thème ne le fait pas spécifiquement.
        fillColor: enabled ? null : AppColors.surface.withOpacity(0.5), // null pour hériter du thème si enabled
        // errorBorder est défini dans le thème global avec AppColors.error
        // contentPadding peut être hérité ou surchargé si besoin.
        // Les styles de label et hint sont aussi hérités (AppTextStyles.body2 et AppTextStyles.caption).
      ),
    );
  }
}
