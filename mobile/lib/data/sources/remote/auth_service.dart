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
  String? get accessToken => _prefs.getString(AppConfig.tokenKey);

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
  Future<AuthResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);
      
      if (response.success) {
        await _saveAuthData(response.data);
      }
      
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
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
        await _saveAuthData(response.data);
      }
      
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.refreshTokenKey);
    await _prefs.remove(AppConfig.userKey);
  }

  // Save authentication data
  Future<void> _saveAuthData(AuthData authData) async {
    await _prefs.setString(AppConfig.tokenKey, authData.accessToken);
    await _prefs.setString(AppConfig.refreshTokenKey, authData.refreshToken);
    await _prefs.setString(AppConfig.userKey, jsonEncode(authData.user.toJson()));
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
}
