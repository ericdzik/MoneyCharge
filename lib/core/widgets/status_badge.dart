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

    switch (status) {
      case StatusType.available:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = customText ?? 'Disponible';
        break;
      case StatusType.lowStock:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = customText ?? 'Stock faible';
        break;
      case StatusType.outOfStock:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        text = customText ?? 'Épuisé';
        break;
      case StatusType.pending:
        backgroundColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1E40AF);
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
