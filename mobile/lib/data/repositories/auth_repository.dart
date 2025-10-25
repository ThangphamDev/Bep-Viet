import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/models/auth_models.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
import 'package:bepviet_mobile/data/sources/remote/google_auth_service.dart';
import 'package:bepviet_mobile/data/sources/local/biometric_auth_service.dart';
import 'package:bepviet_mobile/data/sources/local/app_data_cleaner.dart';

class AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final BiometricAuthService _biometricAuthService;

  AuthRepository(
    this._authService,
    this._googleAuthService,
    this._biometricAuthService,
  );

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
    // Disconnect Google account to force account selection next time
    await _googleAuthService.signOut();

    // Clear local auth data
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
    // Delete account on server first
    await _authService.deleteAccount();

    // Disconnect Google account
    await _googleAuthService.signOut();

    // Clear ALL app data (secure storage, shared prefs, cache, databases)
    await AppDataCleaner.clearAllData();
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

  // Login with Google
  /// Set [forceAccountSelection] to true to always show account chooser
  Future<AuthResponse> loginWithGoogle({
    bool forceAccountSelection = false,
  }) async {
    try {
      final authData = await _googleAuthService.signInAndAuthenticate(
        forceAccountSelection: forceAccountSelection,
      );

      if (authData == null) {
        throw Exception('Google Sign-In failed');
      }

      // Save auth data (similar to regular login)
      final user = UserModel.fromJson(authData['user']);
      final accessToken = authData['accessToken'] as String;
      final refreshToken = authData['refreshToken'] as String;

      await _authService.saveAuthData(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        rememberMe: true, // Always remember Google users
      );

      return AuthResponse(
        success: true,
        token: accessToken,
        data: AuthData(
          token: accessToken,
          user: user.toUserData(),
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    } catch (error) {
      print('Google login error in repository: $error');

      // If account is blocked, sign out to allow user to choose different account
      final errorString = error.toString();
      if (errorString.toLowerCase().contains('blocked') ||
          errorString.toLowerCase().contains('khóa')) {
        try {
          await _googleAuthService.signOut();
          print('Signed out from Google due to blocked account');
        } catch (signOutError) {
          print('Error signing out: $signOutError');
        }
      }

      // Re-throw the error as-is to preserve backend message
      final cleanError = errorString.replaceFirst('Exception: ', '');
      throw Exception(cleanError);
    }
  }

  // Logout Google
  Future<void> logoutGoogle() async {
    await _googleAuthService.signOut();
    await _authService.logout();
  }

  // ========== Biometric Authentication Methods ==========

  /// Check if biometric is available on device
  Future<bool> isBiometricAvailable() async {
    return await _biometricAuthService.isBiometricAvailable();
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    return await _biometricAuthService.isBiometricEnabled();
  }

  /// Enable biometric login (call after successful login)
  Future<void> enableBiometric(String email) async {
    await _biometricAuthService.enableBiometric(email);
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    await _biometricAuthService.disableBiometric();
  }

  /// Login with biometric
  Future<AuthResponse> loginWithBiometric() async {
    try {
      // Check if biometric is enabled
      final isEnabled = await _biometricAuthService.isBiometricEnabled();
      if (!isEnabled) {
        throw Exception(
          'Vui lòng đăng nhập lần đầu để kích hoạt tính năng này',
        );
      }

      // Check if user has valid token
      if (!isLoggedIn || !shouldAutoLogin) {
        throw Exception('Bạn cần đăng nhập bằng email và mật khẩu trước');
      }

      // Get last logged in email
      final email = await _biometricAuthService.getLastLoggedInEmail();
      if (email == null || email.isEmpty) {
        throw Exception(
          'Không tìm thấy thông tin đăng nhập. Vui lòng đăng nhập lại',
        );
      }

      // Authenticate with biometric
      final message = await _biometricAuthService.getBiometricMessage();
      final authenticated = await _biometricAuthService.authenticate(
        reason: message,
      );

      if (!authenticated) {
        throw Exception('Xác thực sinh trắc học bị hủy hoặc thất bại');
      }

      // Verify token is still valid
      final isValid = await isTokenValid();
      if (!isValid) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');
      }

      // Get user profile from server
      final user = await _authService.getUserProfile();

      final token = _authService.accessToken ?? '';
      return AuthResponse(
        success: true,
        token: token,
        data: AuthData(
          token: token,
          user: user.toUserData(),
          accessToken: token,
          refreshToken: '', // No need to refresh
        ),
      );
    } catch (error) {
      print('Biometric login error in repository: $error');
      // Re-throw with clean error message
      final errorMsg = error.toString().replaceFirst('Exception: ', '');
      throw Exception(errorMsg);
    }
  }

  /// Get biometric message
  Future<String> getBiometricMessage() async {
    return await _biometricAuthService.getBiometricMessage();
  }
}
