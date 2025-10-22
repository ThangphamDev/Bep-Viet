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
                                  _buildPremiumSettingsItem(
                                    context: context,
                                    icon: Icons.star,
                                    title: 'Premium',
                                    subtitle: 'Nâng cấp tài khoản Premium',
                                    onTap: () {
                                      // Navigate to Premium Dashboard
                                      context.go('/premium');
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

                            // Danger Zone
                            Card(
                              elevation: 2,
                              color: AppTheme.errorColor.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppTheme.errorColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppTheme.errorColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Vùng nguy hiểm',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.errorColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  _buildDangerItem(
                                    context: context,
                                    icon: Icons.delete_forever,
                                    title: 'Xóa tài khoản',
                                    subtitle: 'Xóa vĩnh viễn tài khoản của bạn',
                                    onTap: () =>
                                        _showDeleteAccountDialog(context),
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

  Widget _buildPremiumSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.errorColor),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.errorColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.errorColor.withOpacity(0.7)),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.errorColor.withOpacity(0.7),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Xóa tài khoản?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn bao gồm:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildWarningItem('• Thông tin cá nhân'),
            _buildWarningItem('• Công thức đã lưu'),
            _buildWarningItem('• Kế hoạch bữa ăn'),
            _buildWarningItem('• Tủ lạnh & danh sách mua sắm'),
            _buildWarningItem('• Đánh giá & bình luận'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn có chắc chắn muốn tiếp tục?',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xóa tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _deleteAccount(context);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
              SizedBox(height: 16),
              Text('Đang xóa tài khoản...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    try {
      // Call delete account API
      await context.read<AuthCubit>().deleteAccount();

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Tài khoản đã được xóa thành công')),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Redirect to login (already logged out by deleteAccount)
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.errorColor.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
