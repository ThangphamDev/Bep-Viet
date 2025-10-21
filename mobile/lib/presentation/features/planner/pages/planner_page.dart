import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/presentation/features/planner/cubit/meal_plan_cubit.dart';
import '../widgets/weekly_meal_planner.dart';
import '../widgets/meal_plan_summary.dart';
import '../widgets/create_meal_plan_dialog.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        // Configure Dio for ngrok tunnel - same pattern as recipes
        dio.options.baseUrl = AppConfig.ngrokBaseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);

        // Add ngrok-skip-browser-warning header
        dio.options.headers['ngrok-skip-browser-warning'] = 'true';

        final apiService = ApiService(dio);
        final cubit = MealPlanCubit(apiService);
        // Load initial meal plans for current week
        cubit.loadMealPlans(
          startDate: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
          endDate: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday)),
        );
        return cubit;
      },
      child: const PlannerPageView(),
    );
  }
}

class PlannerPageView extends StatefulWidget {
  const PlannerPageView({super.key});

  @override
  State<PlannerPageView> createState() => _PlannerPageViewState();
}

class _PlannerPageViewState extends State<PlannerPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedWeekStart = _getWeekStart(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
  }

  void _showCreateMealPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMealPlanDialog(
        weekStart: _selectedWeekStart,
        onCreated: () {
          // Refresh meal plan
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kế hoạch ăn'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _showCreateMealPlanDialog,
            tooltip: 'Tạo kế hoạch tự động',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Kế hoạch tuần', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Tổng quan', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Week Navigator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousWeek,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tuần ${_getWeekNumber(_selectedWeekStart)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${_formatDate(_selectedWeekStart)} - ${_formatDate(_selectedWeekStart.add(const Duration(days: 6)))}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WeeklyMealPlanner(weekStart: _selectedWeekStart),
                MealPlanSummary(weekStart: _selectedWeekStart),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMealPlanDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Tạo kế hoạch'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(date.strftime('%j'));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}

extension DateTimeExtension on DateTime {
  String strftime(String format) {
    if (format == '%j') {
      return difference(DateTime(year, 1, 1)).inDays.toString();
    }
    return toString();
  }
}
