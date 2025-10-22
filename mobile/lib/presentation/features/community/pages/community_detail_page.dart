import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/sources/remote/community_service.dart';
import 'package:bepviet_mobile/data/sources/remote/community_api_service.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import '../cubit/community_cubit.dart';
import 'create_recipe_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final CommunityRecipe recipe;

  const CommunityDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late CommunityDetailCubit _detailCubit;
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isInitialized = false;
  bool _hasUserRated = false;
  int? _userRating;

  @override
  void initState() {
    super.initState();
    _initializeCubit();
  }

  Future<void> _initializeCubit() async {
    // Initialize cubit immediately with basic Dio
    final dio = Dio();
    final communityApiService = CommunityApiService(dio);
    final communityService = CommunityService(communityApiService);
    _detailCubit = CommunityDetailCubit(communityService);
    
    // Add authentication token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Load recipe detail
    _detailCubit.loadRecipe(widget.recipe.id);
    
    // Check if user has already rated this recipe
    _checkUserRating();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _checkUserRating() {
    // Check if current user has already rated this recipe
    // This would need to be implemented based on your user authentication system
    // For now, we'll assume no rating initially
    setState(() {
      _hasUserRated = false;
      _userRating = null;
    });
  }

  @override
  void dispose() {
    _detailCubit.close();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Chi tiết công thức'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated && 
                  state.user.id == widget.recipe.authorId) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _navigateToEdit(context);
                        break;
                      case 'delete':
                        _showDeleteDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: AppTheme.textPrimary),
                          SizedBox(width: 8),
                          Text('Sửa bài viết'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa bài viết', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: !_isInitialized 
        ? Center(child: CircularProgressIndicator())
        : BlocProvider.value(
            value: _detailCubit,
            child: BlocBuilder<CommunityDetailCubit, CommunityDetailState>(
              builder: (context, state) {
                if (state is CommunityDetailLoaded) {
              return _RecipeDetailContent(
                recipe: state.recipe,
                onAddComment: _addComment,
                onAddRating: _addRating,
                commentController: _commentController,
                selectedRating: _selectedRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _selectedRating = rating;
                  });
                },
                hasUserRated: _hasUserRated,
                userRating: _userRating,
              );
            } else if (state is CommunityDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Lỗi: ${state.message}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _detailCubit.loadRecipe(widget.recipe.id),
                      child: Text('Thử lại'),
                    ),
                  ],
                ),
              );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      _detailCubit.addComment(widget.recipe.id, _commentController.text.trim());
      _commentController.clear();
    }
  }

  void _addRating() {
    if (_selectedRating > 0 && !_hasUserRated) {
      _detailCubit.addRating(widget.recipe.id, _selectedRating);
      setState(() {
        _hasUserRated = true;
        _userRating = _selectedRating;
        _selectedRating = 0;
      });
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecipePage(editingRecipe: widget.recipe),
      ),
    ).then((_) {
      // Refresh the recipe data after editing
      Navigator.pop(context, true);
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Xóa bài viết',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa bài viết này không?',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${widget.recipe.title}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hành động này không thể hoàn tác.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecipe(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(BuildContext context) async {
    try {
      final dio = Dio();
      final communityApiService = CommunityApiService(dio);
      final communityService = CommunityService(communityApiService);
      
      await communityService.deleteCommunityRecipe(widget.recipe.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bài viết đã được xóa'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _RecipeDetailContent extends StatefulWidget {
  final CommunityRecipe recipe;
  final VoidCallback onAddComment;
  final VoidCallback onAddRating;
  final TextEditingController commentController;
  final int selectedRating;
  final Function(int) onRatingChanged;
  final bool hasUserRated;
  final int? userRating;

  const _RecipeDetailContent({
    required this.recipe,
    required this.onAddComment,
    required this.onAddRating,
    required this.commentController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.hasUserRated,
    required this.userRating,
  });

  @override
  State<_RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<_RecipeDetailContent> {
  @override
  void initState() {
    super.initState();
    widget.commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.commentController.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image
                if (widget.recipe.imageUrl != null && widget.recipe.imageUrl!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.recipe.imageUrl!.startsWith('data:image')
                          ? Image.memory(
                              Uri.parse(widget.recipe.imageUrl!).data!.contentAsBytes(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              widget.recipe.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Title and region
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.recipe.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (widget.recipe.region != null) ...[
                      const SizedBox(width: 12),
                      _buildRegionBadge(widget.recipe.region!),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Author and stats
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tác giả: ${widget.recipe.authorName ?? 'Người dùng'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (widget.recipe.timeMin != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.timeMin} phút',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Difficulty and cost
                Row(
                  children: [
                    if (widget.recipe.difficulty != null) ...[
                      Icon(
                        Icons.star_outline,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDifficultyName(widget.recipe.difficulty!),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (widget.recipe.costHint != null) ...[
                      Icon(
                        Icons.attach_money,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getCostLevel(widget.recipe.costHint!),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Rating and stats
                Row(
                  children: [
                    // Rating display
                    Row(
                      children: [
                        // Display stars based on rating
                        if (widget.recipe.avgRating != null && widget.recipe.avgRating! > 0) ...[
                          ...List.generate(5, (index) {
                            return Icon(
                              index < widget.recipe.avgRating!.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            widget.recipe.avgRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.recipe.ratingCount} đánh giá)',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ] else ...[
                          // Display empty stars when no rating
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.star_border,
                              color: Colors.grey.shade400,
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            'Chưa có đánh giá',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Comment count
                    Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.recipe.commentCount} bình luận',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                // Description
                if (widget.recipe.descriptionMd != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.recipe.descriptionMd!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Ingredients section
          _buildSection(
            title: 'Nguyên liệu',
            icon: Icons.shopping_cart_outlined,
            child: widget.recipe.ingredients != null && widget.recipe.ingredients!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.ingredients!.length,
                    itemBuilder: (context, index) {
                      final ingredient = widget.recipe.ingredients![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingredient.ingredientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (ingredient.quantity != null) ...[
                              Text(
                                ingredient.quantity!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    child: const Text(
                      'Chưa có thông tin nguyên liệu',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          
          // Steps section
          _buildSection(
            title: 'Cách làm',
            icon: Icons.list_alt_outlined,
            child: widget.recipe.steps != null && widget.recipe.steps!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.steps!.length,
                    itemBuilder: (context, index) {
                      final step = widget.recipe.steps![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${step.orderNo}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.contentMd,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    child: const Text(
                      'Chưa có thông tin cách làm',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          
          // Rating section
          _buildSection(
            title: 'Đánh giá',
            icon: Icons.star_outline,
            child: Column(
              children: [
                // Rating input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Đánh giá công thức này',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: widget.hasUserRated ? null : () => widget.onRatingChanged(index + 1),
                            icon: Icon(
                              index < widget.selectedRating ? Icons.star : Icons.star_border,
                              color: index < widget.selectedRating ? Colors.amber : AppTheme.textSecondary,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      if (widget.hasUserRated) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bạn đã đánh giá ${widget.userRating} sao cho công thức này',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (!widget.hasUserRated && widget.selectedRating > 0) ? widget.onAddRating : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Gửi đánh giá',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Existing ratings
                if (widget.recipe.ratings?.details != null && widget.recipe.ratings!.details!.isNotEmpty) ...[
                  ...widget.recipe.ratings!.details!.map((rating) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.stars ? Icons.star : Icons.star_border,
                              color: index < rating.stars ? Colors.amber : AppTheme.textSecondary,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rating.authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(rating.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          
          // Comments section
          _buildSection(
            title: 'Bình luận',
            icon: Icons.comment_outlined,
            child: Column(
              children: [
                // Comment input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: widget.commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryGreen),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.commentController.text.trim().isNotEmpty ? widget.onAddComment : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Gửi bình luận',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Existing comments
                if (widget.recipe.comments != null && widget.recipe.comments!.isNotEmpty) ...[
                  ...widget.recipe.comments!.map((comment) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.authorName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(comment.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comment.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                    child: const Text(
                      'Chưa có bình luận nào',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [regionColor, regionColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _getDifficultyName(String difficulty) {
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

  String _getCostLevel(int costHint) {
    if (costHint <= 50000) {
      return 'Rẻ';
    } else if (costHint <= 100000) {
      return 'Trung bình';
    } else {
      return 'Đắt';
    }
  }
}