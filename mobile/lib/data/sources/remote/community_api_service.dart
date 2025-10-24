import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class CommunityApiService {
  final Dio _dio;

  CommunityApiService(this._dio) {
    _dio.options.baseUrl = AppConfig.ngrokBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add ngrok-skip-browser-warning header
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  Future<Map<String, dynamic>> getAllCommunityRecipes(Map<String, dynamic> filters) async {
    final response = await _dio.get('/api/community/recipes', queryParameters: filters);
    return response.data;
  }

  Future<Map<String, dynamic>> getFeaturedRecipes({int? limit}) async {
    final response = await _dio.get('/api/community/recipes/featured', queryParameters: {
      if (limit != null) 'limit': limit,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getCommunityRecipeById(String id) async {
    final response = await _dio.get('/api/community/recipes/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createCommunityRecipe(Map<String, dynamic> request) async {
    final response = await _dio.post('/api/community/recipes', data: request);
    return response.data;
  }

  Future<Map<String, dynamic>> addComment(String recipeId, Map<String, dynamic> request) async {
    final response = await _dio.post('/api/community/recipes/$recipeId/comments', data: request);
    return response.data;
  }

  Future<Map<String, dynamic>> addRating(String recipeId, Map<String, dynamic> request) async {
    final response = await _dio.post('/api/community/recipes/$recipeId/ratings', data: request);
    return response.data;
  }

  Future<Map<String, dynamic>> getUserCommunityRecipes() async {
    final response = await _dio.get('/api/community/my-recipes');
    return response.data;
  }

  Future<Map<String, dynamic>> getPendingRecipes() async {
    final response = await _dio.get('/api/community/moderation/pending');
    return response.data;
  }

  Future<Map<String, dynamic>> moderateRecipe(String recipeId, Map<String, dynamic> request) async {
    final response = await _dio.put('/api/community/moderation/$recipeId', data: request);
    return response.data;
  }

  Future<Map<String, dynamic>> updateCommunityRecipe(String recipeId, Map<String, dynamic> request) async {
    final response = await _dio.put('/api/community/recipes/$recipeId', data: request);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteCommunityRecipe(String recipeId) async {
    final response = await _dio.delete('/api/community/recipes/$recipeId');
    return response.data;
  }

  Future<Map<String, dynamic>> uploadImage(List<int> imageBytes, String mimeType) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: 'image.${mimeType.split('/').last}',
      ),
    });
    
    final response = await _dio.post('/api/community/upload-image', data: formData);
    return response.data;
  }
}
