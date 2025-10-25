import 'package:dio/dio.dart';
import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';
import 'package:bepviet_mobile/data/models/analytics_model.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';

class PremiumService {
  final Dio _dio;
  final String baseUrl;

  PremiumService(this._dio, {String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.ngrokBaseUrl {
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  // Subscription APIs
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans(String token) async {
    try {
      final response = await _dio.get(
        '/api/subscriptions/plans',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is List) {
          return (map['data'] as List)
              .map(
                (e) =>
                    SubscriptionPlanModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get subscription plans: $e');
    }
  }

  Future<SubscriptionModel?> getUserSubscription(String token) async {
    try {
      final response = await _dio.get(
        '/api/subscriptions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return SubscriptionModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      return null;
    } catch (e) {
      // Handle 404 or no subscription found gracefully
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get user subscription: $e');
    }
  }

  Future<SubscriptionModel> createSubscription(
    String token,
    CreateSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/subscriptions',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return SubscriptionModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<void> cancelSubscription(String token, String subscriptionId) async {
    try {
      await _dio.put(
        '/api/subscriptions/$subscriptionId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<List<SubscriptionTransactionModel>> getUserTransactions(
    String token,
  ) async {
    try {
      final response = await _dio.get(
        '/api/subscriptions/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is List) {
          return (map['data'] as List)
              .map(
                (e) => SubscriptionTransactionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // VNPay Payment APIs
  Future<Map<String, dynamic>> createVNPayPayment(
    String token, {
    required String planId,
    required int durationMonths,
    String? bankCode,
  }) async {
    try {
      final response = await _dio.post(
        '/api/payments/vnpay/create',
        data: {
          'plan_id': planId,
          'duration_months': durationMonths,
          if (bankCode != null) 'bank_code': bankCode,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return map['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create VNPay payment: $e');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(
    String token,
    String transactionId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/payments/vnpay/status/$transactionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return map['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }

  // Family APIs
  Future<List<FamilyProfileModel>> getUserFamilyProfiles(String token) async {
    try {
      final response = await _dio.get(
        '/api/family/profiles',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is List) {
          return (map['data'] as List)
              .map(
                (e) => FamilyProfileModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get family profiles: $e');
    }
  }

  Future<FamilyProfileModel> createFamilyProfile(
    String token,
    CreateFamilyProfileRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/family/profiles',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return FamilyProfileModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to create family profile: $e');
    }
  }

  Future<FamilyMemberModel> addFamilyMember(
    String token,
    String familyId,
    AddFamilyMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/family/profiles/$familyId/members',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return FamilyMemberModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to add family member: $e');
    }
  }

  Future<FamilyMemberModel> updateFamilyMember(
    String token,
    String memberId,
    UpdateFamilyMemberRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/family/members/$memberId',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] is Map) {
          return FamilyMemberModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to update family member: $e');
    }
  }

  Future<void> deleteFamilyMember(String token, String memberId) async {
    try {
      final response = await _dio.delete(
        '/api/family/members/$memberId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] != true) {
          throw Exception(map['message'] ?? 'Failed to delete family member');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete family member: $e');
    }
  }

  // Analytics APIs
  Future<UserAnalyticsModel> getUserAnalytics(String token) async {
    try {
      final response = await _dio.get(
        '/api/analytics/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return UserAnalyticsModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to get user analytics: $e');
    }
  }

  Future<SystemAnalyticsModel> getSystemAnalytics(String token) async {
    try {
      final response = await _dio.get(
        '/api/analytics/system',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['success'] == true && map['data'] != null) {
          return SystemAnalyticsModel.fromJson(
            map['data'] as Map<String, dynamic>,
          );
        }
      }
      throw Exception('Invalid API response format');
    } catch (e) {
      throw Exception('Failed to get system analytics: $e');
    }
  }
}
