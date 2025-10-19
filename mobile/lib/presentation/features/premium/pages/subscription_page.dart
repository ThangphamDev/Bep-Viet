import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_plan_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_history_card.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'premium';
  bool _isLoading = false;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'basic',
      name: 'Gói Cơ bản',
      price: 0,
      duration: 'Miễn phí',
      features: [
        'Gợi ý món ăn cơ bản',
        'Quản lý tủ lạnh',
        'Lập kế hoạch tuần',
        'Cộng đồng công thức',
      ],
      isPopular: false,
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'Gói Premium',
      price: 99000,
      duration: 'Tháng',
      features: [
        'Tất cả tính năng cơ bản',
        'Hồ sơ gia đình chi tiết',
        'Cảnh báo dinh dưỡng thông minh',
        'Phân tích sức khỏe hàng tuần',
        'Ưu tiên hỗ trợ 24/7',
        'Gợi ý cá nhân hóa',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'family',
      name: 'Gói Gia đình',
      price: 149000,
      duration: 'Tháng',
      features: [
        'Tất cả tính năng Premium',
        'Quản lý tối đa 8 thành viên',
        'Báo cáo sức khỏe gia đình',
        'Cảnh báo dị ứng nâng cao',
        'Tư vấn dinh dưỡng chuyên nghiệp',
        'Tích hợp thiết bị y tế',
      ],
      isPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Đăng ký Premium'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/premium'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showSubscriptionHistory(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Subscription Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
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
                      const Icon(Icons.star, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Premium Active',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gói Premium • Hết hạn 15/02/2024',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusItem(
                          icon: Icons.family_restroom,
                          label: 'Hồ sơ gia đình',
                          isActive: true,
                        ),
                      ),
                      Expanded(
                        child: _buildStatusItem(
                          icon: Icons.health_and_safety,
                          label: 'Cảnh báo sức khỏe',
                          isActive: true,
                        ),
                      ),
                      Expanded(
                        child: _buildStatusItem(
                          icon: Icons.analytics,
                          label: 'Phân tích chi tiết',
                          isActive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription Plans
            Text(
              'Chọn gói đăng ký',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Plans List
            ..._plans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionPlanCard(
                  plan: plan,
                  isSelected: _selectedPlan == plan.id,
                  onSelect: () {
                    setState(() {
                      _selectedPlan = plan.id;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Benefits Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lợi ích khi nâng cấp',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    icon: Icons.family_restroom,
                    title: 'Quản lý hồ sơ gia đình',
                    description:
                        'Theo dõi thông tin sức khỏe của từng thành viên',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.health_and_safety,
                    title: 'Cảnh báo dinh dưỡng thông minh',
                    description:
                        'Nhận cảnh báo về dị ứng và tình trạng sức khỏe',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    icon: Icons.analytics,
                    title: 'Phân tích sức khỏe chi tiết',
                    description:
                        'Báo cáo dinh dưỡng và khuyến nghị cá nhân hóa',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _subscribeToPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _getSubscribeButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Terms and Conditions
            Text(
              'Bằng cách đăng ký, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật của chúng tôi.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  String _getSubscribeButtonText() {
    if (_selectedPlan == 'basic') {
      return 'Đang sử dụng gói miễn phí';
    } else {
      final plan = _plans.firstWhere((p) => p.id == _selectedPlan);
      return 'Đăng ký ${plan.name} - ${plan.price.toStringAsFixed(0)}đ/${plan.duration.toLowerCase()}';
    }
  }

  void _subscribeToPlan() {
    if (_selectedPlan == 'basic') return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đăng ký thành công!'),
          content: Text(
            'Bạn đã đăng ký thành công gói ${_plans.firstWhere((p) => p.id == _selectedPlan).name}. '
            'Cảm ơn bạn đã tin tưởng Bếp Việt!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/premium');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _showSubscriptionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSubscriptionHistorySheet(),
    );
  }

  Widget _buildSubscriptionHistorySheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Lịch sử đăng ký',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                SubscriptionHistoryCard(
                  planName: 'Premium',
                  date: '15/01/2024',
                  amount: 99000,
                  status: 'Active',
                  isActive: true,
                ),
                const SizedBox(height: 12),
                SubscriptionHistoryCard(
                  planName: 'Basic',
                  date: '01/01/2024',
                  amount: 0,
                  status: 'Expired',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final String duration;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    required this.isPopular,
  });
}
