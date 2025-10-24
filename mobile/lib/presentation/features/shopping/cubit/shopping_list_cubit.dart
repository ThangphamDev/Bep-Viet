import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';

class ShoppingListState {
  final bool isLoading;
  final List<ShoppingListModel> shoppingLists;
  final ShoppingListModel? selectedList;
  final String? error;
  final bool isGenerating;

  ShoppingListState({
    this.isLoading = false,
    this.shoppingLists = const [],
    this.selectedList,
    this.error,
    this.isGenerating = false,
  });

  ShoppingListState copyWith({
    bool? isLoading,
    List<ShoppingListModel>? shoppingLists,
    ShoppingListModel? selectedList,
    String? error,
    bool? isGenerating,
  }) {
    return ShoppingListState(
      isLoading: isLoading ?? this.isLoading,
      shoppingLists: shoppingLists ?? this.shoppingLists,
      selectedList: selectedList ?? this.selectedList,
      error: error,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final ApiService _apiService;
  final AuthService _authService;

  ShoppingListCubit(this._apiService, this._authService)
    : super(ShoppingListState());

  Future<void> loadShoppingLists() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xem danh sách mua sắm',
          ),
        );
        return;
      }

      final shoppingLists = await _apiService.getShoppingLists(token);

      // Smart selection: preserve current selection if it still exists, otherwise pick the newest
      ShoppingListModel? newSelectedList;
      if (state.selectedList != null) {
        // Try to keep the current selection if it's still in the list
        try {
          newSelectedList = shoppingLists.firstWhere(
            (list) => list.id == state.selectedList!.id,
          );
        } catch (e) {
          // Current selection no longer exists, pick newest
          newSelectedList = null;
        }
      }

      // If no valid selection, pick the newest (by createdAt - same as backend)
      if (newSelectedList == null && shoppingLists.isNotEmpty) {
        final sortedLists = [...shoppingLists]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        newSelectedList = sortedLists.first;
      }

      emit(
        state.copyWith(
          isLoading: false,
          shoppingLists: shoppingLists,
          selectedList: newSelectedList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải danh sách mua sắm: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadShoppingListById(String listId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xem danh sách mua sắm',
          ),
        );
        return;
      }

      final shoppingList = await _apiService.getShoppingListById(token, listId);
      emit(state.copyWith(isLoading: false, selectedList: shoppingList));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải danh sách mua sắm: ${e.toString()}',
        ),
      );
    }
  }

  Future<String> createShoppingList(CreateShoppingListDto dto) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để tạo danh sách mua sắm',
          ),
        );
        throw Exception('Not logged in');
      }

      // Create list (backend returns list ID only)
      final listId = await _apiService.createShoppingList(token, dto);

      // Reload lists to get the new one
      await loadShoppingLists();

      emit(state.copyWith(isLoading: false));

      return listId;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tạo danh sách mua sắm: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }

  Future<void> generateShoppingListFromMealPlan(String mealPlanId) async {
    emit(state.copyWith(isGenerating: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isGenerating: false,
            error: 'Bạn cần đăng nhập để tạo danh sách mua sắm',
          ),
        );
        return;
      }

      // Generate the shopping list (backend returns {list_id, total_items, message})
      final result = await _apiService.generateShoppingListFromMealPlan(
        token,
        mealPlanId,
      );
      final newListId = result['list_id'] as String;

      // Load the newly created shopping list with full details
      final newList = await _apiService.getShoppingListById(token, newListId);

      // Add to the list of shopping lists
      final updatedLists = [...state.shoppingLists, newList];

      emit(
        state.copyWith(
          isGenerating: false,
          shoppingLists: updatedLists,
          selectedList: newList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isGenerating: false,
          error:
              'Không thể tạo danh sách mua sắm từ kế hoạch bữa ăn: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> addItemToShoppingList(
    String listId,
    AddShoppingItemDto dto,
  ) async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(state.copyWith(error: 'Bạn cần đăng nhập để thêm món hàng'));
        return;
      }

      // Add item (backend returns {id} only)
      await _apiService.addItemToShoppingList(token, listId, dto);

      // Reload the shopping list to get updated data
      await loadShoppingListById(listId);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể thêm món hàng: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateShoppingItem(
    String listId,
    String itemId,
    UpdateShoppingItemDto dto,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để cập nhật món hàng',
          ),
        );
        return;
      }

      // Call update API (backend returns {success, message} only)
      await _apiService.updateShoppingItem(token, listId, itemId, dto);

      // Reload the shopping list to get updated data
      await loadShoppingListById(listId);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể cập nhật món hàng: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> toggleItemChecked(
    String listId,
    String itemId,
    bool isChecked,
  ) async {
    // Optimistic update - update UI immediately
    if (state.selectedList != null && state.selectedList!.id == listId) {
      final updatedItems = state.selectedList!.items.map((item) {
        if (item.id == itemId) {
          return ShoppingItem(
            id: item.id,
            shoppingListId: item.shoppingListId,
            ingredientId: item.ingredientId,
            ingredientName: item.ingredientName,
            quantity: item.quantity,
            unit: item.unit,
            isChecked: isChecked,
            notes: item.notes,
            storeSectionId: item.storeSectionId,
            storeSectionName: item.storeSectionName,
            estimatedPrice: item.estimatedPrice,
            priority: item.priority,
          );
        }
        return item;
      }).toList();

      final updatedList = ShoppingListModel(
        id: state.selectedList!.id,
        userId: state.selectedList!.userId,
        name: state.selectedList!.name,
        description: state.selectedList!.description,
        items: updatedItems,
        isShared: state.selectedList!.isShared,
        sharedWith: state.selectedList!.sharedWith,
        createdAt: state.selectedList!.createdAt,
        updatedAt: state.selectedList!.updatedAt,
      );

      final updatedLists = state.shoppingLists
          .map((list) => list.id == listId ? updatedList : list)
          .toList();

      emit(
        state.copyWith(shoppingLists: updatedLists, selectedList: updatedList),
      );
    }

    // Call API in background without waiting
    try {
      final token = _authService.accessToken;
      if (token != null) {
        _apiService.updateShoppingItem(
          token,
          listId,
          itemId,
          UpdateShoppingItemDto(isPurchased: isChecked),
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> deleteShoppingList(String listId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xóa danh sách',
          ),
        );
        return;
      }

      await _apiService.deleteShoppingList(token, listId);

      final updatedLists = state.shoppingLists
          .where((list) => list.id != listId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          shoppingLists: updatedLists,
          selectedList: state.selectedList?.id == listId
              ? null
              : state.selectedList,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể xóa danh sách: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> removeItemFromShoppingList(String listId, String itemId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để xóa món hàng',
          ),
        );
        return;
      }

      await _apiService.removeItemFromShoppingList(token, listId, itemId);

      // Reload the shopping list to get updated data
      await loadShoppingListById(listId);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể xóa món hàng: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> shareShoppingList(String listId, String email) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = _authService.accessToken;
      if (token == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Bạn cần đăng nhập để chia sẻ danh sách',
          ),
        );
        return;
      }

      await _apiService.shareShoppingList(token, listId, email);

      emit(state.copyWith(isLoading: false));

      // Show success message by emitting temporary success state
      // UI can listen and show snackbar/toast
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể chia sẻ danh sách: ${e.toString()}',
        ),
      );
    }
  }

  void selectShoppingList(ShoppingListModel shoppingList) {
    // Also ensure the list is in shoppingLists if not already
    final lists = state.shoppingLists.any((l) => l.id == shoppingList.id)
        ? state.shoppingLists
        : [...state.shoppingLists, shoppingList];

    emit(state.copyWith(shoppingLists: lists, selectedList: shoppingList));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Helper methods
  List<ShoppingItem> get checkedItems {
    if (state.selectedList == null) return [];
    return state.selectedList!.items.where((item) => item.isChecked).toList();
  }

  List<ShoppingItem> get uncheckedItems {
    if (state.selectedList == null) return [];
    return state.selectedList!.items.where((item) => !item.isChecked).toList();
  }

  Map<String, List<ShoppingItem>> get itemsBySection {
    if (state.selectedList == null) return {};

    final Map<String, List<ShoppingItem>> grouped = {};
    for (final item in state.selectedList!.items) {
      final section = item.storeSectionName ?? 'Khác';
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(item);
    }
    return grouped;
  }

  double get totalEstimatedPrice {
    if (state.selectedList == null) return 0;
    return state.selectedList!.items.fold(
      0.0,
      (sum, item) => sum + (item.estimatedPrice ?? 0) * item.quantity,
    );
  }

  int get completionPercentage {
    if (state.selectedList == null || state.selectedList!.items.isEmpty)
      return 0;
    final totalItems = state.selectedList!.items.length;
    final checkedItems = state.selectedList!.items
        .where((item) => item.isChecked)
        .length;
    return ((checkedItems / totalItems) * 100).round();
  }
}
