import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/community_recipe.dart';
import '../../../../data/sources/remote/community_service.dart';

abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<CommunityRecipe> recipes;
  final bool hasReachedMax;

  CommunityLoaded({
    required this.recipes,
    this.hasReachedMax = false,
  });
}

class CommunityError extends CommunityState {
  final String message;

  CommunityError(this.message);
}

abstract class CommunityDetailState {}

class CommunityDetailInitial extends CommunityDetailState {}

class CommunityDetailLoading extends CommunityDetailState {}

class CommunityDetailLoaded extends CommunityDetailState {
  final CommunityRecipe recipe;

  CommunityDetailLoaded(this.recipe);
}

class CommunityDetailError extends CommunityDetailState {
  final String message;

  CommunityDetailError(this.message);
}

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityService _communityService;

  CommunityCubit(this._communityService) : super(CommunityInitial());

  List<CommunityRecipe> _allRecipes = [];
  int _currentPage = 1;
  static const int _pageSize = 20;
  CommunityFilters? _currentFilters;

  Future<void> loadRecipes({
    String? region,
    String? difficulty,
    int? maxTime,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _allRecipes.clear();
      _currentPage = 1;
      emit(CommunityLoading());
    } else if (state is CommunityLoaded) {
      emit(CommunityLoaded(recipes: _allRecipes, hasReachedMax: false));
    } else {
      emit(CommunityLoading());
    }

    try {
      _currentFilters = CommunityFilters(
        region: region,
        difficulty: difficulty,
        maxTime: maxTime,
        search: search,
        limit: _pageSize,
      );

      final recipes = await _communityService.getAllCommunityRecipes(
        region: region,
        difficulty: difficulty,
        maxTime: maxTime,
        search: search,
        limit: _pageSize,
      );

      if (refresh) {
        _allRecipes = recipes;
      } else {
        _allRecipes.addAll(recipes);
      }

      final hasReachedMax = recipes.length < _pageSize;

      emit(
        CommunityLoaded(
          recipes: List.from(_allRecipes),
          hasReachedMax: hasReachedMax,
        ),
      );

      _currentPage++;
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> loadMoreRecipes() async {
    if (state is! CommunityLoaded) return;

    final currentState = state as CommunityLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final recipes = await _communityService.getAllCommunityRecipes(
        region: _currentFilters?.region,
        difficulty: _currentFilters?.difficulty,
        maxTime: _currentFilters?.maxTime,
        search: _currentFilters?.search,
        limit: _pageSize,
      );

      _allRecipes.addAll(recipes);
      final hasReachedMax = recipes.length < _pageSize;

      emit(
        CommunityLoaded(
          recipes: List.from(_allRecipes),
          hasReachedMax: hasReachedMax,
        ),
      );

      _currentPage++;
    } catch (e) {
      // Don't emit error for load more, just keep current state
    }
  }

  Future<void> loadFeaturedRecipes() async {
      emit(CommunityLoading());

    try {
      final recipes = await _communityService.getFeaturedRecipes(limit: 10);
      _allRecipes = recipes;

      emit(
        CommunityLoaded(
          recipes: List.from(_allRecipes),
          hasReachedMax: true,
        ),
      );
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> loadMyRecipes() async {
      emit(CommunityLoading());

    try {
      final recipes = await _communityService.getUserCommunityRecipes();
      _allRecipes = recipes;

      emit(
        CommunityLoaded(
          recipes: List.from(_allRecipes),
          hasReachedMax: true,
        ),
      );
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> refreshRecipes() async {
    await loadRecipes(
      region: _currentFilters?.region,
      difficulty: _currentFilters?.difficulty,
      maxTime: _currentFilters?.maxTime,
      search: _currentFilters?.search,
      refresh: true,
    );
  }

  Future<void> updateRecipe(String recipeId, CreateCommunityRecipeRequest request) async {
    try {
      await _communityService.updateCommunityRecipe(recipeId, request);
      // Refresh the recipes list to show updated data
      await refreshRecipes();
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _communityService.deleteCommunityRecipe(recipeId);
      // Remove the recipe from the current list
      _allRecipes.removeWhere((recipe) => recipe.id == recipeId);
      emit(
        CommunityLoaded(
          recipes: List.from(_allRecipes),
          hasReachedMax: _allRecipes.length < _pageSize,
        ),
      );
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }
}

class CommunityDetailCubit extends Cubit<CommunityDetailState> {
  final CommunityService _communityService;

  CommunityDetailCubit(this._communityService)
    : super(CommunityDetailInitial());

  Future<void> loadRecipe(String recipeId) async {
    emit(CommunityDetailLoading());

    try {
      final recipe = await _communityService.getCommunityRecipeById(recipeId);
      emit(CommunityDetailLoaded(recipe));
    } catch (e) {
      emit(CommunityDetailError(e.toString()));
    }
  }

  Future<void> addComment(String recipeId, String content) async {
    try {
      await _communityService.addComment(recipeId, content);
      // Reload recipe to get updated comments
      await loadRecipe(recipeId);
    } catch (e) {
      emit(CommunityDetailError(e.toString()));
    }
  }

  Future<void> addRating(String recipeId, int stars) async {
    try {
      await _communityService.addRating(recipeId, stars);
      // Reload recipe to get updated ratings
      await loadRecipe(recipeId);
    } catch (e) {
      emit(CommunityDetailError(e.toString()));
    }
  }
}
