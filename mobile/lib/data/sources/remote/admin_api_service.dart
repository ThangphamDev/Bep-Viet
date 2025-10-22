import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio) {
    _dio.options.baseUrl = AppConfig.ngrokBaseUrl;
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  // Get all community recipes for admin
  Future<Map<String, dynamic>> getAllCommunityRecipesForAdmin({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/api/community/recipes',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    return response.data;
  }

  // Get pending recipes (if needed)
  Future<Map<String, dynamic>> getPendingRecipes() async {
    final response = await _dio.get('/api/community/recipes/pending');
    return response.data;
  }

  // Promote community recipe to official recipe
  Future<Map<String, dynamic>> promoteRecipe(String recipeId) async {
    final response = await _dio.post('/api/community/recipes/$recipeId/promote');
    return response.data;
  }

  // Delete community recipe
  Future<Map<String, dynamic>> deleteCommunityRecipe(String recipeId) async {
    final response = await _dio.delete('/api/community/recipes/$recipeId');
    return response.data;
  }

  // Get all official recipes for admin
  Future<Map<String, dynamic>> getAllOfficialRecipes({
    int limit = 50,
    int offset = 0,
    String? region,
    String? search,
  }) async {
    final response = await _dio.get(
      '/api/recipes',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (region != null) 'region': region,
        if (search != null) 'search': search,
      },
    );
    return response.data;
  }

  // Get official recipe by ID
  Future<Map<String, dynamic>> getOfficialRecipeById(String recipeId) async {
    final response = await _dio.get('/api/recipes/$recipeId');
    return response.data;
  }

  // Delete official recipe
  Future<Map<String, dynamic>> deleteOfficialRecipe(String recipeId) async {
    final response = await _dio.delete('/api/recipes/$recipeId');
    return response.data;
  }
}
