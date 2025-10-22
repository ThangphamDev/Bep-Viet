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
import 'community_detail_page.dart';
import 'create_recipe_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  CommunityCubit? _communityCubit;
  late TabController _tabController;

  bool _showMyRecipes = false;
  String? _selectedRegion;
  String? _selectedDifficulty;
  int? _maxTime;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    // Load recipes after cubit is initialized
    _loadRecipes();
  }

  void _loadRecipes({bool refresh = true}) {
    if (_communityCubit == null) return;
    
    if (refresh) {
      _communityCubit!.loadRecipes(
        region: _selectedRegion,
        difficulty: _selectedDifficulty,
        maxTime: _maxTime,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        refresh: refresh,
      );
    } else {
      _communityCubit!.loadMoreRecipes();
    }
  }

  void _loadMyRecipes() {
    if (_communityCubit == null) return;
    _communityCubit!.loadMyRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildTabBar(),
            // Search and filters removed for cleaner UI like Threads
            Expanded(
              child: BlocProvider.value(
                value: _communityCubit!,
                child: BlocBuilder<CommunityCubit, CommunityState>(
                  builder: (context, state) {
                    if (state is CommunityInitial) {
                      return _EmptyState(showMyRecipes: _showMyRecipes);
                    } else if (state is CommunityLoading) {
                      return const _LoadingState();
                    } else if (state is CommunityLoaded) {
                      return _FeedView(
                        recipes: state.recipes,
                        hasReachedMax: state.hasReachedMax,
                        showMyRecipes: _showMyRecipes,
                        onLoadMore: () => _loadRecipes(refresh: false),
                        onRecipeTap: (recipe) => _navigateToDetail(recipe),
                        onEditRecipe: _showMyRecipes ? (recipe) => _navigateToEdit(recipe) : null,
                        onDeleteRecipe: _showMyRecipes ? (recipe) => _showDeleteDialog(recipe) : null,
                      );
                    } else if (state is CommunityError) {
                      return _ErrorState(
                        message: state.message,
                        onRetry: () => _loadRecipes(),
                      );
                    }
                    return _EmptyState(showMyRecipes: _showMyRecipes);
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/Title with modern design
          const Text(
            'Cộng đồng',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const Spacer(),

          // Action buttons - threads style
          _buildIconButton(
            icon: Icons.notifications_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _buildIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 26, color: AppTheme.textPrimary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 24,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _showMyRecipes = index == 1;
          });
          if (_showMyRecipes) {
            _loadMyRecipes();
          } else {
            _loadRecipes();
          }
        },
        indicatorColor: AppTheme.textPrimary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Dành cho bạn'),
          Tab(text: 'Bài viết của tôi'),
        ],
      ),
    );
  }

  // Search and filter UI removed to streamline the experience like modern social feeds.

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
    );
  }

  void _navigateToEdit(CommunityRecipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecipePage(editingRecipe: recipe),
      ),
    ).then((_) {
      // Refresh the recipes list after editing
      if (_showMyRecipes) {
        _loadMyRecipes();
      } else {
        _loadRecipes();
      }
    });
  }

  void _showDeleteDialog(CommunityRecipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Xóa bài viết',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa bài viết này không?',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${recipe.title}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hành động này không thể hoàn tác.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecipe(recipe.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(String recipeId) {
    if (_communityCubit != null) {
      _communityCubit!.deleteRecipe(recipeId);
    }
  }


  // Legacy search dialog removed (unused)

  // Legacy filter bottom sheet removed (unused)

  // Legacy more options sheet removed (unused)
}

class _FeedView extends StatelessWidget {
  final List<CommunityRecipe> recipes;
  final bool hasReachedMax;
  final bool showMyRecipes;
  final VoidCallback onLoadMore;
  final Function(CommunityRecipe) onRecipeTap;
  final Function(CommunityRecipe)? onEditRecipe;
  final Function(CommunityRecipe)? onDeleteRecipe;

  const _FeedView({
    required this.recipes,
    required this.hasReachedMax,
    required this.showMyRecipes,
    required this.onLoadMore,
    required this.onRecipeTap,
    this.onEditRecipe,
    this.onDeleteRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onLoadMore();
      },
      child: CustomScrollView(
        slivers: [
          // Feed content
          if (recipes.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(showMyRecipes: showMyRecipes),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < recipes.length) {
                    return CommunityFeedCardNew(
                          recipe: recipes[index],
                          onTap: () => onRecipeTap(recipes[index]),
                          onEdit: showMyRecipes ? () => onEditRecipe?.call(recipes[index]) : null,
                          onDelete: showMyRecipes ? () => onDeleteRecipe?.call(recipes[index]) : null,
                          showEditOptions: showMyRecipes,
                          onLike: _handleLike,
                          onComment: _handleComment,
                          onShare: _handleShare,
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

  void _handleLike(String recipeId) {
    // Handle like functionality
    print('Liked recipe: $recipeId');
    // You can implement API call to like/unlike recipe here
  }

  void _handleComment(String recipeId, String comment) {
    // Handle comment functionality
    print('Comment on recipe $recipeId: $comment');
    // You can implement API call to add comment here
  }

  void _handleShare(String recipeId) {
    // Handle share functionality
    print('Shared recipe: $recipeId');
    // Share functionality is already handled in the widget
  }
}

class _EmptyState extends StatelessWidget {
  final bool showMyRecipes;

  const _EmptyState({this.showMyRecipes = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 60,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            showMyRecipes ? 'Chưa có bài viết nào' : 'Chưa có công thức nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showMyRecipes
                ? 'Hãy tạo công thức đầu tiên của bạn!'
                : 'Hãy là người đầu tiên chia sẻ\ncông thức nấu ăn của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang tải...',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
