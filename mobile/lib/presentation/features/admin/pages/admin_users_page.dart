import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/sources/remote/admin_api_service.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';
import 'package:bepviet_mobile/presentation/features/admin/cubit/admin_cubit.dart';
import 'package:bepviet_mobile/presentation/features/admin/pages/admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool? _selectedStatus;
  late AdminRepository _adminRepository;
  late AdminCubit _adminCubit;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    final adminApiService = AdminApiService(dio);
    _adminRepository = AdminRepository(adminApiService);
    _adminCubit = AdminCubit(_adminRepository)..loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _adminCubit.close();
    super.dispose();
  }

  void _performSearch() {
    _adminCubit.loadUsers(
      refresh: true,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      role: _selectedRole,
      isActive: _selectedStatus,
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
                      hintText: 'Tìm kiếm theo tên hoặc email...',
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
                  // Filters
                  Row(
                    children: [
                      // Role filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Vai trò',
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: AppTheme.primaryGreen,
                              size: 20,
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
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'Tất cả',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'USER',
                              child: Text(
                                'Người dùng',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ADMIN',
                              child: Text(
                                'Quản trị viên',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                            _performSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status filter
                      Expanded(
                        child: DropdownButtonFormField<bool?>(
                          value: _selectedStatus,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Trạng thái',
                            prefixIcon: const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryGreen,
                              size: 20,
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
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'Tất cả',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: true,
                              child: Text(
                                'Hoạt động',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text(
                                'Đã khóa',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                            _performSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // User list
            Expanded(
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  return state.when(
                    initial: () =>
                        const Center(child: CircularProgressIndicator()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    loaded: (users, hasMore) {
                      if (users.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Không tìm thấy người dùng',
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
                          itemCount: users.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == users.length) {
                              // Load more indicator
                              context.read<AdminCubit>().loadMoreUsers(
                                search: _searchController.text.trim().isEmpty
                                    ? null
                                    : _searchController.text.trim(),
                                role: _selectedRole,
                                isActive: _selectedStatus,
                              );
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final user = users[index] as UserModel;
                            return _UserCard(
                              user: user,
                              adminRepository: _adminRepository,
                              onBlock: () => _showBlockDialog(context, user),
                              onUnblock: () =>
                                  _showUnblockDialog(context, user),
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

  void _showBlockDialog(BuildContext context, UserModel user) {
    final cubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Khóa người dùng'),
        content: Text('Bạn có chắc muốn khóa người dùng "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await cubit.blockUser(user.id);

                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã khóa người dùng "${user.name}"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi khóa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Khóa'),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, UserModel user) {
    final cubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mở khóa người dùng'),
        content: Text('Bạn có chắc muốn mở khóa người dùng "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await cubit.unblockUser(user.id);

                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã mở khóa người dùng "${user.name}"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi mở khóa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mở khóa'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final AdminRepository adminRepository;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;

  const _UserCard({
    required this.user,
    required this.adminRepository,
    required this.onBlock,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserDetailPage(
                userId: user.id,
                adminRepository: adminRepository,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.badge,
                    label: user.role == 'ADMIN' ? 'Admin' : 'User',
                    color: user.role == 'ADMIN'
                        ? Colors.purple
                        : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.restaurant_menu,
                    label: '${user.recipeCount ?? 0} công thức',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.star,
                    label:
                        user.subscriptionCount != null &&
                            user.subscriptionCount! > 0
                        ? 'Premium'
                        : 'Free',
                    color:
                        user.subscriptionCount != null &&
                            user.subscriptionCount! > 0
                        ? Colors.amber
                        : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (user.isActive)
                    TextButton.icon(
                      onPressed: onBlock,
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Khóa'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    )
                  else
                    TextButton.icon(
                      onPressed: onUnblock,
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Mở khóa'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
