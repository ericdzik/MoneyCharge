import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/merchant_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'category_list_widget.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: merchantProvider.selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      merchantProvider.filterByCategory(null);
                    }
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: merchantProvider.selectedCategory == null
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: merchantProvider.selectedCategory == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Ouvert'),
                  selected: merchantProvider.filterOpen,
                  onSelected: (selected) {
                    merchantProvider.toggleFilterOpen();
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: merchantProvider.filterOpen
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: merchantProvider.filterOpen
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                const CategoryListWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
