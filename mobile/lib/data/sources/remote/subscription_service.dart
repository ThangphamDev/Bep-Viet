import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class SubscriptionService {
  final Dio _dio;
  final String baseUrl;

  SubscriptionService(this._dio, {String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.ngrokBaseUrl {
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  /// Lấy danh sách gói Premium (không cần token)
  Future<List<SubscriptionPlan>> getAllPlans() async {
    try {
      final response = await _dio.get('/api/subscriptions/plans');
      
      if (response.data['success'] == true) {
        final List plans = response.data['data'] as List;
        return plans.map((e) => SubscriptionPlan.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting plans: $e');
      throw Exception('Không thể tải danh sách gói Premium');
    }
  }

  /// Lấy subscription hiện tại của user
  Future<UserSubscription?> getUserSubscription(String token) async {
    try {
      final response = await _dio.get(
        '/api/subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return UserSubscription.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error getting user subscription: $e');
      return null;
    }
  }

  /// Đăng ký gói Premium
  Future<bool> subscribeToPlan(String token, String planId) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions/subscribe',
        data: {'planId': planId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['success'] == true;
    } catch (e) {
      print('Error subscribing to plan: $e');
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Đăng ký thất bại');
      }
      throw Exception('Đăng ký thất bại');
    }
  }

  /// Hủy subscription
  Future<bool> cancelSubscription(String token) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data['success'] == true;
    } catch (e) {
      print('Error cancelling subscription: $e');
      throw Exception('Hủy gói thất bại');
    }
  }
}

// Models
class SubscriptionPlan {
  final String id;
  final String name;
  final String nameEn;
  final double price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final int displayOrder;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.price,
    required this.duration,
    required this.features,
    required this.isPopular,
    required this.displayOrder,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    // Parse features from JSON array
    List<String> featureList = [];
    if (json['features'] != null) {
      if (json['features'] is String) {
        // If it's a JSON string, decode it
        try {
          final decoded = jsonDecode(json['features']);
          featureList = List<String>.from(decoded);
        } catch (e) {
          print('Error parsing features: $e');
        }
      } else if (json['features'] is List) {
        featureList = List<String>.from(json['features']);
      }
    }

    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      price: double.parse(json['price'].toString()),
      duration: json['duration'] as String,
      features: featureList,
      isPopular: json['is_popular'] == 1,
      displayOrder: int.parse(json['display_order'].toString()),
    );
  }

  // Helper để lấy số tháng từ duration string
  int get durationInMonths {
    final match = RegExp(r'^(\d+)_month$').firstMatch(duration);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 1; // Fallback
  }
}

class UserSubscription {
  final bool isPremium;
  final SubscriptionData? data;

  UserSubscription({
    required this.isPremium,
    this.data,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      isPremium: json['isPremium'] == true,
      data: json['data'] != null
          ? SubscriptionData.fromJson(json['data'])
          : null,
    );
  }
}

class SubscriptionData {
  final String id;
  final String planId;
  final String planName;
  final double planPrice;
  final int planDuration;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isActive;

  SubscriptionData({
    required this.id,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.planDuration,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.isActive,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      planPrice: double.parse(json['planPrice'].toString()),
      planDuration: int.parse(json['planDuration'].toString()),
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      isActive: json['isActive'] == true,
    );
  }
}

