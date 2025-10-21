import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/recipe_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        dio.options.baseUrl = AppConfig.ngrokBaseUrl;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        dio.options.headers['ngrok-skip-browser-warning'] = 'true';

        final apiService = ApiService(dio);
        final cubit = FavoritesCubit(apiService);
        cubit.loadFavorites();
        return cubit;
      },
      child: const FavoritesPageView(),
    );
  }
}

class FavoritesPageView extends StatefulWidget {
  const FavoritesPageView({super.key});

  @override
  State<FavoritesPageView> createState() => _FavoritesPageViewState();
}

class _FavoritesPageViewState extends State<FavoritesPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Yêu thích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FavoritesCubit>().loadFavorites(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.1),
                          AppTheme.primaryGreen.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chưa có công thức yêu thích',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy thêm các công thức bạn yêu thích\nđể xem lại dễ dàng hơn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/recipes'),
                    icon: const Icon(Icons.search),
                    label: const Text('Khám phá công thức'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async {
              context.read<FavoritesCubit>().loadFavorites();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final recipe = state.favorites[index];
                return _buildRecipeCard(context, recipe);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, RecipeModel recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/recipes/${recipe.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen.withOpacity(0.1),
                                  AppTheme.primaryGreen.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 60,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen.withOpacity(0.1),
                                AppTheme.primaryGreen.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 60,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      context.read<FavoritesCubit>().removeFavorite(recipe.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã xóa "${recipe.name}" khỏi yêu thích',
                          ),
                          backgroundColor: AppTheme.errorColor,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.cookTimeMinutes ?? 0} phút',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.restaurant,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.difficulty ?? 1}/5',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cubit
class FavoritesCubit extends Cubit<FavoritesState> {
  final ApiService _apiService;

  FavoritesCubit(this._apiService) : super(FavoritesState.initial());

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xem yêu thích');
      }

      final favorites = await _apiService.getFavorites(token);

      emit(state.copyWith(isLoading: false, favorites: favorites, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      if (token == null) return;

      await _apiService.removeFavorite(token, recipeId);

      // Remove from local state
      final updatedFavorites = state.favorites
          .where((recipe) => recipe.id != recipeId)
          .toList();

      emit(state.copyWith(favorites: updatedFavorites));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

// State
class FavoritesState {
  final bool isLoading;
  final List<RecipeModel> favorites;
  final String? error;

  FavoritesState({
    required this.isLoading,
    required this.favorites,
    this.error,
  });

  factory FavoritesState.initial() {
    return FavoritesState(isLoading: false, favorites: []);
  }

  FavoritesState copyWith({
    bool? isLoading,
    List<RecipeModel>? favorites,
    String? error,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      error: error,
    );
  }
}
