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
      return handler.next(err);
    }

    // Nếu đang refresh, thêm request vào queue
    if (_isRefreshing) {
      return _addToQueue(err, handler);
    }

    // Bắt đầu refresh
    _isRefreshing = true;

    try {
      final success = await authService.refreshAccessToken();
      if (!success) {
        await _handleRefreshFailure();
        return handler.next(err);
      }
    } on DioException {
      return handler.next(err);
    } catch (e) {
      return handler.next(err);
    }

    try {
      final newToken = authService.accessToken;
      if (newToken == null) {
        await _handleRefreshFailure();
        return handler.next(err);
      }

      _processQueue(newToken);

      final response = await _retryRequest(err.requestOptions, newToken);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } catch (e) {
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
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

  void _processQueue(String? newToken) {
    for (final callback in _requestQueue) {
      callback(newToken);
    }

    _requestQueue.clear();
  }

  Future<void> _handleRefreshFailure() async {
    _requestQueue.clear();

    try {
      await authService.logout();
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isAuthEndpoint = options.path.contains('/auth/');
    if (!isAuthEndpoint) {
      final token = authService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }
}
