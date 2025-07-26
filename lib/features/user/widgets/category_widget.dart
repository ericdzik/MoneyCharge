import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String category;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryWidget({
    Key? key,
    required this.category,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
