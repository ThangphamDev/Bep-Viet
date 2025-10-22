import 'package:dio/dio.dart';
import 'community_api_service.dart';
import '../../models/community_recipe.dart';

class CommunityService {
  final CommunityApiService _apiService;

  CommunityService(this._apiService);

  Future<List<CommunityRecipe>> getAllCommunityRecipes({
    String? region,
    String? difficulty,
    int? maxTime,
    String? search,
    int? limit,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (region != null) filters['region'] = region;
      if (difficulty != null) filters['difficulty'] = difficulty;
      if (maxTime != null) filters['max_time'] = maxTime;
      if (search != null) filters['search'] = search;
      if (limit != null) filters['limit'] = limit;

      final response = await _apiService.getAllCommunityRecipes(filters);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CommunityRecipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch community recipes: $e');
    }
  }

  Future<List<CommunityRecipe>> getFeaturedRecipes({int limit = 10}) async {
    try {
      final response = await _apiService.getFeaturedRecipes(limit: limit);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CommunityRecipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch featured recipes: $e');
    }
  }

  Future<CommunityRecipe> getCommunityRecipeById(String id) async {
    try {
      final response = await _apiService.getCommunityRecipeById(id);
      return CommunityRecipe.fromJson(response['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch recipe details: $e');
    }
  }

  Future<String> createCommunityRecipe(CreateCommunityRecipeRequest request) async {
    try {
      final response = await _apiService.createCommunityRecipe(request.toJson());
      return response['data']['id'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to create community recipe: $e');
    }
  }

  Future<void> addComment(String recipeId, String content) async {
    try {
      await _apiService.addComment(recipeId, {'content': content});
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> addRating(String recipeId, int stars) async {
    try {
      await _apiService.addRating(recipeId, {'stars': stars});
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to add rating: $e');
    }
  }

  Future<List<CommunityRecipe>> getUserCommunityRecipes() async {
    try {
      final response = await _apiService.getUserCommunityRecipes();
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CommunityRecipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch user recipes: $e');
    }
  }

  Future<List<CommunityRecipe>> getPendingRecipes() async {
    try {
      final response = await _apiService.getPendingRecipes();
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CommunityRecipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch pending recipes: $e');
    }
  }

  Future<void> moderateRecipe(String recipeId, String action, {String? note}) async {
    try {
      await _apiService.moderateRecipe(recipeId, {
        'action': action,
        'note': note,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to moderate recipe: $e');
    }
  }

  Future<void> updateCommunityRecipe(String recipeId, CreateCommunityRecipeRequest request) async {
    try {
      await _apiService.updateCommunityRecipe(recipeId, request.toJson());
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to update community recipe: $e');
    }
  }

  Future<void> deleteCommunityRecipe(String recipeId) async {
    try {
      await _apiService.deleteCommunityRecipe(recipeId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to delete community recipe: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
