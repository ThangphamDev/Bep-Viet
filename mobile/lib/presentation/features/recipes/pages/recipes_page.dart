import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
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
        dio.options.baseUrl = AppConfig.ngrokBaseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        dio.options.headers['ngrok-skip-browser-warning'] = 'true';

        final apiService = ApiService(dio);
        final cubit = RecipesCubit(apiService);
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
  final ScrollController _scrollController = ScrollController();
  String _selectedRegion = '';
  int? _maxTime = 60;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    context.read<RecipesCubit>().loadRecipes(
      region: _selectedRegion.isEmpty ? null : _selectedRegion,
      maxTime: _maxTime,
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  Future<void> _handleRefresh() async {
    _loadRecipes();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _handleRefresh,
        child: BlocBuilder<RecipesCubit, RecipesState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              cacheExtent: 1000,
              slivers: [
                // App Bar với gradient
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.primaryGreen,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    centerTitle: true,
                    title: const Text(
                      'Công thức',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeaderIconButton(
                                  icon: Icons.favorite_outline,
                                  onTap: () => context.push('/favorites'),
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderIconButton(
                                  icon: Icons.lightbulb_outline,
                                  onTap: () => context.go('/suggest'),
                                  isHighlight: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm công thức...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.primaryGreen,
                          size: 22,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                  _loadRecipes();
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _loadRecipes(),
                    ),
                  ),
                ),

                // Region Filters
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vùng miền',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildRegionChip(
                                'Tất cả',
                                _selectedRegion.isEmpty,
                                '',
                              ),
                              _buildRegionChip(
                                'Miền Bắc',
                                _selectedRegion == 'BAC',
                                'BAC',
                              ),
                              _buildRegionChip(
                                'Miền Trung',
                                _selectedRegion == 'TRUNG',
                                'TRUNG',
                              ),
                              _buildRegionChip(
                                'Miền Nam',
                                _selectedRegion == 'NAM',
                                'NAM',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Time Filter
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Thời gian tối đa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${_maxTime ?? 60} phút',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primaryGreen,
                              inactiveTrackColor: Colors.grey.shade300,
                              thumbColor: AppTheme.primaryGreen,
                              overlayColor: AppTheme.primaryGreen.withOpacity(
                                0.2,
                              ),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
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
                              },
                              onChangeEnd: (_) => _loadRecipes(),
                            ),
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
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                              ),
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
                        childCount: 6,
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
                          onTap: () => context.push('/recipes/${recipe.id}'),
                        );
                      }, childCount: state.recipes.length),
                    ),
                  ),

                // Empty State
                if (!state.isLoading && state.recipes.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen.withOpacity(0.1),
                                  AppTheme.primaryGreen.withOpacity(0.05),
                                ],
                              ),
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
                            'Hãy thử thay đổi từ khóa tìm kiếm\nhoặc điều chỉnh bộ lọc',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                              height: 1.5,
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
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlight ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: isHighlight
              ? null
              : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isHighlight ? AppTheme.primaryGreen : Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegionChip(String label, bool isSelected, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRegion = value;
          });
          _loadRecipes();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
        limit: 50,
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
