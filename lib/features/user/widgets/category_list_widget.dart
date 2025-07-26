import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/features/user/widgets/category_widget.dart';

class CategoryListWidget extends StatefulWidget {
  const CategoryListWidget({Key? key}) : super(key: key);

  @override
  _CategoryListWidgetState createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final merchantProvider = Provider.of<MerchantProvider>(context);
    final categories = merchantProvider.uniqueServiceCategories;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryWidget(
            category: category,
            icon: _getIconForCategory(category),
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() {
                if (_selectedCategory == category) {
                  _selectedCategory = null;
                  merchantProvider.applyFilters(services: []);
                } else {
                  _selectedCategory = category;
                  merchantProvider.applyFilters(services: [category]);
                }
              });
            },
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transfert d\'argent':
        return Icons.send;
      case 'paiement de factures':
        return Icons.receipt;
      case 'recharge mobile':
        return Icons.phone_android;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
