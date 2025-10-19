import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/presentation/features/suggest/cubit/suggest_cubit.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggest_filters.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggestion_card.dart';

class SuggestPage extends StatelessWidget {
  const SuggestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SuggestCubit(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
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
                'Gợi ý món ăn',
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
                  child: Icon(Icons.lightbulb, size: 40, color: Colors.white),
                ),
              ),
            ),
            actions: [
              // Recipes Button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/recipes'),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Công thức'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              // Filter Toggle Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: BlocBuilder<SuggestCubit, SuggestState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Filters Section
                    if (_showFilters) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SuggestFiltersWidget(
                          selectedRegion: state.selectedRegion,
                          selectedSeason: state.selectedSeason,
                          servings: state.servings,
                          budget: state.budget,
                          spicePreference: state.spicePreference,
                          maxTime: state.maxTime,
                          onRegionChanged: (region) =>
                              context.read<SuggestCubit>().updateRegion(region),
                          onSeasonChanged: (season) =>
                              context.read<SuggestCubit>().updateSeason(season),
                          onServingsChanged: (servings) => context
                              .read<SuggestCubit>()
                              .updateServings(servings),
                          onBudgetChanged: (budget) =>
                              context.read<SuggestCubit>().updateBudget(budget),
                          onSpicePreferenceChanged: (spice) => context
                              .read<SuggestCubit>()
                              .updateSpicePreference(spice),
                          onMaxTimeChanged: (time) =>
                              context.read<SuggestCubit>().updateMaxTime(time),
                        ),
                      ),
                    ],

                    // Search Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isSearching
                              ? null
                              : () => context
                                    .read<SuggestCubit>()
                                    .searchSuggestions(),
                          icon: state.isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(
                            state.isSearching
                                ? 'Đang tìm kiếm...'
                                : 'Tìm gợi ý',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 16),

                    // Suggestions List
                    if (state.suggestions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
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
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ] else if (!state.isSearching && !state.isLoading) ...[
                      // Empty State
                      Container(
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
                                Icons.lightbulb_outline,
                                size: 60,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Chưa có gợi ý nào',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hãy điều chỉnh bộ lọc và nhấn "Tìm gợi ý" để xem các món ăn phù hợp',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
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
    );
  }
}
