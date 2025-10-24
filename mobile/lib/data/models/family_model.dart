class FamilyProfileModel {
  final String id;
  final String name;
  final String? note;
  final List<FamilyMemberModel> members;

  const FamilyProfileModel({
    required this.id,
    required this.name,
    this.note,
    this.members = const [],
  });

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      note: json['note'] as String?,
      members:
          (json['members'] as List<dynamic>?)
              ?.map(
                (e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'members': members.map((e) => e.toJson()).toList(),
    };
  }

  FamilyProfileModel copyWith({
    String? id,
    String? name,
    String? note,
    List<FamilyMemberModel>? members,
  }) {
    return FamilyProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      members: members ?? this.members,
    );
  }
}

class FamilyMemberModel {
  final String id;
  final String name;
  final String? ageGroup;
  final int spiceTolerance;
  final Map<String, dynamic>? dietJson;
  final Map<String, dynamic>? allergiesJson;
  final String? note;

  const FamilyMemberModel({
    required this.id,
    required this.name,
    this.ageGroup,
    this.spiceTolerance = 1,
    this.dietJson,
    this.allergiesJson,
    this.note,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ageGroup: json['age_group'] as String?,
      spiceTolerance: json['spice_tolerance'] as int? ?? 1,
      dietJson: json['diet_json'] as Map<String, dynamic>?,
      allergiesJson: json['allergies_json'] as Map<String, dynamic>?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age_group': ageGroup,
      'spice_tolerance': spiceTolerance,
      'diet_json': dietJson,
      'allergies_json': allergiesJson,
      'note': note,
    };
  }

  FamilyMemberModel copyWith({
    String? id,
    String? name,
    String? ageGroup,
    int? spiceTolerance,
    Map<String, dynamic>? dietJson,
    Map<String, dynamic>? allergiesJson,
    String? note,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ageGroup: ageGroup ?? this.ageGroup,
      spiceTolerance: spiceTolerance ?? this.spiceTolerance,
      dietJson: dietJson ?? this.dietJson,
      allergiesJson: allergiesJson ?? this.allergiesJson,
      note: note ?? this.note,
    );
  }
}

class CreateFamilyProfileRequest {
  final String name;
  final String? note;

  const CreateFamilyProfileRequest({required this.name, this.note});

  factory CreateFamilyProfileRequest.fromJson(Map<String, dynamic> json) {
    return CreateFamilyProfileRequest(
      name: json['name'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'note': note};
  }
}

class AddFamilyMemberRequest {
  final String name;
  final String? ageGroup;
  final int spiceTolerance;
  final Map<String, dynamic>? dietJson;
  final Map<String, dynamic>? allergiesJson;
  final String? note;

  const AddFamilyMemberRequest({
    required this.name,
    this.ageGroup,
    this.spiceTolerance = 1,
    this.dietJson,
    this.allergiesJson,
    this.note,
  });

  factory AddFamilyMemberRequest.fromJson(Map<String, dynamic> json) {
    return AddFamilyMemberRequest(
      name: json['name'] as String,
      ageGroup: json['age_group'] as String?,
      spiceTolerance: json['spice_tolerance'] as int? ?? 1,
      dietJson: json['diet_json'] as Map<String, dynamic>?,
      allergiesJson: json['allergies_json'] as Map<String, dynamic>?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age_group': ageGroup,
      'spice_tolerance': spiceTolerance,
      'diet_json': dietJson,
      'allergies_json': allergiesJson,
      'note': note,
    };
  }
}

class UpdateFamilyMemberRequest {
  final String name;
  final String? ageGroup;
  final int spiceTolerance;
  final Map<String, dynamic>? dietJson;
  final Map<String, dynamic>? allergiesJson;
  final String? note;

  const UpdateFamilyMemberRequest({
    required this.name,
    this.ageGroup,
    this.spiceTolerance = 1,
    this.dietJson,
    this.allergiesJson,
    this.note,
  });

  factory UpdateFamilyMemberRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyMemberRequest(
      name: json['name'] as String,
      ageGroup: json['age_group'] as String?,
      spiceTolerance: json['spice_tolerance'] as int? ?? 1,
      dietJson: json['diet_json'] as Map<String, dynamic>?,
      allergiesJson: json['allergies_json'] as Map<String, dynamic>?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age_group': ageGroup,
      'spice_tolerance': spiceTolerance,
      'diet_json': dietJson,
      'allergies_json': allergiesJson,
      'note': note,
    };
  }
}

class FamilyProfilesResponse {
  final bool success;
  final List<FamilyProfileModel> data;
  final String? message;

  const FamilyProfilesResponse({
    required this.success,
    this.data = const [],
    this.message,
  });

  factory FamilyProfilesResponse.fromJson(Map<String, dynamic> json) {
    return FamilyProfilesResponse(
      success: json['success'] as bool,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => FamilyProfileModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

// ⚠️ ALLERGEN CHECK MODELS
class ConflictingIngredient {
  final String ingredientId;
  final String ingredientName;

  const ConflictingIngredient({
    required this.ingredientId,
    required this.ingredientName,
  });

  factory ConflictingIngredient.fromJson(Map<String, dynamic> json) {
    return ConflictingIngredient(
      ingredientId: json['ingredientId'] as String,
      ingredientName: json['ingredientName'] as String,
    );
  }
}

class AllergenConflict {
  final String memberId;
  final String memberName;
  final String memberAgeGroup;
  final List<ConflictingIngredient> conflictingIngredients;

  const AllergenConflict({
    required this.memberId,
    required this.memberName,
    required this.memberAgeGroup,
    required this.conflictingIngredients,
  });

  factory AllergenConflict.fromJson(Map<String, dynamic> json) {
    return AllergenConflict(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      memberAgeGroup: json['memberAgeGroup'] as String,
      conflictingIngredients: (json['conflictingIngredients'] as List<dynamic>)
          .map((e) => ConflictingIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CheckAllergensResponse {
  final bool success;
  final bool hasConflicts;
  final List<AllergenConflict> conflicts;
  final String? message;

  const CheckAllergensResponse({
    required this.success,
    required this.hasConflicts,
    this.conflicts = const [],
    this.message,
  });

  factory CheckAllergensResponse.fromJson(Map<String, dynamic> json) {
    return CheckAllergensResponse(
      success: json['success'] as bool,
      hasConflicts: json['hasConflicts'] as bool,
      conflicts:
          (json['conflicts'] as List<dynamic>?)
              ?.map((e) => AllergenConflict.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }
}
