class RecipeModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final int? servings;
  final int? difficulty;
  final String? mealType;
  final String? baseRegion;
  final List<String>? tags;
  final List<RecipeIngredientModel>? ingredients;
  final List<RecipeStepModel>? steps;
  final List<RecipeVariantModel>? variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.servings,
    this.difficulty,
    this.mealType,
    this.baseRegion,
    this.tags,
    this.ingredients,
    this.steps,
    this.variants,
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name:
          json['name_vi'] as String? ??
          json['name'] as String? ??
          'Unknown Recipe',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      prepTimeMinutes:
          json['prep_time_min'] as int? ?? json['prepTimeMinutes'] as int?,
      cookTimeMinutes:
          json['cook_time_min'] as int? ?? json['cookTimeMinutes'] as int?,
      totalTimeMinutes:
          json['total_time_min'] as int? ?? json['totalTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] as int?,
      mealType: json['meal_type'] as String? ?? json['mealType'] as String?,
      baseRegion:
          json['base_region'] as String? ?? json['baseRegion'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'totalTimeMinutes': totalTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'mealType': mealType,
      'baseRegion': baseRegion,
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
      ingredientId: json['ingredientId'] as String,
      ingredientName: json['ingredientName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
    );
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
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      imageUrl: json['imageUrl'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
    );
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
      region: json['region'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
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
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
    );
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
