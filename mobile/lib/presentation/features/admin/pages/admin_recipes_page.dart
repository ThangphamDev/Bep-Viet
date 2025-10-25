import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';
import 'package:bepviet_mobile/data/sources/remote/admin_api_service.dart';
import 'package:bepviet_mobile/presentation/features/admin/cubit/admin_cubit.dart';
import 'package:bepviet_mobile/presentation/features/admin/widgets/admin_official_recipe_card.dart';

class AdminRecipesPage extends StatefulWidget {
  const AdminRecipesPage({super.key});

  @override
  State<AdminRecipesPage> createState() => _AdminRecipesPageState();
}

class _AdminRecipesPageState extends State<AdminRecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRegion;
  late AdminRepository _adminRepository;
  late AdminCubit _adminCubit;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    final adminApiService = AdminApiService(dio);
    _adminRepository = AdminRepository(adminApiService);
    _adminCubit = AdminCubit(_adminRepository)..loadOfficialRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _adminCubit.close();
    super.dispose();
  }

  void _performSearch() {
    _adminCubit.loadOfficialRecipes(
      refresh: true,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      region: _selectedRegion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminCubit,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Search and Filter section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm công thức...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryGreen,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                                _performSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (value) => _performSearch(),
                  ),
                  const SizedBox(height: 12),
                  // Region filter
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRegion,
                          decoration: InputDecoration(
                            labelText: 'Vùng miền',
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: AppTheme.primaryGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryGreen,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả'),
                            ),
                            DropdownMenuItem(
                              value: 'BAC',
                              child: Text('Miền Bắc'),
                            ),
                            DropdownMenuItem(
                              value: 'TRUNG',
                              child: Text('Miền Trung'),
                            ),
                            DropdownMenuItem(
                              value: 'NAM',
                              child: Text('Miền Nam'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRegion = value;
                            });
                            _performSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _performSearch,
                        icon: const Icon(Icons.search, size: 20),
                        label: const Text('Tìm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Recipe list
            Expanded(
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  return state.when(
                    initial: () =>
                        const Center(child: CircularProgressIndicator()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                          _performSearch();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          itemCount: recipes.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == recipes.length) {
                              // Load more indicator
                              context
                                  .read<AdminCubit>()
                                  .loadMoreOfficialRecipes(
                                    search:
                                        _searchController.text.trim().isEmpty
                                        ? null
                                        : _searchController.text.trim(),
                                    region: _selectedRegion,
                                  );
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
                              adminRepository: _adminRepository,
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
                            onPressed: _performSearch,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
          'Bạn có chắc muốn xóa công thức chính thức "${recipe.title}"?',
        ),
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
