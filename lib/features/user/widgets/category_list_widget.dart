import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        final categories = merchantProvider.uniqueServiceCategories;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = merchantProvider.selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      merchantProvider.filterByCategory(category);
                    } else {
                      merchantProvider.filterByCategory(null);
                    }
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
