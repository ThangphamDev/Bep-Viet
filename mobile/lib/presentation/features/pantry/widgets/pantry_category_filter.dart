import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class PantryCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const PantryCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'code': 'all', 'name': 'Tất cả', 'icon': Icons.apps},
      {'code': 'meat', 'name': 'Thịt', 'icon': Icons.set_meal},
      {'code': 'vegetables', 'name': 'Rau', 'icon': Icons.eco},
      {'code': 'fruits', 'name': 'Trái cây', 'icon': Icons.apple},
      {'code': 'dairy', 'name': 'Sữa', 'icon': Icons.local_drink},
      {'code': 'grains', 'name': 'Ngũ cốc', 'icon': Icons.grain},
      {'code': 'spices', 'name': 'Gia vị', 'icon': Icons.spa},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['code'];
          
          return GestureDetector(
            onTap: () => onCategoryChanged(category['code'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryGreen 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}