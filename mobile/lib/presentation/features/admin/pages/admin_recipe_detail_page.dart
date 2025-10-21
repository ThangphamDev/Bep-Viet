import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/presentation/features/admin/cubit/admin_cubit.dart';

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
      return (recipe as RecipeModel).totalTimeMinutes;
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
      return (recipe as CommunityRecipe).avgRating;
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
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'promote':
                  if (!isOfficialRecipe) _showPromoteDialog(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!isOfficialRecipe)
                const PopupMenuItem(
                  value: 'promote',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text('Promote'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.secondaryGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                recipeAuthorName ?? 'Người dùng',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
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
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Chi phí',
                  value: '${recipeCostHint ?? 0} VNĐ',
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
                  value: recipeAvgRating.toString(),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.comment,
                  label: 'Bình luận',
                  value: '${recipeCommentCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
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
                  value: '${recipeCommentCount}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.star,
                  label: 'Đánh giá',
                  value: '${recipeRatingCount}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.trending_up,
                  label: 'Điểm TB',
                  value: recipeAvgRating.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showPromoteDialog(context),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Promote'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('Xóa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showPromoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
  title: const Text('Promote Recipe'),
  content: Text('Bạn có chắc muốn promote công thức "${recipeTitle}" thành công thức chính thức?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement promote functionality
            },
            child: const Text('Promote'),
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
}
