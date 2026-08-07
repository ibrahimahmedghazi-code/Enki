import 'package:flutter/material.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/core/utils/categories.dart'; 
 
enum SearchType { user, course }
 
class SearchHeaderWidget extends StatelessWidget {
  final SearchType selectedType;
  final String? selectedCategory;
  final ValueChanged<SearchType> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onQueryChanged;
 
  const SearchHeaderWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onQueryChanged,
    this.selectedCategory,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText:
                'Search ${selectedType == SearchType.user ? "Users" : "Courses"}...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: SearchType.values.map((type) {
            final bool isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: isSelected,
                selectedColor: AppColors.enkiMain.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.enkiMain : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) => onTypeChanged(type),
              ),
            );
          }).toList(),
        ),
        if (selectedType == SearchType.course) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: AppCategories.courseCategories.map((cat) {
                final bool isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) =>
                        onCategoryChanged(val ? cat : null),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
