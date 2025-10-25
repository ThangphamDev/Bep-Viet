import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/repositories/admin_repository.dart';
import 'package:bepviet_mobile/presentation/features/admin/pages/admin_recipe_detail_page.dart';

class AdminUserDetailPage extends StatefulWidget {
  final String userId;
  final AdminRepository adminRepository;

  const AdminUserDetailPage({
    super.key,
    required this.userId,
    required this.adminRepository,
  });

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  UserModel? _user;
  List<CommunityRecipe> _recipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await widget.adminRepository.getUserById(widget.userId);
      final recipes = await widget.adminRepository.getUserRecipes(
        widget.userId,
      );

      setState(() {
        _user = user;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Chi tiết người dùng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    'Lỗi: $_error',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    _buildUserInfoCard(),
                    const SizedBox(height: 16),
                    // Recipes Section
                    _buildRecipesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    if (_user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and Name
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(
              _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _user!.email,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _user!.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _user!.isActive ? Icons.check_circle : Icons.block,
                  size: 18,
                  color: _user!.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  _user!.statusDisplay,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _user!.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          // User Details
          _buildInfoRow(
            Icons.badge,
            'Vai trò',
            _user!.role == 'ADMIN' ? 'Quản trị viên' : 'Người dùng',
            _user!.role == 'ADMIN' ? Colors.purple : AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Vùng miền',
            _user!.regionDisplay,
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.restaurant_menu,
            'Số công thức',
            '${_user!.recipeCount ?? 0}',
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.star,
            'Gói dịch vụ',
            _user!.subscriptionCount != null && _user!.subscriptionCount! > 0
                ? 'Premium'
                : 'Free',
            _user!.subscriptionCount != null && _user!.subscriptionCount! > 0
                ? Colors.amber
                : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Ngày tham gia',
            _formatDate(_user!.createdAt),
            AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 24,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 12),
              Text(
                'Công thức đã đăng (${_recipes.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recipes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 60,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có công thức nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _recipes.map((recipe) {
                return _buildRecipeCard(recipe);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(CommunityRecipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminRecipeDetailPage(
                recipeId: recipe.id,
                adminRepository: widget.adminRepository,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.timeMin} phút',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          (recipe.avgRating ?? 0.0).toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          recipe.status ?? 'PENDING',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(recipe.status ?? 'PENDING'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(recipe.status ?? 'PENDING'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        size: 40,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status;
    }
  }
}
