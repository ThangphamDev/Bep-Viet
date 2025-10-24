import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/admin_api_service.dart';

class AdminRepository {
  final AdminApiService _apiService;

  AdminRepository(this._apiService);

  // Get all community recipes for admin
  Future<List<CommunityRecipe>> getAllCommunityRecipesForAdmin({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.getAllCommunityRecipesForAdmin(
        limit: limit,
        offset: offset,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> recipesJson = response['data'];
        return recipesJson
            .map((json) => CommunityRecipe.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load community recipes: $e');
    }
  }

  // Get pending recipes
  Future<List<CommunityRecipe>> getPendingRecipes() async {
    try {
      final response = await _apiService.getPendingRecipes();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> recipesJson = response['data'];
        return recipesJson
            .map((json) => CommunityRecipe.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load pending recipes: $e');
    }
  }

  // Promote recipe to official
  Future<bool> promoteRecipe(String recipeId) async {
    try {
      final response = await _apiService.promoteRecipe(recipeId);
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to promote recipe: $e');
    }
  }

  // Delete community recipe
  Future<bool> deleteCommunityRecipe(String recipeId) async {
    try {
      final response = await _apiService.deleteCommunityRecipe(recipeId);
      return response['success'] == true;
    } catch (e) {
      print('Delete community recipe error: $e');
      // Re-throw với message rõ ràng hơn
      if (e.toString().contains('500')) {
        throw Exception('Server error: Không thể xóa công thức. Vui lòng kiểm tra quyền admin hoặc thử lại sau.');
      }
      throw Exception('Failed to delete recipe: ${e.toString()}');
    }
  }

  // Get all official recipes for admin
  Future<List<RecipeModel>> getAllOfficialRecipes({
    int limit = 50,
    int offset = 0,
    String? region,
    String? search,
  }) async {
    try {
      final response = await _apiService.getAllOfficialRecipes(
        limit: limit,
        offset: offset,
        region: region,
        search: search,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> recipesJson = response['data'];
        return recipesJson
            .map((json) => RecipeModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load official recipes: $e');
    }
  }

  // Get official recipe by ID
  Future<RecipeModel> getOfficialRecipeById(String recipeId) async {
    try {
      final response = await _apiService.getOfficialRecipeById(recipeId);
      return RecipeModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load recipe details: $e');
    }
  }

  // Delete official recipe
  Future<bool> deleteOfficialRecipe(String recipeId) async {
    try {
      final response = await _apiService.deleteOfficialRecipe(recipeId);
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete official recipe: $e');
    }
  }
}
