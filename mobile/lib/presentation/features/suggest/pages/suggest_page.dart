import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/presentation/features/suggest/cubit/suggest_cubit.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggest_filters.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggestion_card.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/image_analysis_widget.dart';

class SuggestPage extends StatelessWidget {
  const SuggestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        // Configure Dio for ngrok tunnel
        dio.options.baseUrl = AppConfig.ngrokBaseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);

        // Add ngrok-skip-browser-warning header
        dio.options.headers['ngrok-skip-browser-warning'] = 'true';

        final apiService = ApiService(dio);
        return SuggestCubit(apiService);
      },
      child: const SuggestPageView(),
    );
  }
}

class SuggestPageView extends StatefulWidget {
  const SuggestPageView({super.key});

  @override
  State<SuggestPageView> createState() => _SuggestPageViewState();
}

class _SuggestPageViewState extends State<SuggestPageView> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;
  bool _showImageAnalysis = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onIngredientsDetected(List<Map<String, dynamic>> ingredients) {
    // TODO: Use detected ingredients for suggestions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã nhận diện ${ingredients.length} nguyên liệu!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await context.read<SuggestCubit>().searchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          cacheExtent: 1000,
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
                  'Gợi ý món ăn',
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
                        top: 35, // ✅ Tăng từ 25 lên 35 để xuống thấp hơn
                        child: Icon(
                          Icons.lightbulb,
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
                            // Recipes Button
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
                                  onTap: () => context.go('/recipes'),
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
                                          Icons.menu_book,
                                          size: 14, // ✅ Giảm từ 16 xuống 14
                                          color: AppTheme.primaryGreen,
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ), // ✅ Giảm từ 4 xuống 3
                                        Text(
                                          'Công thức',
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
                            const SizedBox(width: 6),
                            // Camera Button - NEW!
                            Container(
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showImageAnalysis = !_showImageAnalysis;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      _showImageAnalysis
                                          ? Icons.close
                                          : Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Filter Button
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
                                  onTap: () {
                                    setState(() {
                                      _showFilters = !_showFilters;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      _showFilters
                                          ? Icons.filter_list_off
                                          : Icons.filter_list,
                                      size: 14,
                                      color: AppTheme.primaryGreen,
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

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Image Analysis Section - Animated
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showImageAnalysis
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                child: ImageAnalysisWidget(
                                  apiService: context
                                      .read<SuggestCubit>()
                                      .apiService,
                                  onIngredientsDetected: _onIngredientsDetected,
                                  onClose: () {
                                    setState(() {
                                      _showImageAnalysis = false;
                                    });
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Filters Section - Animated
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showFilters
                            ? Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
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
                                child: SuggestFiltersWidget(
                                  selectedRegion: state.selectedRegion,
                                  selectedSeason: state.selectedSeason,
                                  servings: state.servings,
                                  budget: state.budget,
                                  spicePreference: state.spicePreference,
                                  maxTime: state.maxTime,
                                  onRegionChanged: (region) => context
                                      .read<SuggestCubit>()
                                      .updateRegion(region),
                                  onSeasonChanged: (season) => context
                                      .read<SuggestCubit>()
                                      .updateSeason(season),
                                  onServingsChanged: (servings) => context
                                      .read<SuggestCubit>()
                                      .updateServings(servings),
                                  onBudgetChanged: (budget) => context
                                      .read<SuggestCubit>()
                                      .updateBudget(budget),
                                  onSpicePreferenceChanged: (spice) => context
                                      .read<SuggestCubit>()
                                      .updateSpicePreference(spice),
                                  onMaxTimeChanged: (time) => context
                                      .read<SuggestCubit>()
                                      .updateMaxTime(time),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Search Button - Enhanced
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: state.isSearching
                                ? null
                                : AppTheme.primaryGradient,
                            boxShadow: state.isSearching
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: state.isSearching
                                  ? null
                                  : () => context
                                        .read<SuggestCubit>()
                                        .searchSuggestions(),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.isSearching)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    const SizedBox(width: 12),
                                    Text(
                                      state.isSearching
                                          ? 'Đang tìm kiếm...'
                                          : 'Tìm gợi ý phù hợp',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Error Message
                      if (state.error != null)
                        Container(
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
                                onPressed: () =>
                                    context.read<SuggestCubit>().clearError(),
                                icon: const Icon(
                                  Icons.close,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Loading Shimmer - Show when searching
                      if (state.isSearching) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppTheme.primaryGreen,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Đang tìm gợi ý cho bạn...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const SuggestionCardShimmer(),
                              const SuggestionCardShimmer(),
                              const SuggestionCardShimmer(),
                            ],
                          ),
                        ),
                      ]
                      // Suggestions List
                      else if (state.suggestions.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gợi ý cho bạn (${state.suggestions.length})',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.suggestions.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SuggestionCard(
                              suggestion: suggestion,
                              onTap: () {
                                // Navigate to recipe detail
                                context.go('/recipes/${suggestion.recipeId}');
                              },
                              onAddToMealPlan: () {
                                // Add to meal plan logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã thêm "${suggestion.recipeName}" vào kế hoạch',
                                    ),
                                    backgroundColor: AppTheme.primaryGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ] else if (!state.isSearching && !state.isLoading) ...[
                        // Empty State - Enhanced
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                AppTheme.primaryGreen.withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryGreen.withOpacity(
                                            0.1,
                                          ),
                                          AppTheme.primaryGreen.withOpacity(
                                            0.05,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(70),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryGreen
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_outline,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Chưa có gợi ý nào',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Hãy điều chỉnh bộ lọc và nhấn "Tìm gợi ý phù hợp" để khám phá các món ăn ngon phù hợp với bạn',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Nhấn nút bộ lọc phía trên để bắt đầu',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 100,
                      ), // Bottom padding for navigation
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer loading card for suggestions
class SuggestionCardShimmer extends StatelessWidget {
  const SuggestionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 16,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              height: 14,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 14,
                              width: 60,
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
              const SizedBox(height: 16),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
