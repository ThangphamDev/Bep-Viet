class RecipeModel {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? imageUrl;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final int? servings;
  final int? difficulty;
  final String? mealType;
  final String? region;
  final String? baseRegion;
  final String? authenticity;
  final int? spiceLevel;
  final int? saltiness;
  final int? hardness;
  final double? ratingAvg;
  final int? ratingCount;
  final List<String>? tags;
  final List<RecipeIngredientModel>? ingredients;
  final List<RecipeStepModel>? steps;
  final List<RecipeVariantModel>? variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.imageUrl,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.servings,
    this.difficulty,
    this.mealType,
    this.region,
    this.baseRegion,
    this.authenticity,
    this.spiceLevel,
    this.saltiness,
    this.hardness,
    this.ratingAvg,
    this.ratingCount,
    this.tags,
    this.ingredients,
    this.steps,
    this.variants,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id']?.toString() ?? '',
      name:
          json['name_vi']?.toString() ??
          json['name']?.toString() ??
          'Unknown Recipe',
      nameEn: json['name_en']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      prepTimeMinutes:
          _parseInt(json['prep_time_min']) ??
          _parseInt(json['prepTimeMinutes']),
      cookTimeMinutes:
          _parseInt(json['cook_time_min']) ??
          _parseInt(json['cookTimeMinutes']),
      totalTimeMinutes:
          _parseInt(json['total_time_min']) ??
          _parseInt(json['totalTimeMinutes']),
      servings: _parseInt(json['servings']),
      difficulty: _parseInt(json['difficulty']),
      mealType: json['meal_type']?.toString() ?? json['mealType']?.toString(),
      region: json['region']?.toString(),
      baseRegion:
          json['base_region']?.toString() ?? json['baseRegion']?.toString(),
      authenticity: json['authenticity']?.toString(),
      spiceLevel: _parseInt(json['spice_level']) ?? _parseInt(json['spiceLevel']),
      saltiness: _parseInt(json['saltiness']),
      hardness: _parseInt(json['hardness']),
      ratingAvg: _parseDouble(json['rating_avg']) ?? _parseDouble(json['ratingAvg']),
      ratingCount: _parseInt(json['rating_count']) ?? _parseInt(json['ratingCount']),
      tags: json['tags'] != null
          ? (json['tags'] as List)
                .map(
                  (e) => e is Map<String, dynamic>
                      ? e['name']?.toString() ?? ''
                      : e.toString(),
                )
                .where((name) => name.isNotEmpty)
                .toList()
          : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map(
                  (e) =>
                      RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      variants: json['variants'] != null
          ? (json['variants'] as List)
                .map(
                  (e) => RecipeVariantModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,

    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  RecipeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? totalTimeMinutes,
    int? servings,
    int? difficulty,
    String? mealType,
    String? baseRegion,
    List<String>? tags,
    List<RecipeIngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
    List<RecipeVariantModel>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      mealType: mealType ?? this.mealType,
      baseRegion: baseRegion ?? this.baseRegion,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      variants: variants ?? this.variants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'totalTimeMinutes': totalTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'mealType': mealType,
      'region': region,
      'baseRegion': baseRegion,
      'authenticity': authenticity,
      'spiceLevel': spiceLevel,
      'saltiness': saltiness,
      'hardness': hardness,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'tags': tags,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'steps': steps?.map((e) => e.toJson()).toList(),
      'variants': variants?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class RecipeIngredientModel {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? notes;

  RecipeIngredientModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      ingredientId:
          json['ingredient_id']?.toString() ??
          json['ingredientId']?.toString() ??
          '',
      ingredientName:
          json['ingredient_name']?.toString() ??
          json['ingredientName']?.toString() ??
          '',
      quantity: _parseDouble(json['quantity']) ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      notes: json['note']?.toString() ?? json['notes']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }
}

class RecipeStepModel {
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final int? durationMinutes;

  RecipeStepModel({
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.durationMinutes,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      stepNumber:
          _parseInt(json['stepNumber']) ?? _parseInt(json['step_number']) ?? 0,
      instruction: json['instruction']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      durationMinutes:
          _parseInt(json['durationMinutes']) ??
          _parseInt(json['duration_minutes']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
    };
  }
}

class RecipeVariantModel {
  final String region;
  final String? name;
  final String? description;
  final List<RecipeIngredientModel>? ingredients;
  final List<RecipeStepModel>? steps;
  final double? estimatedCost;

  RecipeVariantModel({
    required this.region,
    this.name,
    this.description,
    this.ingredients,
    this.steps,
    this.estimatedCost,
  });

  factory RecipeVariantModel.fromJson(Map<String, dynamic> json) {
    return RecipeVariantModel(
      region:
          json['region']?.toString() ??
          json['variant_region']?.toString() ??
          '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map(
                  (e) =>
                      RecipeIngredientModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      estimatedCost:
          _parseDouble(json['estimatedCost']) ??
          _parseDouble(json['total_cost']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'name': name,
      'description': description,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'steps': steps?.map((e) => e.toJson()).toList(),
      'estimatedCost': estimatedCost,
    };
  }
}
