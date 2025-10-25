import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
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

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  String _selectedPlan = 'PREMIUM';
  bool _isLoading = true;
  String? _errorMessage;
  List<SubscriptionPlanModel> _apiPlans = [];
  SubscriptionModel? _currentSubscription;
  String? _pendingTransactionId;
  SubscriptionPlanModel? _pendingPlan;
  bool _isCheckingPayment = false; // Prevent simultaneous checks
  String? _lastProcessedDeepLink; // Track processed deep links
  bool _hasCheckedInitialLink = false; // Track if initial link was checked
  bool _didHandlePaymentResult =
      false; // Track if payment result already handled

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  Timer? _pollTimer; // Timer for polling instead of recursive Future.delayed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLinks = AppLinks();
    _listenDeepLinks();
    _loadData();
  }

  @override
  void dispose() {
    _pollTimer?.cancel(); // Cancel polling timer
    _linkSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // Stop polling when app goes to background
      _pollTimer?.cancel();
      print('🔴 App PAUSED - polling timer cancelled');
    } else if (state == AppLifecycleState.resumed) {
      print(
        '🟢 App RESUMED - checking payment: $_isCheckingPayment, pending: $_pendingTransactionId',
      );

      // DISABLE LIFECYCLE PAYMENT CHECK - Deep link handler will handle it
      // This prevents double checking which causes black screen
      // Lifecycle handler is only for stopping polling

      /* COMMENTED OUT - causing double check issue
      // Only check if there's still a pending transaction
      // (deep link handler will have cleared it if it ran)
      if (_pendingTransactionId != null && _pendingPlan != null) {
        final txnId = _pendingTransactionId;
        final plan = _pendingPlan;
        
        // Clear immediately to prevent re-entry
        setState(() {
          _pendingTransactionId = null;
          _pendingPlan = null;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && txnId != null && plan != null) {
            // Close ALL dialogs first
            while (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            
            // Then check with a fresh dialog (only if not already checking)
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !_isCheckingPayment) {
                _checkPaymentStatus(txnId, plan);
              }
            });
          }
        });
      }
      */
    }
  }

  void _listenDeepLinks() {
    // Listen for incoming deep links (app in background/foreground)
    _linkSub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Check for initial deep link (cold start) - ONLY ONCE per widget lifecycle
    // AND only if there's a pending transaction (user just made payment)
    if (!_hasCheckedInitialLink) {
      _hasCheckedInitialLink = true;
      _appLinks.getInitialLink().then((Uri? uri) {
        if (uri != null) {
          print('📱 Initial deep link found: ${uri.toString()}');

          // Extract transaction ID from link
          final txnRef = uri.queryParameters['vnp_TxnRef'];

          // ONLY process if:
          // 1. There's a pending transaction (user just initiated payment)
          // 2. OR the transaction in link matches pending transaction
          if (_pendingTransactionId != null &&
              txnRef == _pendingTransactionId) {
            print('✅ Initial link matches pending transaction - processing');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _handleIncomingLink(uri);
              }
            });
          } else {
            print(
              '⚠️ Initial link is STALE (no pending transaction) - IGNORING',
            );
            print('   Pending: $_pendingTransactionId, Link txn: $txnRef');
          }
        } else {
          print('📱 No initial deep link (normal app launch)');
        }
      });
    }
  }

  void _handleIncomingLink(Uri uri) async {
    print('🔗 DEEP LINK RECEIVED: ${uri.toString()}');

    // Only handle bepviet://vnpay
    if (uri.scheme == 'bepviet' && uri.host == 'vnpay') {
      final code = uri.queryParameters['vnp_ResponseCode'];
      final txnRef = uri.queryParameters['vnp_TxnRef']; // orderId

      print(
        '🔗 VNPay deep link - code=$code, txnRef=$txnRef, isChecking=$_isCheckingPayment',
      );

      // CRITICAL: Check if already handled
      if (_didHandlePaymentResult || _isCheckingPayment) {
        print(
          '⚠️ ALREADY HANDLED - SKIPPING (handled=$_didHandlePaymentResult, checking=$_isCheckingPayment)',
        );
        return;
      }

      // CRITICAL: Check if this deep link was already processed
      if (_lastProcessedDeepLink == txnRef) {
        print('⚠️ DEEP LINK ALREADY PROCESSED - SKIPPING (txnRef=$txnRef)');
        return;
      }

      // Mark this deep link as processed
      _lastProcessedDeepLink = txnRef;
      print('✅ Marked deep link as processed: $txnRef');

      // Stop polling timer and mark as handled
      _pollTimer?.cancel();
      _didHandlePaymentResult = true; // Prevent duplicate checks
      print('✅ Cancelled polling timer and marked result as handled');

      // Save plan before clearing (to prevent lifecycle handler from interfering)
      final plan =
          _pendingPlan ??
          (_apiPlans.isNotEmpty
              ? _apiPlans.firstWhere(
                  (p) => p.id == _selectedPlan,
                  orElse: () => _apiPlans.first,
                )
              : null);

      print('🔗 Found plan: ${plan?.name}');

      // Clear pending IMMEDIATELY to prevent lifecycle handler from running
      if (mounted) {
        setState(() {
          _pendingTransactionId = null;
          _pendingPlan = null;
        });
        print('🔗 Pending transaction cleared');
      }

      if (mounted) {
        // Close all dialogs first
        int dialogsClosed = 0;
        while (Navigator.canPop(context)) {
          Navigator.of(context).pop();
          dialogsClosed++;
        }
        print('🔗 Closed $dialogsClosed dialogs');
      }

      // Small delay to ensure dialogs are closed
      await Future.delayed(const Duration(milliseconds: 300));

      // IMPORTANT: Backend IPN already verified payment and activated subscription
      // We trust VNPay response code and just reload data
      if (mounted) {
        if (code == '00') {
          print('✅ Payment successful - reloading subscription data');

          // Reload data to get updated subscription
          await _loadData();

          // Show success message
          if (mounted) {
            final planName = plan?.name ?? 'Premium';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Đã đăng ký thành công gói $planName!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          print('❌ Payment failed (code=$code)');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thanh toán không thành công (Mã lỗi: $code)'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        // Reset flags for next payment attempt
        _didHandlePaymentResult = false;
        _isCheckingPayment = false;
        _lastProcessedDeepLink = null;
        print('🔄 Reset flags for next payment');
      }
    }
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
    }

    // Check if plan exists before accessing (prevents "Bad state: No element")
    final hasPlan = _plans.any((p) => p.id == _selectedPlan);
    if (!hasPlan) {
      return 'Đang tải...';
    }

    final plan = _plans.firstWhere((p) => p.id == _selectedPlan);
    return 'Đăng ký ${plan.name} - ${plan.price.toStringAsFixed(0)}đ/${plan.duration.toLowerCase()}';
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

    // Show payment method selection dialog
    _showPaymentMethodDialog(selectedPlanData);
  }

  Future<void> _showPaymentMethodDialog(SubscriptionPlanModel plan) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            const Text('Chọn phương thức thanh toán'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gói: ${plan.name}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${plan.price.toStringAsFixed(0)}đ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            // VNPay button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _payWithVNPay(plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet, size: 24),
              label: const Text(
                'Thanh toán VNPay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Direct payment (test mode)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _payDirectly(plan);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Thanh toán trực tiếp (Test)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payWithVNPay(SubscriptionPlanModel plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final token = context.read<AuthCubit>().authRepository.accessToken;
        if (token != null) {
          // Determine duration months
          int durationMonths = 1;
          if (plan.duration.toLowerCase().contains('năm') ||
              plan.duration.toLowerCase().contains('year')) {
            durationMonths = 12;
          }

          // Create VNPay payment
          final dio = Dio();
          dio.options.baseUrl = AppConfig.ngrokBaseUrl;
          dio.options.headers['ngrok-skip-browser-warning'] = 'true';

          final premiumService = PremiumService(dio);
          final paymentData = await premiumService.createVNPayPayment(
            token,
            planId: plan.id,
            durationMonths: durationMonths,
          );

          final paymentUrl = paymentData['payment_url'] as String;
          final transactionId = paymentData['transaction_id'] as String;

          // Save pending transaction for auto-check when app resumes
          setState(() {
            _pendingTransactionId = transactionId;
            _pendingPlan = plan;
            _isLoading = false;
          });

          // Open VNPay URL in browser
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            // Show auto-check dialog with polling
            if (mounted) {
              _showPaymentPendingDialogWithAutoCheck(transactionId, plan);
            }
          } else {
            throw Exception('Không thể mở trình duyệt');
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
            content: Text('Lỗi tạo thanh toán: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // Poll payment status once (used by Timer.periodic)
  Future<void> _pollOnce(
    String transactionId,
    SubscriptionPlanModel plan,
    bool Function() isDialogClosed,
  ) async {
    if (_isCheckingPayment || _didHandlePaymentResult || isDialogClosed()) {
      return;
    }

    try {
      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token == null) return;

      final premiumService = PremiumService(
        Dio()
          ..options.baseUrl = AppConfig.ngrokBaseUrl
          ..options.headers['ngrok-skip-browser-warning'] = 'true',
      );

      final statusData = await premiumService.checkPaymentStatus(
        token,
        transactionId,
      );
      final status = statusData['status'] as String;

      if (status == 'COMPLETED') {
        _didHandlePaymentResult = true;
        _pollTimer?.cancel();

        // Close pending dialog
        if (mounted && Navigator.canPop(context) && !isDialogClosed()) {
          Navigator.pop(context);
        }

        // Reload data
        await _loadData();

        // Show success
        if (mounted) {
          _showSuccess(plan);
        }
      } else if (status == 'FAILED') {
        _didHandlePaymentResult = true;
        _pollTimer?.cancel();

        // Close pending dialog
        if (mounted && Navigator.canPop(context) && !isDialogClosed()) {
          Navigator.pop(context);
        }

        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán thất bại. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Reset flags for next attempt
        _didHandlePaymentResult = false;
        _isCheckingPayment = false;
        _lastProcessedDeepLink = null;
      }
      // If status is PENDING, do nothing and let timer continue
    } catch (e) {
      print('⚠️ Poll error: $e');
      // Continue polling on error
    }
  }

  // Show success snackbar
  void _showSuccess(SubscriptionPlanModel plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Đã đăng ký thành công gói ${plan.name}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Reset flags after showing success
    _didHandlePaymentResult = false;
    _isCheckingPayment = false;
    _lastProcessedDeepLink = null;
  }

  void _showPaymentPendingDialogWithAutoCheck(
    String transactionId,
    SubscriptionPlanModel plan,
  ) {
    bool dialogClosed = false;
    int pollCount = 0;
    const maxPolls = 30; // Poll for ~60 seconds (every 2 seconds)

    // Cancel any existing timer
    _pollTimer?.cancel();

    // Start polling with Timer.periodic
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (dialogClosed || _didHandlePaymentResult || pollCount >= maxPolls) {
        _pollTimer?.cancel();
        return;
      }

      pollCount++;
      await _pollOnce(transactionId, plan, () => dialogClosed);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          dialogClosed = true;
          _pollTimer?.cancel();
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
                dialogClosed = true;
                _pollTimer?.cancel();
                Navigator.pop(context);
                setState(() => _isLoading = false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                dialogClosed = true;
                _pollTimer?.cancel();
                Navigator.pop(context);
                await _checkPaymentStatus(transactionId, plan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Kiểm tra ngay'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPaymentStatus(
    String transactionId,
    SubscriptionPlanModel? plan, // Make nullable
  ) async {
    print(
      '💳 _checkPaymentStatus CALLED - txn=$transactionId, mounted=$mounted, isChecking=$_isCheckingPayment',
    );

    if (!mounted || _isCheckingPayment) {
      print(
        '⚠️ _checkPaymentStatus SKIPPED - mounted=$mounted, isChecking=$_isCheckingPayment',
      );
      return;
    }

    // Set flag to prevent simultaneous checks
    _isCheckingPayment = true;
    print('💳 Set _isCheckingPayment = true');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismiss if stuck
      builder: (context) => WillPopScope(
        onWillPop: () async {
          // Allow back button to close if stuck
          _isCheckingPayment = false;
          _lastProcessedDeepLink = null;
          return true;
        },
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang kiểm tra thanh toán...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final token = context.read<AuthCubit>().authRepository.accessToken;
        if (token != null) {
          final dio = Dio();
          dio.options.baseUrl = AppConfig.ngrokBaseUrl;
          dio.options.headers['ngrok-skip-browser-warning'] = 'true';
          dio.options.connectTimeout = const Duration(seconds: 10);
          dio.options.receiveTimeout = const Duration(seconds: 10);

          final premiumService = PremiumService(dio);

          // Add timeout wrapper
          final response = await premiumService
              .checkPaymentStatus(token, transactionId)
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  throw Exception('Timeout checking payment status');
                },
              );

          print('💳 API Response: $response');

          // premium_service already unwraps { success, data } and returns only data part
          final status = response['status'] as String;

          print('💳 Payment status from DB: $status');
          print('💳 mounted=$mounted');

          // Clear flags first (before checking mounted)
          _isCheckingPayment = false;
          _lastProcessedDeepLink = null;

          if (mounted) {
            // Close loading dialog
            try {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            } catch (e) {
              print('⚠️ Error closing dialog: $e');
            }

            if (status == 'COMPLETED') {
              // Reload data first
              await _loadData();

              // Then show success with celebration
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
                      // Success icon with animation
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
                      // Title
                      const Text(
                        '🎉 Chúc mừng!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Message
                      Text(
                        plan != null
                            ? 'Bạn đã đăng ký thành công gói ${plan.name}!'
                            : 'Bạn đã đăng ký thành công gói Premium!',
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
                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Clear processed deep link to allow future payments
                            _lastProcessedDeepLink = null;
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
            } else if (status == 'PENDING') {
              // Still pending - allow retry
              _lastProcessedDeepLink = null;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Giao dịch đang chờ xử lý. Vui lòng thử lại sau.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            } else {
              // Failed - allow retry
              _lastProcessedDeepLink = null;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thanh toán thất bại hoặc đã hủy.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          } else {
            // Token is null
            if (mounted) {
              Navigator.pop(context);
              _isCheckingPayment = false;
              _lastProcessedDeepLink = null; // Allow retry after re-login
              print('💳 Set _isCheckingPayment = false (TOKEN NULL)');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Not authenticated
          if (mounted) {
            Navigator.pop(context);
            _isCheckingPayment = false;
            _lastProcessedDeepLink = null; // Allow retry after login
            print('💳 Set _isCheckingPayment = false (NOT AUTHENTICATED)');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng đăng nhập để kiểm tra thanh toán.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if still open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Clear checking flag
        _isCheckingPayment = false;
        _lastProcessedDeepLink = null; // Allow retry
        print('💳 Set _isCheckingPayment = false (ERROR), error=$e');

        // Show error with more details
        final errorMsg = e.toString().contains('Timeout')
            ? 'Kiểm tra thanh toán quá lâu. Vui lòng kiểm tra lại sau.'
            : 'Không thể kiểm tra thanh toán. Vui lòng thử lại.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Đóng',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _payDirectly(SubscriptionPlanModel plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final token = context.read<AuthCubit>().authRepository.accessToken;
        if (token != null) {
          // Determine duration months
          int durationMonths = 1;
          if (plan.duration.toLowerCase().contains('năm') ||
              plan.duration.toLowerCase().contains('year')) {
            durationMonths = 12;
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
                  'Bạn đã đăng ký thành công gói ${plan.name}. '
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
