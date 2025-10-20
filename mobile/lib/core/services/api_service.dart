import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bepviet_mobile/core/config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.ngrokBaseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Generic HTTP methods
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api$endpoint',
      ).replace(queryParameters: queryParams);

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  // Recipes API
  Future<List<Map<String, dynamic>>> getRecipes({
    String? mealType,
    String? difficulty,
    String? baseRegion,
    int? maxTime,
    String? search,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (mealType != null) queryParams['meal_type'] = mealType;
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (baseRegion != null) queryParams['base_region'] = baseRegion;
    if (maxTime != null) queryParams['max_time'] = maxTime.toString();
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest(
      'GET',
      '/recipes',
      queryParams: queryParams,
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getRecipeById(String id) async {
    final response = await _makeRequest('GET', '/recipes/$id');
    return response['data'];
  }

  Future<List<Map<String, dynamic>>> getRecipeIngredients(String id) async {
    final response = await _makeRequest('GET', '/recipes/$id/ingredients');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getRecipeVariants(String id) async {
    final response = await _makeRequest('GET', '/recipes/$id/variants');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  // Family API
  Future<List<Map<String, dynamic>>> getFamilyProfiles(String userId) async {
    final response = await _makeRequest(
      'GET',
      '/family',
      queryParams: {'userId': userId},
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createFamilyProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/family',
      queryParams: {'userId': userId},
      body: profileData,
    );
    return response['data'];
  }

  Future<List<Map<String, dynamic>>> getFamilyMembers(
    String familyId,
    String userId,
  ) async {
    final response = await _makeRequest(
      'GET',
      '/family/$familyId/members',
      queryParams: {'userId': userId},
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> addFamilyMember(
    String userId,
    Map<String, dynamic> memberData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/family/members',
      queryParams: {'userId': userId},
      body: memberData,
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> updateFamilyMember(
    String memberId,
    String userId,
    Map<String, dynamic> memberData,
  ) async {
    final response = await _makeRequest(
      'PATCH',
      '/family/members/$memberId',
      queryParams: {'userId': userId},
      body: memberData,
    );
    return response['data'];
  }

  Future<void> deleteFamilyMember(String memberId, String userId) async {
    await _makeRequest(
      'DELETE',
      '/family/members/$memberId',
      queryParams: {'userId': userId},
    );
  }

  // Subscriptions API
  Future<Map<String, dynamic>?> getMySubscription(String userId) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/subscriptions/my',
        queryParams: {'userId': userId},
      );
      return response['data'];
    } catch (e) {
      // Return null if no subscription found
      return null;
    }
  }

  Future<Map<String, dynamic>> createSubscription(
    String userId,
    Map<String, dynamic> subscriptionData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/subscriptions/checkout',
      queryParams: {'userId': userId},
      body: subscriptionData,
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> updateSubscription(
    String subscriptionId,
    String userId,
    Map<String, dynamic> subscriptionData,
  ) async {
    final response = await _makeRequest(
      'PATCH',
      '/subscriptions/$subscriptionId',
      queryParams: {'userId': userId},
      body: subscriptionData,
    );
    return response['data'];
  }

  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    await _makeRequest(
      'PUT',
      '/subscriptions/$subscriptionId/cancel',
      queryParams: {'userId': userId},
    );
  }

  // Advisory API
  Future<List<Map<String, dynamic>>> checkRecipeAdvisory(
    String recipeId,
    List<String> familyMemberIds, {
    String? variantRegion,
  }) async {
    final body = {
      'recipe_id': recipeId,
      'family_member_ids': familyMemberIds,
      if (variantRegion != null) 'variant_region': variantRegion,
    };

    final response = await _makeRequest('POST', '/advisory/check', body: body);
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getAdvisories(String userId) async {
    final response = await _makeRequest(
      'GET',
      '/advisory',
      queryParams: {'userId': userId},
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createAdvisory(
    String userId,
    Map<String, dynamic> advisoryData,
  ) async {
    final response = await _makeRequest(
      'POST',
      '/advisory',
      queryParams: {'userId': userId},
      body: advisoryData,
    );
    return response['data'];
  }

  // Ingredients API
  Future<List<Map<String, dynamic>>> getIngredients({
    String? category,
    String? search,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest(
      'GET',
      '/ingredients',
      queryParams: queryParams,
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  // Regions API
  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await _makeRequest('GET', '/regions');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  // Suggestions API
  Future<List<Map<String, dynamic>>> getSuggestions({
    String? userId,
    String? mealType,
    String? region,
    int? maxTime,
    int? servings,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (mealType != null) queryParams['meal_type'] = mealType;
    if (region != null) queryParams['region'] = region;
    if (maxTime != null) queryParams['max_time'] = maxTime.toString();
    if (servings != null) queryParams['servings'] = servings.toString();

    final response = await _makeRequest(
      'GET',
      '/suggestions',
      queryParams: queryParams,
    );
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
}
