import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/presentation/features/planner/cubit/meal_plan_cubit.dart';
import 'package:bepviet_mobile/presentation/features/pantry/cubit/pantry_cubit.dart';
import 'package:bepviet_mobile/presentation/widgets/recipe_selection_dialog.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
import 'package:bepviet_mobile/presentation/features/planner/services/cooking_service.dart';
import 'package:bepviet_mobile/presentation/features/planner/widgets/cooking_result_dialog.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedWeek = DateTime.now();

  // Cache for performance optimization
  String? _lastLoadedWeek;
  bool _isLoadingMealPlans = false;
  bool _disposed = false;
  bool _isGeneratingPlan = false; // Loading state cho smart planning

  // Debounce timer to prevent rapid successive calls
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('PlannerPage initState called');
    _selectedWeek = _getStartOfWeek(DateTime.now());

    // Delay initial load to avoid conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_disposed) {
        print('PlannerPage loading meal plans...');
        _loadMealPlansIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Normalize to local date-only (midnight) then get Monday as start of week
    final localDate = DateTime(date.year, date.month, date.day);
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }

  void _loadMealPlansIfNeeded() {
    if (_disposed || !mounted) return;

    final currentWeekString = DateFormat('yyyy-MM-dd').format(_selectedWeek);

    // Only load if we haven't loaded this week yet and not currently loading
    if (_lastLoadedWeek != currentWeekString && !_isLoadingMealPlans) {
      // Cancel previous timer if exists
      _debounceTimer?.cancel();

      // Add debounce to prevent rapid successive calls
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted && !_disposed) {
          _loadMealPlans();
        }
      });
    }
  }

  Future<void> _loadMealPlans() async {
    if (_disposed || !mounted || _isLoadingMealPlans)
      return; // Prevent multiple concurrent loads

    try {
      if (mounted) {
        setState(() {
          _isLoadingMealPlans = true;
        });
      }

      final dateString = DateFormat('yyyy-MM-dd').format(_selectedWeek);
      _lastLoadedWeek = dateString;

      await context.read<MealPlanCubit>().loadMealPlans(date: dateString);
    } catch (error) {
      if (mounted && !_disposed) {
        // Show timeout error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().contains('timeout')
                  ? 'Kết nối chậm, vui lòng thử lại'
                  : 'Lỗi tải dữ liệu, vui lòng thử lại',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _loadMealPlans(),
            ),
          ),
        );
      }
    } finally {
      if (mounted && !_disposed) {
        setState(() {
          _isLoadingMealPlans = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    print('PlannerPage build called');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kế hoạch bữa ăn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Nút Tủ lạnh
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.kitchen_outlined, size: 24),
              ),
              tooltip: 'Tủ lạnh',
              onPressed: () => context.go('/pantry'),
            ),
          ),
          // Nút Danh sách mua sắm
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 24),
              ),
              tooltip: 'Danh sách mua sắm',
              onPressed: () => context.go('/shopping'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildWeeklyPlanView(),
          if (_isGeneratingPlan)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang lập kế hoạch...',
                          style: TextStyle(fontSize: 16),
                        ),
          ],
        ),
      ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isGeneratingPlan
          ? null
          : FloatingActionButton.extended(
        onPressed: _showGeneratePlanDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          'Lập kế hoạch thông minh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        heroTag: 'smart_plan',
      ),
    );
  }

  Widget _buildWeeklyPlanView() {
    return BlocBuilder<MealPlanCubit, MealPlanState>(
      builder: (context, state) {
        return Column(
          children: [
            // Week Navigator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoadingMealPlans || _disposed
                          ? null
                          : () {
                              if (mounted && !_disposed) {
                                setState(() {
                                  _selectedWeek = _selectedWeek.subtract(
                                    const Duration(days: 7),
                                  );
                                });
                                _loadMealPlansIfNeeded();
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: _isLoadingMealPlans
                              ? Colors.grey.shade400
                              : AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            _getWeekRangeText(_selectedWeek),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (_isLoadingMealPlans) ...[
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 2,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoadingMealPlans || _disposed
                          ? null
                          : () {
                              if (mounted && !_disposed) {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    const Duration(days: 7),
                                  );
                                });
                                _loadMealPlansIfNeeded();
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: _isLoadingMealPlans
                              ? Colors.grey.shade400
                              : AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Meal Plan List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_disposed || !mounted) return;
                  // Reset cache and force reload
                  _lastLoadedWeek = null;
                  await _loadMealPlans();
                },
                child: _buildMealPlanContent(state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealPlanContent(MealPlanState state) {
    print(
      'PlannerPage: _buildMealPlanContent - isLoading: ${state.isLoading}, error: ${state.error}, mealPlans count: ${state.mealPlans.length}',
    );

    // Don't show loading indicator if we're in smart planning mode
    // (we already have the overlay loading indicator)
    if (state.isLoading && !_isGeneratingPlan) {
      print('PlannerPage: Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      print('PlannerPage: Showing error: ${state.error}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMealPlans,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Always show 7-day weekly view regardless of meal plan state
    return _buildWeeklySchedule(state);
  }

  Widget _buildWeeklySchedule(MealPlanState state) {
    print(
      'PlannerPage: _buildWeeklySchedule called with ${state.mealPlans.length} meal plans',
    );

    // Generate 7 days starting from Monday of the selected week
    final weekStart = DateTime(
      _selectedWeek.year,
      _selectedWeek.month,
      _selectedWeek.day,
    );
    final days = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    print(
      'PlannerPage: Generated ${days.length} days from ${DateFormat('yyyy-MM-dd').format(weekStart)}',
    );

    // Get all meals from all meal plans for this week
    final allMeals = <MealSlot>[];
    for (final mealPlan in state.mealPlans) {
      allMeals.addAll(mealPlan.meals);
    }
    print('PlannerPage: Found ${allMeals.length} total meals');
    
    // Get the meal plan ID (từ currentPlan hoặc first plan)
    final mealPlanId = state.currentPlan?.id ?? (state.mealPlans.isNotEmpty ? state.mealPlans.first.id : '');

    return SingleChildScrollView(
      child: Column(
        children: [
          // Daily rows layout - each day is a row with meal slots
          ...days.map((day) => _buildDayRow(day, allMeals, mealPlanId)).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    final today = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(day) ==
        DateFormat('yyyy-MM-dd').format(today);
  }

  Widget _buildDayRow(DateTime day, List<MealSlot> allMeals, String mealPlanId) {
    final dayString = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(day.year, day.month, day.day));
    final today = DateTime.now();
    final isPastDay = day.isBefore(
      DateTime(today.year, today.month, today.day),
    );
    final isToday = _isToday(day);
    final dayName = _getDayName(day);

    // Get meals for this specific day
    final dayMeals = allMeals.where((meal) {
      String mealDateOnly;
      final mealDateTime = DateTime.tryParse(meal.date);
      if (mealDateTime != null) {
        final local = mealDateTime.toLocal();
        final localDateOnly = DateTime(local.year, local.month, local.day);
        mealDateOnly = DateFormat('yyyy-MM-dd').format(localDateOnly);
      } else {
        mealDateOnly = meal.date;
      }
      return mealDateOnly == dayString;
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isToday
                ? AppTheme.primaryGreen.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: isToday ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isToday
              ? AppTheme.primaryGreen.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with name and date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.primaryGreen
                      : AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM').format(day),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isToday
                            ? Colors.white.withOpacity(0.9)
                            : AppTheme.primaryGreen.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Clear all meals button - only show if there are meals for this day
              if (dayMeals.any((m) => m.recipeName != null && m.recipeName!.isNotEmpty))
                IconButton(
                  onPressed: () => _showClearDayDialog(day, dayMeals, mealPlanId),
                  icon: const Icon(Icons.delete_sweep),
                  color: Colors.red.shade400,
                  iconSize: 20,
                  tooltip: 'Xóa toàn bộ',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              if (isPastDay)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Đã qua',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Meal slots in horizontal row
          Row(
            children: MealType.values.map((mealType) {
              final meal = dayMeals.firstWhere(
                (m) => m.mealType == mealType,
                orElse: () => MealSlot(
                  id: '',
                  mealPlanId: allMeals.isNotEmpty
                      ? allMeals.first.mealPlanId
                      : 'default',
                  date: dayString,
                  mealType: mealType,
                  servings: 1,
                ),
              );

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildHorizontalMealSlot(meal, day, isPastDay),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMealSlot(MealSlot meal, DateTime day, bool isPastDay) {
    final hasRecipe = meal.recipeName != null && meal.recipeName!.isNotEmpty;
    final mealTypeDisplay = _getMealTypeDisplay(meal.mealType);
    final mealIcon = _getMealTypeIcon(meal.mealType);
    final mealColor = _getMealTypeColor(meal.mealType);
    final mealGradient = _getMealTypeGradient(meal.mealType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isPastDay
            ? null
            : () {
                print(
                  'Meal slot tapped: ${meal.mealType} on ${DateFormat('yyyy-MM-dd').format(day)}',
                );
                print('isPastDay: $isPastDay');

                // If meal has recipe, show options menu. Otherwise, show recipe selection
                if (hasRecipe) {
                  _showMealOptions(meal, day);
                } else {
                  _selectRecipeForMeal(meal, day);
                }
              },
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: hasRecipe
                ? LinearGradient(
                    colors: mealGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hasRecipe ? null : Colors.grey.withOpacity(0.05),
            border: Border.all(
              color: hasRecipe
                  ? mealColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: hasRecipe
                ? [
                    BoxShadow(
                      color: mealColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Meal type header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mealIcon,
                    size: 14,
                    color: hasRecipe
                        ? mealColor.withOpacity(0.9)
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mealTypeDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasRecipe
                          ? mealColor.withOpacity(0.9)
                          : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Recipe image and name or add button
              if (hasRecipe) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Recipe image
                      if (meal.recipeImage != null && meal.recipeImage!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.recipeImage!,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: mealColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 20,
                                  color: mealColor,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(mealColor),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Recipe name
                      Flexible(
                        child: Text(
                          meal.recipeName!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPastDay
                                ? Colors.grey.shade600
                                : Colors.grey.shade800,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!isPastDay) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: mealColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: mealColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Thêm món',
                          style: TextStyle(
                            fontSize: 8,
                            color: mealColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  // Helper methods
  String _getWeekRangeText(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${DateFormat('dd/MM').format(weekStart)} - ${DateFormat('dd/MM').format(weekEnd)}';
  }

  String _getMealTypeName(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Sáng';
      case MealType.lunch:
        return 'Trưa';
      case MealType.dinner:
        return 'Tối';
    }
  }

  // Get icon for meal type
  IconData _getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny; // Sunrise for breakfast
      case MealType.lunch:
        return Icons.wb_sunny_outlined; // Sun for lunch
      case MealType.dinner:
        return Icons.nightlight_round; // Moon for dinner
    }
  }

  // Get color for meal type
  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange; // Morning orange
      case MealType.lunch:
        return Colors.amber; // Afternoon yellow
      case MealType.dinner:
        return Colors.indigo; // Evening purple/blue
    }
  }

  // Get gradient colors for meal type
  List<Color> _getMealTypeGradient(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return [Colors.orange.shade300, Colors.orange.shade100];
      case MealType.lunch:
        return [Colors.amber.shade300, Colors.amber.shade100];
      case MealType.dinner:
        return [Colors.indigo.shade300, Colors.indigo.shade100];
    }
  }

  // Dialog methods
  Future<void> _showGeneratePlanDialog() async {
    print('🤖 Smart Planning: Starting...');
    if (!mounted || _disposed) {
      print('🤖 Smart Planning: Widget not mounted or disposed');
      return;
    }
    
    // Set loading state
    setState(() => _isGeneratingPlan = true);
    print('🤖 Smart Planning: Loading state set to true');
    
    // Lưu TẤT CẢ dependencies vào biến local NGAY từ đầu để tránh lỗi deactivated widget
    final apiService = context.read<ApiService>();
    final authService = context.read<AuthService>();
    final mealPlanCubit = context.read<MealPlanCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final token = authService.accessToken;
      if (token == null) {
        print('🤖 Smart Planning: No token found');
        setState(() => _isGeneratingPlan = false);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Bạn cần đăng nhập để sử dụng chức năng này'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      print('🤖 Smart Planning: Token OK');

      // Lấy meal plan hiện tại
      final currentState = mealPlanCubit.state;
      String? mealPlanId;
      
      print('🤖 Smart Planning: Current meal plans count: ${currentState.mealPlans.length}');
      
      // Nếu chưa có meal plan cho tuần này, tạo mới
      if (currentState.mealPlans.isEmpty) {
        print('🤖 Smart Planning: No meal plan, creating new one...');
        final weekString = DateFormat('yyyy-MM-dd').format(_selectedWeek);
        await mealPlanCubit.createMealPlan(
          weekString,
          note: 'Kế hoạch tuần ${DateFormat('dd/MM').format(_selectedWeek)}',
        );
        print('🤖 Smart Planning: Meal plan created');
        
        if (!mounted || _disposed) {
          setState(() => _isGeneratingPlan = false);
          return;
        }
        
        // Đợi một chút để state cập nhật
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted || _disposed) {
          setState(() => _isGeneratingPlan = false);
          return;
        }
        
        final newState = mealPlanCubit.state;
        if (newState.mealPlans.isNotEmpty) {
          mealPlanId = newState.mealPlans.first.id;
          print('🤖 Smart Planning: Got meal plan ID: $mealPlanId');
        } else {
          print('🤖 Smart Planning: ERROR - No meal plan after creation');
        }
      } else {
        mealPlanId = currentState.mealPlans.first.id;
        print('🤖 Smart Planning: Using existing meal plan ID: $mealPlanId');
      }

      if (mealPlanId == null) {
        print('🤖 Smart Planning: ERROR - mealPlanId is null');
        setState(() => _isGeneratingPlan = false);
        throw Exception('Không thể tạo kế hoạch bữa ăn');
      }

      print('🤖 Smart Planning: Calling AI to generate meal suggestions...');
      // Gọi API để lấy gợi ý món ăn (sử dụng giá trị mặc định)
      final suggestedPlan = await apiService.generateMealPlan(
        token,
        startDate: _selectedWeek,
        region: 'NAM', // Mặc định
        budgetPerMeal: 50000, // Mặc định
        servings: 2, // Mặc định
      );
      
      print('🤖 Smart Planning: AI returned ${suggestedPlan.meals.length} meal suggestions');
      
      if (!mounted || _disposed) {
        setState(() => _isGeneratingPlan = false);
        return;
      }

      // Lấy lại state mới sau khi tạo meal plan
      final latestState = mealPlanCubit.state;
      
      // Lấy danh sách các buổi ăn hiện có
      final existingMeals = latestState.mealPlans.isNotEmpty 
          ? latestState.mealPlans.first.meals 
          : <MealSlot>[];
      int addedCount = 0;

      print('🤖 Smart Planning: Existing meals count: ${existingMeals.length}');

      // Lấy ngày hiện tại (chỉ ngày, bỏ giờ)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      print('🤖 Smart Planning: Today date: $todayDate');

      // Track các recipe_id đã được thêm để tránh trùng lặp
      final Set<String> usedRecipeIds = existingMeals
          .where((meal) => meal.recipeId != null)
          .map((meal) => meal.recipeId!)
          .toSet();
      
      print('🤖 Smart Planning: Existing recipe IDs: ${usedRecipeIds.length}');

      // Duyệt qua từng món ăn được gợi ý
      print('🤖 Smart Planning: Processing suggestions...');
      for (final suggestedMeal in suggestedPlan.meals) {
        // Parse ngày của món ăn được gợi ý
        final mealDate = DateTime.tryParse(suggestedMeal.date);
        if (mealDate == null) {
          print('🤖 Smart Planning: Skipped meal - invalid date: ${suggestedMeal.date}');
          continue;
        }
        
        final mealDateOnly = DateTime(mealDate.year, mealDate.month, mealDate.day);
        
        // Bỏ qua những ngày đã qua
        if (mealDateOnly.isBefore(todayDate)) {
          print('🤖 Smart Planning: Skipped meal - past date: $mealDateOnly (${suggestedMeal.mealType})');
          continue;
        }

        // Kiểm tra xem buổi này đã có món ăn chưa
        final hasExistingMeal = existingMeals.any((meal) =>
            meal.date == suggestedMeal.date &&
            meal.mealType == suggestedMeal.mealType &&
            meal.recipeName != null &&
            meal.recipeName!.isNotEmpty);

        if (hasExistingMeal) {
          print('🤖 Smart Planning: Skipped meal - slot already filled: $mealDateOnly (${suggestedMeal.mealType})');
          continue;
        }

        if (suggestedMeal.recipeId == null) {
          print('🤖 Smart Planning: Skipped meal - no recipe ID: $mealDateOnly (${suggestedMeal.mealType})');
          continue;
        }

        // Kiểm tra món ăn đã được dùng trong tuần chưa (tránh trùng lặp)
        if (usedRecipeIds.contains(suggestedMeal.recipeId)) {
          print('🤖 Smart Planning: Skipped meal - recipe already used: ${suggestedMeal.recipeName} (${suggestedMeal.recipeId})');
          continue;
        }

        // Nếu chưa có món ăn, thêm vào
        print('🤖 Smart Planning: Adding meal: ${suggestedMeal.recipeName} to $mealDateOnly (${suggestedMeal.mealType})');
        
        // Convert to UPPERCASE - backend expects this!
        String mealSlotString = '';
        switch (suggestedMeal.mealType) {
          case MealType.breakfast:
            mealSlotString = 'BREAKFAST';
            break;
          case MealType.lunch:
            mealSlotString = 'LUNCH';
            break;
          case MealType.dinner:
            mealSlotString = 'DINNER';
            break;
        }

        final dto = AddMealDto(
          date: suggestedMeal.date,
          mealSlot: mealSlotString,
          recipeId: suggestedMeal.recipeId!,
          servings: 2, // Mặc định
        );

        await mealPlanCubit.addMealToPlan(mealPlanId, dto);
        print('🤖 Smart Planning: Meal added successfully');
        
        // Thêm recipe_id vào danh sách đã dùng để tránh trùng lặp
        usedRecipeIds.add(suggestedMeal.recipeId!);
        
        if (!mounted || _disposed) {
          print('🤖 Smart Planning: Widget disposed after adding meal');
          setState(() => _isGeneratingPlan = false);
          return;
        }
        
        addedCount++;
        
        // Đợi một chút giữa các request để tránh quá tải
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (!mounted || _disposed) {
          setState(() => _isGeneratingPlan = false);
          return;
        }
      }

      print('🤖 Smart Planning: Completed! Added $addedCount meals');

      // Tắt loading
      setState(() => _isGeneratingPlan = false);

      if (!mounted || _disposed) return;
      
      // Reload meal plans
      print('🤖 Smart Planning: Reloading meal plans...');
      _lastLoadedWeek = null;
      if (mounted && !_disposed) {
        _loadMealPlans();
      }

      // Hiển thị thông báo
      print('🤖 Smart Planning: Showing result notification');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            addedCount > 0
                ? '🎉 Đã lập kế hoạch thành công! Thêm $addedCount món ăn'
                : '✓ Kế hoạch của bạn đã đầy đủ!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('🤖 Smart Planning: ERROR - ${e.toString()}');
      print('🤖 Smart Planning: ERROR Stack trace: ${StackTrace.current}');
      
      // Tắt loading
      if (mounted && !_disposed) {
        setState(() => _isGeneratingPlan = false);
      }
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear all meals for a specific day
  Future<void> _showClearDayDialog(DateTime day, List<MealSlot> dayMeals, String mealPlanId) async {
    if (!mounted || _disposed) return;
    
    // Filter only meals that have recipes
    final mealsToDelete = dayMeals.where((m) => m.recipeName != null && m.recipeName!.isNotEmpty).toList();
    
    if (mealsToDelete.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ món ăn'),
        content: Text(
          'Bạn có chắc muốn xóa ${mealsToDelete.length} món ăn của ngày ${DateFormat('dd/MM/yyyy').format(day)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
                    ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted && !_disposed) {
      await _clearDayMeals(day, mealsToDelete, mealPlanId);
    }
  }

  Future<void> _clearDayMeals(DateTime day, List<MealSlot> mealsToDelete, String mealPlanId) async {
    if (!mounted || _disposed) return;
    
    // Store ALL dependencies locally FIRST
    final mealPlanCubit = context.read<MealPlanCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      if (!mounted || _disposed) return;
      
      // Use the day parameter for date (already in correct local timezone)
      final dateString = DateFormat('yyyy-MM-dd').format(day);
      
      // Delete all meals for this day (without reloading after each deletion)
      for (final meal in mealsToDelete) {
        if (!mounted || _disposed) break;
        
        // Convert MealType to string for API (UPPERCASE - backend expects this!)
        String mealSlotString = '';
        switch (meal.mealType) {
      case MealType.breakfast:
            mealSlotString = 'BREAKFAST';
            break;
      case MealType.lunch:
            mealSlotString = 'LUNCH';
            break;
      case MealType.dinner:
            mealSlotString = 'DINNER';
            break;
        }
        
        // Skip reload for batch deletion - we'll reload once at the end
        await mealPlanCubit.removeMealFromPlan(
          mealPlanId, 
          dateString, 
          mealSlotString,
          reloadAfter: false,
        );
        
        if (!mounted || _disposed) break;
        
        // Small delay to avoid overwhelming the backend
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (!mounted || _disposed) return;
      
      // Reload meal plans
      _lastLoadedWeek = null;
      await _loadMealPlans();
      
      if (!mounted || _disposed) return;
      
      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('✓ Đã xóa ${mealsToDelete.length} món ăn'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted || _disposed) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('❌ Lỗi khi xóa món ăn'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _selectRecipeForMeal(MealSlot meal, DateTime day) async {
    print(
      '_selectRecipeForMeal called for meal: ${meal.mealType} on day: $day',
    );
    print('Meal plan ID: ${meal.mealPlanId}');

    final parentContext = context;
    String mealTypeDisplay = '';
    String mealSlotString = '';

    // Get or create a meal plan for this week if none exists
    final currentState = parentContext.read<MealPlanCubit>().state;
    String mealPlanId = meal.mealPlanId;

    print('Current meal plan ID before check: $mealPlanId');
    print('Available meal plans: ${currentState.mealPlans.length}');

    if (mealPlanId.isEmpty || mealPlanId == 'default') {
      if (currentState.mealPlans.isNotEmpty) {
        mealPlanId = currentState.mealPlans.first.id;
        print('Using first available meal plan: $mealPlanId');
      } else {
        print('No meal plans available, creating new one...');
        // Create a new meal plan for this week
        final weekString = DateFormat('yyyy-MM-dd').format(_selectedWeek);

        // Show loading indicator
        showDialog(
          context: parentContext,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        try {
          await parentContext.read<MealPlanCubit>().createMealPlan(
            weekString,
            note: 'Kế hoạch tuần ${DateFormat('dd/MM').format(_selectedWeek)}',
          );

          // Close loading dialog
          if (mounted && Navigator.canPop(parentContext)) {
            Navigator.of(parentContext).pop();
          }

          // Get the newly created meal plan ID
          final newState = parentContext.read<MealPlanCubit>().state;
          if (newState.mealPlans.isNotEmpty) {
            mealPlanId = newState.mealPlans.last.id; // Get the newest plan
            print('Created new meal plan with ID: $mealPlanId');
          } else {
            print('Failed to create meal plan');
            ScaffoldMessenger.of(parentContext).showSnackBar(
              const SnackBar(
                content: Text(
                  'Không thể tạo kế hoạch bữa ăn. Vui lòng thử lại.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } catch (e) {
          // Close loading dialog
          if (mounted && Navigator.canPop(parentContext)) {
            Navigator.of(parentContext).pop();
          }

          print('Error creating meal plan: $e');
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text('Lỗi tạo kế hoạch bữa ăn. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // Convert to UPPERCASE - backend expects this!
    switch (meal.mealType) {
      case MealType.breakfast:
        mealTypeDisplay = 'bữa sáng';
        mealSlotString = 'BREAKFAST';
        break;
      case MealType.lunch:
        mealTypeDisplay = 'bữa trưa';
        mealSlotString = 'LUNCH';
        break;
      case MealType.dinner:
        mealTypeDisplay = 'bữa tối';
        mealSlotString = 'DINNER';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => RecipeSelectionDialog(
        mealType: meal.mealType,
        mealTypeDisplay: mealTypeDisplay,
        date: day,
        onRecipeSelected: (RecipeModel recipe) async {
          // Create AddMealDto for adding recipe to meal plan
          print('Adding recipe ${recipe.name} to meal plan $mealPlanId');
          print(
            'DTO details - date: ${DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day))}, mealSlot: $mealSlotString, recipeId: ${recipe.id}',
          );

          final dto = AddMealDto(
            // Use local date-only for payload to avoid timezone shifts
            date: DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime(day.year, day.month, day.day)),
            mealSlot: mealSlotString,
            recipeId: recipe.id,
            servings: meal.servings,
          );

          try {
            // Add meal to plan and wait for completion using parentContext
            print('Calling addMealToPlan...');
            await parentContext.read<MealPlanCubit>().addMealToPlan(
              mealPlanId,
              dto,
            );
            print('addMealToPlan completed successfully');

            // Auto-consume ingredients from pantry if available
            try {
              print('Auto-consuming ingredients for recipe ${recipe.id}...');
              final pantryCubit = parentContext.read<PantryCubit>();
              await pantryCubit.consumeIngredientsFromRecipe(
                recipe.id,
                meal.servings,
              );
              print('Auto-consume completed');
            } catch (e) {
              print('Auto-consume failed (non-critical): $e');
              // Don't show error to user as this is optional functionality
            }

            // Close dialog after successful operation
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            // Force reload meal plans to get updated data
            _lastLoadedWeek = null; // Reset cache
            _loadMealPlans();

            // Force rebuild UI
            if (mounted) {
              setState(() {});
            }

            // Show success message with delay using parentContext
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thêm ${recipe.name} vào $mealTypeDisplay',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });
          } catch (e) {
            // Close dialog on error
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            // Show error message with delay using parentContext
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi thêm món ăn: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }

  void _showMealOptions(MealSlot meal, DateTime day) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              '${meal.recipeName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              '${_getMealTypeName(meal.mealType)} - ${DateFormat('dd/MM/yyyy').format(day)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Options
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: AppTheme.primaryGreen),
              title: const Text('Đã nấu'),
              subtitle: const Text('Trừ nguyên liệu từ tủ lạnh'),
              onTap: () {
                Navigator.pop(context);
                _markMealAsCooked(meal, day);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Thay đổi món ăn'),
              onTap: () {
                Navigator.pop(context);
                _selectRecipeForMeal(meal, day);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa món ăn'),
              onTap: () {
                Navigator.pop(context);
                _removeMealFromPlan(meal, day);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _removeMealFromPlan(MealSlot meal, DateTime day) {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Xóa món ăn'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${meal.recipeName}" khỏi bữa ${_getMealTypeName(meal.mealType).toLowerCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Debug info
                print('=== REMOVE MEAL DEBUG ===');
                print('Removing meal: ${meal.recipeName}');
                print('Original meal plan ID: ${meal.mealPlanId}');
                print('Meal ID: ${meal.id}');
                print('Recipe ID: ${meal.recipeId}');
                print(
                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day))}',
                );

                // Get meal slot string for API (UPPERCASE - backend expects this!)
                String mealSlotString = '';
                switch (meal.mealType) {
                  case MealType.breakfast:
                    mealSlotString = 'BREAKFAST';
                    break;
                  case MealType.lunch:
                    mealSlotString = 'LUNCH';
                    break;
                  case MealType.dinner:
                    mealSlotString = 'DINNER';
                    break;
                }

                print('Meal slot: $mealSlotString');

                // Get current state for debugging
                final currentState = parentContext.read<MealPlanCubit>().state;
                print('Available meal plans: ${currentState.mealPlans.length}');
                for (var plan in currentState.mealPlans) {
                  print('  Plan ID: ${plan.id}, Week: ${plan.weekStartDate}');
                }

                String planIdToUse = meal.mealPlanId;

                // Check if meal plan ID is valid
                if (meal.mealPlanId.isEmpty || meal.mealPlanId == 'default') {
                  if (currentState.mealPlans.isNotEmpty) {
                    planIdToUse = currentState.mealPlans.first.id;
                    print(
                      'Using first available plan ID: $planIdToUse instead of ${meal.mealPlanId}',
                    );
                  } else {
                    throw Exception('Không tìm thấy kế hoạch bữa ăn');
                  }
                }

                print('Final plan ID to use: $planIdToUse');
                print(
                  'API call: DELETE /api/meal-plans/$planIdToUse/meals/${DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day))}/$mealSlotString',
                );

                await parentContext.read<MealPlanCubit>().removeMealFromPlan(
                  planIdToUse,
                  DateFormat(
                    'yyyy-MM-dd',
                  ).format(DateTime(day.year, day.month, day.day)),
                  mealSlotString,
                );

                print('Remove meal completed successfully');
                print('=== END DEBUG ===');

                // Force reload meal plans
                _lastLoadedWeek = null; // Reset cache
                _loadMealPlans();

                // Show success message using parentContext
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa "${meal.recipeName}" thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa món ăn: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markMealAsCooked(MealSlot meal, DateTime day) async {
    if (meal.recipeId == null || meal.recipeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xác định món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final parentContext = context;
    final scaffoldMessenger = ScaffoldMessenger.of(parentContext);

    // Show loading snackbar (lightweight, không block UI)
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Đang xử lý...'),
          ],
        ),
        duration: Duration(seconds: 10), // Auto-dismiss after 10s
        backgroundColor: Color(0xFF616161),
      ),
    );

    try {
      // Initialize cooking service
      final cookingService = CookingService(
        apiService: parentContext.read<ApiService>(),
        authService: parentContext.read<AuthService>(),
      );

      // Cook meal (check and consume ingredients)
      final result = await cookingService.cookMeal(
        recipeId: meal.recipeId!,
        recipeName: meal.recipeName ?? 'Món ăn',
        servings: 1,
      );

      if (!mounted) return;

      // Nếu THIẾU nguyên liệu → Ẩn loading snackbar và hiển thị dialog
      if (!result.success && result.missingIngredients.isNotEmpty) {
        // Hide loading snackbar
        scaffoldMessenger.hideCurrentSnackBar();
        
        final shouldAddToCart = await showDialog<bool>(
          context: parentContext,
          builder: (context) => CookingResultDialog(
            result: result,
            recipeName: meal.recipeName ?? 'Món ăn',
          ),
        );

        // TODO: Thêm vào shopping list nếu user muốn
        if (shouldAddToCart == true) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Đã thêm ${result.missingIngredients.length} nguyên liệu vào danh sách mua sắm',
              ),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
        return;
      }

      // Nếu ĐỦ nguyên liệu và consume thành công
      if (result.success) {
        print('=== COOKING SUCCESS: Starting to remove meal from plan ===');
        print('Meal: ${meal.recipeName}');
        print('Meal plan ID from slot: ${meal.mealPlanId}');
        print('Recipe ID: ${meal.recipeId}');
        
        // 1. Lấy meal plan ID từ cubit state (vì meal.mealPlanId có thể trống)
        final currentState = parentContext.read<MealPlanCubit>().state;
        String? planIdToUse = meal.mealPlanId;
        
        // Nếu meal.mealPlanId trống hoặc 'default', lấy từ currentPlan
        if (planIdToUse.isEmpty || planIdToUse == 'default') {
          if (currentState.currentPlan != null && currentState.currentPlan!.id.isNotEmpty) {
            planIdToUse = currentState.currentPlan!.id;
            print('Using currentPlan ID: $planIdToUse');
          } else if (currentState.mealPlans.isNotEmpty) {
            planIdToUse = currentState.mealPlans.first.id;
            print('Using first available plan ID: $planIdToUse');
          }
        }
        
        if (planIdToUse == null || planIdToUse.isEmpty || planIdToUse == 'default') {
          print('❌ ERROR: Cannot find valid meal plan ID!');
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Không tìm thấy kế hoạch bữa ăn'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // 2. Xóa món ăn khỏi kế hoạch
        String mealSlotString = '';
        switch (meal.mealType) {
          case MealType.breakfast:
            mealSlotString = 'BREAKFAST';
            break;
          case MealType.lunch:
            mealSlotString = 'LUNCH';
            break;
          case MealType.dinner:
            mealSlotString = 'DINNER';
            break;
        }

        final dateString = DateFormat('yyyy-MM-dd').format(DateTime(day.year, day.month, day.day));
        print('Date: $dateString, Meal slot: $mealSlotString, Plan ID: $planIdToUse');

        try {
          await parentContext.read<MealPlanCubit>().removeMealFromPlan(
            planIdToUse,
            dateString,
            mealSlotString,
          );
          print('✓ Meal removed successfully from plan');
        } catch (e) {
          print('❌ Error removing meal from plan: $e');
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa món: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // 2. Force reload meal plans
        _lastLoadedWeek = null;
        await _loadMealPlans();
        print('✓ Meal plans reloaded');

        // 3. Reload pantry
        parentContext.read<PantryCubit>().loadPantryItems();
        print('✓ Pantry reload triggered');

        // 4. Hide loading snackbar và hiển thị success
        scaffoldMessenger.hideCurrentSnackBar();
        await Future.delayed(const Duration(milliseconds: 100)); // Small delay
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('✓ Nấu thành công món "${meal.recipeName}"'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        print('✓ Success snackbar shown');
        print('=== COOKING SUCCESS: Complete ===');
      } else {
        // Có lỗi khi consume
        print('❌ Cooking failed: ${result.message}');
        
        // Hide loading snackbar
        scaffoldMessenger.hideCurrentSnackBar();
        await Future.delayed(const Duration(milliseconds: 100));
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ EXCEPTION in _markMealAsCooked: $e');
      
      // Hide loading snackbar
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        await Future.delayed(const Duration(milliseconds: 100));
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        print('✓ Error snackbar shown');
      }
    }
  }

  String _getMealTypeDisplay(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Sáng';
      case MealType.lunch:
        return 'Trưa';
      case MealType.dinner:
        return 'Tối';
    }
  }

  String _getDayName(DateTime day) {
    switch (day.weekday) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

}
