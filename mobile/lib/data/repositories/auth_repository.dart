import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // Check if user is logged in
  bool get isLoggedIn => _authService.isLoggedIn;

  // Get current user
  UserModel? get currentUser => _authService.currentUser;

  // Get access token
  String? get accessToken => _authService.accessToken;

  // Login
  Future<AuthResponse> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
  }) async {
    return await _authService.register(
      email: email,
      password: password,
      name: name,
      region: region,
      subregion: subregion,
    );
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  // Get user profile
  Future<UserModel> getUserProfile() async {
    return await _authService.getUserProfile();
  }

  // Check token validity
  Future<bool> isTokenValid() async {
    return await _authService.isTokenValid();
  }

  // Clear all authentication data (for debugging)
  Future<void> clearAuthData() async {
    await _authService.logout();
  }
}
