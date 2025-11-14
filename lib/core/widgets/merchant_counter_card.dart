import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class MerchantCounterCard extends StatelessWidget {
  final int merchantCount;
  final VoidCallback onPressed;

  const MerchantCounterCard({
    super.key,
    required this.merchantCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.08).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 400) {
            return _buildColumn();
          }
          return _buildRow();
        },
      ),
    );
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$merchantCount points de service trouvés',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingS),
        SizedBox(
          width: double.infinity,
          child: _buildButton(),
        ),
      ],
    );
  }

  Widget _buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '$merchantCount points de service trouvés',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        _buildButton(),
      ],
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        textStyle: AppTextStyles.button.copyWith(
          fontSize: 12,
          color: AppColors.onSecondary,
        ),
      ),
      child: const Text('Vue Liste'),
    );
  }
}