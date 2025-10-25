import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

/// Service để xử lý logic nấu ăn và consume nguyên liệu từ tủ lạnh
class CookingService {
  final ApiService _apiService;
  final AuthService _authService;

  CookingService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  /// Kiểm tra và consume nguyên liệu khi nấu món
  /// 
  /// Returns:
  /// - `success`: true nếu đủ nguyên liệu và consume thành công
  /// - `missingIngredients`: danh sách nguyên liệu thiếu (nếu có)
  /// - `message`: thông báo kết quả
  Future<CookingResult> cookMeal({
    required String recipeId,
    required String recipeName,
    int servings = 1,
  }) async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        return CookingResult(
          success: false,
          message: 'Bạn cần đăng nhập để sử dụng chức năng này',
          missingIngredients: [],
        );
      }

      // 1. Lấy recipe details với ingredients
      print('Fetching recipe: $recipeId');
      final recipe = await _apiService.getRecipeById(recipeId);
      print('Recipe fetched successfully: ${recipe.name}');
      
      if (recipe.ingredients == null || recipe.ingredients!.isEmpty) {
        return CookingResult(
          success: false,
          message: 'Món ăn không có danh sách nguyên liệu',
          missingIngredients: [],
        );
      }

      // 2. Lấy danh sách nguyên liệu trong tủ lạnh
      final pantryItems = await _apiService.getPantryItems(token);

      // 3. Tính toán servings ratio
      final servingsRatio = servings / (recipe.servings ?? 1);

      // 4. Kiểm tra từng nguyên liệu
      final List<MissingIngredient> missingIngredients = [];
      final Map<String, List<PantryItemModel>> pantryMap = {};
      
      // Tạo map để lookup nhanh - lưu TẤT CẢ items của cùng ingredient
      for (final pantryItem in pantryItems) {
        if (!pantryMap.containsKey(pantryItem.ingredientId)) {
          pantryMap[pantryItem.ingredientId] = [];
        }
        pantryMap[pantryItem.ingredientId]!.add(pantryItem);
      }

      // Kiểm tra availability
      for (final recipeIngredient in recipe.ingredients!) {
        final requiredQuantity = recipeIngredient.quantity * servingsRatio;
        final itemsForIngredient = pantryMap[recipeIngredient.ingredientId];

        if (itemsForIngredient == null || itemsForIngredient.isEmpty) {
          // Không có nguyên liệu này
          missingIngredients.add(MissingIngredient(
            ingredientId: recipeIngredient.ingredientId,
            ingredientName: recipeIngredient.ingredientName,
            requiredQuantity: requiredQuantity,
            availableQuantity: 0,
            unit: recipeIngredient.unit,
            status: MissingStatus.notInPantry,
          ));
        } else {
          // Tính tổng số lượng available từ tất cả items
          final totalAvailable = itemsForIngredient.fold<double>(
            0, 
            (sum, item) => sum + item.currentQuantity,
          );
          
          if (totalAvailable < requiredQuantity) {
            // Có nhưng không đủ
            missingIngredients.add(MissingIngredient(
              ingredientId: recipeIngredient.ingredientId,
              ingredientName: recipeIngredient.ingredientName,
              requiredQuantity: requiredQuantity,
              availableQuantity: totalAvailable,
              unit: recipeIngredient.unit,
              status: MissingStatus.insufficient,
            ));
          }
        }
      }

      // 5. Nếu thiếu nguyên liệu, trả về danh sách thiếu
      if (missingIngredients.isNotEmpty) {
        return CookingResult(
          success: false,
          message: 'Không đủ nguyên liệu để nấu món này',
          missingIngredients: missingIngredients,
        );
      }

      // 6. Đủ nguyên liệu, tiến hành consume
      final List<String> consumedIngredients = [];
      final List<String> failedIngredients = [];

      for (final recipeIngredient in recipe.ingredients!) {
        var remainingQuantity = recipeIngredient.quantity * servingsRatio;
        final itemsForIngredient = pantryMap[recipeIngredient.ingredientId]!;

        // Sort items by expiry date (consume items that expire soon first)
        // Note: Backend also sorts by expire_date ASC automatically
        itemsForIngredient.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1; // Items without expiry date go last
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });

        bool hasError = false;

        // Backend consume endpoint: POST /api/pantry/consume
        // - Accepts ingredient_id + quantity (not itemId)
        // - Automatically picks item with earliest expire_date
        // - Only consumes from 1 item per call (LIMIT 1)
        // So we need to call multiple times for large quantities

        // Consume từng item cho đến khi đủ số lượng
        for (final pantryItem in itemsForIngredient) {
          if (remainingQuantity <= 0) break;

          final quantityToConsume = remainingQuantity > pantryItem.currentQuantity
              ? pantryItem.currentQuantity
              : remainingQuantity;

          try {
            // Backend will automatically select the item with earliest expire_date
            // We pass itemId for logging but backend doesn't use it
            await _apiService.consumePantryItem(
              token,
              pantryItem.id,  // Not used by backend, but kept for compatibility
              ConsumePantryItemDto(
                ingredientId: recipeIngredient.ingredientId,  // Backend uses this
                quantity: quantityToConsume,  // DTO.toJson() auto-converts to int
              ),
            );
            remainingQuantity -= quantityToConsume;
          } catch (e) {
            hasError = true;
            print('Failed to consume ${recipeIngredient.ingredientName}: $e');
            break;
          }
        }

        if (hasError || remainingQuantity > 0.001) { // Small tolerance for floating point
          failedIngredients.add(recipeIngredient.ingredientName);
        } else {
          consumedIngredients.add(recipeIngredient.ingredientName);
        }
      }

      // 7. Trả về kết quả
      if (failedIngredients.isEmpty) {
        return CookingResult(
          success: true,
          message: 'Đã nấu món "$recipeName" thành công!\nĐã trừ ${consumedIngredients.length} nguyên liệu khỏi tủ lạnh.',
          missingIngredients: [],
          consumedCount: consumedIngredients.length,
        );
      } else {
        return CookingResult(
          success: false,
          message: 'Có lỗi khi trừ một số nguyên liệu.\nĐã trừ: ${consumedIngredients.length}\nThất bại: ${failedIngredients.length}',
          missingIngredients: [],
          consumedCount: consumedIngredients.length,
          failedCount: failedIngredients.length,
        );
      }
    } catch (e) {
      return CookingResult(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        missingIngredients: [],
      );
    }
  }

  /// Chỉ kiểm tra availability mà không consume
  Future<CookingResult> checkIngredientAvailability({
    required String recipeId,
    int servings = 1,
  }) async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        return CookingResult(
          success: false,
          message: 'Bạn cần đăng nhập để sử dụng chức năng này',
          missingIngredients: [],
        );
      }

      // 1. Lấy recipe details
      final recipe = await _apiService.getRecipeById(recipeId);
      
      if (recipe.ingredients == null || recipe.ingredients!.isEmpty) {
        return CookingResult(
          success: false,
          message: 'Món ăn không có danh sách nguyên liệu',
          missingIngredients: [],
        );
      }

      // 2. Lấy pantry items
      final pantryItems = await _apiService.getPantryItems(token);

      // 3. Tính servings ratio
      final servingsRatio = servings / (recipe.servings ?? 1);

      // 4. Check availability
      final List<MissingIngredient> missingIngredients = [];
      final Map<String, List<PantryItemModel>> pantryMap = {};
      
      for (final pantryItem in pantryItems) {
        if (!pantryMap.containsKey(pantryItem.ingredientId)) {
          pantryMap[pantryItem.ingredientId] = [];
        }
        pantryMap[pantryItem.ingredientId]!.add(pantryItem);
      }

      for (final recipeIngredient in recipe.ingredients!) {
        final requiredQuantity = recipeIngredient.quantity * servingsRatio;
        final itemsForIngredient = pantryMap[recipeIngredient.ingredientId];

        if (itemsForIngredient == null || itemsForIngredient.isEmpty) {
          missingIngredients.add(MissingIngredient(
            ingredientId: recipeIngredient.ingredientId,
            ingredientName: recipeIngredient.ingredientName,
            requiredQuantity: requiredQuantity,
            availableQuantity: 0,
            unit: recipeIngredient.unit,
            status: MissingStatus.notInPantry,
          ));
        } else {
          final totalAvailable = itemsForIngredient.fold<double>(
            0, 
            (sum, item) => sum + item.currentQuantity,
          );
          
          if (totalAvailable < requiredQuantity) {
            missingIngredients.add(MissingIngredient(
              ingredientId: recipeIngredient.ingredientId,
              ingredientName: recipeIngredient.ingredientName,
              requiredQuantity: requiredQuantity,
              availableQuantity: totalAvailable,
              unit: recipeIngredient.unit,
              status: MissingStatus.insufficient,
            ));
          }
        }
      }

      if (missingIngredients.isEmpty) {
        return CookingResult(
          success: true,
          message: 'Đủ nguyên liệu để nấu món này!',
          missingIngredients: [],
        );
      } else {
        return CookingResult(
          success: false,
          message: 'Thiếu ${missingIngredients.length} nguyên liệu',
          missingIngredients: missingIngredients,
        );
      }
    } catch (e) {
      return CookingResult(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        missingIngredients: [],
      );
    }
  }
}

/// Kết quả của việc kiểm tra/nấu món
class CookingResult {
  final bool success;
  final String message;
  final List<MissingIngredient> missingIngredients;
  final int consumedCount;
  final int failedCount;

  CookingResult({
    required this.success,
    required this.message,
    required this.missingIngredients,
    this.consumedCount = 0,
    this.failedCount = 0,
  });
}

/// Nguyên liệu bị thiếu
class MissingIngredient {
  final String ingredientId;
  final String ingredientName;
  final double requiredQuantity;
  final double availableQuantity;
  final String unit;
  final MissingStatus status;

  MissingIngredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.unit,
    required this.status,
  });

  double get missingQuantity => requiredQuantity - availableQuantity;
}

/// Trạng thái thiếu nguyên liệu
enum MissingStatus {
  notInPantry,    // Không có trong tủ lạnh
  insufficient,   // Có nhưng không đủ
}

