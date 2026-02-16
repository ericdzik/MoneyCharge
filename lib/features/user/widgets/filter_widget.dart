import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'category_list_widget.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MerchantProvider, LocationProvider>(
      builder: (context, merchantProvider, locationProvider, child) {
        final isLocationAvailable = locationProvider.currentPosition != null;

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
                // distance filter chips, 3, 5, 10 km
                // distance filter chips, 3, 5, 10 km
                FilterChip(
                  label: const Text('3 km'),
                  selected: merchantProvider.maxDistanceInKm == 3,
                  onSelected: isLocationAvailable
                      ? (selected) {
                          if (selected) {
                            merchantProvider.filterByDistance(3);
                          }
                        }
                      : null,
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: merchantProvider.maxDistanceInKm == 3
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: merchantProvider.maxDistanceInKm == 3
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('5 km'),
                  selected: merchantProvider.maxDistanceInKm == 5,
                  onSelected: isLocationAvailable
                      ? (selected) {
                          if (selected) {
                            merchantProvider.filterByDistance(5);
                          }
                        }
                      : null,
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: merchantProvider.maxDistanceInKm == 5
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: merchantProvider.maxDistanceInKm == 5
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('10 km'),
                  selected: merchantProvider.maxDistanceInKm == 10,
                  onSelected: isLocationAvailable
                      ? (selected) {
                          if (selected) {
                            merchantProvider.filterByDistance(10);
                          }
                        }
                      : null,
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: merchantProvider.maxDistanceInKm == 10
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight: merchantProvider.maxDistanceInKm == 10
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
