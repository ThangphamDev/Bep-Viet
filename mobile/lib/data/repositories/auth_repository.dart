import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // Check if user is logged in
  bool get isLoggedIn => _authService.isLoggedIn;

  // Check if should auto login
  bool get shouldAutoLogin => _authService.shouldAutoLogin;

  // Get current user
  UserModel? get currentUser => _authService.currentUser;

  // Get access token
  String? get accessToken => _authService.accessToken;

  // Login
  Future<AuthResponse> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    return await _authService.login(email, password, rememberMe: rememberMe);
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
    return await _authService.register(
      email: email,
      password: password,
      name: name,
      region: region,
      subregion: subregion,
      rememberMe: rememberMe,
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

  // Delete account
  Future<void> deleteAccount() async {
    return await _authService.deleteAccount();
  }

  // Update profile
  Future<UserModel> updateProfile({
    required String name,
    required String region,
    required String subregion,
  }) async {
    return await _authService.updateProfile(
      name: name,
      region: region,
      subregion: subregion,
    );
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
