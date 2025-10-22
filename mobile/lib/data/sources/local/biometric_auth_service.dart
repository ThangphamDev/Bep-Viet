import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoggedInEmailKey = 'last_logged_in_email';

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate with biometric
  Future<bool> authenticate({String reason = 'Xác thực để đăng nhập'}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error reading biometric enabled status: $e');
      return false;
    }
  }

  /// Enable biometric login
  Future<void> enableBiometric(String email) async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      await _secureStorage.write(key: _lastLoggedInEmailKey, value: email);
    } catch (e) {
      print('Error enabling biometric: $e');
      rethrow;
    }
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
      await _secureStorage.delete(key: _lastLoggedInEmailKey);
    } catch (e) {
      print('Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Get last logged in email
  Future<String?> getLastLoggedInEmail() async {
    try {
      return await _secureStorage.read(key: _lastLoggedInEmailKey);
    } catch (e) {
      print('Error reading last logged in email: $e');
      return null;
    }
  }

  /// Get biometric type name in Vietnamese
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Khuôn mặt';
      case BiometricType.fingerprint:
        return 'Vân tay';
      case BiometricType.iris:
        return 'Mống mắt';
      case BiometricType.strong:
        return 'Sinh trắc học mạnh';
      case BiometricType.weak:
        return 'Sinh trắc học yếu';
      default:
        return 'Sinh trắc học';
    }
  }

  /// Get friendly biometric message
  Future<String> getBiometricMessage() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return 'Đăng nhập bằng sinh trắc học';
    }

    if (biometrics.contains(BiometricType.face)) {
      return 'Đăng nhập bằng khuôn mặt';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Đăng nhập bằng vân tay';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Đăng nhập bằng mống mắt';
    }

    return 'Đăng nhập bằng sinh trắc học';
  }
}
