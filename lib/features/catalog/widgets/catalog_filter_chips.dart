/// Filter chips widget for catalog category selection
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class CatalogFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CatalogFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          Color getColor() {
            if (category == AppStrings.toxic) return Colors.red;
            if (category == AppStrings.safe) return Colors.green;
            if (category == AppStrings.cyanobacteria) return Colors.blue;
            if (category == AppStrings.dinoflagellate) return Colors.purple;
            if (category == AppStrings.diatom) return Colors.orange;
            return AppColors.primaryBlue;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: Colors.grey[100],
              selectedColor: getColor().withOpacity(0.2),
              checkmarkColor: getColor(),
              labelStyle: TextStyle(
                color: isSelected ? getColor() : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? getColor() : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}