import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

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
        final cubit = RecipesCubit(apiService);
        // Load initial recipes
        cubit.loadRecipes();
        return cubit;
      },
      child: const RecipesPageView(),
    );
  }
}

class RecipesPageView extends StatefulWidget {
  const RecipesPageView({super.key});

  @override
  State<RecipesPageView> createState() => _RecipesPageViewState();
}

class _RecipesPageViewState extends State<RecipesPageView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = '';
  int? _maxTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    context.read<RecipesCubit>().loadRecipes(
          region: _selectedRegion.isEmpty ? null : _selectedRegion,
          maxTime: _maxTime,
      search: _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<RecipesCubit, RecipesState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(), // ✅ Scroll mượt mà hơn
            cacheExtent: 1000, // ✅ Cache để scroll mượt
              slivers: [
              // Custom App Bar
                SliverAppBar(
                expandedHeight: 120, // ✅ Giảm từ 140 xuống 120
                floating: false,
                  pinned: true,
                backgroundColor:
                    AppTheme.primaryGreen, // ✅ Giữ màu xanh khi collapse
                  elevation: 0,
                forceElevated: false, // ✅ Tắt elevation để giảm jank
                stretch: false, // ✅ Tắt stretch để giảm jank
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Công thức',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Stack(
                      children: [
                        // Background Icon
                        const Positioned(
                          left: 20,
                          top: 35, // ✅ Tăng từ 30 lên 35 để xuống thấp hơn
                          child: Icon(
                            Icons.menu_book,
                            size: 28, // ✅ Giảm từ 32 xuống 28
                            color: Colors.white70,
                          ),
                        ),
                        // Action Buttons
                        Positioned(
                          right: 16,
                          top: 30, // ✅ Tăng từ 20 lên 30 để xuống thấp hơn
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Suggestions Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.go('/suggest'),
                                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, // ✅ Giảm từ 12 xuống 10
                                        vertical: 6, // ✅ Giảm từ 8 xuống 6
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lightbulb,
                                            size: 14, // ✅ Giảm từ 16 xuống 14
                                            color: AppTheme.primaryGreen,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ), // ✅ Giảm từ 4 xuống 3
                                          Text(
                                            'Gợi ý',
                                            style: TextStyle(
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  11, // ✅ Giảm từ 12 xuống 11
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),

              // Search and Filters
                SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm công thức...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _loadRecipes();
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade400,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _loadRecipes(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Region Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildModernFilterChip(
                              'Tất cả',
                              _selectedRegion.isEmpty,
                              () {
                                setState(() {
                                  _selectedRegion = '';
                                });
                                _loadRecipes();
                              },
                            ),
                            _buildModernFilterChip(
                              'Miền Bắc',
                              _selectedRegion == 'BAC',
                              () {
                                setState(() {
                                  _selectedRegion = 'BAC';
                                });
                                _loadRecipes();
                              },
                            ),
                            _buildModernFilterChip(
                              'Miền Trung',
                              _selectedRegion == 'TRUNG',
                              () {
                                setState(() {
                                  _selectedRegion = 'TRUNG';
                                });
                                _loadRecipes();
                              },
                            ),
                            _buildModernFilterChip(
                              'Miền Nam',
                              _selectedRegion == 'NAM',
                              () {
                                setState(() {
                                  _selectedRegion = 'NAM';
                                });
                        _loadRecipes();
                      },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Filter
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Thời gian tối đa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_maxTime ?? 60} phút',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.primaryGreen,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: AppTheme.primaryGreen,
                                overlayColor: AppTheme.primaryGreen.withOpacity(
                                  0.2,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: (_maxTime ?? 60).toDouble(),
                                min: 15,
                                max: 120,
                                divisions: 7,
                                onChanged: (value) {
                                  setState(() {
                                    _maxTime = value.round();
                                  });
                        _loadRecipes();
                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Error Message
              if (state.error != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<RecipesCubit>().clearError();
                            _loadRecipes();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading Shimmer
              if (state.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                          childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                      (context, index) => const RecipeCardShimmer(),
                      childCount: 6, // Show 6 shimmer cards
                    ),
                  ),
                ),

              // Recipes Grid
              if (!state.isLoading && state.recipes.isNotEmpty)
                  SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                              final recipe = state.recipes[index];
                      return ModernRecipeCard(
                        recipe: recipe,
                        onTap: () => context.go('/recipes/${recipe.id}'),
                      );
                    }, childCount: state.recipes.length),
                  ),
                ),

              // Empty State
              if (!state.isLoading && state.recipes.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            size: 60,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Không tìm thấy công thức',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Recipe Card Widget
class ModernRecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap;

  const ModernRecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                // Recipe Image
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey.shade200,
                  ),
                  child: recipe.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                child: CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
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
                            errorWidget: (context, url, error) =>
                                _buildPlaceholderImage(),
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),

                // Recipe Info
                Container(
                  padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                children: [
                      // Recipe Name
                  Text(
                    recipe.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.1,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Region badge
                      if (recipe.baseRegion != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getRegionDisplay(recipe.baseRegion!),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),

                      // Stats row
                  Row(
                    children: [
                      if (recipe.cookTimeMinutes != null) ...[
                            _buildStatChip(
                              Icons.access_time,
                              '${recipe.cookTimeMinutes}m',
                            ),
                        const SizedBox(width: 4),
                          ],
                          if (recipe.difficulty != null)
                            _buildStatChip(
                              Icons.star,
                              '${recipe.difficulty}/5',
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Colors.grey.shade200,
      ),
      child: const Center(
        child: Icon(Icons.restaurant, size: 32, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppTheme.textSecondary),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Shimmer Loading Card
class RecipeCardShimmer extends StatelessWidget {
  const RecipeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            // Content placeholder
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 9,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        height: 14,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 14,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
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
}

// Simple Cubit for Recipes
class RecipesCubit extends Cubit<RecipesState> {
  final ApiService _apiService;

  RecipesCubit(this._apiService) : super(RecipesState());

  Future<void> loadRecipes({
    String? region,
    int? maxTime,
    String? search,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final recipes = await _apiService.getRecipes(
        region: region,
        maxTime: maxTime,
        search: search,
        limit: 50, // Limit to 50 recipes
      );

      emit(state.copyWith(recipes: recipes, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

class RecipesState {
  final List<RecipeModel> recipes;
  final bool isLoading;
  final String? error;

  RecipesState({this.recipes = const [], this.isLoading = false, this.error});

  RecipesState copyWith({
    List<RecipeModel>? recipes,
    bool? isLoading,
    String? error,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
