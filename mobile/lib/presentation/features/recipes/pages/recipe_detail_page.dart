import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        // Configure Dio for ngrok tunnel
        dio.options.baseUrl =
            'https://gullably-nonpsychological-leisha.ngrok-free.dev';
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);

        // Add ngrok-skip-browser-warning header
        dio.options.headers['ngrok-skip-browser-warning'] = 'true';

        final apiService = ApiService(dio);
        return RecipeDetailCubit(apiService, recipeId);
      },
      child: RecipeDetailPageView(recipeId: recipeId),
    );
  }
}

class RecipeDetailPageView extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPageView({super.key, required this.recipeId});

  @override
  State<RecipeDetailPageView> createState() => _RecipeDetailPageViewState();
}

class _RecipeDetailPageViewState extends State<RecipeDetailPageView>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  String _selectedVariantRegion = '';
  final ScrollController _scrollController = ScrollController();
  bool _showActionButtons = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _lastScrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<RecipeDetailCubit>().loadRecipe();
    _scrollController.addListener(_onScroll);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start with buttons visible
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    final scrollDelta = currentPosition - _lastScrollPosition;

    // Only hide/show if scroll delta is significant (> 5px)
    if (scrollDelta.abs() > 5) {
      if (scrollDelta > 0) {
        // Scrolling down - hide buttons
        if (_showActionButtons) {
          setState(() {
            _showActionButtons = false;
          });
          _animationController.reverse();
        }
      } else {
        // Scrolling up - show buttons
        if (!_showActionButtons) {
          setState(() {
            _showActionButtons = true;
          });
          _animationController.forward();
        }
      }
    }

    _lastScrollPosition = currentPosition;
  }

  Future<void> _showMealSlotDialog(RecipeModel recipe) async {
    final mealSlot = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Thêm vào kế hoạch',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn bữa ăn hôm nay:',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            _buildMealSlotOption(
              dialogContext,
              'BREAKFAST',
              '🌅 Bữa sáng',
              '7:00 - 9:00',
            ),
            _buildMealSlotOption(
              dialogContext,
              'LUNCH',
              '☀️ Bữa trưa',
              '11:00 - 13:00',
            ),
            _buildMealSlotOption(
              dialogContext,
              'DINNER',
              '🌙 Bữa tối',
              '18:00 - 20:00',
            ),
          ],
        ),
      ),
    );

    if (mealSlot != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _addToToday(recipe, mealSlot);
      }
    }
  }

  Widget _buildMealSlotOption(
    BuildContext dialogContext,
    String value,
    String title,
    String time,
  ) {
    return InkWell(
      onTap: () => Navigator.of(dialogContext).pop(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen.withOpacity(0.05),
              AppTheme.primaryGreen.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryGreen.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToToday(RecipeModel recipe, String mealSlot) async {
    bool isLoading = false;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(height: 16),
                Text('Đang thêm vào kế hoạch...'),
              ],
            ),
          ),
        ),
      );
      isLoading = true;

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để sử dụng tính năng này');
      }

      // Create Dio and ApiService
      final dio = Dio();
      dio.options.baseUrl =
          'https://gullably-nonpsychological-leisha.ngrok-free.dev';
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';
      final apiService = ApiService(dio);

      // Call API
      await apiService.quickAddToToday(
        token: token,
        recipeId: recipe.id,
        mealSlot: mealSlot,
        servings: recipe.servings ?? 2,
        variantRegion: recipe.baseRegion,
      );

      if (!mounted) return;

      // Close loading dialog
      if (isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
        isLoading = false;
      }

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã thêm "${recipe.name}" vào ${_getMealSlotName(mealSlot)}',
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if showing
      if (isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  String _getMealSlotName(String mealSlot) {
    switch (mealSlot) {
      case 'BREAKFAST':
        return 'bữa sáng hôm nay';
      case 'LUNCH':
        return 'bữa trưa hôm nay';
      case 'DINNER':
        return 'bữa tối hôm nay';
      default:
        return 'hôm nay';
    }
  }

  Future<void> _toggleFavorite(RecipeModel recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final dio = Dio();
      dio.options.baseUrl =
          'https://gullably-nonpsychological-leisha.ngrok-free.dev';
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';
      final apiService = ApiService(dio);

      if (recipe.isFavorite) {
        // Optimistically update UI
        context.read<RecipeDetailCubit>().toggleFavoriteStatus(false);

        // Remove from favorites
        await apiService.removeFavorite(token, recipe.id);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${recipe.name}" khỏi yêu thích'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Optimistically update UI
        context.read<RecipeDetailCubit>().toggleFavoriteStatus(true);

        // Add to favorites
        await apiService.addFavorite(token, recipe.id);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Đã thêm "${recipe.name}" vào yêu thích')),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Revert on error
      context.read<RecipeDetailCubit>().toggleFavoriteStatus(
        !recipe.isFavorite,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<RecipeDetailCubit, RecipeDetailState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<RecipeDetailCubit>().loadRecipe(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final recipe = state.recipe!;
            _selectedVariantRegion = _selectedVariantRegion.isEmpty
                ? recipe.baseRegion ?? 'NAM'
                : _selectedVariantRegion;

            return Scaffold(
              body: Column(
                children: [
                  // Simple App Bar
                  AppBar(
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    title: Text(
                      recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => _toggleFavorite(recipe),
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chia sẻ công thức'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                      ),
                    ],
                  ),

                  // Recipe Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          if (recipe.imageUrl != null &&
                              recipe.imageUrl!.isNotEmpty) {
                            _showImageDialog(context, recipe.imageUrl!);
                          }
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            recipe.imageUrl != null &&
                                    recipe.imageUrl!.isNotEmpty
                                ? Center(
                                    child: CachedNetworkImage(
                                      imageUrl: recipe.imageUrl!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      placeholder: (context, url) =>
                                          _buildLoadingImage(),
                                      errorWidget: (context, url, error) =>
                                          _buildPlaceholderImage(),
                                    ),
                                  )
                                : _buildPlaceholderImage(),
                            if (recipe.imageUrl != null &&
                                recipe.imageUrl!.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recipe Info
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe Title
                            Text(
                              recipe.name,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            // Description
                            if (recipe.description != null) ...[
                              Text(
                                recipe.description!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Stats Row
                            Row(
                              children: [
                                _buildStatCard(
                                  Icons.access_time,
                                  'Thời gian',
                                  _getTimeDisplay(recipe),
                                ),
                                const SizedBox(width: 8),
                                _buildStatCard(
                                  Icons.restaurant,
                                  'Độ khó',
                                  '${recipe.difficulty ?? 1}/5',
                                ),
                                const SizedBox(width: 8),
                                if (recipe.baseRegion != null)
                                  _buildStatCard(
                                    Icons.location_on,
                                    'Vùng miền',
                                    _getRegionDisplay(recipe.baseRegion!),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Custom Tab Bar
                            Container(
                              color: AppTheme.surfaceColor,
                              child: Row(
                                children: [
                                  _buildTabButton('Nguyên liệu', 0),
                                  _buildTabButton('Thông tin', 1),
                                ],
                              ),
                            ),

                            // Tab Content
                            IndexedStack(
                              index: _selectedTabIndex,
                              children: [
                                _buildIngredientsTab(state),
                                _buildInfoTab(state),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  // Only show container when buttons should be visible
                  if (_fadeAnimation.value == 0.0) {
                    return const SizedBox.shrink();
                  }

                  return Transform.translate(
                    offset: Offset(0, (1 - _fadeAnimation.value) * 80),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showMealSlotDialog(recipe),
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Thêm vào kế hoạch'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryGreen,
                                  side: const BorderSide(
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Bắt đầu nấu'),
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Bắt đầu nấu'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
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
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeDisplay(RecipeModel recipe) {
    if (recipe.totalTimeMinutes != null && recipe.totalTimeMinutes! > 0) {
      final hours = recipe.totalTimeMinutes! ~/ 60;
      final minutes = recipe.totalTimeMinutes! % 60;
      if (hours > 0) {
        return '${hours}h ${minutes}p';
      } else {
        return '${minutes}p';
      }
    } else if (recipe.cookTimeMinutes != null && recipe.cookTimeMinutes! > 0) {
      final hours = recipe.cookTimeMinutes! ~/ 60;
      final minutes = recipe.cookTimeMinutes! % 60;
      if (hours > 0) {
        return '${hours}h ${minutes}p';
      } else {
        return '${minutes}p';
      }
    } else if (recipe.prepTimeMinutes != null && recipe.prepTimeMinutes! > 0) {
      final hours = recipe.prepTimeMinutes! ~/ 60;
      final minutes = recipe.prepTimeMinutes! % 60;
      if (hours > 0) {
        return '${hours}h ${minutes}p';
      } else {
        return '${minutes}p';
      }
    }
    return 'Chưa xác định';
  }

  String _getRegionDisplay(String region) {
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

  Widget _buildIngredientsTab(RecipeDetailState state) {
    if (state.ingredients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có thông tin nguyên liệu',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nguyên liệu (${state.ingredients.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...state.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.ingredientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (ingredient.quantity > 0 ||
                            ingredient.unit.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${ingredient.quantity > 0 ? ingredient.quantity.toString() : ''} ${ingredient.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                        if (ingredient.notes != null &&
                            ingredient.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ingredient.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoTab(RecipeDetailState state) {
    final recipe = state.recipe!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chi tiết',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Tên món', recipe.name),
          _buildInfoCard('Loại món', recipe.mealType ?? 'Chưa xác định'),
          _buildInfoCard('Độ khó', '${recipe.difficulty ?? 1}/5'),
          _buildInfoCard(
            'Thời gian nấu',
            '${recipe.cookTimeMinutes ?? 0} phút',
          ),
          _buildInfoCard('Số khẩu phần', '${recipe.servings ?? 1} người'),
          _buildInfoCard(
            'Vùng miền',
            recipe.baseRegion != null
                ? _getRegionDisplay(recipe.baseRegion!)
                : 'Chưa xác định',
          ),
          if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Thẻ phân loại',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.tags!
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppTheme.primaryGreen),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.2),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 80, color: AppTheme.primaryGreen),
            SizedBox(height: 12),
            Text(
              'Không có ảnh',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Công thức này chưa có hình ảnh',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
            SizedBox(height: 12),
            Text(
              'Đang tải ảnh...',
              style: TextStyle(color: AppTheme.primaryGreen, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 60),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RecipeDetailCubit and RecipeDetailState classes
class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final ApiService _apiService;
  final String _recipeId;

  RecipeDetailCubit(this._apiService, this._recipeId)
    : super(RecipeDetailState.initial());

  Future<void> loadRecipe() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Get userId for favorite check
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConfig.userIdKey);

      final recipe = await _apiService.getRecipeById(_recipeId, userId: userId);
      final ingredients = await _apiService.getRecipeIngredients(_recipeId);
      final variants = await _apiService.getRecipeVariants(_recipeId);

      emit(
        state.copyWith(
          isLoading: false,
          recipe: recipe,
          ingredients: ingredients,
          variants: variants,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void toggleFavoriteStatus(bool isFavorite) {
    if (state.recipe != null) {
      final updatedRecipe = state.recipe!.copyWith(isFavorite: isFavorite);
      emit(state.copyWith(recipe: updatedRecipe));
    }
  }
}

class RecipeDetailState {
  final bool isLoading;
  final RecipeModel? recipe;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeVariantModel> variants;
  final String? error;

  RecipeDetailState({
    required this.isLoading,
    this.recipe,
    required this.ingredients,
    required this.variants,
    this.error,
  });

  factory RecipeDetailState.initial() {
    return RecipeDetailState(isLoading: false, ingredients: [], variants: []);
  }

  RecipeDetailState copyWith({
    bool? isLoading,
    RecipeModel? recipe,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeVariantModel>? variants,
    String? error,
  }) {
    return RecipeDetailState(
      isLoading: isLoading ?? this.isLoading,
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      variants: variants ?? this.variants,
      error: error ?? this.error,
    );
  }
}
