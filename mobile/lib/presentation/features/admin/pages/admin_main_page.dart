import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/sources/remote/admin_api_service.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';
import 'package:bepviet_mobile/presentation/features/admin/cubit/admin_cubit.dart';
import 'package:bepviet_mobile/presentation/features/admin/widgets/admin_community_recipe_card.dart';
import 'package:bepviet_mobile/presentation/features/admin/widgets/admin_official_recipe_card.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Đăng xuất',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_outlined, size: 20),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.people_outline, size: 20),
              text: 'Cộng đồng',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu_outlined, size: 20),
              text: 'Công thức',
            ),
            Tab(
              icon: Icon(Icons.people, size: 20),
              text: 'Người dùng',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          _AdminDashboardContent(),
          _AdminCommunityContent(),
          _AdminRecipesContent(),
          _AdminUsersContent(),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Quản lý Cộng đồng';
      case 2:
        return 'Quản lý Công thức';
      case 3:
        return 'Quản lý Người dùng';
      default:
        return 'Admin';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 80,
            color: AppTheme.primaryGreen,
          ),
          SizedBox(height: 20),
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Chào mừng đến với trang quản trị',
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

class _AdminCommunityContent extends StatelessWidget {
  const _AdminCommunityContent();

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
                    padding: const EdgeInsets.only(top: 8),
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

class _AdminRecipesContent extends StatelessWidget {
  const _AdminRecipesContent();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();
        final adminApiService = AdminApiService(dio);
        final adminRepository = AdminRepository(adminApiService);
        return AdminCubit(adminRepository)..loadOfficialRecipes();
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
                          'Chưa có công thức chính thức nào',
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
                    context.read<AdminCubit>().loadOfficialRecipes(refresh: true);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: recipes.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == recipes.length) {
                        // Load more indicator
                        context.read<AdminCubit>().loadMoreOfficialRecipes();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final recipe = recipes[index];
                      return AdminOfficialRecipeCard(
                        recipe: recipe,
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
                        context.read<AdminCubit>().loadOfficialRecipes(refresh: true);
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

  void _showDeleteDialog(BuildContext context, recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Bạn có chắc muốn xóa công thức chính thức "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminCubit>().deleteOfficialRecipe(recipe.id);
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

class _AdminUsersContent extends StatelessWidget {
  const _AdminUsersContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 20),
            Text(
              'Quản lý Người dùng',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Quản lý tài khoản người dùng',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
