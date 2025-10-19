import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/constants/app_constants.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeDetailCubit(ApiService(Dio()), recipeId),
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedVariantRegion = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RecipeDetailCubit>().loadRecipe();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

          return CustomScrollView(
            slivers: [
              // Custom App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.surfaceColor,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Add to favorites
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã thêm vào yêu thích'),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Share recipe
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
                flexibleSpace: FlexibleSpaceBar(
                  background: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),

              // Recipe Info
              SliverToBoxAdapter(
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
                            '${recipe.totalTimeMinutes ?? 0} phút',
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            Icons.people,
                            'Khẩu phần',
                            '${recipe.servings ?? 1} người',
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            Icons.star,
                            'Độ khó',
                            '${recipe.difficulty ?? 1}/5',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Region Variants
                      if (state.variants.isNotEmpty) ...[
                        Text(
                          'Biến thể theo vùng:',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: state.variants.map((variant) {
                              final isSelected =
                                  variant.region == _selectedVariantRegion;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedVariantRegion = variant.region;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryGreen
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryGreen
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      AppConstants.regionNames[variant
                                              .region] ??
                                          variant.region,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Cost Estimate
                      if (state.variants.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chi phí ước tính: ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${(state.variants.firstWhere((v) => v.region == _selectedVariantRegion, orElse: () => state.variants.first).estimatedCost ?? 0) / 1000}k VNĐ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.surfaceColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryGreen,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primaryGreen,
                    tabs: const [
                      Tab(text: 'Nguyên liệu'),
                      Tab(text: 'Cách làm'),
                      Tab(text: 'Thông tin'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIngredientsTab(state),
                    _buildStepsTab(state),
                    _buildInfoTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
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
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add to meal plan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm vào kế hoạch bữa ăn'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Thêm vào kế hoạch'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Start cooking
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bắt đầu nấu ăn'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu nấu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(height: 4),
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
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab(RecipeDetailState state) {
    final selectedVariant = state.variants.firstWhere(
      (v) => v.region == _selectedVariantRegion,
      orElse: () => state.variants.isNotEmpty
          ? state.variants.first
          : RecipeVariantModel(region: _selectedVariantRegion),
    );

    final ingredients =
        selectedVariant.ingredients ?? state.recipe?.ingredients ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_grocery_store,
                  color: AppTheme.primaryGreen,
                  size: 20,
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
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (ingredient.notes != null)
                      Text(
                        ingredient.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${ingredient.quantity} ${ingredient.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsTab(RecipeDetailState state) {
    final selectedVariant = state.variants.firstWhere(
      (v) => v.region == _selectedVariantRegion,
      orElse: () => state.variants.isNotEmpty
          ? state.variants.first
          : RecipeVariantModel(region: _selectedVariantRegion),
    );

    final steps = selectedVariant.steps ?? state.recipe?.steps ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                      step.instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    if (step.durationMinutes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${step.durationMinutes} phút',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(RecipeDetailState state) {
    final recipe = state.recipe!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Thông tin cơ bản', [
            _buildInfoRow('Tên món', recipe.name),
            if (recipe.mealType != null)
              _buildInfoRow(
                'Loại bữa ăn',
                AppConstants.mealTypeNames[recipe.mealType!] ??
                    recipe.mealType!,
              ),
            if (recipe.baseRegion != null)
              _buildInfoRow(
                'Vùng miền',
                AppConstants.regionNames[recipe.baseRegion!] ??
                    recipe.baseRegion!,
              ),
            if (recipe.servings != null)
              _buildInfoRow('Khẩu phần', '${recipe.servings} người'),
            if (recipe.totalTimeMinutes != null)
              _buildInfoRow('Thời gian nấu', '${recipe.totalTimeMinutes} phút'),
            if (recipe.difficulty != null)
              _buildInfoRow('Độ khó', '${recipe.difficulty}/5'),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Thời gian chi tiết', [
            if (recipe.prepTimeMinutes != null)
              _buildInfoRow('Chuẩn bị', '${recipe.prepTimeMinutes} phút'),
            if (recipe.cookTimeMinutes != null)
              _buildInfoRow('Nấu', '${recipe.cookTimeMinutes} phút'),
            if (recipe.totalTimeMinutes != null)
              _buildInfoRow(
                'Tổng thời gian',
                '${recipe.totalTimeMinutes} phút',
              ),
          ]),
          if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard('Tags', [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: recipe.tags!.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cubit for Recipe Detail
class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final ApiService _apiService;
  final String recipeId;

  RecipeDetailCubit(this._apiService, this.recipeId)
    : super(RecipeDetailState());

  Future<void> loadRecipe() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final recipe = await _apiService.getRecipeById(recipeId);
      final variants = await _apiService.getRecipeVariants(recipeId);

      emit(
        state.copyWith(recipe: recipe, variants: variants, isLoading: false),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class RecipeDetailState {
  final RecipeModel? recipe;
  final List<RecipeVariantModel> variants;
  final bool isLoading;
  final String? error;

  RecipeDetailState({
    this.recipe,
    this.variants = const [],
    this.isLoading = false,
    this.error,
  });

  RecipeDetailState copyWith({
    RecipeModel? recipe,
    List<RecipeVariantModel>? variants,
    bool? isLoading,
    String? error,
  }) {
    return RecipeDetailState(
      recipe: recipe ?? this.recipe,
      variants: variants ?? this.variants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
