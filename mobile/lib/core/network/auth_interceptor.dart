import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

/// Interceptor tự động refresh token khi gặp lỗi 401 Unauthorized
///
/// Flow:
/// 1. API call bị lỗi 401
/// 2. Interceptor detect và gọi refresh token
/// 3. Lưu access token mới
/// 4. Retry request ban đầu với token mới
/// 5. Nếu refresh thất bại → logout user
class AuthInterceptor extends Interceptor {
  final AuthService authService;
  final Dio dio;

  // Lock để tránh nhiều requests cùng lúc gọi refresh
  bool _isRefreshing = false;
  final List<void Function(String?)> _requestQueue = [];

  AuthInterceptor({required this.authService, required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Chỉ xử lý lỗi 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Bỏ qua nếu là endpoint auth (tránh infinite loop)
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');
    if (isAuthEndpoint) {
      print('⚠️ Auth endpoint failed, skipping refresh');
      return handler.next(err);
    }

    print(
      '🔄 [AuthInterceptor] Detected 401 error, attempting token refresh...',
    );

    // Nếu đang refresh, thêm request vào queue
    if (_isRefreshing) {
      print('⏳ [AuthInterceptor] Already refreshing, queuing request...');
      return _addToQueue(err, handler);
    }

    // Bắt đầu refresh
    _isRefreshing = true;

    try {
      // Gọi refresh token
      final success = await authService.refreshAccessToken();

      if (success) {
        print('✅ [AuthInterceptor] Token refreshed successfully');

        // Lấy token mới
        final newToken = authService.accessToken;

        if (newToken != null) {
          // Retry request ban đầu với token mới
          final response = await _retryRequest(err.requestOptions, newToken);

          // Xử lý queue - retry tất cả requests đang chờ
          _processQueue(newToken);

          return handler.resolve(response);
        } else {
          print('❌ [AuthInterceptor] New token is null');
          await _handleRefreshFailure();
          return handler.next(err);
        }
      } else {
        print('❌ [AuthInterceptor] Refresh token failed');
        await _handleRefreshFailure();
        return handler.next(err);
      }
    } catch (e) {
      print('❌ [AuthInterceptor] Error during refresh: $e');
      await _handleRefreshFailure();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retry request với token mới
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    print('🔄 [AuthInterceptor] Retrying request: ${requestOptions.path}');

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $newToken'},
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      extra: requestOptions.extra,
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Thêm request vào queue khi đang refresh
  void _addToQueue(DioException err, ErrorInterceptorHandler handler) {
    _requestQueue.add((newToken) async {
      if (newToken != null) {
        try {
          final response = await _retryRequest(err.requestOptions, newToken);
          handler.resolve(response);
        } catch (e) {
          handler.next(err);
        }
      } else {
        handler.next(err);
      }
    });
  }

  /// Xử lý queue - retry tất cả requests với token mới
  void _processQueue(String? newToken) {
    print(
      '📤 [AuthInterceptor] Processing ${_requestQueue.length} queued requests',
    );

    for (final callback in _requestQueue) {
      callback(newToken);
    }

    _requestQueue.clear();
  }

  /// Xử lý khi refresh thất bại - logout user
  Future<void> _handleRefreshFailure() async {
    print('🚪 [AuthInterceptor] Refresh failed, logging out user...');

    // Clear queue
    _requestQueue.clear();

    // Logout user
    try {
      await authService.logout();
      print('✅ [AuthInterceptor] User logged out');
    } catch (e) {
      print('❌ [AuthInterceptor] Error during logout: $e');
    }

    // TODO: Navigate to login page
    // Bạn có thể thêm navigation ở đây nếu cần
    // navigatorKey.currentState?.pushReplacementNamed('/login');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request (optional)
    // print('🚀 [Request] ${options.method} ${options.path}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response (optional)
    // print('✅ [Response] ${response.statusCode} ${response.requestOptions.path}');
    return handler.next(response);
  }
}
