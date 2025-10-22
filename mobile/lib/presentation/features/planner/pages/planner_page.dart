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

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  DateTime _selectedWeek = DateTime.now();

  // Cache for performance optimization
  String? _lastLoadedWeek;
  bool _isLoadingMealPlans = false;
  bool _disposed = false;

  // Debounce timer to prevent rapid successive calls
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('PlannerPage initState called');
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Lịch trình'),
            Tab(text: 'Tạo kế hoạch'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWeeklyPlanView(), _buildCreatePlanView()],
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

    if (state.isLoading) {
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Week navigation header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tuần ${DateFormat('dd/MM').format(days.first)} - ${DateFormat('dd/MM').format(days.last)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _disposed
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
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    IconButton(
                      onPressed: _disposed
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
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Daily rows layout - each day is a row with meal slots
          ...days.map((day) => _buildDayRow(day, allMeals)).toList(),

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

  Widget _buildDayRow(DateTime day, List<MealSlot> allMeals) {
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: hasRecipe
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            border: Border.all(
              color: hasRecipe
                  ? AppTheme.primaryGreen.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Meal type header
              Text(
                mealTypeDisplay,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: hasRecipe
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              // Recipe name or add button
              if (hasRecipe) ...[
                Expanded(
                  child: Center(
                    child: Text(
                      meal.recipeName!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isPastDay
                            ? Colors.grey.shade500
                            : AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ] else if (!isPastDay) ...[
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePlanView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Generate
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      const Text(
                        'Tạo kế hoạch tự động',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI sẽ tạo kế hoạch 7 ngày cân bằng dinh dưỡng và chi phí',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showGeneratePlanDialog(),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Tạo kế hoạch thông minh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Manual Create
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.create, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      const Text(
                        'Tạo kế hoạch thủ công',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tự chọn món ăn cho từng bữa trong tuần',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateManualPlanDialog(),
                    icon: const Icon(Icons.create),
                    label: const Text('Tạo kế hoạch mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mẹo hay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Kế hoạch tự động sẽ tránh lặp món và cân bằng chi phí\n'
                  '• Kiểm tra tủ lạnh trước khi tạo kế hoạch\n'
                  '• Có thể chỉnh sửa từng bữa ăn sau khi tạo\n'
                  '• Tạo danh sách mua sắm từ kế hoạch bữa ăn',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
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

  // Dialog methods
  void _showGeneratePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => _GeneratePlanDialog(
        selectedWeek: _selectedWeek,
        onGenerated: () {
          _loadMealPlans();
          _tabController.animateTo(0);
        },
      ),
    );
  }

  void _showCreateManualPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateManualPlanDialog(
        selectedWeek: _selectedWeek,
        onCreated: () {
          _loadMealPlans();
          _tabController.animateTo(0);
        },
      ),
    );
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

    switch (meal.mealType) {
      case MealType.breakfast:
        mealTypeDisplay = 'bữa sáng';
        mealSlotString = 'breakfast';
        break;
      case MealType.lunch:
        mealTypeDisplay = 'bữa trưa';
        mealSlotString = 'lunch';
        break;
      case MealType.dinner:
        mealTypeDisplay = 'bữa tối';
        mealSlotString = 'dinner';
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
              leading: const Icon(Icons.edit, color: AppTheme.primaryGreen),
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

                // Get meal slot string for API
                String mealSlotString = '';
                switch (meal.mealType) {
                  case MealType.breakfast:
                    mealSlotString = 'breakfast';
                    break;
                  case MealType.lunch:
                    mealSlotString = 'lunch';
                    break;
                  case MealType.dinner:
                    mealSlotString = 'dinner';
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

  // Method to generate shopping list from current meal plan
}

// Generate Plan Dialog
class _GeneratePlanDialog extends StatefulWidget {
  final DateTime selectedWeek;
  final VoidCallback onGenerated;

  const _GeneratePlanDialog({
    required this.selectedWeek,
    required this.onGenerated,
  });

  @override
  State<_GeneratePlanDialog> createState() => _GeneratePlanDialogState();
}

class _GeneratePlanDialogState extends State<_GeneratePlanDialog> {
  final _nameController = TextEditingController();
  int _servings = 2;
  String _budgetRange = 'medium';

  @override
  void initState() {
    super.initState();
    _nameController.text =
        'Kế hoạch tuần ${DateFormat('dd/MM').format(widget.selectedWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealPlanCubit, MealPlanState>(
      listener: (context, state) {
        if (!state.isLoading &&
            state.error == null &&
            state.mealPlans.isNotEmpty) {
          Navigator.pop(context);
          widget.onGenerated();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kế hoạch đã được tạo thành công!')),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.error}')));
        }
      },
      child: AlertDialog(
        title: const Text('Tạo kế hoạch thông minh'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên kế hoạch',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Servings
              Text(
                'Số phần ăn: $_servings',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _servings.toDouble(),
                min: 1,
                max: 8,
                divisions: 7,
                onChanged: (value) => setState(() => _servings = value.round()),
              ),
              const SizedBox(height: 16),

              // Budget
              const Text(
                'Mức chi phí:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _budgetRange,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Tiết kiệm')),
                  DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                  DropdownMenuItem(value: 'high', child: Text('Cao cấp')),
                ],
                onChanged: (value) => setState(() => _budgetRange = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          BlocBuilder<MealPlanCubit, MealPlanState>(
            builder: (context, state) {
              final isLoading = state.isLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _generatePlan,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tạo kế hoạch'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _generatePlan() {
    context.read<MealPlanCubit>().generateMealPlan(
      startDate: widget.selectedWeek,
      region: 'NAM',
      budgetPerMeal: _budgetRange == 'low'
          ? 30000
          : (_budgetRange == 'high' ? 80000 : 50000),
      servings: 2,
    );
  }
}

// Create Manual Plan Dialog
class _CreateManualPlanDialog extends StatefulWidget {
  final DateTime selectedWeek;
  final VoidCallback onCreated;

  const _CreateManualPlanDialog({
    required this.selectedWeek,
    required this.onCreated,
  });

  @override
  State<_CreateManualPlanDialog> createState() =>
      _CreateManualPlanDialogState();
}

class _CreateManualPlanDialogState extends State<_CreateManualPlanDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text =
        'Kế hoạch tuần ${DateFormat('dd/MM').format(widget.selectedWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealPlanCubit, MealPlanState>(
      listener: (context, state) {
        if (!state.isLoading &&
            state.error == null &&
            state.mealPlans.isNotEmpty) {
          Navigator.pop(context);
          widget.onCreated();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kế hoạch đã được tạo thành công!')),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.error}')));
        }
      },
      child: AlertDialog(
        title: const Text('Tạo kế hoạch mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên kế hoạch *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          BlocBuilder<MealPlanCubit, MealPlanState>(
            builder: (context, state) {
              final isLoading = state.isLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _createPlan,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tạo'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _createPlan() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên kế hoạch')),
      );
      return;
    }

    context.read<MealPlanCubit>().createMealPlan(
      DateFormat('yyyy-MM-dd').format(widget.selectedWeek),
      note: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
    );
  }
}
