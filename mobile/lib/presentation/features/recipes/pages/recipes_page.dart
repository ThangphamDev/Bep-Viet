import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/constants/app_constants.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';

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
  String _selectedMealType = '';
  int? _maxTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecipes() {
    context.read<RecipesCubit>().loadRecipes(
      mealType: _selectedMealType.isEmpty ? null : _selectedMealType,
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
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.surfaceColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Công thức',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.go('/suggest'),
                    icon: const Icon(
                      Icons.lightbulb,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),

              // Search and Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công thức...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadRecipes();
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _loadRecipes(),
                      ),
                      const SizedBox(height: 16),

                      // Meal Type Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Tất cả',
                              _selectedMealType.isEmpty,
                              () {
                                setState(() {
                                  _selectedMealType = '';
                                });
                                _loadRecipes();
                              },
                            ),
                            ...AppConstants.mealTypeNames.entries.map((entry) {
                              return _buildFilterChip(
                                entry.value,
                                _selectedMealType == entry.key,
                                () {
                                  setState(() {
                                    _selectedMealType = entry.key;
                                  });
                                  _loadRecipes();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Filter
                      Row(
                        children: [
                          const Text('Thời gian tối đa: '),
                          Expanded(
                            child: Slider(
                              value: (_maxTime ?? 60).toDouble(),
                              min: 15,
                              max: 120,
                              divisions: 7,
                              activeColor: AppTheme.primaryGreen,
                              onChanged: (value) {
                                setState(() {
                                  _maxTime = value.round();
                                });
                                _loadRecipes();
                              },
                            ),
                          ),
                          Text('${_maxTime ?? 60} phút'),
                        ],
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

              // Loading Indicator
              if (state.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),

              // Recipes List
              if (!state.isLoading && state.recipes.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final recipe = state.recipes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () => context.go('/recipes/${recipe.id}'),
                      ),
                    );
                  }, childCount: state.recipes.length),
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

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryGreen,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// Simple Recipe Card Widget
class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Recipe Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: recipe.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),
                const SizedBox(width: 16),

                // Recipe Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Meal type badge
                      if (recipe.mealType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppConstants.mealTypeNames[recipe.mealType!] ??
                                recipe.mealType!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Stats row
                      Row(
                        children: [
                          if (recipe.cookTimeMinutes != null)
                            _buildStatChip(
                              Icons.access_time,
                              '${recipe.cookTimeMinutes} phút',
                            ),
                          if (recipe.cookTimeMinutes != null &&
                              recipe.servings != null)
                            const SizedBox(width: 8),
                          if (recipe.servings != null)
                            _buildStatChip(
                              Icons.people,
                              '${recipe.servings} người',
                            ),
                          if (recipe.servings != null &&
                              recipe.difficulty != null)
                            const SizedBox(width: 8),
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

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: const Icon(
        Icons.restaurant,
        size: 32,
        color: AppTheme.textTertiary,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Simple Cubit for Recipes
class RecipesCubit extends Cubit<RecipesState> {
  final ApiService _apiService;

  RecipesCubit(this._apiService) : super(RecipesState());

  Future<void> loadRecipes({
    String? mealType,
    int? maxTime,
    String? search,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final recipes = await _apiService.getRecipes(
        mealType: mealType,
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
