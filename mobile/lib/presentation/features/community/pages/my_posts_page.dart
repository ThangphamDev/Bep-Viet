import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/sources/remote/community_service.dart';
import 'package:bepviet_mobile/data/sources/remote/community_api_service.dart';
import '../cubit/community_cubit.dart';
import '../widgets/community_feed_card_new.dart';
import '../widgets/delete_recipe_dialog.dart';
import 'community_detail_page.dart';
import 'create_recipe_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  CommunityCubit? _communityCubit;

  @override
  void initState() {
    super.initState();
    _initializeCubit();
  }

  Future<void> _initializeCubit() async {
    final dio = Dio();

    // Add authentication token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    final communityApiService = CommunityApiService(dio);
    final communityService = CommunityService(communityApiService);

    setState(() {
      _communityCubit = CommunityCubit(communityService);
    });

    _loadMyRecipes();
  }

  void _loadMyRecipes() {
    if (_communityCubit == null) return;
    _communityCubit!.loadMyRecipes();
  }

  @override
  void dispose() {
    _communityCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_communityCubit == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: BlocProvider.value(
                value: _communityCubit!,
                child: BlocBuilder<CommunityCubit, CommunityState>(
                  builder: (context, state) {
                    if (state is CommunityInitial) {
                      return const _MyEmptyState();
                    } else if (state is CommunityLoading) {
                      return const _MyLoadingState();
                    } else if (state is CommunityLoaded) {
                      return _MyFeedView(
                        recipes: state.recipes,
                        hasReachedMax: state.hasReachedMax,
                        onLoadMore: _loadMyRecipes,
                        onRecipeTap: (recipe) => _navigateToDetail(recipe),
                        onEditRecipe: (recipe) => _navigateToEdit(recipe),
                        onDeleteRecipe: (recipe) => _showDeleteDialog(recipe),
                      );
                    } else if (state is CommunityError) {
                      return _MyErrorState(
                        message: state.message,
                        onRetry: _loadMyRecipes,
                      );
                    }
                    return const _MyEmptyState();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 20, top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 24, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          const Text(
            'Bài viết của tôi',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 26, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _navigateToCreateRecipe(),
      backgroundColor: AppTheme.textPrimary,
      elevation: 2,
      child: const Icon(Icons.edit_outlined, color: Colors.white, size: 26),
    );
  }

  void _navigateToDetail(CommunityRecipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailPage(recipe: recipe),
      ),
    );
  }

  void _navigateToCreateRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRecipePage()),
    ).then((_) => _loadMyRecipes());
  }

  void _navigateToEdit(CommunityRecipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecipePage(editingRecipe: recipe),
      ),
    ).then((_) => _loadMyRecipes());
  }

  void _showDeleteDialog(CommunityRecipe recipe) {
    DeleteRecipeDialog.show(
      context: context,
      recipeTitle: recipe.title,
      onConfirm: () => _deleteRecipe(recipe.id),
    );
  }

  void _deleteRecipe(String recipeId) {
    if (_communityCubit != null) {
      _communityCubit!.deleteRecipe(recipeId);
    }
  }
}

class _MyFeedView extends StatelessWidget {
  final List<CommunityRecipe> recipes;
  final bool hasReachedMax;
  final VoidCallback onLoadMore;
  final Function(CommunityRecipe) onRecipeTap;
  final Function(CommunityRecipe) onEditRecipe;
  final Function(CommunityRecipe) onDeleteRecipe;

  const _MyFeedView({
    required this.recipes,
    required this.hasReachedMax,
    required this.onLoadMore,
    required this.onRecipeTap,
    required this.onEditRecipe,
    required this.onDeleteRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onLoadMore();
      },
      child: CustomScrollView(
        slivers: [
          if (recipes.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Không có bài viết nào')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < recipes.length) {
                    return CommunityFeedCardNew(
                          recipe: recipes[index],
                          onTap: () => onRecipeTap(recipes[index]),
                          onEdit: () => onEditRecipe(recipes[index]),
                          onDelete: () => onDeleteRecipe(recipes[index]),
                          showEditOptions: true,
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 300.ms,
                          delay: (index * 50).ms,
                        );
                  } else if (!hasReachedMax) {
                    onLoadMore();
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return null;
                },
                childCount: hasReachedMax ? recipes.length : recipes.length + 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _MyEmptyState extends StatelessWidget {
  const _MyEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Không có bài viết nào'),
    );
  }
}

class _MyLoadingState extends StatelessWidget {
  const _MyLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _MyErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MyErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
