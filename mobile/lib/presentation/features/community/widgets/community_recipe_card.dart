import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import '../../../../data/models/community_recipe.dart';

class CommunityRecipeCard extends StatelessWidget {
  final CommunityRecipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const CommunityRecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppTheme.primaryGreen.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and region
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (recipe.region != null) ...[
                      const SizedBox(width: 12),
                      _buildRegionBadge(recipe.region!),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Author and time info
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.authorName ?? 'Người dùng',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (recipe.timeMin != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.timeMin} phút',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                if (recipe.descriptionMd != null) ...[
                  Text(
                    recipe.descriptionMd!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.comment_outlined,
                      label: '${recipe.commentCount}',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.star_outline,
                      label: recipe.avgRating > 0 
                          ? recipe.avgRating.toStringAsFixed(1)
                          : 'Chưa đánh giá',
                    ),
                    const SizedBox(width: 12),
                    if (recipe.difficulty != null)
                      _buildDifficultyChip(recipe.difficulty!),
                    const Spacer(),
                    if (onFavorite != null)
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionBadge(String region) {
    String regionText;
    Color regionColor;
    
    switch (region) {
      case 'BAC':
        regionText = 'Bắc';
        regionColor = Colors.blue;
        break;
      case 'TRUNG':
        regionText = 'Trung';
        regionColor = Colors.orange;
        break;
      case 'NAM':
        regionText = 'Nam';
        regionColor = Colors.green;
        break;
      default:
        regionText = region;
        regionColor = AppTheme.primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [regionColor, regionColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: regionColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        regionText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    String difficultyText;
    Color difficultyColor;
    
    switch (difficulty) {
      case 'DE':
        difficultyText = 'Dễ';
        difficultyColor = Colors.green;
        break;
      case 'TRUNG_BINH':
        difficultyText = 'Trung bình';
        difficultyColor = Colors.orange;
        break;
      case 'KHO':
        difficultyText = 'Khó';
        difficultyColor = Colors.red;
        break;
      default:
        difficultyText = difficulty;
        difficultyColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficultyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficultyText,
        style: TextStyle(
          fontSize: 12,
          color: difficultyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
