import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/sources/remote/premium_service.dart';
import 'package:bepviet_mobile/data/repositories/premium_repository.dart';
import 'package:bepviet_mobile/presentation/features/premium/cubit/premium_cubit.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_plan_card.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_history_card.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'PREMIUM';
  bool _isLoading = true;
  String? _errorMessage;
  List<SubscriptionPlanModel> _apiPlans = [];
  SubscriptionModel? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final token = context.read<AuthCubit>().authRepository.accessToken;
        if (token != null) {
          // Create PremiumRepository instance
          final premiumService = PremiumService(Dio());
          final premiumRepo = PremiumRepository(premiumService);

          // Load plans and current subscription
          final plans = await premiumRepo.getSubscriptionPlans(token);
          final subscription = await premiumRepo.getUserSubscription(token);

          setState(() {
            _apiPlans = plans;
            _currentSubscription = subscription;
            // Set selected plan to current subscription or first paid plan
            if (subscription != null) {
              _selectedPlan = subscription.plan;
            } else if (plans.isNotEmpty) {
              // Find first paid plan
              final paidPlan = plans.firstWhere(
                (p) => p.price > 0,
                orElse: () => plans.first,
              );
              _selectedPlan = paidPlan.id;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Convert API plans to local SubscriptionPlan for compatibility with widgets
  List<SubscriptionPlan> get _plans {
    return _apiPlans.map((apiPlan) {
      return SubscriptionPlan(
        id: apiPlan.id,
        name: apiPlan.name,
        price: apiPlan.price,
        duration: apiPlan.duration == 'month' ? 'Tháng' : 'Năm',
        features: apiPlan.features,
        isPopular: apiPlan.isPopular,
      );
    }).toList();
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Subscription Status
                  if (_currentSubscription != null &&
                      _currentSubscription!.status == 'ACTIVE')
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
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _currentSubscription!.plan == 'PREMIUM'
                                    ? 'Premium Active'
                                    : '${_currentSubscription!.plan} Active',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gói ${_currentSubscription!.plan} • Hết hạn ${_formatDate(_currentSubscription!.endedAt)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _subscribeToPlan() async {
    // Find selected plan to get price
    final selectedPlanData = _apiPlans.firstWhere((p) => p.id == _selectedPlan);

    // If FREE plan, just continue
    if (selectedPlanData.price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bạn đang sử dụng gói miễn phí'),
          backgroundColor: AppTheme.infoColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final token = context.read<AuthCubit>().authRepository.accessToken;
        if (token != null) {
          // Create subscription
          // Determine duration months based on plan type
          int durationMonths = 1; // Default to 1 month
          if (selectedPlanData.duration.toLowerCase().contains('năm') ||
              selectedPlanData.duration.toLowerCase().contains('year')) {
            durationMonths = 12;
          } else if (selectedPlanData.duration.toLowerCase().contains(
                'tháng',
              ) ||
              selectedPlanData.duration.toLowerCase().contains('month')) {
            durationMonths = 1;
          }

          final request = CreateSubscriptionRequest(
            plan: _selectedPlan,
            durationMonths: durationMonths,
          );

          context.read<PremiumCubit>().add(CreateSubscription(token, request));

          // Wait a bit for the subscription to be created
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            setState(() {
              _isLoading = false;
            });

            // Show success dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Đăng ký thành công!'),
                content: Text(
                  'Bạn đã đăng ký thành công gói ${selectedPlanData.name}. '
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
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng ký: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _showSubscriptionHistory() async {
    // Load transactions
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final token = context.read<AuthCubit>().authRepository.accessToken;
    if (token == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      builder: (context) => _buildSubscriptionHistorySheet(token),
    );
  }

  Widget _buildSubscriptionHistorySheet(String token) {
    return Material(
      color: Colors.transparent,
      child: Container(
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
              child: FutureBuilder<List<SubscriptionTransactionModel>>(
                future: _loadTransactions(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang tải lịch sử...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Lỗi tải dữ liệu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final transactions = snapshot.data;

                  if (transactions == null || transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có lịch sử giao dịch',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return SubscriptionHistoryCard(
                        planName: transaction.planName,
                        date: _formatDate(transaction.createdAt),
                        amount: transaction.amount,
                        status: _translateStatus(transaction.status),
                        isActive: transaction.status == 'COMPLETED',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<SubscriptionTransactionModel>> _loadTransactions(
    String token,
  ) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = AppConfig.ngrokBaseUrl;
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';

      final premiumService = PremiumService(dio);
      final premiumRepo = PremiumRepository(premiumService);

      return await premiumRepo.getUserTransactions(token);
    } catch (e) {
      throw Exception('Không thể tải lịch sử giao dịch: $e');
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'PENDING':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
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
