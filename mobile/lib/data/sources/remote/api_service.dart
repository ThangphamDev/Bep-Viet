import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
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
}
