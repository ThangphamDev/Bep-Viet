class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? region;
  final String? subregion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? recipeCount;
  final int? subscriptionCount;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.region,
    this.subregion,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.recipeCount,
    this.subscriptionCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      region: json['region']?.toString(),
      subregion: json['subregion']?.toString(),
      isActive: _parseBool(json['is_active']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']),
      recipeCount: _parseInt(json['recipe_count']),
      subscriptionCount: _parseInt(json['subscription_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'region': region,
      'subregion': subregion,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'recipe_count': recipeCount,
      'subscription_count': subscriptionCount,
    };
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return true;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String get regionDisplay {
    switch (region) {
      case 'BAC':
        return 'Miền Bắc';
      case 'TRUNG':
        return 'Miền Trung';
      case 'NAM':
        return 'Miền Nam';
      default:
        return 'Không rõ';
    }
  }

  String get statusDisplay => isActive ? 'Hoạt động' : 'Đã khóa';

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? region,
    String? subregion,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? recipeCount,
    int? subscriptionCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recipeCount: recipeCount ?? this.recipeCount,
      subscriptionCount: subscriptionCount ?? this.subscriptionCount,
    );
  }
}
