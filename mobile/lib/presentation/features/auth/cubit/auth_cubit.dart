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

  void _checkAuthStatus() {
    if (_authRepository.isLoggedIn) {
      final user = _authRepository.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(email, password);
      if (response.success) {
        emit(AuthAuthenticated(user: response.data.user));
      } else {
        emit(const AuthError(message: 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
  }) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        region: region,
        subregion: subregion,
      );
      if (response.success) {
        emit(AuthAuthenticated(user: response.data.user));
      } else {
        emit(const AuthError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
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
        final user = _authRepository.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        await _authRepository.logout();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    }
  }
}
