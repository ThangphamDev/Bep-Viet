import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService(this._dio, {String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.baseUrl {
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Recipes
  Future<List<RecipeModel>> getRecipes({
    String? mealType,
    int? maxTime,
    String? search,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {
          if (mealType != null) 'meal_type': mealType,
          if (maxTime != null) 'max_time': maxTime,
          if (search != null) 'search': search,
          if (limit != null) 'limit': limit,
        },
      );

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
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  Future<List<RecipeIngredientModel>> getRecipeIngredients(String id) async {
    try {
      final response = await _dio.get('/api/recipes/$id/ingredients');
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
        queryParameters: {'userId': userId, if (limit != null) 'limit': limit},
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
  }) async {
    try {
      final response = await _dio.get(
        '/api/ingredients',
        queryParameters: {
          if (search != null) 'search': search,
          if (category != null) 'category': category,
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
