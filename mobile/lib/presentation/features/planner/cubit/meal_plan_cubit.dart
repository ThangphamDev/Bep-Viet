import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';

class MealPlanState {
  final bool isLoading;
  final List<MealPlanModel> mealPlans;
  final MealPlanModel? currentPlan;
  final String? error;
  final DateTime selectedDate;

  MealPlanState({
    this.isLoading = false,
    this.mealPlans = const [],
    this.currentPlan,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  MealPlanState copyWith({
    bool? isLoading,
    List<MealPlanModel>? mealPlans,
    MealPlanModel? currentPlan,
    String? error,
    DateTime? selectedDate,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      mealPlans: mealPlans ?? this.mealPlans,
      currentPlan: currentPlan ?? this.currentPlan,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class MealPlanCubit extends Cubit<MealPlanState> {
  final ApiService _apiService;
  final AuthService _authService;

  MealPlanCubit(this._apiService, this._authService) : super(MealPlanState());

  Future<void> loadMealPlans({String? date}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xem kế hoạch bữa ăn',
          ),
        );
        return;
      }

      final userId = _authService.currentUser?.id;
      if (userId == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Không tìm thấy thông tin người dùng',
          ),
        );
        return;
      }

      // Calculate Monday of the current week (week starts on Monday)
      DateTime targetDate;
      if (date != null) {
        targetDate = DateFormat('yyyy-MM-dd').parse(date);
      } else {
        targetDate = DateTime.now();
      }

      // Get Monday of the week (ISO 8601: Monday = 1, Sunday = 7)
      final mondayOfWeek = targetDate.subtract(
        Duration(days: targetDate.weekday - 1),
      );
      final weekStartDate = DateFormat('yyyy-MM-dd').format(mondayOfWeek);

      final mealPlan = await _apiService.getMealPlanByWeek(
        token,
        userId,
        weekStartDate,
      );

      if (mealPlan != null) {
        emit(
          state.copyWith(
            isLoading: false,
            mealPlans: [mealPlan],
            currentPlan: mealPlan,
          ),
        );
      } else {
        emit(
          state.copyWith(isLoading: false, mealPlans: [], currentPlan: null),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải kế hoạch bữa ăn: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> createMealPlan(String weekStartDate, {String? note}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để tạo kế hoạch bữa ăn',
          ),
        );
        return;
      }

      final dto = CreateMealPlanDto(weekStartDate: weekStartDate, note: note);

      final mealPlan = await _apiService.createMealPlan(token, dto);
      final updatedPlans = [...state.mealPlans, mealPlan];

      emit(
        state.copyWith(
          isLoading: false,
          mealPlans: updatedPlans,
          currentPlan: mealPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tạo kế hoạch bữa ăn: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> addMealToPlan(String planId, AddMealDto dto) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để thêm món ăn',
          ),
        );
        return;
      }

      // Call API to add meal (this just returns success, not full plan)
      await _apiService.addMealToPlan(token, planId, dto);

      // Instead of trying to use the response, reload all meal plans
      await loadMealPlans();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể thêm món ăn: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> quickAddMealToToday(QuickAddMealDto dto) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để thêm món ăn',
          ),
        );
        return;
      }

      final updatedPlan = await _apiService.quickAddMealToToday(token, dto);

      // Update or add the plan for today
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final existingPlanIndex = state.mealPlans.indexWhere(
        (plan) =>
            plan.weekStartDate == todayString ||
            plan.meals.any((meal) => meal.date == todayString),
      );

      List<MealPlanModel> updatedPlans;
      if (existingPlanIndex >= 0) {
        updatedPlans = [...state.mealPlans];
        updatedPlans[existingPlanIndex] = updatedPlan;
      } else {
        updatedPlans = [...state.mealPlans, updatedPlan];
      }

      emit(
        state.copyWith(
          isLoading: false,
          mealPlans: updatedPlans,
          currentPlan: updatedPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể thêm món ăn hôm nay: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> generateMealPlan({
    DateTime? startDate,
    String? region,
    int? budgetPerMeal,
    int servings = 2,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để tạo kế hoạch tự động',
          ),
        );
        return;
      }

      final mealPlan = await _apiService.generateMealPlan(
        token,
        startDate: startDate,
        budgetPerMeal: budgetPerMeal,
        region: region,
        servings: servings,
      );

      final updatedPlans = [...state.mealPlans, mealPlan];

      emit(
        state.copyWith(
          isLoading: false,
          mealPlans: updatedPlans,
          currentPlan: mealPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tạo kế hoạch tự động: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteMealPlan(String planId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xóa kế hoạch',
          ),
        );
        return;
      }

      await _apiService.deleteMealPlan(token, planId);

      final updatedPlans = state.mealPlans
          .where((plan) => plan.id != planId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          mealPlans: updatedPlans,
          currentPlan: state.currentPlan?.id == planId
              ? null
              : state.currentPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể xóa kế hoạch: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> removeMealFromPlan(
    String planId,
    String date,
    String mealSlot, {
    bool reloadAfter = true,
  }) async {
    if (reloadAfter) {
      emit(state.copyWith(isLoading: true, error: null));
    }

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xóa món ăn',
          ),
        );
        return;
      }

      await _apiService.removeMealFromPlan(token, planId, date, mealSlot);

      // Reload meal plans to get updated data (only if requested)
      if (reloadAfter) {
        await loadMealPlans();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể xóa món ăn: ${e.toString()}',
        ),
      );
    }
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    // Load meal plans for the selected date
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    loadMealPlans(date: dateString);
  }

  void selectMealPlan(MealPlanModel mealPlan) {
    emit(state.copyWith(currentPlan: mealPlan));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Helper methods
  MealPlanModel? getMealPlanForDate(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    for (final plan in state.mealPlans) {
      if (plan.meals.any((meal) => meal.date == dateString)) {
        return plan;
      }
    }
    return null;
  }

  List<MealSlot> getMealsForSlot(MealType mealType) {
    final todayPlan = getMealPlanForDate(state.selectedDate);
    if (todayPlan == null) return [];

    final dateString =
        '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';
    return todayPlan.meals
        .where((meal) => meal.date == dateString && meal.mealType == mealType)
        .toList();
  }

  bool hasMealsForDate(DateTime date) {
    final plan = getMealPlanForDate(date);
    return plan != null && plan.meals.isNotEmpty;
  }
}
