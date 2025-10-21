import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/presentation/routes/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        UserModel? currentUser;
        bool isLoading = false;

        if (state is AuthAuthenticated) {
          currentUser = state.user;
        } else if (state is AuthLoading) {
          isLoading = true;
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Custom App Bar
                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      backgroundColor: AppTheme.primaryGreen,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        titlePadding: const EdgeInsets.only(
                          left: 16,
                          bottom: 16,
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                          ),
                          child: Stack(
                            children: [
                              // Background Icon
                              const Positioned(
                                left: 20,
                                top: 35,
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white70,
                                ),
                              ),
                              // Logout Button
                              Positioned(
                                right: 16,
                                top: 30,
                                child: IconButton(
                                  onPressed: () async {
                                    // Show confirmation dialog
                                    final shouldLogout = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Đăng xuất'),
                                        content: const Text(
                                          'Bạn có chắc chắn muốn đăng xuất?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Đăng xuất'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldLogout == true) {
                                      await context.read<AuthCubit>().logout();
                                      // Force refresh the router to trigger redirect
                                      if (context.mounted) {
                                        context.go(AppRoutes.login);
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Profile Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Avatar Section
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                border: Border.all(
                                  color: AppTheme.primaryGreen,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // User Info Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin cá nhân',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      'Tên',
                                      currentUser?.name ?? 'Chưa cập nhật',
                                    ),
                                    _buildInfoRow(
                                      'Email',
                                      currentUser?.email ?? 'Chưa cập nhật',
                                    ),
                                    _buildInfoRow(
                                      'Vùng',
                                      currentUser?.region ?? 'Chưa cập nhật',
                                    ),
                                    _buildInfoRow(
                                      'Tỉnh/Thành phố',
                                      currentUser?.subregion ?? 'Chưa cập nhật',
                                    ),
                                    _buildInfoRow(
                                      'Vai trò',
                                      currentUser?.role ?? 'USER',
                                    ),
                                    _buildInfoRow(
                                      'Trạng thái',
                                      currentUser?.isActive == true
                                          ? 'Hoạt động'
                                          : 'Tạm khóa',
                                    ),
                                    if (currentUser?.createdAt != null)
                                      _buildInfoRow(
                                        'Ngày tạo',
                                        _formatDate(currentUser!.createdAt!),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Settings Section
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildSettingsItem(
                                    icon: Icons.edit,
                                    title: 'Chỉnh sửa thông tin',
                                    subtitle: 'Cập nhật thông tin cá nhân',
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Tính năng đang phát triển',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsItem(
                                    icon: Icons.notifications,
                                    title: 'Thông báo',
                                    subtitle: 'Quản lý thông báo',
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Tính năng đang phát triển',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsItem(
                                    icon: Icons.security,
                                    title: 'Bảo mật',
                                    subtitle: 'Đổi mật khẩu, xác thực',
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Tính năng đang phát triển',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsItem(
                                    icon: Icons.help,
                                    title: 'Trợ giúp',
                                    subtitle: 'FAQ, liên hệ hỗ trợ',
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Tính năng đang phát triển',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // App Info
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin ứng dụng',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      'Tên ứng dụng',
                                      AppConfig.appName,
                                    ),
                                    _buildInfoRow(
                                      'Phiên bản',
                                      AppConfig.appVersion,
                                    ),
                                    _buildInfoRow(
                                      'Mô tả',
                                      AppConfig.appDescription,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 100), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
