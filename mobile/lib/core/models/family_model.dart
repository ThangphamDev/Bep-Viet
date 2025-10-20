class FamilyProfileModel {
  final String id;
  final String ownerUserId;
  final String name;
  final String? description;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FamilyMemberModel> members;

  FamilyProfileModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    this.description,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
  });

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyProfileModel(
      id: json['id'] ?? '',
      ownerUserId: json['owner_user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      memberCount: json['member_count'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      members:
          (json['members'] as List?)
              ?.map((member) => FamilyMemberModel.fromJson(member))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'description': description,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}

class FamilyMemberModel {
  final String id;
  final String familyId;
  final String name;
  final int age;
  final List<String> allergies;
  final SpiceLevel spiceLevel;
  final List<DietFlag> dietFlags;
  final List<String> healthConditions;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMemberModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.age,
    this.allergies = const [],
    required this.spiceLevel,
    this.dietFlags = const [],
    this.healthConditions = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] ?? '',
      familyId: json['family_id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      allergies: List<String>.from(json['allergies'] ?? []),
      spiceLevel: SpiceLevel.fromString(json['spice_level'] ?? 'MEDIUM'),
      dietFlags:
          (json['diet_flags'] as List?)
              ?.map((flag) => DietFlag.fromString(flag))
              .toList() ??
          [],
      healthConditions: List<String>.from(json['health_conditions'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'name': name,
      'age': age,
      'allergies': allergies,
      'spice_level': spiceLevel.value,
      'diet_flags': dietFlags.map((flag) => flag.value).toList(),
      'health_conditions': healthConditions,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum SpiceLevel {
  none('NONE'),
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const SpiceLevel(this.value);
  final String value;

  static SpiceLevel fromString(String value) {
    return SpiceLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => SpiceLevel.medium,
    );
  }
}

enum DietFlag {
  vegetarian('VEGETARIAN'),
  vegan('VEGAN'),
  glutenFree('GLUTEN_FREE'),
  dairyFree('DAIRY_FREE'),
  keto('KETO');

  const DietFlag(this.value);
  final String value;

  static DietFlag fromString(String value) {
    return DietFlag.values.firstWhere(
      (flag) => flag.value == value,
      orElse: () => DietFlag.vegetarian,
    );
  }
}


