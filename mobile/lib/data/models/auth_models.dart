// Auth Request/Response Models
import 'user_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? region;
  final String? subregion;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.region,
    this.subregion,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (region != null) 'region': region,
      if (subregion != null) 'subregion': subregion,
    };
  }
}

class AuthResponse {
  final bool success;
  final AuthData data;
  final String? message;
  final String token;
  final String? accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.success,
    required this.data,
    required this.token,
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] ?? {};
    return AuthResponse(
      success: json['success'] == true,
      data: AuthData.fromJson(dataJson),
      token:
          dataJson['token']?.toString() ??
          dataJson['accessToken']?.toString() ??
          '',
      message: json['message']?.toString(),
      accessToken:
          dataJson['accessToken']?.toString() ?? dataJson['token']?.toString(),
      refreshToken: dataJson['refreshToken']?.toString(),
    );
  }
}

class AuthData {
  final String token;
  final String accessToken;
  final String? refreshToken;
  final UserData user;

  AuthData({
    required this.token,
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    final tokenValue =
        json['token']?.toString() ?? json['accessToken']?.toString() ?? '';
    return AuthData(
      token: tokenValue,
      accessToken: json['accessToken']?.toString() ?? tokenValue,
      refreshToken: json['refreshToken']?.toString(),
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserData {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? region;
  final String? subregion;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.region,
    this.subregion,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      region: json['region']?.toString(),
      subregion: json['subregion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      if (region != null) 'region': region,
      if (subregion != null) 'subregion': subregion,
    };
  }

  // Convert to UserModel
  UserModel toUserModel() {
    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
      region: region,
      subregion: subregion,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }
}

// Extension for UserModel to convert to UserData
extension UserModelExtension on UserModel {
  UserData toUserData() {
    return UserData(
      id: id,
      email: email,
      name: name,
      role: role,
      region: region,
      subregion: subregion,
    );
  }
}
