import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email hoặc mật khẩu không đúng');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Tài khoản không tồn tại');
      } else if (e.response?.data != null && e.response?.data is Map) {
        final errorMessage =
            e.response?.data['message'] ?? 'Đăng nhập thất bại';
        throw Exception(errorMessage);
      } else {
        throw Exception('Không thể kết nối đến server');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đăng nhập thất bại');
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Email đã được sử dụng');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Thông tin không hợp lệ';
        throw Exception(errorMessage);
      } else if (e.response?.data != null && e.response?.data is Map) {
        final errorMessage = e.response?.data['message'] ?? 'Đăng ký thất bại';
        throw Exception(errorMessage);
      } else {
        throw Exception('Không thể kết nối đến server');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đăng ký thất bại');
    }
  }

  Future<UserModel> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/users/me',
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

  Future<void> deleteAccount(String token) async {
    try {
      await _dio.delete(
        '/api/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<UserModel> updateProfile(
    String token, {
    required String name,
    required String region,
    required String subregion,
  }) async {
    try {
      final response = await _dio.put(
        '/api/users/profile',
        data: {'name': name, 'region': region, 'subregion': subregion},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return UserModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/api/users/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Meal Plans
  Future<Map<String, dynamic>> quickAddToToday({
    required String token,
    required String recipeId,
    required String mealSlot,
    required int servings,
    String? variantRegion,
  }) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans/quick-add',
        data: {
          'recipe_id': recipeId,
          'meal_slot': mealSlot,
          'servings': servings,
          if (variantRegion != null) 'variant_region': variantRegion,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false};
    } catch (e) {
      throw Exception('Failed to add meal to today: $e');
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

  Future<RecipeModel> getRecipeById(String id, {String? userId}) async {
    try {
      final queryParams = userId != null ? {'userId': userId} : null;
      final response = await _dio.get(
        '/api/recipes/$id',
        queryParameters: queryParams,
      );

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

  Future<Map<String, dynamic>> getRecipeIngredientsRaw(String recipeId) async {
    try {
      final response = await _dio.get('/api/recipes/$recipeId/ingredients');

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch recipe ingredients: $e');
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

  // Favorites
  Future<List<RecipeModel>> getFavorites(String token) async {
    try {
      final response = await _dio.get(
        '/api/recipes/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      throw Exception('Failed to get favorites: $e');
    }
  }

  Future<void> addFavorite(String token, String recipeId) async {
    try {
      await _dio.post(
        '/api/recipes/$recipeId/favorite',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String token, String recipeId) async {
    try {
      await _dio.delete(
        '/api/recipes/$recipeId/favorite',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
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

  // Gemini AI - Image Recognition
  Future<Map<String, dynamic>> analyzeImageBase64(String imageBase64) async {
    try {
      final response = await _dio.post(
        '/api/gemini/analyze-image-base64',
        data: {'imageBase64': imageBase64},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  Future<Map<String, dynamic>> getSuggestionsFromIngredients({
    required List<String> ingredientIds,
    String? region,
    int? limit,
  }) async {
    try {
      final response = await _dio.post(
        '/api/gemini/suggest-from-ingredients',
        queryParameters: {
          if (region != null) 'region': region,
          if (limit != null) 'limit': limit,
        },
        data: {'ingredient_ids': ingredientIds},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'data': []};
    } catch (e) {
      throw Exception('Failed to get suggestions from ingredients: $e');
    }
  }

  // Gemini AI Chatbot - Conversational recipe suggestions
  Future<Map<String, dynamic>> getAiSuggestionsChatbot({
    required List<String> ingredientIds,
    String? region,
    int? spicePreference,
    String? userPrompt,
    int? limit,
  }) async {
    try {
      final response = await _dio.post(
        '/api/gemini/ai-suggest-chatbot',
        data: {
          'ingredient_ids': ingredientIds,
          if (region != null) 'region': region,
          if (spicePreference != null) 'spice_preference': spicePreference,
          if (userPrompt != null && userPrompt.isNotEmpty) 'prompt': userPrompt,
          if (limit != null) 'limit': limit,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'data': null};
    } catch (e) {
      throw Exception('Failed to get AI chatbot suggestions: $e');
    }
  }

  // Gemini AI - Text + Filters based suggestion (OLD VERSION)
  Future<Map<String, dynamic>> getAiSuggestions({
    required List<String> ingredientIds,
    String? region,
    int? spicePreference,
    String? userPrompt,
    int? limit,
  }) async {
    try {
      final response = await _dio.post(
        '/api/gemini/ai-suggest',
        data: {
          'ingredient_ids': ingredientIds,
          if (region != null) 'region': region,
          if (spicePreference != null) 'spice_preference': spicePreference,
          if (userPrompt != null && userPrompt.isNotEmpty) 'prompt': userPrompt,
          if (limit != null) 'limit': limit,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'data': []};
    } catch (e) {
      throw Exception('Failed to get AI suggestions: $e');
    }
  }

  // NOTE: Prompt building đã được chuyển sang backend
  // Backend sẽ phân tích user prompt với Gemini và trả về kết quả đã được filter

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

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    try {
      final response = await _dio.get(
        '/api/ingredients/search',
        queryParameters: {'q': query},
      );
      if (response.data is List) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search ingredients: $e');
    }
  }

  // ===== PHASE 3 API METHODS =====

  // Meal Plans
  Future<List<MealPlanModel>> getMealPlans(String token, {String? date}) async {
    try {
      final response = await _dio.get(
        '/api/meal-plans',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      print('Get meal plans error: $e');
      throw Exception('Không thể tải kế hoạch bữa ăn: ${e.toString()}');
    }
  }

  Future<MealPlanModel?> getMealPlanByWeek(
    String token,
    String userId,
    String weekStartDate,
  ) async {
    try {
      final response = await _dio.get(
        '/api/meal-plans/$userId/$weekStartDate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          return MealPlanModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      print('Get meal plan by week error: $e');
      return null; // Return null instead of throwing for not found
    }
  }

  Future<MealPlanModel> createMealPlan(
    String token,
    CreateMealPlanDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Create a meal plan model with the returned ID
          return MealPlanModel(
            id: data['id']?.toString() ?? 'unknown',
            userId: 'current-user',
            weekStartDate: dto.weekStartDate,
            name: dto.note ?? 'Kế hoạch bữa ăn',
            description: dto.note,
            meals: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      print('Create meal plan error: $e');
      throw Exception('Không thể tạo kế hoạch bữa ăn: ${e.toString()}');
    }
  }

  Future<bool> addMealToPlan(
    String token,
    String planId,
    AddMealDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans/$planId/meals',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      throw Exception('Failed to add meal to plan: $e');
    }
  }

  Future<MealPlanModel> quickAddMealToToday(
    String token,
    QuickAddMealDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/meal-plans/quick-add',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true) {
          // Create a meal plan model for today
          final today = DateTime.now();
          final todayStr =
              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

          return MealPlanModel(
            id: responseData['data']?['meal_plan_id'] ?? 'today-plan',
            userId: 'current-user',
            weekStartDate: todayStr,
            name: 'Kế hoạch hôm nay',
            description: 'Đã thêm món ăn vào hôm nay',
            meals: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      print('Quick add meal error: $e');
      throw Exception('Không thể thêm món ăn: ${e.toString()}');
    }
  }

  Future<MealPlanModel> generateMealPlan(
    String token, {
    DateTime? startDate,
    String? region,
    int? budgetPerMeal,
    int servings = 2,
  }) async {
    try {
      final weekStart = startDate ?? DateTime.now();
      final weekStartStr =
          '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

      final response = await _dio.post(
        '/api/meal-plans/generate',
        data: {
          'week_start': weekStartStr,
          'region': region ?? 'NAM',
          'budget_per_meal': budgetPerMeal ?? 50000,
          'servings': servings,
          'constraints': {
            'max_time': 60,
            'no_repeat': true,
            'nutrition_balance': true,
          },
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🤖 API generateMealPlan - Status: ${response.statusCode}');
      print('🤖 API generateMealPlan - Response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        print(
          '🤖 API generateMealPlan - responseData["success"]: ${responseData['success']}',
        );
        print(
          '🤖 API generateMealPlan - responseData["data"] type: ${responseData['data']?.runtimeType}',
        );

        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          print('🤖 API generateMealPlan - data keys: ${data.keys}');

          // Parse meals from the response
          List<MealSlot> meals = [];
          if (data['days'] is List) {
            final days = data['days'] as List;
            print('🤖 API generateMealPlan - days count: ${days.length}');
            for (var day in days) {
              if (day is Map<String, dynamic> &&
                  day['meals'] is Map<String, dynamic>) {
                final dayMeals = day['meals'] as Map<String, dynamic>;
                final date = day['date']?.toString() ?? '';

                print('🤖 API generateMealPlan - Processing date: $date');
                print(
                  '🤖 API generateMealPlan - dayMeals keys: ${dayMeals.keys}',
                );

                // Parse each meal slot (breakfast, lunch, dinner)
                // Check both uppercase and lowercase keys
                final mealTypesMap = {
                  MealType.breakfast: ['BREAKFAST', 'breakfast'],
                  MealType.lunch: ['LUNCH', 'lunch'],
                  MealType.dinner: ['DINNER', 'dinner'],
                };

                for (var entry in mealTypesMap.entries) {
                  final mealTypeEnum = entry.key;
                  final possibleKeys = entry.value;

                  // Try to find meal data with either uppercase or lowercase key
                  Map<String, dynamic>? mealData;
                  String? foundKey;

                  for (var key in possibleKeys) {
                    if (dayMeals[key] is Map<String, dynamic>) {
                      mealData = dayMeals[key] as Map<String, dynamic>;
                      foundKey = key;
                      break;
                    }
                  }

                  if (mealData != null && foundKey != null) {
                    print(
                      '🤖 API generateMealPlan - Found meal: $foundKey = ${mealData['recipe_name']}',
                    );

                    final meal = MealSlot(
                      id: 'generated-${DateTime.now().millisecondsSinceEpoch}-$foundKey-$date',
                      mealPlanId:
                          'generated-${DateTime.now().millisecondsSinceEpoch}',
                      date: date,
                      mealType: mealTypeEnum,
                      recipeId: mealData['recipe_id']?.toString(),
                      recipeName:
                          mealData['recipe_name']?.toString() ?? 'Món ăn',
                      recipeImage: mealData['recipe_image']?.toString(),
                      servings: mealData['servings'] ?? servings,
                    );
                    meals.add(meal);
                  }
                }
              }
            }

            print(
              '🤖 API generateMealPlan - Total meals parsed: ${meals.length}',
            );
          }

          // Convert the backend response to our model format
          final mealPlan = MealPlanModel(
            id: 'generated-${DateTime.now().millisecondsSinceEpoch}',
            userId: 'current-user',
            weekStartDate: data['week_start'] ?? weekStartStr,
            name: 'Kế hoạch tự động',
            description: 'Kế hoạch bữa ăn được tạo tự động',
            meals: meals,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return mealPlan;
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      print('Generate meal plan error: $e');
      throw Exception('Không thể tạo kế hoạch tự động: ${e.toString()}');
    }
  }

  Future<void> deleteMealPlan(String token, String planId) async {
    try {
      await _dio.delete(
        '/api/meal-plans/$planId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete meal plan: $e');
    }
  }

  Future<void> removeMealFromPlan(
    String token,
    String planId,
    String date,
    String mealSlot,
  ) async {
    try {
      await _dio.delete(
        '/api/meal-plans/$planId/meals/$date/$mealSlot',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      print('Remove meal from plan error: $e');
      throw Exception('Không thể xóa món ăn: ${e.toString()}');
    }
  }

  // Shopping Lists
  Future<List<ShoppingListModel>> getShoppingLists(String token) async {
    try {
      final response = await _dio.get(
        '/api/shopping/lists',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      print('Get shopping lists error: $e');
      throw Exception('Không thể tải danh sách mua sắm: ${e.toString()}');
    }
  }

  Future<ShoppingListModel> getShoppingListById(
    String token,
    String listId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/shopping/lists/$listId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Backend returns groups, need to flatten to items
          final List<dynamic> allItems = [];
          if (data['groups'] is List) {
            for (final group in data['groups']) {
              if (group['items'] is List) {
                allItems.addAll(group['items']);
              }
            }
          }

          // Transform to format expected by ShoppingListModel
          final transformedData = {
            'id': data['id'],
            'user_id':
                listId, // Not provided by backend, use listId as placeholder
            'name': data['title'] ?? 'Danh sách mua sắm',
            'description': null,
            'items': allItems
                .map(
                  (item) => {
                    'id': item['id']?.toString() ?? '',
                    'shopping_list_id': listId,
                    'ingredient_id': item['ingredient_id']?.toString() ?? '',
                    'ingredient_name':
                        item['ingredient_name']?.toString() ?? 'Nguyên liệu',
                    'quantity':
                        double.tryParse(item['quantity']?.toString() ?? '0') ??
                        0.0,
                    'unit': item['unit']?.toString() ?? 'g',
                    'is_checked': item['is_checked'] ?? false,
                    'notes': item['note']?.toString(),
                    'store_section_id': item['store_section']?.toString(),
                    'store_section_name': item['section_name']?.toString(),
                    'estimated_price':
                        double.tryParse(
                          item['price_per_unit']?.toString() ?? '0',
                        ) ??
                        0.0,
                    'priority': 0,
                  },
                )
                .toList(),
            'is_shared': data['is_shared'] ?? false,
            'shared_with': [],
            'created_at': data['created_at'],
            'updated_at': data['updated_at'],
          };

          return ShoppingListModel.fromJson(transformedData);
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch shopping list: $e');
    }
  }

  Future<String> createShoppingList(
    String token,
    CreateShoppingListDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/shopping/lists',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          // Backend returns {success, data: {id}}, return the list ID
          return responseData['data']['id'].toString();
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create shopping list: $e');
    }
  }

  Future<Map<String, dynamic>> generateShoppingListFromMealPlan(
    String token,
    String mealPlanId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/shopping/generate-from-meal-plan',
        data: {'meal_plan_id': mealPlanId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          // Backend returns {list_id, total_items, message}
          return responseData['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to generate shopping list: $e');
    }
  }

  Future<Map<String, dynamic>> addItemToShoppingList(
    String token,
    String listId,
    AddShoppingItemDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/shopping/lists/$listId/items',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          // Backend returns {success, data: {id}}, not shopping list
          return responseData['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to add item to shopping list: $e');
    }
  }

  Future<void> updateShoppingItem(
    String token,
    String listId,
    String itemId,
    UpdateShoppingItemDto dto,
  ) async {
    try {
      await _dio.put(
        '/api/shopping/lists/$listId/items/$itemId/check',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Backend returns {success, message} only, no data to return
    } catch (e) {
      throw Exception('Failed to update shopping item: $e');
    }
  }

  Future<void> deleteShoppingList(String token, String listId) async {
    try {
      await _dio.delete(
        '/api/shopping/lists/$listId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete shopping list: $e');
    }
  }

  Future<void> removeItemFromShoppingList(
    String token,
    String listId,
    String itemId,
  ) async {
    try {
      await _dio.delete(
        '/api/shopping/lists/$listId/items/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to remove item from shopping list: $e');
    }
  }

  Future<void> shareShoppingList(
    String token,
    String listId,
    String email,
  ) async {
    try {
      await _dio.post(
        '/api/shopping/lists/$listId/share',
        data: {'email': email},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to share shopping list: $e');
    }
  }

  // Pantry Management
  Future<List<PantryItemModel>> getPantryItems(
    String token, {
    String? location,
    bool? isExpired,
    bool? isLowStock,
    String? sortBy,
  }) async {
    try {
      final response = await _dio.get(
        '/api/pantry',
        queryParameters: {
          if (location != null) 'location': location,
          if (isExpired != null) 'is_expired': isExpired.toString(),
          if (isLowStock != null) 'is_low_stock': isLowStock.toString(),
          if (sortBy != null) 'sort_by': sortBy,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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

  Future<PantryStatsModel> getPantryStats(String token) async {
    try {
      final response = await _dio.get(
        '/api/pantry/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          return PantryStatsModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        return PantryStatsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to fetch pantry stats: $e');
    }
  }

  Future<PantryItemModel> addPantryItem(
    String token,
    AddPantryItemDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/api/pantry',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        return PantryItemModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to add pantry item: $e');
    }
  }

  Future<PantryItemModel> updatePantryItem(
    String token,
    String itemId,
    UpdatePantryItemDto dto,
  ) async {
    try {
      final response = await _dio.put(
        '/api/pantry/$itemId',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true &&
            responseData['data'] is Map<String, dynamic>) {
          return PantryItemModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        return PantryItemModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update pantry item: $e');
    }
  }

  Future<void> consumePantryItem(
    String token,
    String itemId,
    ConsumePantryItemDto dto,
  ) async {
    try {
      await _dio.post(
        '/api/pantry/$itemId/consume',
        data: dto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to consume pantry item: $e');
    }
  }

  Future<void> deletePantryItem(String token, String itemId) async {
    try {
      await _dio.delete(
        '/api/pantry/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to delete pantry item: $e');
    }
  }

  // ⚠️ ALLERGEN CHECK - Premium Family Feature
  Future<CheckAllergensResponse> checkRecipeAllergens(
    String token,
    String recipeId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/family/check-allergens',
        data: {'recipeId': recipeId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        return CheckAllergensResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Invalid API response format');
    } catch (e) {
      // If API fails, return no conflicts (fail-safe)
      return const CheckAllergensResponse(
        success: false,
        hasConflicts: false,
        conflicts: [],
        message: 'Failed to check allergens',
      );
    }
  }
}
