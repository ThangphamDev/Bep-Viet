import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService(this._dio, {String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.ngrokBaseUrl {
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add ngrok-skip-browser-warning header
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  // Auth
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<UserModel> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is Map<String, dynamic>) {
          return UserModel.fromJson(map['data'] as Map<String, dynamic>);
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Recipes
  Future<List<RecipeModel>> getRecipes({
    String? region,
    int? maxTime,
    String? search,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {
          if (region != null) 'region': region,
          if (maxTime != null) 'max_time': maxTime,
          if (search != null) 'search': search,
          'limit': limit ?? 50, // Default limit to 50 recipes
        },
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await _dio.get('/api/recipes/$id');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          return RecipeModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  Future<List<RecipeIngredientModel>> getRecipeIngredients(String id) async {
    try {
      final response = await _dio.get('/api/recipes/$id/ingredients');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map(
                (e) =>
                    RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map(
              (e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch recipe ingredients: $e');
    }
  }

  Future<List<RecipeVariantModel>> getRecipeVariants(String id) async {
    try {
      final response = await _dio.get('/api/recipes/$id/variants');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map(
                (e) => RecipeVariantModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => RecipeVariantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch recipe variants: $e');
    }
  }

  // Suggestions
  Future<List<SuggestionModel>> searchSuggestions(
    SearchSuggestionsRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/suggestions/search',
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => SuggestionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => SuggestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search suggestions: $e');
    }
  }

  Future<List<SuggestionModel>> getSuggestionsByPantry({
    required String userId,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/suggestions/pantry',
        queryParameters: {
          'userId': userId,
          'limit': limit ?? 50, // Default limit to 50 suggestions
        },
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => SuggestionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pantry suggestions: $e');
    }
  }

  // Regions
  Future<List<Map<String, dynamic>>> getRegions() async {
    try {
      final response = await _dio.get('/api/regions');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch regions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSubregions() async {
    try {
      final response = await _dio.get('/api/regions/subregions');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch subregions: $e');
    }
  }

  // Seasons
  Future<List<Map<String, dynamic>>> getSeasons() async {
    try {
      final response = await _dio.get('/api/seasons');
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch seasons: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentSeason() async {
    try {
      final response = await _dio.get('/api/seasons/current');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch current season: $e');
    }
  }

  // Ingredients
  Future<List<Map<String, dynamic>>> getIngredients({
    String? search,
    String? category,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/ingredients',
        queryParameters: {
          if (search != null) 'search': search,
          if (category != null) 'category': category,
          'limit': limit ?? 50, // Default limit to 50 ingredients
        },
      );
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch ingredients: $e');
    }
  }

  // =================== PHASE 3 API METHODS ===================

  // Meal Plans
  Future<List<MealPlanModel>> getMealPlans({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/meal-plans',
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          'limit': limit ?? 50,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => MealPlanModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => MealPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch meal plans: $e');
    }
  }

  Future<MealPlanModel> getMealPlan(String id) async {
    try {
      final response = await _dio.get('/api/meal-plans/$id');
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return MealPlanModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return MealPlanModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch meal plan: $e');
    }
  }

  Future<MealPlanModel> createMealPlan(CreateMealPlanRequest request) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return MealPlanModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return MealPlanModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create meal plan: $e');
    }
  }

  Future<MealPlanModel> updateMealPlan(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        '/api/meal-plans/$id',
        data: updates,
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return MealPlanModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return MealPlanModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update meal plan: $e');
    }
  }

  Future<void> deleteMealPlan(String id) async {
    try {
      await _dio.delete('/api/meal-plans/$id');
    } catch (e) {
      throw Exception('Failed to delete meal plan: $e');
    }
  }

  // Shopping Lists
  Future<List<ShoppingListModel>> getShoppingLists({
    bool? isShared,
    String? status,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/shopping',
        queryParameters: {
          if (isShared != null) 'is_shared': isShared,
          if (status != null) 'status': status,
          'limit': limit ?? 50,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => ShoppingListModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => ShoppingListModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch shopping lists: $e');
    }
  }

  Future<ShoppingListModel> getShoppingList(String id) async {
    try {
      final response = await _dio.get('/api/shopping/$id');
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return ShoppingListModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return ShoppingListModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch shopping list: $e');
    }
  }

  Future<ShoppingListModel> createShoppingList(CreateShoppingListRequest request) async {
    try {
      final response = await _dio.post(
        '/api/shopping',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return ShoppingListModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return ShoppingListModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create shopping list: $e');
    }
  }

  Future<ShoppingListModel> updateShoppingList(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        '/api/shopping/$id',
        data: updates,
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return ShoppingListModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return ShoppingListModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update shopping list: $e');
    }
  }

  Future<void> deleteShoppingList(String id) async {
    try {
      await _dio.delete('/api/shopping/$id');
    } catch (e) {
      throw Exception('Failed to delete shopping list: $e');
    }
  }

  Future<ShoppingItemModel> updateShoppingItem(String listId, String itemId, UpdateShoppingItemRequest request) async {
    try {
      final response = await _dio.put(
        '/api/shopping/$listId/items/$itemId',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return ShoppingItemModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return ShoppingItemModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update shopping item: $e');
    }
  }

  // Pantry Items
  Future<List<PantryItemModel>> getPantryItems({
    String? category,
    String? location,
    String? status,
    String? sortBy,
    bool? isAscending,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/pantry',
        queryParameters: {
          if (category != null) 'category': category,
          if (location != null) 'location': location,
          if (status != null) 'status': status,
          if (sortBy != null) 'sort_by': sortBy,
          if (isAscending != null) 'ascending': isAscending,
          'limit': limit ?? 100,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => PantryItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      if (response.data is List) {
        return (response.data as List)
            .map((e) => PantryItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch pantry items: $e');
    }
  }

  Future<PantryItemModel> getPantryItem(String id) async {
    try {
      final response = await _dio.get('/api/pantry/$id');
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return PantryItemModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch pantry item: $e');
    }
  }

  Future<PantryItemModel> createPantryItem(CreatePantryItemRequest request) async {
    try {
      final response = await _dio.post(
        '/api/pantry',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return PantryItemModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create pantry item: $e');
    }
  }

  Future<PantryItemModel> updatePantryItem(String id, UpdatePantryItemRequest request) async {
    try {
      final response = await _dio.put(
        '/api/pantry/$id',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return PantryItemModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update pantry item: $e');
    }
  }

  Future<void> deletePantryItem(String id) async {
    try {
      await _dio.delete('/api/pantry/$id');
    } catch (e) {
      throw Exception('Failed to delete pantry item: $e');
    }
  }

  Future<PantryItemModel> usePantryItem(String id, UsePantryItemRequest request) async {
    try {
      final response = await _dio.post(
        '/api/pantry/$id/use',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return PantryItemModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to use pantry item: $e');
    }
  }

  // Create shopping list from meal plan
  Future<ShoppingListModel> createShoppingListFromMealPlan(String mealPlanId, CreateShoppingListRequest request) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans/$mealPlanId/shopping-list',
        data: request.toJson(),
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return ShoppingListModel.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return ShoppingListModel.fromJson(responseData);
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create shopping list from meal plan: $e');
    }
  }
}
