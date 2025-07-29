import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        final categories = merchantProvider.uniqueServiceCategories;
        return Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: merchantProvider.selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    merchantProvider.filterByCategory(category);
                  } else {
                    merchantProvider.filterByCategory(null);
                  }
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
