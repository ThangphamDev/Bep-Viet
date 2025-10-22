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

    if (_authRepository.isLoggedIn && _authRepository.shouldAutoLogin) {
      // Token exists and not expired - verify with server
      try {
        final isValid = await _authRepository.isTokenValid();
        if (isValid) {
          // Token valid, get fresh user data
          final user = await _authRepository.getUserProfile();

          // Wait for splash screen minimum duration
          await splashFuture;
          emit(AuthAuthenticated(user: user));
        } else {
          // Token invalid or expired, logout
          await _authRepository.logout();

          // Wait for splash screen minimum duration
          await splashFuture;
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        // Error verifying token (network error, user deleted, etc.)
        await _authRepository.logout();

        // Wait for splash screen minimum duration
        await splashFuture;
        emit(AuthUnauthenticated());
      }
    } else {
      // No token or token expired
      if (_authRepository.isLoggedIn) {
        await _authRepository.logout();
      }

      // Wait for splash screen minimum duration
      await splashFuture;
      emit(AuthUnauthenticated());
    }
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

  Future<void> deleteAccount() async {
    try {
      await _authRepository.deleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String region,
    required String subregion,
  }) async {
    try {
      final updatedUser = await _authRepository.updateProfile(
        name: name,
        region: region,
        subregion: subregion,
      );

      // Update the current state with new user data
      if (state is AuthAuthenticated) {
        emit(AuthAuthenticated(user: updatedUser));
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
