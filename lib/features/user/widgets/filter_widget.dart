import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/merchant_provider.dart';

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
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Ouvert'),
                  selected: merchantProvider.filterOpen,
                  onSelected: (selected) {
                    merchantProvider.toggleFilterOpen();
                  },
                ),
                const SizedBox(width: 8),
                // Ajoutez d'autres filtres ici, par exemple par catégorie
              ],
            ),
          ),
        );
      },
    );
  }
}
