import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
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
        throw Exception(
          'Server error: Không thể xóa công thức. Vui lòng kiểm tra quyền admin hoặc thử lại sau.',
        );
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
        return recipesJson.map((json) => RecipeModel.fromJson(json)).toList();
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

  // Get community recipe by ID
  Future<CommunityRecipe> getCommunityRecipeById(String recipeId) async {
    try {
      final response = await _apiService.getCommunityRecipeById(recipeId);
      return CommunityRecipe.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load community recipe details: $e');
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

  // ============ USER MANAGEMENT ============

  // Get all users
  Future<List<UserModel>> getAllUsers({
    int limit = 50,
    int offset = 0,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.getAllUsers(
        limit: limit,
        offset: offset,
        search: search,
        role: role,
        isActive: isActive,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersJson = response['data'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _apiService.getUserById(userId);
      return UserModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  // Get user recipes
  Future<List<CommunityRecipe>> getUserRecipes(String userId) async {
    try {
      final response = await _apiService.getUserRecipes(userId);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> recipesJson = response['data'];
        return recipesJson
            .map((json) => CommunityRecipe.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load user recipes: $e');
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    try {
      final response = await _apiService.blockUser(userId);
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    try {
      final response = await _apiService.unblockUser(userId);
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }
}
