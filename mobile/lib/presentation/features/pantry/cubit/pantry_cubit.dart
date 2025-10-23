import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';

class PantryState {
  final bool isLoading;
  final List<PantryItemModel> pantryItems;
  final PantryStatsModel? stats;
  final String? error;
  final String selectedLocation;
  final String sortBy;
  final bool showExpired;
  final bool showLowStock;

  PantryState({
    this.isLoading = false,
    this.pantryItems = const [],
    this.stats,
    this.error,
    this.selectedLocation = 'all',
    this.sortBy = 'expiry_date',
    this.showExpired = false,
    this.showLowStock = false,
  });

  PantryState copyWith({
    bool? isLoading,
    List<PantryItemModel>? pantryItems,
    PantryStatsModel? stats,
    String? error,
    String? selectedLocation,
    String? sortBy,
    bool? showExpired,
    bool? showLowStock,
  }) {
    return PantryState(
      isLoading: isLoading ?? this.isLoading,
      pantryItems: pantryItems ?? this.pantryItems,
      stats: stats ?? this.stats,
      error: error,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      sortBy: sortBy ?? this.sortBy,
      showExpired: showExpired ?? this.showExpired,
      showLowStock: showLowStock ?? this.showLowStock,
    );
  }
}

class PantryCubit extends Cubit<PantryState> {
  final ApiService _apiService;
  final AuthService _authService;

  PantryCubit(this._apiService, this._authService) : super(PantryState());

  Future<void> loadPantryItems({
    String? location,
    bool? isExpired,
    bool? isLowStock,
    String? sortBy,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn cần đăng nhập để xem tủ kho',
        ));
        return;
      }

      final pantryItems = await _apiService.getPantryItems(
        token,
        location: location != 'all' ? location : null,
        isExpired: isExpired,
        isLowStock: isLowStock,
        sortBy: sortBy ?? state.sortBy,
      );

      emit(state.copyWith(
        isLoading: false,
        pantryItems: pantryItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể tải thông tin tủ kho: ${e.toString()}',
      ));
    }
  }

  Future<void> loadPantryStats() async {
    try {
      final token = _authService.accessToken;
      if (token == null) return;

      final stats = await _apiService.getPantryStats(token);
      emit(state.copyWith(stats: stats));
    } catch (e) {
      // Don't show error for stats loading failure
      // Just log it or handle silently
    }
  }

  Future<void> addPantryItem(AddPantryItemDto dto) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn cần đăng nhập để thêm nguyên liệu',
        ));
        return;
      }

      final newItem = await _apiService.addPantryItem(token, dto);
      final updatedItems = [...state.pantryItems, newItem];
      
      emit(state.copyWith(
        isLoading: false,
        pantryItems: updatedItems,
      ));

      // Reload stats
      await loadPantryStats();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể thêm nguyên liệu: ${e.toString()}',
      ));
    }
  }

  Future<void> updatePantryItem(String itemId, UpdatePantryItemDto dto) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn cần đăng nhập để cập nhật nguyên liệu',
        ));
        return;
      }

      final updatedItem = await _apiService.updatePantryItem(token, itemId, dto);
      final updatedItems = state.pantryItems
          .map((item) => item.id == itemId ? updatedItem : item)
          .toList();
      
      emit(state.copyWith(
        isLoading: false,
        pantryItems: updatedItems,
      ));

      // Reload stats
      await loadPantryStats();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể cập nhật nguyên liệu: ${e.toString()}',
      ));
    }
  }

  Future<void> consumePantryItem(String itemId, double quantity) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn cần đăng nhập để sử dụng nguyên liệu',
        ));
        return;
      }

      // Find the item to get ingredientId
      final item = state.pantryItems.firstWhere((item) => item.id == itemId);
      
      await _apiService.consumePantryItem(
        token, 
        itemId, 
        ConsumePantryItemDto(
          ingredientId: item.ingredientId,
          quantity: quantity,
        ),
      );

      // Reload pantry items to get updated quantities
      await loadPantryItems(
        location: state.selectedLocation,
        isExpired: state.showExpired ? true : null,
        isLowStock: state.showLowStock ? true : null,
        sortBy: state.sortBy,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể sử dụng nguyên liệu: ${e.toString()}',
      ));
    }
  }

  Future<void> deletePantryItem(String itemId, {bool reloadAfter = true}) async {
    if (reloadAfter) {
      emit(state.copyWith(isLoading: true, error: null));
    }
    
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn cần đăng nhập để xóa nguyên liệu',
        ));
        return;
      }

      await _apiService.deletePantryItem(token, itemId);
      
      if (reloadAfter) {
        final updatedItems = state.pantryItems
            .where((item) => item.id != itemId)
            .toList();
        
        emit(state.copyWith(
          isLoading: false,
          pantryItems: updatedItems,
        ));

        // Reload stats
        await loadPantryStats();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể xóa nguyên liệu: ${e.toString()}',
      ));
    }
  }

  void setLocationFilter(String location) {
    emit(state.copyWith(selectedLocation: location));
    loadPantryItems(
      location: location,
      isExpired: state.showExpired ? true : null,
      isLowStock: state.showLowStock ? true : null,
      sortBy: state.sortBy,
    );
  }

  void setSortBy(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
    loadPantryItems(
      location: state.selectedLocation != 'all' ? state.selectedLocation : null,
      isExpired: state.showExpired ? true : null,
      isLowStock: state.showLowStock ? true : null,
      sortBy: sortBy,
    );
  }

  void toggleShowExpired(bool showExpired) {
    emit(state.copyWith(showExpired: showExpired));
    loadPantryItems(
      location: state.selectedLocation != 'all' ? state.selectedLocation : null,
      isExpired: showExpired ? true : null,
      isLowStock: state.showLowStock ? true : null,
      sortBy: state.sortBy,
    );
  }

  void toggleShowLowStock(bool showLowStock) {
    emit(state.copyWith(showLowStock: showLowStock));
    loadPantryItems(
      location: state.selectedLocation != 'all' ? state.selectedLocation : null,
      isExpired: state.showExpired ? true : null,
      isLowStock: showLowStock ? true : null,
      sortBy: state.sortBy,
    );
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Helper methods
  List<PantryItemModel> get expiredItems {
    return state.pantryItems.where((item) => item.isExpired).toList();
  }

  List<PantryItemModel> get expiringSoonItems {
    return state.pantryItems.where((item) => item.isExpiringSoon).toList();
  }

  List<PantryItemModel> get lowStockItems {
    return state.pantryItems.where((item) => item.isLowStock).toList();
  }

  Map<String, List<PantryItemModel>> get itemsByLocation {
    final Map<String, List<PantryItemModel>> grouped = {};
    for (final item in state.pantryItems) {
      final location = PantryLocation.values
          .firstWhere((loc) => loc.value == item.location, orElse: () => PantryLocation.pantry)
          .displayName;
      
      if (!grouped.containsKey(location)) {
        grouped[location] = [];
      }
      grouped[location]!.add(item);
    }
    return grouped;
  }

  List<PantryItemModel> getItemsByLocation(PantryLocation location) {
    return state.pantryItems
        .where((item) => item.location == location.value)
        .toList();
  }

  bool hasItemsNeedingAttention() {
    return expiredItems.isNotEmpty || 
           expiringSoonItems.isNotEmpty || 
           lowStockItems.isNotEmpty;
  }

  int get itemsNeedingAttentionCount {
    return expiredItems.length + expiringSoonItems.length + lowStockItems.length;
  }

  // Search and filter methods
  List<PantryItemModel> searchItems(String query) {
    if (query.isEmpty) return state.pantryItems;
    
    final lowerQuery = query.toLowerCase();
    return state.pantryItems.where((item) =>
      item.ingredientName.toLowerCase().contains(lowerQuery) ||
      (item.notes?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  List<PantryItemModel> getFilteredItems({
    String? search,
    PantryLocation? location,
    bool? showOnlyExpired,
    bool? showOnlyLowStock,
  }) {
    var items = state.pantryItems;

    if (search != null && search.isNotEmpty) {
      items = searchItems(search);
    }

    if (location != null) {
      items = items.where((item) => item.location == location.value).toList();
    }

    if (showOnlyExpired == true) {
      items = items.where((item) => item.isExpired).toList();
    }

    if (showOnlyLowStock == true) {
      items = items.where((item) => item.isLowStock).toList();
    }

    return items;
  }

  // Auto-consume ingredients when cooking
  Future<void> consumeIngredientsFromRecipe(String recipeId, int servings) async {
    try {
      final token = _authService.accessToken;
      if (token == null) return;

      // TODO: Get recipe ingredients from API
      // For now, we'll implement a mock version
      // In real implementation, you would:
      // 1. Get recipe ingredients with their quantities
      // 2. Calculate actual quantities needed based on servings
      // 3. Check pantry for available ingredients
      // 4. Auto-consume if available, or create shopping list if not

      print('Auto-consuming ingredients for recipe $recipeId with $servings servings');
      
      // Mock consumption - this would be replaced with actual API calls
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reload pantry to reflect consumed ingredients
      await loadPantryItems();
      
    } catch (e) {
      print('Error auto-consuming ingredients: $e');
      // Don't emit error for auto-consumption failures
      // as this is a background operation
    }
  }

  // Check if pantry has enough ingredients for a recipe
  Future<Map<String, dynamic>> checkIngredientsAvailability(String recipeId, int servings) async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        return {
          'available': false,
          'missing': [],
          'message': 'Cần đăng nhập để kiểm tra nguyên liệu'
        };
      }

      // TODO: Implement actual checking logic
      // This would involve:
      // 1. Get recipe ingredients
      // 2. Check pantry inventory
      // 3. Calculate what's missing
      
      return {
        'available': true,
        'missing': [],
        'message': 'Đủ nguyên liệu để nấu'
      };
    } catch (e) {
      return {
        'available': false,
        'missing': [],
        'message': 'Lỗi kiểm tra nguyên liệu: $e'
      };
    }
  }
}