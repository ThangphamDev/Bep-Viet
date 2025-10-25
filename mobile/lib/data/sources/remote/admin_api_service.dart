import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio) {
    _dio.options.baseUrl = AppConfig.ngrokBaseUrl;
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get all community recipes for admin
  Future<Map<String, dynamic>> getAllCommunityRecipesForAdmin({
    int limit = 50,
    int offset = 0,
  }) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/community/recipes',
      queryParameters: {'limit': limit, 'offset': offset},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Get pending recipes (if needed)
  Future<Map<String, dynamic>> getPendingRecipes() async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/community/moderation/pending',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Promote community recipe to official recipe
  Future<Map<String, dynamic>> promoteRecipe(String recipeId) async {
    final token = await _getToken();
    final response = await _dio.post(
      '/api/community/recipes/$recipeId/promote-to-official',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Delete community recipe
  Future<Map<String, dynamic>> deleteCommunityRecipe(String recipeId) async {
    final token = await _getToken();
    final response = await _dio.delete(
      '/api/community/recipes/$recipeId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Get all official recipes for admin
  Future<Map<String, dynamic>> getAllOfficialRecipes({
    int limit = 20,
    int offset = 0,
    String? region,
    String? search,
  }) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/recipes',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (region != null) 'region': region,
        if (search != null) 'search': search,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Get official recipe by ID
  Future<Map<String, dynamic>> getOfficialRecipeById(String recipeId) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/recipes/$recipeId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Get community recipe by ID
  Future<Map<String, dynamic>> getCommunityRecipeById(String recipeId) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/api/community/recipes/$recipeId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }

  // Delete official recipe
  Future<Map<String, dynamic>> deleteOfficialRecipe(String recipeId) async {
    final token = await _getToken();
    final response = await _dio.delete(
      '/api/recipes/$recipeId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data;
  }
}
