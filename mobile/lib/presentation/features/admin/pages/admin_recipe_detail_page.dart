import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';

class AdminRecipeDetailPage extends StatelessWidget {
  final dynamic recipe; // Can be CommunityRecipe or RecipeModel
  final bool isOfficialRecipe;

  const AdminRecipeDetailPage({
    super.key,
    required this.recipe,
    this.isOfficialRecipe = false,
  });

  // Helper methods to get recipe information
  String get recipeTitle {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).name;
    } else {
      return (recipe as CommunityRecipe).title;
    }
  }

  String? get recipeDescription {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).description;
    } else {
      return (recipe as CommunityRecipe).descriptionMd;
    }
  }

  int? get recipeTimeMin {
    if (isOfficialRecipe) {
      final rec = recipe as RecipeModel;
      return rec.cookTimeMinutes ?? rec.totalTimeMinutes ?? rec.prepTimeMinutes;
    } else {
      return (recipe as CommunityRecipe).timeMin;
    }
  }

  String? get recipeDifficulty {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).difficulty?.toString();
    } else {
      return (recipe as CommunityRecipe).difficulty;
    }
  }

  String? get recipeRegion {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).baseRegion;
    } else {
      return (recipe as CommunityRecipe).region;
    }
  }

  String? get recipeStatus {
    if (isOfficialRecipe) {
      return 'OFFICIAL';
    } else {
      return (recipe as CommunityRecipe).status;
    }
  }

  String? get recipeAuthorName {
    if (isOfficialRecipe) {
      return 'Bếp Việt';
    } else {
      return (recipe as CommunityRecipe).authorName;
    }
  }

  // Unified accessors for lists and stats used in the UI
  List<dynamic>? get recipeIngredients {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).ingredients;
    } else {
      return (recipe as CommunityRecipe).ingredients;
    }
  }

  List<dynamic>? get recipeSteps {
    if (isOfficialRecipe) {
      return (recipe as RecipeModel).steps;
    } else {
      return (recipe as CommunityRecipe).steps;
    }
  }

  int get recipeCommentCount {
    if (isOfficialRecipe) {
      return 0;
    } else {
      return (recipe as CommunityRecipe).commentCount;
    }
  }

  int get recipeRatingCount {
    if (isOfficialRecipe) {
      return 0;
    } else {
      return (recipe as CommunityRecipe).ratingCount;
    }
  }

  double get recipeAvgRating {
    if (isOfficialRecipe) {
      return 0.0;
    } else {
      return (recipe as CommunityRecipe).avgRating ?? 0.0;
    }
  }

  int? get recipeCostHint {
    if (isOfficialRecipe) {
      return null;
    } else {
      return (recipe as CommunityRecipe).costHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isOfficialRecipe ? 'Chi tiết Công thức Chính thức' : 'Chi tiết Công thức'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'Xóa công thức',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Header
            _buildRecipeHeader(),
            const SizedBox(height: 24),

            // Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 24),

            // Description
            if (recipeDescription != null && recipeDescription!.isNotEmpty)
              _buildDescription(),
            const SizedBox(height: 24),

            // Recipe Info
            _buildRecipeInfo(),
            const SizedBox(height: 24),

            // Ingredients
            _buildIngredients(),
            const SizedBox(height: 24),

            // Steps
            _buildSteps(),
            const SizedBox(height: 24),

            // Comments & Ratings
            _buildCommentsAndRatings(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildRecipeHeader() {
    final recipe = this.recipe;
    final imageUrl = isOfficialRecipe && recipe is RecipeModel 
        ? recipe.imageUrl 
        : recipe is CommunityRecipe 
            ? recipe.imageUrl 
            : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Image - only show if imageUrl exists
        if (imageUrl != null && imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl.startsWith('data:image')
                ? Image.memory(
                    base64Decode(imageUrl.split(',')[1]),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Recipe Title and Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipeTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recipeAuthorName ?? 'Bếp Việt',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${recipeTimeMin ?? 0} phút',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.8),
            AppTheme.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              recipeTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(recipeStatus ?? 'APPROVED'),
            borderRadius: BorderRadius.circular(20),
          ),
            child: Text(
            _getStatusText(recipeStatus ?? 'APPROVED'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getDifficultyColor(recipeDifficulty ?? 'DE'),
            borderRadius: BorderRadius.circular(20),
          ),
            child: Text(
            _getDifficultyText(recipeDifficulty ?? 'DE'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
            child: Text(
            _getRegionText(recipeRegion ?? 'BAC'),
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recipeDescription ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo() {
    final recipe = this.recipe;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin Công thức',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Thời gian',
                  value: '${recipeTimeMin ?? 0} phút',
                  color: AppTheme.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.restaurant_menu,
                  label: 'Loại bữa ăn',
                  value: _getMealTypeText(recipe is RecipeModel ? recipe.mealType : null),
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.star,
                  label: 'Đánh giá',
                  value: isOfficialRecipe && recipe is RecipeModel
                      ? '${recipe.ratingAvg?.toStringAsFixed(1) ?? '0.0'}'
                      : recipeAvgRating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.comment,
                  label: 'Bình luận',
                  value: isOfficialRecipe && recipe is RecipeModel
                      ? '${recipe.ratingCount ?? 0}'
                      : '${recipeCommentCount}',
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          if (isOfficialRecipe && recipe is RecipeModel) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Chi tiết Công thức',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.local_fire_department,
                    label: 'Độ cay',
                    value: _getLevel(recipe.spiceLevel),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.water_drop,
                    label: 'Độ mặn',
                    value: _getLevel(recipe.saltiness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.restaurant,
                    label: 'Độ cứng',
                    value: _getLevel(recipe.hardness),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.verified,
                    label: 'Tính xác thực',
                    value: _getAuthenticityText(recipe.authenticity),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color color = AppTheme.primaryGreen,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIngredients() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nguyên liệu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (recipeIngredients != null && recipeIngredients!.isNotEmpty)
            ...recipeIngredients!.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          // handle both model shapes
                          ingredient is CommunityRecipeIngredient
                              ? ingredient.ingredientName
                              : (ingredient is RecipeIngredientModel
                                  ? ingredient.ingredientName
                                  : ingredient['ingredientName'] ?? ''),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
            ingredient is CommunityRecipeIngredient
              ? (ingredient.quantity ?? '')
              : (ingredient is RecipeIngredientModel
                ? ingredient.quantity.toString()
                : (ingredient['quantity']?.toString() ?? '')),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ))
          else
            const Text(
              'Chưa có thông tin nguyên liệu',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cách làm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (recipeSteps != null && recipeSteps!.isNotEmpty)
            ...recipeSteps!.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            // orderNo vs stepNumber
                            '${step is CommunityRecipeStep ? step.orderNo : (step is RecipeStepModel ? step.stepNumber : (step['orderNo'] ?? step['stepNumber'] ?? ''))}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step is CommunityRecipeStep
                              ? step.contentMd
                              : (step is RecipeStepModel
                                  ? step.instruction
                                  : (step['contentMd'] ?? step['instruction'] ?? '')),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          else
            const Text(
              'Chưa có thông tin cách làm',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsAndRatings() {
    final recipe = this.recipe;
    final commentCount = isOfficialRecipe && recipe is RecipeModel 
        ? recipe.ratingCount ?? 0 
        : recipeCommentCount;
    final ratingCount = isOfficialRecipe && recipe is RecipeModel 
        ? recipe.ratingCount ?? 0 
        : recipeRatingCount;
    final avgRating = isOfficialRecipe && recipe is RecipeModel 
        ? recipe.ratingAvg ?? 0.0 
        : recipeAvgRating;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tương tác',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.comment,
                  label: 'Bình luận',
                  value: '$commentCount',
                  color: AppTheme.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.star,
                  label: 'Đánh giá',
                  value: avgRating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.trending_up,
                  label: 'Số đánh giá',
                  value: '$ratingCount',

                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  title: const Text('Delete Recipe'),
  content: Text('Bạn có chắc muốn xóa công thức "${recipeTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Đã duyệt';
      case 'PENDING':
        return 'Chờ duyệt';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'DE':
        return Colors.green;
      case 'TRUNG_BINH':
        return Colors.orange;
      case 'KHO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'DE':
        return 'Dễ';
      case 'TRUNG_BINH':
        return 'Trung bình';
      case 'KHO':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  String _getRegionText(String region) {
    switch (region) {
      case 'BAC':
        return 'Miền Bắc';
      case 'TRUNG':
        return 'Miền Trung';
      case 'NAM':
        return 'Miền Nam';
      default:
        return region;
    }
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMealTypeText(String? mealType) {
    if (mealType == null) return 'N/A';
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return 'Bữa sáng';
      case 'LUNCH':
        return 'Bữa trưa';
      case 'DINNER':
        return 'Bữa tối';
      case 'SNACK':
        return 'Ăn vặt';
      default:
        return mealType;
    }
  }

  String _getLevel(int? level) {
    if (level == null) return 'N/A';
    if (level == 0) return 'Không';
    if (level == 1) return 'Ít';
    if (level == 2) return 'Vừa';
    if (level == 3) return 'Nhiều';
    if (level >= 4) return 'Rất nhiều';
    return level.toString();
  }

  String _getAuthenticityText(String? authenticity) {
    if (authenticity == null) return 'N/A';
    switch (authenticity.toUpperCase()) {
      case 'TRUYEN_THONG':
        return 'Truyền thống';
      case 'HIEN_DAI':
        return 'Hiện đại';
      case 'FUSION':
        return 'Fusion';
      default:
        return authenticity;
    }
  }
}
