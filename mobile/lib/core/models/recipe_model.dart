class RecipeModel {
  final String id;
  final String nameVi;
  final String? nameEn;
  final String mealType;
  final String? difficulty;
  final int? cookTimeMin;
  final String? baseRegion;
  final String? description;
  final String? instructions;
  final String? imageUrl;
  final List<String> tags;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeVariantModel> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.nameVi,
    this.nameEn,
    required this.mealType,
    this.difficulty,
    this.cookTimeMin,
    this.baseRegion,
    this.description,
    this.instructions,
    this.imageUrl,
    this.tags = const [],
    this.ingredients = const [],
    this.variants = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] ?? '',
      nameVi: json['name_vi'] ?? '',
      nameEn: json['name_en'],
      mealType: json['meal_type'] ?? '',
      difficulty: json['difficulty'],
      cookTimeMin: json['cook_time_min'],
      baseRegion: json['base_region'],
      description: json['description'],
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      tags: List<String>.from(json['tags'] ?? []),
      ingredients:
          (json['ingredients'] as List?)
              ?.map((ingredient) => RecipeIngredientModel.fromJson(ingredient))
              .toList() ??
          [],
      variants:
          (json['variants'] as List?)
              ?.map((variant) => RecipeVariantModel.fromJson(variant))
              .toList() ??
          [],
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
      'name_vi': nameVi,
      'name_en': nameEn,
      'meal_type': mealType,
      'difficulty': difficulty,
      'cook_time_min': cookTimeMin,
      'base_region': baseRegion,
      'description': description,
      'instructions': instructions,
      'image_url': imageUrl,
      'tags': tags,
      'ingredients': ingredients
          .map((ingredient) => ingredient.toJson())
          .toList(),
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RecipeIngredientModel {
  final String id;
  final String name;
  final String? category;
  final double? quantity;
  final String? unit;
  final String? notes;

  RecipeIngredientModel({
    required this.id,
    required this.name,
    this.category,
    this.quantity,
    this.unit,
    this.notes,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      quantity: json['quantity']?.toDouble(),
      unit: json['unit'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }
}

class RecipeVariantModel {
  final String id;
  final String region;
  final String? name;
  final String? description;
  final List<String> modifications;
  final List<RecipeIngredientModel> ingredients;

  RecipeVariantModel({
    required this.id,
    required this.region,
    this.name,
    this.description,
    this.modifications = const [],
    this.ingredients = const [],
  });

  factory RecipeVariantModel.fromJson(Map<String, dynamic> json) {
    return RecipeVariantModel(
      id: json['id'] ?? '',
      region: json['region'] ?? '',
      name: json['name'],
      description: json['description'],
      modifications: List<String>.from(json['modifications'] ?? []),
      ingredients:
          (json['ingredients'] as List?)
              ?.map((ingredient) => RecipeIngredientModel.fromJson(ingredient))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'name': name,
      'description': description,
      'modifications': modifications,
      'ingredients': ingredients
          .map((ingredient) => ingredient.toJson())
          .toList(),
    };
  }
}


