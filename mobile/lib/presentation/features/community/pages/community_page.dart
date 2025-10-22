import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/sources/remote/community_service.dart';
import 'package:bepviet_mobile/data/sources/remote/community_api_service.dart';
import '../cubit/community_cubit.dart';
import '../widgets/community_filters_bottom_sheet.dart';
import '../widgets/community_feed_card.dart';
import 'community_detail_page.dart';
import 'create_recipe_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  late CommunityCubit _communityCubit;
  late TabController _tabController;
  
  bool _showFeatured = false;
  String? _selectedRegion;
  String? _selectedDifficulty;
  int? _maxTime;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCubit();
    _loadRecipes();
  }

  void _initializeCubit() {
    final dio = Dio();
    final communityApiService = CommunityApiService(dio);
    final communityService = CommunityService(communityApiService);
    _communityCubit = CommunityCubit(communityService);
  }

  void _loadRecipes({bool refresh = true}) {
    if (refresh) {
      _communityCubit.loadRecipes(
        region: _selectedRegion,
        difficulty: _selectedDifficulty,
        maxTime: _maxTime,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        refresh: refresh,
      );
    } else {
      _communityCubit.loadMoreRecipes();
    }
  }

  void _loadFeaturedRecipes() {
    _communityCubit.loadFeaturedRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _communityCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            if (!_showFeatured) _buildSearchAndFilters(),
            Expanded(
              child: BlocProvider.value(
                value: _communityCubit,
                child: BlocBuilder<CommunityCubit, CommunityState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const _EmptyState(),
                      loading: () => const _LoadingState(),
                      loaded: (recipes, hasReachedMax) => _FeedView(
                        recipes: recipes,
                        hasReachedMax: hasReachedMax,
                        showFeatured: _showFeatured,
                        onLoadMore: () => _loadRecipes(refresh: false),
                        onRecipeTap: (recipe) => _navigateToDetail(recipe),
                      ),
                      error: (message) => _ErrorState(
                        message: message,
                        onRetry: () => _loadRecipes(),
                      ),
                    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cộng đồng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.search,
                onTap: () => _showSearchDialog(),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.more_vert,
                onTap: () => _showMoreOptions(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _showFeatured = index == 1;
          });
          if (_showFeatured) {
            _loadFeaturedRecipes();
          } else {
            _loadRecipes();
          }
        },
        indicatorColor: AppTheme.primaryGreen,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Nổi bật'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  if (value.isEmpty) {
                    _loadRecipes();
                  }
                },
                onSubmitted: (value) => _loadRecipes(),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm công thức...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Filter button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFilterBottomSheet(),
                borderRadius: BorderRadius.circular(24),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToCreateRecipe(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
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
      MaterialPageRoute(
        builder: (context) => const CreateRecipePage(),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            _loadRecipes();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              _loadRecipes();
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return CommunityFiltersBottomSheet(
              initialRegion: _selectedRegion,
              initialDifficulty: _selectedDifficulty,
              initialMaxTime: _maxTime,
              onFiltersChanged: (region, difficulty, maxTime) {
                setState(() {
                  _selectedRegion = region;
                  _selectedDifficulty = difficulty;
                  _maxTime = maxTime;
                });
                _loadRecipes();
                Navigator.pop(context); // Close bottom sheet after applying filters
              },
              onClearFilters: () {
                setState(() {
                  _selectedRegion = null;
                  _selectedDifficulty = null;
                  _maxTime = null;
                });
                _loadRecipes();
                Navigator.pop(context); // Close bottom sheet after clearing filters
              },
            );
          },
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Làm mới'),
              onTap: () {
                _loadRecipes();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Trợ giúp'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedView extends StatelessWidget {
  final List<CommunityRecipe> recipes;
  final bool hasReachedMax;
  final bool showFeatured;
  final VoidCallback onLoadMore;
  final Function(CommunityRecipe) onRecipeTap;

  const _FeedView({
    required this.recipes,
    required this.hasReachedMax,
    required this.showFeatured,
    required this.onLoadMore,
    required this.onRecipeTap,
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
            const SliverFillRemaining(
              child: _EmptyState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < recipes.length) {
                    return CommunityFeedCard(
                      recipe: recipes[index],
                      onTap: () => onRecipeTap(recipes[index]),
                    ).animate().fadeIn(
                      duration: 300.ms,
                      delay: (index * 50).ms,
                    ).slideY(
                      begin: 0.2,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            'Chưa có công thức nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy là người đầu tiên chia sẻ\ncông thức nấu ăn của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
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
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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