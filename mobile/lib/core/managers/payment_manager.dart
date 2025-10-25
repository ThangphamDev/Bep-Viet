import 'dart:async';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/sources/remote/premium_service.dart';

/// Payment state machine
enum PaymentState {
  idle, // No payment in progress
  creating, // Creating payment URL
  waiting, // Waiting for user to complete payment (browser open)
  processing, // Processing payment result (deep link received)
  completed, // Payment completed successfully
  failed, // Payment failed
}

/// Payment result from deep link
class PaymentResult {
  final String transactionId;
  final String responseCode;
  final bool isSuccess;
  final Map<String, String> allParams;

  PaymentResult({
    required this.transactionId,
    required this.responseCode,
    required this.allParams,
  }) : isSuccess = responseCode == '00';

  factory PaymentResult.fromUri(Uri uri) {
    final params = uri.queryParameters;

    // Support both old (vnp_*) and new (simplified) param names
    final transactionId = params['transactionId'] ?? params['vnp_TxnRef'] ?? '';
    final responseCode =
        params['responseCode'] ?? params['vnp_ResponseCode'] ?? '99';

    return PaymentResult(
      transactionId: transactionId,
      responseCode: responseCode,
      allParams: params,
    );
  }
}

/// Callback for payment status updates
typedef PaymentStatusCallback =
    void Function(PaymentState state, PaymentResult? result);

/// Manages VNPay payment flow with proper state management
class PaymentManager {
  // Dependencies
  late final PremiumService _premiumService;

  // State
  PaymentState _state = PaymentState.idle;
  String? _pendingTransactionId;
  Timer? _pollingTimer;
  Completer<PaymentResult>? _pollingCompleter;

  // Callbacks
  final List<PaymentStatusCallback> _statusCallbacks = [];

  // Configuration
  final int maxPollingAttempts;
  final Duration pollingInterval;
  final Duration retryDelay;
  final int maxRetryAttempts;

  PaymentManager({
    this.maxPollingAttempts = 30, // 30 * 2s = 60 seconds
    this.pollingInterval = const Duration(seconds: 2),
    this.retryDelay = const Duration(seconds: 2),
    this.maxRetryAttempts = 3,
  }) {
    _initializeService();
  }

  void _initializeService() {
    final dio = Dio();
    dio.options.baseUrl = AppConfig.ngrokBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers['ngrok-skip-browser-warning'] = 'true';
    _premiumService = PremiumService(dio);
  }

  // Getters
  PaymentState get state => _state;
  String? get pendingTransactionId => _pendingTransactionId;
  bool get isProcessing =>
      _state != PaymentState.idle &&
      _state != PaymentState.completed &&
      _state != PaymentState.failed;

  /// Register callback for state changes
  void addStatusListener(PaymentStatusCallback callback) {
    _statusCallbacks.add(callback);
  }

  /// Remove callback
  void removeStatusListener(PaymentStatusCallback callback) {
    _statusCallbacks.remove(callback);
  }

  /// Notify all listeners
  void _notifyListeners(PaymentState newState, [PaymentResult? result]) {
    _state = newState;
    for (final callback in _statusCallbacks) {
      callback(newState, result);
    }
  }

  /// Create VNPay payment and return payment URL
  Future<String> createPayment({
    required String token,
    required SubscriptionPlanModel plan,
    required int durationMonths,
    String? bankCode,
  }) async {
    if (isProcessing) {
      throw Exception('Payment already in progress');
    }

    try {
      _notifyListeners(PaymentState.creating);

      final paymentData = await _premiumService.createVNPayPayment(
        token,
        planId: plan.id,
        durationMonths: durationMonths,
        bankCode: bankCode,
      );

      _pendingTransactionId = paymentData['transaction_id'] as String;
      _notifyListeners(PaymentState.waiting);

      return paymentData['payment_url'] as String;
    } catch (e) {
      _notifyListeners(PaymentState.failed);
      rethrow;
    }
  }

  /// Start polling for payment status
  /// Returns a Future that completes when payment is done (success or fail)
  Future<PaymentResult?> startPolling(String token) {
    if (_pendingTransactionId == null) {
      throw Exception('No pending transaction');
    }

    // Cancel existing polling if any
    _stopPolling();

    // Create new completer
    _pollingCompleter = Completer<PaymentResult>();

    int attemptCount = 0;

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      attemptCount++;

      try {
        final statusData = await _premiumService.checkPaymentStatus(
          token,
          _pendingTransactionId!,
        );

        final status = statusData['status'] as String;

        if (status == 'COMPLETED') {
          final result = PaymentResult(
            transactionId: _pendingTransactionId!,
            responseCode: '00',
            allParams: {'status': 'COMPLETED'},
          );
          _completePayment(result);
        } else if (status == 'FAILED') {
          final result = PaymentResult(
            transactionId: _pendingTransactionId!,
            responseCode: '99',
            allParams: {'status': 'FAILED'},
          );
          _completePayment(result);
        } else if (attemptCount >= maxPollingAttempts) {
          // Timeout - stop polling but don't mark as failed
          // User can still check manually via deep link
          timer.cancel();
        }
      } catch (e) {
        // Continue polling on error
      }
    });

    return _pollingCompleter!.future;
  }

  /// Handle deep link payment result
  Future<void> handleDeepLink(Uri uri, String token) async {
    if (uri.scheme != 'bepviet' || uri.host != 'vnpay') {
      return;
    }

    // Parse result
    final result = PaymentResult.fromUri(uri);

    // Check if this is for our pending transaction
    if (_pendingTransactionId != null &&
        result.transactionId == _pendingTransactionId) {
      // Stop polling immediately
      _stopPolling();

      // Process result
      _notifyListeners(PaymentState.processing, result);

      if (result.isSuccess) {
        // Success - wait for IPN with retry mechanism
        await _waitForIPNWithRetry(token, result.transactionId);
        _completePayment(result);
      } else {
        // Failed
        _completePayment(result);
      }
    }
  }

  /// Wait for IPN to process with retry mechanism
  Future<void> _waitForIPNWithRetry(String token, String transactionId) async {
    for (int attempt = 0; attempt < maxRetryAttempts; attempt++) {
      try {
        final statusData = await _premiumService.checkPaymentStatus(
          token,
          transactionId,
        );

        final status = statusData['status'] as String;

        if (status == 'COMPLETED') {
          return; // Success!
        }

        // Still pending, wait and retry
        if (attempt < maxRetryAttempts - 1) {
          final delay = retryDelay * (attempt + 1); // Exponential backoff
          await Future.delayed(delay);
        }
      } catch (e) {
        if (attempt < maxRetryAttempts - 1) {
          await Future.delayed(retryDelay * (attempt + 1));
        }
      }
    }
  }

  /// Complete payment and cleanup
  void _completePayment(PaymentResult result) {
    _stopPolling();

    final newState = result.isSuccess
        ? PaymentState.completed
        : PaymentState.failed;
    _notifyListeners(newState, result);

    // Complete the polling future if it exists
    if (_pollingCompleter != null && !_pollingCompleter!.isCompleted) {
      _pollingCompleter!.complete(result);
    }
  }

  /// Stop polling timer
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Cancel current payment
  void cancelPayment() {
    _stopPolling();
    _pendingTransactionId = null;
    _notifyListeners(PaymentState.idle);
  }

  /// Reset to idle state (call after showing success/error to user)
  void reset() {
    _stopPolling();
    _pendingTransactionId = null;
    _pollingCompleter = null;
    _notifyListeners(PaymentState.idle);
  }

  /// Dispose resources
  void dispose() {
    _stopPolling();
    _statusCallbacks.clear();
    _pollingCompleter = null;
  }
}
