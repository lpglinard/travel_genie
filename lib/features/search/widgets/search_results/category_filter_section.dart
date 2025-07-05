import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class CategoryFilterSection extends StatelessWidget {
  const CategoryFilterSection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final Function(String) onCategorySelected;

  List<String> _getCategories(BuildContext context) {
    return [
      AppLocalizations.of(context).categoryAll,
      AppLocalizations.of(context).categoryAttractions,
      AppLocalizations.of(context).categoryRestaurants,
      AppLocalizations.of(context).categoryHotels,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _getCategories(context).length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final category = _getCategories(context)[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () => onCategorySelected(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 2 : 0,
              ),
              child: Text(
                category,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
