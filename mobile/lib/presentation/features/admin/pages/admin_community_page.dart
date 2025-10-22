import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';
import 'package:bepviet_mobile/data/sources/remote/admin_api_service.dart';
import 'package:bepviet_mobile/presentation/features/admin/cubit/admin_cubit.dart';
import 'package:bepviet_mobile/presentation/features/admin/widgets/admin_community_recipe_card.dart';

class AdminCommunityPage extends StatelessWidget {
  const AdminCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        final adminApiService = AdminApiService(dio);
        final adminRepository = AdminRepository(adminApiService);
        return AdminCubit(adminRepository)..loadCommunityRecipes();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loaded: (recipes, hasMore) {
                if (recipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Chưa có công thức nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AdminCubit>().loadCommunityRecipes(refresh: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: recipes.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == recipes.length) {
                        // Load more indicator
                        context.read<AdminCubit>().loadMoreRecipes();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final recipe = recipes[index];
                      return AdminCommunityRecipeCard(
                        recipe: recipe,
                        onPromote: () {
                          _showPromoteDialog(context, recipe);
                        },
                        onDelete: () {
                          _showDeleteDialog(context, recipe);
                        },
                      );
                    },
                  ),
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lỗi: $message',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AdminCubit>().loadCommunityRecipes(refresh: true);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPromoteDialog(BuildContext context, recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote Recipe'),
        content: Text('Bạn có chắc muốn promote công thức "${recipe.title}" thành công thức chính thức?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminCubit>().promoteRecipe(recipe.id);
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Bạn có chắc muốn xóa công thức "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminCubit>().deleteRecipe(recipe.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
