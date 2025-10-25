import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/managers/payment_manager.dart';
import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/sources/remote/premium_service.dart';
import 'package:bepviet_mobile/data/repositories/premium_repository.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_plan_card.dart'
    show SubscriptionPlanCard, ISubscriptionPlan;
import 'package:bepviet_mobile/presentation/features/premium/widgets/subscription_history_card.dart';

/// Refactored Subscription Page with clean payment flow management
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // UI State
  String _selectedPlan = 'PREMIUM';
  bool _isLoading = true;
  String? _errorMessage;

  // Data
  List<SubscriptionPlanModel> _apiPlans = [];
  SubscriptionModel? _currentSubscription;

  // Payment Manager - handles all payment logic
  late final PaymentManager _paymentManager;

  // Deep Link Handler
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Dialog Management
  BuildContext? _currentDialogContext;

  @override
  void initState() {
    super.initState();
    _initializePaymentManager();
    _initializeDeepLinks();
    _loadData();
  }

  @override
  void dispose() {
    _paymentManager.dispose();
    _linkSubscription?.cancel();
    _closeDialog();
    super.dispose();
  }

  /// Initialize payment manager with callbacks
  void _initializePaymentManager() {
    _paymentManager = PaymentManager();

    // Listen to payment state changes
    _paymentManager.addStatusListener((state, result) async {
      if (!mounted) return;

      switch (state) {
        case PaymentState.creating:
          _showLoadingDialog('Đang tạo thanh toán...');
          break;

        case PaymentState.waiting:
          _closeDialog();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) _showPaymentPendingDialog();
          break;

        case PaymentState.processing:
          _closeDialog();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) _showLoadingDialog('Đang xử lý thanh toán...');
          break;

        case PaymentState.completed:
          // Success handler will close dialog and show success
          await _handlePaymentSuccess(result!);
          break;

        case PaymentState.failed:
          _closeDialog();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) _handlePaymentFailed(result);
          break;

        case PaymentState.idle:
          _closeDialog();
          break;
      }
    });
  }

  /// Initialize deep link handler - SINGLE SOURCE OF TRUTH
  void _initializeDeepLinks() {
    _appLinks = AppLinks();

    // Listen to incoming links (app in background/foreground)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        // Only handle VNPay deep links
        if (uri.scheme == 'bepviet' && uri.host == 'vnpay') {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        // Deep link error - silently ignore
      },
    );
  }

  /// Handle deep link - delegates to PaymentManager
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      final token = _getToken();
      if (token == null) return;

      await _paymentManager.handleDeepLink(uri, token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý thanh toán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Load subscription data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = _getToken();
      if (token == null) throw Exception('Not authenticated');

      final premiumService = PremiumService(Dio());
      final premiumRepo = PremiumRepository(premiumService);

      final plans = await premiumRepo.getSubscriptionPlans(token);
      final subscription = await premiumRepo.getUserSubscription(token);

      setState(() {
        _apiPlans = plans;
        _currentSubscription = subscription;

        // Set selected plan
        if (subscription != null) {
          _selectedPlan = subscription.plan;
        } else if (plans.isNotEmpty) {
          final paidPlan = plans.firstWhere(
            (p) => p.price > 0,
            orElse: () => plans.first,
          );
          _selectedPlan = paidPlan.id;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Handle payment success
  Future<void> _handlePaymentSuccess(PaymentResult result) async {
    // Close any loading dialog first
    _closeDialog();

    // Small delay to ensure dialog is closed
    await Future.delayed(const Duration(milliseconds: 300));

    // Reload data to get updated subscription
    await _loadData();

    // Show success dialog
    if (!mounted) return;

    // Post frame callback to ensure page is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🎉 Chúc mừng!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn đã đăng ký thành công gói ${_currentSubscription?.plan ?? "Premium"}!',
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cảm ơn bạn đã tin tưởng Bếp Việt ❤️',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _paymentManager.reset();
                      // Navigate to Premium dashboard
                      context.go('/premium');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tuyệt vời!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        // Fallback: just navigate to premium
        context.go('/premium');
      }
    });
  }

  /// Handle payment failed
  void _handlePaymentFailed(PaymentResult? result) {
    if (!mounted) return;

    final errorCode = result?.responseCode ?? '99';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanh toán không thành công (Mã lỗi: $errorCode)'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    _paymentManager.reset();
  }

  /// Show loading dialog
  void _showLoadingDialog(String message) {
    if (!mounted) return;

    _closeDialog();

    // Post frame callback to ensure dialog is shown after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            _currentDialogContext = dialogContext;
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(message),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } catch (e) {
        // Silently ignore dialog error
      }
    });
  }

  /// Show payment pending dialog with auto-check
  void _showPaymentPendingDialog() {
    if (!mounted) return;

    _closeDialog();

    final token = _getToken();
    if (token == null) return;

    // Start background polling
    _paymentManager.startPolling(token);

    // Post frame callback to ensure dialog is shown after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            _currentDialogContext = dialogContext;
            return WillPopScope(
              onWillPop: () async {
                _paymentManager.cancelPayment();
                return true;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Đang chờ thanh toán'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Vui lòng hoàn tất thanh toán trên VNPay',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Hệ thống đang tự động kiểm tra thanh toán...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _paymentManager.cancelPayment();
                    },
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        // Silently ignore dialog error
      }
    });
  }

  /// Close current dialog if exists
  void _closeDialog() {
    if (_currentDialogContext != null) {
      try {
        // Only pop if dialog context is still valid and mounted
        if (Navigator.canPop(_currentDialogContext!)) {
          Navigator.of(_currentDialogContext!, rootNavigator: false).pop();
        }
      } catch (e) {
        // Silently ignore dialog close error
      } finally {
        _currentDialogContext = null;
      }
    }
  }

  /// Get auth token
  String? _getToken() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return context.read<AuthCubit>().authRepository.accessToken;
    }
    return null;
  }

  /// Start VNPay payment
  Future<void> _payWithVNPay(SubscriptionPlanModel plan) async {
    final token = _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục')),
      );
      return;
    }

    try {
      // Determine duration
      int durationMonths = 1;
      if (plan.duration.toLowerCase().contains('năm') ||
          plan.duration.toLowerCase().contains('year')) {
        durationMonths = 12;
      }

      // Create payment via PaymentManager
      final paymentUrl = await _paymentManager.createPayment(
        token: token,
        plan: plan,
        durationMonths: durationMonths,
      );

      // Open VNPay URL in browser
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Không thể mở trình duyệt');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo thanh toán: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Start subscription process
  Future<void> _subscribeToPlan() async {
    final selectedPlanData = _apiPlans.firstWhere((p) => p.id == _selectedPlan);

    if (selectedPlanData.price == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bạn đang sử dụng gói miễn phí'),
          backgroundColor: AppTheme.infoColor,
        ),
      );
      return;
    }

    // Show payment method selection
    _showPaymentMethodDialog(selectedPlanData);
  }

  /// Show payment method dialog
  Future<void> _showPaymentMethodDialog(SubscriptionPlanModel plan) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        title: Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Chọn phương thức thanh toán',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gói: ${plan.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Số tiền: ${plan.price.toStringAsFixed(0)}đ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // VNPay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _payWithVNPay(plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0088CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.account_balance_wallet, size: 22),
                  label: const Text(
                    'Thanh toán VNPay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Convert API plans to local SubscriptionPlanUI for compatibility
  List<SubscriptionPlanUI> get _plans {
    return _apiPlans.map((apiPlan) {
      return SubscriptionPlanUI(
        id: apiPlan.id,
        name: apiPlan.name,
        price: apiPlan.price,
        duration: apiPlan.duration == 'month' ? 'Tháng' : 'Năm',
        features: apiPlan.features,
        isPopular: apiPlan.isPopular,
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getSubscribeButtonText() {
    if (_selectedPlan == 'basic') {
      return 'Đang sử dụng gói miễn phí';
    }

    final hasPlan = _plans.any((p) => p.id == _selectedPlan);
    if (!hasPlan) {
      return 'Đang tải...';
    }

    final plan = _plans.firstWhere((p) => p.id == _selectedPlan);
    return 'Đăng ký ${plan.name} - ${plan.price.toStringAsFixed(0)}đ/${plan.duration.toLowerCase()}';
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
          onPressed: () => context.go('/'),
          tooltip: 'Về trang chủ',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showSubscriptionHistory,
            tooltip: 'Lịch sử đăng ký',
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
                    _buildCurrentSubscriptionCard(),
                  const SizedBox(height: 24),

                  // Subscription Plans
                  Text(
                    'Chọn gói đăng ký',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

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
                  _buildBenefitsCard(),
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
                      child: Text(
                        _getSubscribeButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms
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

  Widget _buildCurrentSubscriptionCard() {
    return Container(
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
                _currentSubscription!.plan == 'PREMIUM'
                    ? 'Premium Active'
                    : '${_currentSubscription!.plan} Active',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gói ${_currentSubscription!.plan} • Hết hạn ${_formatDate(_currentSubscription!.endedAt)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lợi ích khi nâng cấp',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.family_restroom,
            title: 'Quản lý hồ sơ gia đình',
            description: 'Theo dõi thông tin sức khỏe của từng thành viên',
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            icon: Icons.health_and_safety,
            title: 'Cảnh báo dinh dưỡng thông minh',
            description: 'Nhận cảnh báo về dị ứng và tình trạng sức khỏe',
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            icon: Icons.analytics,
            title: 'Phân tích sức khỏe chi tiết',
            description: 'Báo cáo dinh dưỡng và khuyến nghị cá nhân hóa',
          ),
        ],
      ),
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

  Future<void> _showSubscriptionHistory() async {
    final token = _getToken();
    if (token == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHistorySheet(token),
    );
  }

  Widget _buildHistorySheet(String token) {
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text('Chưa có lịch sử giao dịch'),
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
    final dio = Dio();
    final premiumService = PremiumService(dio);
    final premiumRepo = PremiumRepository(premiumService);
    return await premiumRepo.getUserTransactions(token);
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

// Local model for UI compatibility (implements ISubscriptionPlan interface)
class SubscriptionPlanUI implements ISubscriptionPlan {
  @override
  final String id;
  @override
  final String name;
  @override
  final int price;
  @override
  final String duration;
  @override
  final List<String> features;
  @override
  final bool isPopular;

  SubscriptionPlanUI({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    required this.isPopular,
  });
}
