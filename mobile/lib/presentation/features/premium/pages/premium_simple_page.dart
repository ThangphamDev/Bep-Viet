import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/data/sources/remote/subscription_service.dart';

/// Trang Premium đơn giản - chỉ hiển thị thông tin cơ bản
class PremiumSimplePage extends StatefulWidget {
  final VoidCallback? onUpgradeSuccess;
  
  const PremiumSimplePage({super.key, this.onUpgradeSuccess});

  @override
  State<PremiumSimplePage> createState() => _PremiumSimplePageState();
}

class _PremiumSimplePageState extends State<PremiumSimplePage> {
  bool _isPremium = false;
  bool _isLoading = true;
  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _selectedPlan;
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(Dio());
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    
    try {
      final plans = await _subscriptionService.getAllPlans();
      setState(() {
        _plans = plans;
        // Chọn gói phổ biến nhất làm mặc định
        _selectedPlan = plans.firstWhere(
          (p) => p.isPopular,
          orElse: () => plans.isNotEmpty ? plans.first : throw Exception('No plans'),
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plans: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải gói Premium: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Status Card
                  _buildPremiumStatusCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Plans Section (only show if not premium)
                  if (!_isPremium) ...[
                    _buildPlansSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Features Section
                  _buildFeaturesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Family Management (Premium Feature)
                  _buildFamilySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn gói Premium',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_plans.isEmpty)
          const Center(
            child: Text('Không có gói Premium nào'),
          )
        else
          ..._plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final bool isSelected = _selectedPlan?.id == plan.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio Icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                        ),
                      ),
                      if (plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PHỔ BIẾN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.durationInMonths} tháng',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Price
            Text(
              _formatPrice(plan.price),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _isPremium
            ? LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
              )
            : LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade800],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isPremium
                ? AppTheme.primaryGreen.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isPremium ? Icons.workspace_premium : Icons.person,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _isPremium ? 'Gói Premium' : 'Gói Miễn phí',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPremium
                ? 'Bạn đang sử dụng đầy đủ tính năng Premium'
                : 'Nâng cấp để mở khóa tất cả tính năng',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          if (!_isPremium)
            ElevatedButton(
              onPressed: _showUpgradeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Nâng cấp Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Công thức cơ bản',
        'description': 'Truy cập công thức nấu ăn',
        'premium': false,
      },
      {
        'icon': Icons.family_restroom,
        'title': 'Quản lý gia đình',
        'description': 'Theo dõi thành viên gia đình',
        'premium': true,
      },
      {
        'icon': Icons.health_and_safety,
        'title': 'Cảnh báo sức khỏe',
        'description': 'Cảnh báo dị ứng & dinh dưỡng',
        'premium': true,
      },
      {
        'icon': Icons.analytics,
        'title': 'Thống kê chi tiết',
        'description': 'Báo cáo dinh dưỡng hàng tuần',
        'premium': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tính năng',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              isPremium: feature['premium'] as bool,
            )),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isPremium,
  }) {
    final isLocked = isPremium && !_isPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked
              ? Colors.grey.shade300
              : AppTheme.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.grey.shade200
                  : AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isLocked ? Colors.grey : AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? Colors.grey
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLocked
                        ? Colors.grey
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(
              Icons.lock,
              color: Colors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hồ sơ gia đình',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            if (_isPremium)
              TextButton.icon(
                onPressed: () {
                  // Navigate to family management
                  Navigator.pushNamed(context, '/premium/family');
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (!_isPremium)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tính năng Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nâng cấp Premium để quản lý thông tin dinh dưỡng cho cả gia đình',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showUpgradeDialog,
                  child: const Text('Nâng cấp ngay'),
                ),
              ],
            ),
          )
        else
          _buildFamilyList(),
      ],
    );
  }

  Widget _buildFamilyList() {
    // Mock data - trong thực tế sẽ load từ API
    final familyMembers = [
      {'name': 'Bố', 'age': 'Người lớn', 'allergies': 'Hải sản'},
      {'name': 'Mẹ', 'age': 'Người lớn', 'allergies': 'Không'},
      {'name': 'Con', 'age': 'Trẻ em', 'allergies': 'Sữa'},
    ];

    return Column(
      children: familyMembers
          .map((member) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${member['age']} • Dị ứng: ${member['allergies']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showUpgradeDialog() {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn gói Premium'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gói: ${_selectedPlan!.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Giá: ${_formatPrice(_selectedPlan!.price)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Thời hạn: ${_selectedPlan!.durationInMonths} tháng',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tính năng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._selectedPlan!.features.map((feature) => _buildBenefitItem(feature)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _upgradeToPremium();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M VNĐ';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K VNĐ';
    }
    return '${price.toStringAsFixed(0)} VNĐ';
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _upgradeToPremium() async {
    if (_selectedPlan == null) return;

    setState(() => _isLoading = true);
    
    try {
      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      // Gọi API đăng ký
      final success = await _subscriptionService.subscribeToPlan(
        token,
        _selectedPlan!.id,
      );

      if (success) {
        setState(() {
          _isPremium = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Nâng cấp Premium thành công!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          
          // Gọi callback để thông báo upgrade thành công
          widget.onUpgradeSuccess?.call();
        }
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

