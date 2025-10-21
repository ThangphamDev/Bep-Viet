import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/presentation/features/suggest/cubit/suggest_cubit.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggest_filters.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggestion_card.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await context.read<SuggestCubit>().searchSuggestions();
  }

  Future<void> _showMealSlotDialog(SuggestionModel suggestion) async {
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
                'Thêm vào hôm nay',
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
              suggestion.recipeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn bữa ăn:',
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
      // Delay nhỏ để đảm bảo dialog chọn bữa đã đóng hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _addToToday(suggestion, mealSlot);
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
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToToday(SuggestionModel suggestion, String mealSlot) async {
    bool isLoading = false;

    try {
      // Get token first
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      if (!mounted) return;

      // Show loading AFTER checking token
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang thêm vào kế hoạch...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      isLoading = true;

      // Call API
      final dio = Dio();
      dio.options.baseUrl = AppConfig.ngrokBaseUrl;
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';
      final apiService = ApiService(dio);

      await apiService.quickAddToToday(
        token: token,
        recipeId: suggestion.recipeId,
        mealSlot: mealSlot,
        servings: suggestion.servings ?? 2,
        variantRegion: suggestion.variantRegion,
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
                  'Đã thêm "${suggestion.recipeName}" vào ${_getMealSlotName(mealSlot)}',
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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            // Modern Compact App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              elevation: 0,
              forceElevated: false,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Gợi ý món ăn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Công thức Button
                          _buildActionButton(
                            icon: Icons.menu_book,
                            label: 'Công thức',
                            onTap: () => context.go('/recipes'),
                            isPrimary: false,
                          ),
                          const SizedBox(width: 8),
                          // AI Camera Button
                          _buildActionButton(
                            icon: Icons.camera_alt,
                            label: 'AI',
                            onTap: () => context.go('/ai-suggest'),
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Quick Filters Bar
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        // Region Filter
                        const Text(
                          'Vùng miền',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickFilterChip(
                                'Tất cả',
                                state.selectedRegion.isEmpty,
                                () => context.read<SuggestCubit>().updateRegion(
                                  '',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickFilterChip(
                                'Miền Bắc',
                                state.selectedRegion == 'BAC',
                                () => context.read<SuggestCubit>().updateRegion(
                                  'BAC',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickFilterChip(
                                'Miền Trung',
                                state.selectedRegion == 'TRUNG',
                                () => context.read<SuggestCubit>().updateRegion(
                                  'TRUNG',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickFilterChip(
                                'Miền Nam',
                                state.selectedRegion == 'NAM',
                                () => context.read<SuggestCubit>().updateRegion(
                                  'NAM',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // More Filters Button
                        InkWell(
                          onTap: () =>
                              setState(() => _showFilters = !_showFilters),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showFilters ? Icons.expand_less : Icons.tune,
                                  size: 18,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showFilters
                                      ? 'Ẩn bộ lọc'
                                      : 'Bộ lọc nâng cao',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Advanced Filters (Collapsible)
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showFilters
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryGreen.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
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
                  );
                },
              ),
            ),

            // Search Button
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: ElevatedButton(
                      onPressed: state.isSearching
                          ? null
                          : () => context
                                .read<SuggestCubit>()
                                .searchSuggestions(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: state.isSearching ? 0 : 4,
                        shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(Icons.search, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            state.isSearching
                                ? 'Đang tìm kiếm...'
                                : 'Tìm gợi ý phù hợp',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Column(
                    children: [
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
                                // Navigate to recipe detail - use push to keep navigation stack
                                context.push('/recipes/${suggestion.recipeId}');
                              },
                              onAddToMealPlan: () =>
                                  _showMealSlotDialog(suggestion),
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

  // Helper: Build action button in header
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isPrimary ? 0.15 : 0.08),
                blurRadius: isPrimary ? 8 : 4,
                offset: Offset(0, isPrimary ? 3 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Build quick filter chip
  Widget _buildQuickFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.grey.shade100,
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
