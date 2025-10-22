import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/premium_simple_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/premium_dashboard_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/data/sources/remote/subscription_service.dart';

/// Premium Gate - Kiểm tra trạng thái Premium từ DB và hiển thị trang phù hợp
class PremiumGatePage extends StatefulWidget {
  const PremiumGatePage({super.key});

  @override
  State<PremiumGatePage> createState() => _PremiumGatePageState();
}

class _PremiumGatePageState extends State<PremiumGatePage> {
  bool _isPremium = false;
  bool _isLoading = true;
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(Dio());
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isPremium = false;
          _isLoading = false;
        });
        return;
      }

      final token = context.read<AuthCubit>().authRepository.accessToken;
      if (token == null) {
        setState(() {
          _isPremium = false;
          _isLoading = false;
        });
        return;
      }

      // Gọi API kiểm tra subscription
      final subscription = await _subscriptionService.getUserSubscription(token);
      
      setState(() {
        _isPremium = subscription?.isPremium ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking premium status: $e');
      setState(() {
        _isPremium = false;
        _isLoading = false;
      });
    }
  }

  // Callback khi nâng cấp Premium thành công
  void _onPremiumUpgraded() {
    setState(() {
      _isPremium = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Nếu chưa Premium → hiển thị trang đăng ký
    if (!_isPremium) {
      return PremiumSimplePage(
        onUpgradeSuccess: _onPremiumUpgraded,
      );
    }

    // Nếu đã Premium → hiển thị Dashboard
    return const PremiumDashboardPage();
  }
}
