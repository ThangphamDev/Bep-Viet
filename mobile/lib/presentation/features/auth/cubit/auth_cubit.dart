import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';
import 'package:bepviet_mobile/data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? region;
  final String? subregion;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.region,
    this.subregion,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

// States
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistered extends AuthState {
  const AuthRegistered();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  // Getter for auth repository
  AuthRepository get authRepository => _authRepository;

  Future<void> _checkAuthStatus() async {
    // Show splash screen for at least 1 second
    final splashFuture = Future.delayed(const Duration(seconds: 1));

    // Always show login page on app start
    // User can use biometric if enabled, or login manually
    await splashFuture;
    emit(AuthUnauthenticated());
  }

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(
        email,
        password,
        rememberMe: rememberMe,
      );
      if (response.success) {
        emit(AuthAuthenticated(user: response.data.user));
      } else {
        emit(const AuthError(message: 'Đăng nhập thất bại'));
      }
    } catch (e) {
      // Clean up the error message (remove "Exception: " prefix)
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
    bool rememberMe = false,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        region: region,
        subregion: subregion,
        rememberMe: rememberMe,
      );
      if (response.success) {
        // Logout immediately after registration to clear token
        await _authRepository.logout();
        // Emit registered state (not authenticated)
        emit(const AuthRegistered());
      } else {
        emit(const AuthError(message: 'Đăng ký thất bại'));
      }
    } catch (e) {
      // Clean up the error message (remove "Exception: " prefix)
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> logout() async {
    try {
      // Clear data immediately without loading state for faster logout
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, still emit unauthenticated to clear the session
      emit(AuthUnauthenticated());
    }
  }

  Future<void> checkAuth() async {
    try {
      final isValid = await _authRepository.isTokenValid();
      if (isValid) {
        // Get fresh user data from server
        final user = await _authRepository.getUserProfile();
        emit(AuthAuthenticated(user: user));
      } else {
        await _authRepository.logout();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Error (network, user deleted, etc.) - logout
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.loginWithGoogle();
      if (response.success) {
        emit(AuthAuthenticated(user: response.data.user));
      } else {
        emit(const AuthError(message: 'Đăng nhập Google thất bại'));
      }
    } catch (e) {
      // Clean up the error message
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authRepository.deleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // ========== Biometric Authentication Methods ==========

  Future<void> loginWithBiometric() async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.loginWithBiometric();
      if (response.success) {
        emit(AuthAuthenticated(user: response.data.user));
      } else {
        emit(const AuthError(message: 'Đăng nhập sinh trắc học thất bại'));
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<bool> isBiometricAvailable() async {
    return await _authRepository.isBiometricAvailable();
  }

  Future<bool> isBiometricEnabled() async {
    return await _authRepository.isBiometricEnabled();
  }

  Future<void> enableBiometric(String email) async {
    await _authRepository.enableBiometric(email);
  }

  Future<void> disableBiometric() async {
    await _authRepository.disableBiometric();
  }

  Future<String> getBiometricMessage() async {
    return await _authRepository.getBiometricMessage();
  }
}
