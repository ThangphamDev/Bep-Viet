import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';

part 'admin_cubit.freezed.dart';

@freezed
class AdminState with _$AdminState {
  const factory AdminState.initial() = _Initial;
  const factory AdminState.loading() = _Loading;
  const factory AdminState.loaded({
    required List<dynamic> recipes, // Changed to dynamic to handle both types
    @Default(false) bool hasMore,
  }) = _Loaded;
  const factory AdminState.error(String message) = _Error;
}

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _adminRepository;

  AdminCubit(this._adminRepository) : super(const AdminState.initial());

  Future<void> loadCommunityRecipes({bool refresh = false}) async {
    if (refresh) {
      emit(const AdminState.loading());
    } else if (state is _Loaded) {
      // Don't show loading if we're loading more
    } else {
      emit(const AdminState.loading());
    }

    try {
      final recipes = await _adminRepository.getAllCommunityRecipesForAdmin();
      emit(
        AdminState.loaded(
          recipes: recipes,
          hasMore: recipes.length >= 50, // Assuming 50 is the limit
        ),
      );
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<void> loadMoreRecipes() async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.hasMore) return;

    try {
      final currentRecipes = currentState.recipes;
      final moreRecipes = await _adminRepository.getAllCommunityRecipesForAdmin(
        offset: currentRecipes.length,
      );

      if (moreRecipes.isEmpty) {
        emit(currentState.copyWith(hasMore: false));
      } else {
        emit(
          currentState.copyWith(
            recipes: [...currentRecipes, ...moreRecipes],
            hasMore: moreRecipes.length >= 50,
          ),
        );
      }
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<bool> promoteRecipe(String recipeId) async {
    try {
      final success = await _adminRepository.promoteRecipe(recipeId);
      if (success) {
        // Reload recipes to reflect changes
        await loadCommunityRecipes(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      emit(AdminState.error('Failed to promote recipe: $e'));
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      final success = await _adminRepository.deleteCommunityRecipe(recipeId);
      if (success) {
        // Remove recipe from current list
        final currentState = state;
        if (currentState is _Loaded) {
          final updatedRecipes = currentState.recipes
              .where((recipe) => recipe.id != recipeId)
              .toList();
          emit(currentState.copyWith(recipes: updatedRecipes));
        }
        return true;
      }
      return false;
    } catch (e) {
      emit(AdminState.error('Failed to delete recipe: $e'));
      return false;
    }
  }

  // Official Recipes Methods
  Future<void> loadOfficialRecipes({
    bool refresh = false,
    String? search,
    String? region,
  }) async {
    if (refresh) {
      emit(const AdminState.loading());
    } else if (state is _Loaded) {
      // Don't show loading if we're loading more
    } else {
      emit(const AdminState.loading());
    }

    try {
      final recipes = await _adminRepository.getAllOfficialRecipes(
        search: search,
        region: region,
      );
      emit(
        AdminState.loaded(
          recipes: recipes,
          hasMore: recipes.length >= 50, // Assuming 50 is the limit
        ),
      );
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<void> loadMoreOfficialRecipes({String? search, String? region}) async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.hasMore) return;

    try {
      final currentRecipes = currentState.recipes;
      final moreRecipes = await _adminRepository.getAllOfficialRecipes(
        offset: currentRecipes.length,
        search: search,
        region: region,
      );

      if (moreRecipes.isEmpty) {
        emit(currentState.copyWith(hasMore: false));
      } else {
        emit(
          currentState.copyWith(
            recipes: [...currentRecipes, ...moreRecipes],
            hasMore: moreRecipes.length >= 50,
          ),
        );
      }
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<void> deleteOfficialRecipe(String recipeId) async {
    final success = await _adminRepository.deleteOfficialRecipe(recipeId);
    if (success) {
      // Remove recipe from current list
      final currentState = state;
      if (currentState is _Loaded) {
        final updatedRecipes = currentState.recipes
            .where((recipe) => recipe.id != recipeId)
            .toList();
        emit(currentState.copyWith(recipes: updatedRecipes));
      }
    } else {
      throw Exception('Failed to delete recipe');
    }
  }

  // ============ USER MANAGEMENT METHODS ============

  Future<void> loadUsers({
    bool refresh = false,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    if (refresh) {
      emit(const AdminState.loading());
    } else if (state is _Loaded) {
      // Don't show loading if we're loading more
    } else {
      emit(const AdminState.loading());
    }

    try {
      final users = await _adminRepository.getAllUsers(
        search: search,
        role: role,
        isActive: isActive,
      );
      emit(
        AdminState.loaded(
          recipes: users, // Using 'recipes' field for users too
          hasMore: users.length >= 50,
        ),
      );
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<void> loadMoreUsers({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.hasMore) return;

    try {
      final currentUsers = currentState.recipes; // 'recipes' holds users
      final moreUsers = await _adminRepository.getAllUsers(
        offset: currentUsers.length,
        search: search,
        role: role,
        isActive: isActive,
      );

      if (moreUsers.isEmpty) {
        emit(currentState.copyWith(hasMore: false));
      } else {
        emit(
          currentState.copyWith(
            recipes: [...currentUsers, ...moreUsers],
            hasMore: moreUsers.length >= 50,
          ),
        );
      }
    } catch (e) {
      emit(AdminState.error(e.toString()));
    }
  }

  Future<void> blockUser(String userId) async {
    final success = await _adminRepository.blockUser(userId);
    if (success) {
      // Update user in current list
      final currentState = state;
      if (currentState is _Loaded) {
        final updatedUsers = currentState.recipes.map((user) {
          if (user.id == userId) {
            // Assuming user has a copyWith or similar
            return (user as dynamic).copyWith
                ? (user as dynamic).copyWith(isActive: false)
                : user;
          }
          return user;
        }).toList();
        emit(currentState.copyWith(recipes: updatedUsers));
      }
    } else {
      throw Exception('Failed to block user');
    }
  }

  Future<void> unblockUser(String userId) async {
    final success = await _adminRepository.unblockUser(userId);
    if (success) {
      // Update user in current list
      final currentState = state;
      if (currentState is _Loaded) {
        final updatedUsers = currentState.recipes.map((user) {
          if (user.id == userId) {
            return (user as dynamic).copyWith
                ? (user as dynamic).copyWith(isActive: true)
                : user;
          }
          return user;
        }).toList();
        emit(currentState.copyWith(recipes: updatedUsers));
      }
    } else {
      throw Exception('Failed to unblock user');
    }
  }
}
