import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/presentation/features/pantry/services/pantry_suggestions_service.dart';

/// Card hiển thị recipe suggestion với badge nguyên liệu có sẵn
class PantryRecipeCard extends StatelessWidget {
  final RecipeSuggestion recipe;
  final int totalPantryIngredients;

  const PantryRecipeCard({
    super.key,
    required this.recipe,
    required this.totalPantryIngredients,
  });

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(String? difficulty) {
    switch (difficulty?.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return 'N/A';
    }
  }

  String _getMealTypeText(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST':
        return 'Sáng';
      case 'LUNCH':
        return 'Trưa';
      case 'DINNER':
        return 'Tối';
      case 'SNACK':
        return 'Ăn vặt';
      default:
        return '';
    }
  }

  IconData _getMealTypeIcon(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.wb_sunny_outlined;
      case 'LUNCH':
        return Icons.wb_cloudy_outlined;
      case 'DINNER':
        return Icons.nightlight_outlined;
      case 'SNACK':
        return Icons.fastfood_outlined;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchPercentage = (recipe.pantryMatchCount / totalPantryIngredients * 100).clamp(0, 100).toInt();
    final hasHighMatch = matchPercentage >= 70;
    final hasMediumMatch = matchPercentage >= 40;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/recipes/${recipe.recipeId}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image với badge
            Stack(
              children: [
                // Recipe Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                        ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Match badge (top left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasHighMatch
                          ? AppTheme.primaryGreen
                          : hasMediumMatch
                              ? Colors.orange
                              : Colors.grey[600],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasHighMatch ? Icons.check_circle : Icons.inventory_2,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Có ${recipe.pantryMatchCount} NL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Rating badge (top right)
                if (recipe.ratingAvg != null && recipe.ratingAvg! > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            recipe.ratingAvg!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.nameVi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Meal type
                      if (recipe.mealType != null)
                        _buildTag(
                          icon: _getMealTypeIcon(recipe.mealType),
                          label: _getMealTypeText(recipe.mealType),
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          textColor: AppTheme.primaryGreen,
                        ),

                      // Difficulty
                      if (recipe.difficulty != null)
                        _buildTag(
                          icon: Icons.bar_chart,
                          label: _getDifficultyText(recipe.difficulty),
                          color: _getDifficultyColor(recipe.difficulty).withOpacity(0.1),
                          textColor: _getDifficultyColor(recipe.difficulty),
                        ),

                      // Cook time
                      if (recipe.cookTimeMin != null)
                        _buildTag(
                          icon: Icons.schedule,
                          label: '${recipe.cookTimeMin} phút',
                          color: Colors.blue.withOpacity(0.1),
                          textColor: Colors.blue,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

