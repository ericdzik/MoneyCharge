import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

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
    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              Text(text),
            ],
          );

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
            ),
            child: child,
          ),
        );
      case ButtonType.outline:
        return SizedBox(
          width: width,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}