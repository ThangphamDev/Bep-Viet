import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';

class AuthService {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthService(this._apiService, this._prefs);

  // Check if user is logged in
  bool get isLoggedIn => _prefs.getString(AppConfig.tokenKey) != null;

  // Get current access token
  String? get accessToken {
    final token = _prefs.getString(AppConfig.tokenKey);
    print(
      '🔑 AuthService - Access token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}',
    );
    return token;
  }

  // Get current refresh token
  String? get refreshToken => _prefs.getString(AppConfig.refreshTokenKey);

  // Get current user
  UserModel? get currentUser {
    final userJson = _prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Login
  Future<AuthResponse> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      if (response.success) {
        await _saveAuthData(response.data, rememberMe: rememberMe);
      }

      return response;
    } catch (e) {
      // Re-throw the exception as-is (already formatted from api_service)
      rethrow;
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
    bool rememberMe = false,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
        region: region,
        subregion: subregion,
      );
      final response = await _apiService.register(request);

      if (response.success) {
        await _saveAuthData(response.data, rememberMe: rememberMe);
      }

      return response;
    } catch (e) {
      // Re-throw the exception as-is (already formatted from api_service)
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.refreshTokenKey);
    await _prefs.remove(AppConfig.userKey);
    await _prefs.remove(AppConfig.userIdKey);
    await _prefs.remove(AppConfig.rememberMeKey);
    await _prefs.remove(AppConfig.tokenExpiryKey);
  }

  // Save authentication data
  Future<void> _saveAuthData(
    AuthData authData, {
    bool rememberMe = false,
  }) async {
    await _prefs.setString(AppConfig.tokenKey, authData.accessToken);
    await _prefs.setString(AppConfig.refreshTokenKey, authData.refreshToken);
    await _prefs.setString(
      AppConfig.userKey,
      jsonEncode(authData.user.toJson()),
    );
    await _prefs.setString(AppConfig.userIdKey, authData.user.id);
    await _prefs.setBool(AppConfig.rememberMeKey, rememberMe);

    // Save token expiry time (7 days from now if remember me, 1 day otherwise)
    final expiryDays = rememberMe ? 7 : 1;
    final expiryTime = DateTime.now().add(Duration(days: expiryDays));
    await _prefs.setString(
      AppConfig.tokenExpiryKey,
      expiryTime.toIso8601String(),
    );
  }

  // Check if should auto login
  bool get shouldAutoLogin {
    // Check token expiry (regardless of remember me flag)
    // Token expiry is 7 days if remember me, 1 day otherwise
    final expiryString = _prefs.getString(AppConfig.tokenExpiryKey);
    if (expiryString == null) return false;

    try {
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<UserModel> getUserProfile() async {
    final token = accessToken;
    if (token == null) {
      throw Exception('No access token found');
    }

    try {
      return await _apiService.getUserProfile(token);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Check token validity
  Future<bool> isTokenValid() async {
    final token = accessToken;
    if (token == null) return false;

    try {
      await _apiService.getUserProfile(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final token = accessToken;
    if (token == null) {
      throw Exception('No access token found');
    }

    try {
      await _apiService.deleteAccount(token);
      await logout();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
