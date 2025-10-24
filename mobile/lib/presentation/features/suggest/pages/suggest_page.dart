import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';
import 'package:bepviet_mobile/presentation/features/suggest/cubit/suggest_cubit.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggest_filters.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggestion_card.dart';
import 'package:bepviet_mobile/presentation/features/planner/cubit/meal_plan_cubit.dart';

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
  final ValueNotifier<bool> _showRecipeButton = ValueNotifier<bool>(true);
  bool _showFilters = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce: Only check 150ms after scroll stops
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      // Show button only at top of page (offset <= 100)
      final shouldShow = _scrollController.offset <= 100;

      // Only update if changed (avoid unnecessary rebuilds)
      if (_showRecipeButton.value != shouldShow) {
        _showRecipeButton.value = shouldShow;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showRecipeButton.dispose();
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
        // ⚠️ CHECK ALLERGENS FIRST (Premium Family feature)
        await _checkAllergensAndAdd(suggestion, mealSlot);
      }
    }
  }

  /// ⚠️ Check allergens before adding meal (Premium Family feature)
  Future<void> _checkAllergensAndAdd(
    SuggestionModel suggestion,
    String mealSlot,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) {
        await _addToToday(suggestion, mealSlot);
        return;
      }

      // Create API service
      final dio = Dio();
      dio.options.baseUrl = AppConfig.ngrokBaseUrl;
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';
      final apiService = ApiService(dio);

      // Check allergens
      final allergenResponse = await apiService.checkRecipeAllergens(
        token,
        suggestion.recipeId,
      );

      if (!mounted) return;

      // If has conflicts → Show warning dialog
      if (allergenResponse.hasConflicts &&
          allergenResponse.conflicts.isNotEmpty) {
        final shouldAdd = await _showAllergenWarningDialog(
          suggestion,
          allergenResponse.conflicts,
        );

        if (shouldAdd == true && mounted) {
          await _addToToday(suggestion, mealSlot);
        }
      } else {
        // No conflicts → Add directly
        await _addToToday(suggestion, mealSlot);
      }
    } catch (e) {
      // If allergen check fails → Add directly (fail-safe)
      if (mounted) {
        await _addToToday(suggestion, mealSlot);
      }
    }
  }

  /// ⚠️ Show allergen warning dialog
  Future<bool?> _showAllergenWarningDialog(
    SuggestionModel suggestion,
    List<AllergenConflict> conflicts,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6B6B),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cảnh báo dị ứng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Món "${suggestion.recipeName}" có nguyên liệu mà thành viên trong gia đình bị dị ứng:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // List conflicts
              ...conflicts.map(
                (conflict) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 16,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              conflict.memberName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Dị ứng với:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: conflict.conflictingIngredients.map((ing) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              ing.ingredientName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn có chắc chắn muốn thêm món này?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vẫn thêm',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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

      // Show loading dialog
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

      // Get or create meal plan for today's week (same logic as planner)
      final mealPlanCubit = context.read<MealPlanCubit>();
      final currentState = mealPlanCubit.state;

      // Get today's date and week start
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final weekStart = todayDate.subtract(
        Duration(days: todayDate.weekday - 1),
      );
      final weekString = DateFormat('yyyy-MM-dd').format(weekStart);

      String mealPlanId = '';

      // Find existing meal plan for this week
      final existingPlan = currentState.mealPlans
          .where((plan) => plan.weekStartDate == weekString)
          .firstOrNull;

      if (existingPlan != null) {
        mealPlanId = existingPlan.id;
      } else {
        // Create new meal plan for this week
        await mealPlanCubit.createMealPlan(
          weekString,
          note: 'Kế hoạch tuần ${DateFormat('dd/MM').format(weekStart)}',
        );

        // Get the newly created plan
        final newState = mealPlanCubit.state;
        if (newState.mealPlans.isNotEmpty) {
          mealPlanId = newState.mealPlans.last.id;
        } else {
          throw Exception('Không thể tạo kế hoạch bữa ăn');
        }
      }

      // Create AddMealDto (same as planner)
      final dto = AddMealDto(
        date: DateFormat('yyyy-MM-dd').format(todayDate),
        mealSlot: mealSlot,
        recipeId: suggestion.recipeId,
        servings: suggestion.servings ?? 2,
      );

      // Add meal to plan using MealPlanCubit (same as planner)
      await mealPlanCubit.addMealToPlan(mealPlanId, dto);

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
            // 🎨 NEW: Modern Header with Gradient
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý món ăn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Khám phá món ăn phù hợp với bạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 80,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        // AI Camera Button
                        Positioned(
                          top: 8,
                          right: 16,
                          child: _buildAICameraButton(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🎯 NEW: Quick Region Filter Cards
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Vùng miền',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Region cards grid
                        Row(
                          children: [
                            _buildRegionCard(
                              '🇻🇳 Tất cả',
                              state.selectedRegion.isEmpty,
                              () =>
                                  context.read<SuggestCubit>().updateRegion(''),
                            ),
                            const SizedBox(width: 8),
                            _buildRegionCard(
                              '🏔️ Bắc',
                              state.selectedRegion == 'BAC',
                              () => context.read<SuggestCubit>().updateRegion(
                                'BAC',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRegionCard(
                              '🏝️ Trung',
                              state.selectedRegion == 'TRUNG',
                              () => context.read<SuggestCubit>().updateRegion(
                                'TRUNG',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRegionCard(
                              '🌴 Nam',
                              state.selectedRegion == 'NAM',
                              () => context.read<SuggestCubit>().updateRegion(
                                'NAM',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Advanced filter button
                        InkWell(
                          onTap: () =>
                              setState(() => _showFilters = !_showFilters),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _showFilters
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: _showFilters
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryGreen
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showFilters ? Icons.expand_less : Icons.tune,
                                  size: 20,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showFilters
                                      ? 'Ẩn bộ lọc nâng cao'
                                      : 'Mở bộ lọc nâng cao',
                                  style: const TextStyle(
                                    fontSize: 14,
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

            // 🔍 NEW: Modern Search Button
            SliverToBoxAdapter(
              child: BlocBuilder<SuggestCubit, SuggestState>(
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: state.isSearching
                          ? null
                          : () => context
                                .read<SuggestCubit>()
                                .searchSuggestions(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.search, size: 18),
                            ),
                          const SizedBox(width: 12),
                          Text(
                            state.isSearching
                                ? 'Đang tìm kiếm...'
                                : 'Tìm gợi ý phù hợp',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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

                      // ✨ Loading Shimmer - Show when searching
                      if (state.isSearching) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Modern loading header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryGreen.withOpacity(0.1),
                                      AppTheme.primaryGreen.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Đang tìm kiếm...',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Chúng tôi đang tìm món ăn phù hợp nhất',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const SuggestionCardShimmer(),
                              const SuggestionCardShimmer(),
                            ],
                          ),
                        ),
                      ]
                      // 🎯 Suggestions List Header
                      else if (state.suggestions.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen.withOpacity(0.1),
                                AppTheme.primaryGreen.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
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
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tìm thấy ${state.suggestions.length} món',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Được gợi ý dựa trên sở thích của bạn',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            // Suggestions List - Use SliverList for better performance
            BlocBuilder<SuggestCubit, SuggestState>(
              buildWhen: (previous, current) =>
                  previous.suggestions != current.suggestions ||
                  previous.isSearching != current.isSearching,
              builder: (context, state) {
                if (state.suggestions.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final suggestion = state.suggestions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RepaintBoundary(
                        child: SuggestionCard(
                          key: ValueKey(suggestion.recipeId),
                          suggestion: suggestion,
                          onTap: () {
                            context.push('/recipes/${suggestion.recipeId}');
                          },
                          onAddToMealPlan: () =>
                              _showMealSlotDialog(suggestion),
                        ),
                      ),
                    );
                  }, childCount: state.suggestions.length),
                );
              },
            ),

            // Empty State
            BlocBuilder<SuggestCubit, SuggestState>(
              buildWhen: (previous, current) =>
                  previous.suggestions != current.suggestions ||
                  previous.isSearching != current.isSearching ||
                  previous.isLoading != current.isLoading,
              builder: (context, state) {
                if (state.suggestions.isNotEmpty ||
                    state.isSearching ||
                    state.isLoading) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child: Container(
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
                                    AppTheme.primaryGreen.withOpacity(0.1),
                                    AppTheme.primaryGreen.withOpacity(0.05),
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
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.3,
                                    ),
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
                        const Text(
                          'Hãy điều chỉnh bộ lọc và nhấn "Tìm gợi ý phù hợp" để khám phá các món ăn ngon phù hợp với bạn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                );
              },
            ),

            // Bottom Padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      // Floating Recipe Button - Bottom Left
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showRecipeButton,
        builder: (context, isVisible, child) {
          return _RecipeFloatingButton(isVisible: isVisible);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // 🎨 NEW: AI Camera Button
  Widget _buildAICameraButton(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/ai-suggest'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'AI Scan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 NEW: Region Card
  Widget _buildRegionCard(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized Floating Button Widget - Only rebuilds this widget
class _RecipeFloatingButton extends StatelessWidget {
  final bool isVisible;

  const _RecipeFloatingButton({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      curve: Curves.easeInOut,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isVisible ? 1.0 : 0.8,
        curve: Curves.easeOutBack,
        child: Visibility(
          visible: isVisible,
          maintainSize: false,
          maintainAnimation: true,
          maintainState: true,
          child: FloatingActionButton.extended(
            heroTag: 'recipe_fab',
            onPressed: () => context.go('/recipes'),
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryGreen,
            elevation: isVisible ? 8 : 0,
            icon: const Icon(Icons.menu_book_outlined, size: 24),
            label: const Text(
              'Công thức',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 NEW: Modern Shimmer loading card
class SuggestionCardShimmer extends StatelessWidget {
  const SuggestionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            // Content shimmer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Reason box
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action button
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
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
