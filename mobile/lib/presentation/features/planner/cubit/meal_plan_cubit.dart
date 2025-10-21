import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  final ApiService _apiService;

  MealPlanCubit(this._apiService) : super(MealPlanState());

  Future<void> loadMealPlans({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final mealPlans = await _apiService.getMealPlans(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      emit(state.copyWith(mealPlans: mealPlans, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMealPlan(String id) async {
    emit(state.copyWith(isLoadingDetail: true, detailError: null));

    try {
      final mealPlan = await _apiService.getMealPlan(id);
      emit(state.copyWith(currentMealPlan: mealPlan, isLoadingDetail: false));
    } catch (e) {
      emit(state.copyWith(isLoadingDetail: false, detailError: e.toString()));
    }
  }

  Future<void> createMealPlan(CreateMealPlanRequest request) async {
    emit(state.copyWith(isCreating: true, createError: null));

    try {
      final mealPlan = await _apiService.createMealPlan(request);
      
      // Add to list and set as current
      final updatedMealPlans = [...state.mealPlans, mealPlan];
      emit(state.copyWith(
        mealPlans: updatedMealPlans,
        currentMealPlan: mealPlan,
        isCreating: false,
      ));
    } catch (e) {
      emit(state.copyWith(isCreating: false, createError: e.toString()));
    }
  }

  Future<void> updateMealPlan(String id, Map<String, dynamic> updates) async {
    emit(state.copyWith(isUpdating: true, updateError: null));

    try {
      final updatedMealPlan = await _apiService.updateMealPlan(id, updates);
      
      // Update in list and current
      final updatedMealPlans = state.mealPlans
          .map((mp) => mp.id == id ? updatedMealPlan : mp)
          .toList();
      
      emit(state.copyWith(
        mealPlans: updatedMealPlans,
        currentMealPlan: state.currentMealPlan?.id == id ? updatedMealPlan : state.currentMealPlan,
        isUpdating: false,
      ));
    } catch (e) {
      emit(state.copyWith(isUpdating: false, updateError: e.toString()));
    }
  }

  Future<void> deleteMealPlan(String id) async {
    emit(state.copyWith(isDeleting: true, deleteError: null));

    try {
      await _apiService.deleteMealPlan(id);
      
      // Remove from list and clear current if it's the deleted one
      final updatedMealPlans = state.mealPlans.where((mp) => mp.id != id).toList();
      final currentMealPlan = state.currentMealPlan?.id == id ? null : state.currentMealPlan;
      
      emit(state.copyWith(
        mealPlans: updatedMealPlans,
        currentMealPlan: currentMealPlan,
        isDeleting: false,
      ));
    } catch (e) {
      emit(state.copyWith(isDeleting: false, deleteError: e.toString()));
    }
  }

  Future<void> createShoppingListFromMealPlan(String mealPlanId, CreateShoppingListRequest request) async {
    emit(state.copyWith(isCreatingShoppingList: true, shoppingListError: null));

    try {
      final shoppingList = await _apiService.createShoppingListFromMealPlan(mealPlanId, request);
      emit(state.copyWith(
        createdShoppingList: shoppingList,
        isCreatingShoppingList: false,
      ));
    } catch (e) {
      emit(state.copyWith(isCreatingShoppingList: false, shoppingListError: e.toString()));
    }
  }

  void clearErrors() {
    emit(state.copyWith(
      error: null,
      detailError: null,
      createError: null,
      updateError: null,
      deleteError: null,
      shoppingListError: null,
    ));
  }

  void clearCurrentMealPlan() {
    emit(state.copyWith(currentMealPlan: null));
  }

  void clearCreatedShoppingList() {
    emit(state.copyWith(createdShoppingList: null));
  }
}

class MealPlanState {
  final List<MealPlanModel> mealPlans;
  final MealPlanModel? currentMealPlan;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isCreatingShoppingList;
  final String? error;
  final String? detailError;
  final String? createError;
  final String? updateError;
  final String? deleteError;
  final String? shoppingListError;
  final ShoppingListModel? createdShoppingList;

  MealPlanState({
    this.mealPlans = const [],
    this.currentMealPlan,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isCreatingShoppingList = false,
    this.error,
    this.detailError,
    this.createError,
    this.updateError,
    this.deleteError,
    this.shoppingListError,
    this.createdShoppingList,
  });

  MealPlanState copyWith({
    List<MealPlanModel>? mealPlans,
    MealPlanModel? currentMealPlan,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isCreatingShoppingList,
    String? error,
    String? detailError,
    String? createError,
    String? updateError,
    String? deleteError,
    String? shoppingListError,
    ShoppingListModel? createdShoppingList,
  }) {
    return MealPlanState(
      mealPlans: mealPlans ?? this.mealPlans,
      currentMealPlan: currentMealPlan,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isCreatingShoppingList: isCreatingShoppingList ?? this.isCreatingShoppingList,
      error: error,
      detailError: detailError,
      createError: createError,
      updateError: updateError,
      deleteError: deleteError,
      shoppingListError: shoppingListError,
      createdShoppingList: createdShoppingList,
    );
  }
}