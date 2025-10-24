import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/core/constants/app_constants.dart';

/// 🎨 Modern Redesigned Suggestion Card
/// - Full-width image on top
/// - Glassmorphism effects
/// - Better visual hierarchy
class SuggestionCard extends StatelessWidget {
  final SuggestionModel suggestion;
  final VoidCallback? onTap;
  final VoidCallback? onAddToMealPlan;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
    this.onAddToMealPlan,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime =
        (suggestion.prepTimeMinutes ?? 0) + (suggestion.cookTimeMinutes ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ IMAGE SECTION with overlay badges
              _buildImageSection(totalTime),

              // 📝 CONTENT SECTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Name
                    Text(
                      suggestion.recipeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // 📊 Stats Row
                    _buildStatsRow(totalTime),

                    const SizedBox(height: 12),

                    // 💡 Reason with score
                    _buildReasonSection(),

                    const SizedBox(height: 16),

                    // 💰 Cost + Action Button
                    _buildActionSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🖼️ Image section with gradient overlay and badges
  Widget _buildImageSection(int totalTime) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Main Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: suggestion.recipeImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: suggestion.recipeImageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),

          // Top badges
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Region badge
                _buildGlassBadge(
                  AppConstants.regionNames[suggestion.variantRegion] ??
                      suggestion.variantRegion,
                  Icons.location_on,
                ),
                // Score badge
                _buildGlassBadge(
                  '${suggestion.seasonScore.round()}%',
                  Icons.stars,
                ),
              ],
            ),
          ),

          // Bottom quick stats
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _buildGlassStatBadge(Icons.schedule, '$totalTime phút'),
                const SizedBox(width: 8),
                _buildGlassStatBadge(
                  Icons.people,
                  '${suggestion.servings ?? 2}',
                ),
                const SizedBox(width: 8),
                _buildGlassStatBadge(
                  Icons.local_fire_department,
                  '${suggestion.difficulty ?? 1}/5',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎭 Glassmorphism badge
  Widget _buildGlassBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatBadge(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryGreen),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Stats Row (simplified)
  Widget _buildStatsRow(int totalTime) {
    return Row(
      children: [
        if (suggestion.tagNames != null && suggestion.tagNames!.isNotEmpty)
          _buildStatItem(
            Icons.restaurant_menu,
            suggestion.tagNames!.split(',').first.trim(),
          )
        else
          _buildStatItem(Icons.restaurant_menu, 'Món ăn'),
        if (suggestion.items != null && suggestion.items!.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 1,
            height: 16,
            color: Colors.grey.shade300,
          ),
          _buildStatItem(
            Icons.shopping_basket,
            '${suggestion.items!.length} NL',
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 💡 Reason Section
  Widget _buildReasonSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.08),
            AppTheme.primaryGreen.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              suggestion.reason,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 💰 Action Section
  Widget _buildActionSection(BuildContext context) {
    return Row(
      children: [
        // Cost
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chi phí',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                suggestion.totalCost > 0
                    ? suggestion.totalCost >= 1000
                          ? '${(suggestion.totalCost / 1000).round()}k đ'
                          : '${suggestion.totalCost.round()} đ'
                    : 'Chưa có',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: suggestion.totalCost > 0
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Button
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: onAddToMealPlan,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Thêm hôm nay',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.restaurant,
        size: 48,
        color: AppTheme.textTertiary,
      ),
    );
  }
}
