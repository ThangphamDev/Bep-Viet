class FamilyProfileModel {
  final String id;
  final String name;
  final String? note;
  final List<FamilyMemberModel> members;

  FamilyProfileModel({
    required this.id,
    required this.name,
    this.note,
    this.members = const [],
  });

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      note: json['note'],
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
      'name': name,
      'note': note,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }

  // Helper method to get member count
  int get memberCount => members.length;
}

class FamilyMemberModel {
  final String id;
  final String familyId;
  final String name;
  final int age;
  final String? dietaryRestrictions;
  final String? allergies;

  FamilyMemberModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.age,
    this.dietaryRestrictions,
    this.allergies,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id']?.toString() ?? '',
      familyId: json['family_id']?.toString() ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      dietaryRestrictions: json['dietary_restrictions'],
      allergies: json['allergies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'name': name,
      'age': age,
      'dietary_restrictions': dietaryRestrictions,
      'allergies': allergies,
    };
  }
}
