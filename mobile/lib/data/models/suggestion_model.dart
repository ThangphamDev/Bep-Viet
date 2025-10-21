class SuggestionModel {
  final String recipeId;
  final String recipeName;
  final String? recipeImageUrl;
  final String variantRegion;
  final double totalCost;
  final double seasonScore;
  final String reason;
  final List<SuggestionItemModel>? items;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final int? difficulty;
  final String? tagNames; // Tags từ backend (Cháo, Súp, Cho bé ăn, etc.)
  final double? requestMatchScore; // Điểm khớp với yêu cầu người dùng
  final double? ingredientMatchScore; // Điểm khớp nguyên liệu
  final double? matchScore; // Điểm tổng hợp (final score)

  SuggestionModel({
    required this.recipeId,
    required this.recipeName,
    this.recipeImageUrl,
    required this.variantRegion,
    required this.totalCost,
    required this.seasonScore,
    required this.reason,
    this.items,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.difficulty,
    this.tagNames,
    this.requestMatchScore,
    this.ingredientMatchScore,
    this.matchScore,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      recipeId:
          json['recipe_id'] as String? ?? json['recipeId'] as String? ?? '',
      recipeName:
          json['name_vi'] as String? ??
          json['recipeName'] as String? ??
          'Unknown Recipe',
      recipeImageUrl:
          json['image_url'] as String? ?? json['recipeImageUrl'] as String?,
      variantRegion:
          json['variant_region'] as String? ??
          json['variantRegion'] as String? ??
          json['base_region'] as String? ??
          'BAC',
      totalCost: _parseDouble(
        json['total_cost'] ?? json['totalCost'] ?? json['estimatedCost'],
      ),
      seasonScore: _parseDouble(json['season_score'] ?? json['seasonScore']),
      reason: json['reason'] as String? ?? 'Món ăn ngon',
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (e) =>
                      SuggestionItemModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      prepTimeMinutes:
          json['prep_time_min'] as int? ?? json['prepTimeMinutes'] as int?,
      cookTimeMinutes:
          json['cook_time_min'] as int? ?? json['cookTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] as int?,
      tagNames: json['tag_names'] as String?,
      requestMatchScore: _parseDouble(json['requestMatchScore']),
      ingredientMatchScore: _parseDouble(json['ingredientMatchScore']),
      matchScore: _parseDouble(json['matchScore']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value.isNaN ? 0.0 : value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.isNaN == true ? 0.0 : (parsed ?? 0.0);
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImageUrl': recipeImageUrl,
      'variantRegion': variantRegion,
      'totalCost': totalCost,
      'seasonScore': seasonScore,
      'reason': reason,
      'items': items?.map((e) => e.toJson()).toList(),
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'tagNames': tagNames,
      'requestMatchScore': requestMatchScore,
      'ingredientMatchScore': ingredientMatchScore,
      'matchScore': matchScore,
    };
  }
}

class SuggestionItemModel {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final double estCost;

  SuggestionItemModel({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.estCost,
  });

  factory SuggestionItemModel.fromJson(Map<String, dynamic> json) {
    return SuggestionItemModel(
      ingredientId:
          json['ingredient_id'] as String? ??
          json['ingredientId'] as String? ??
          '',
      ingredientName:
          json['ingredient_name'] as String? ??
          json['ingredientName'] as String? ??
          'Unknown Ingredient',
      quantity: _parseDouble(json['quantity']),
      unit: json['unit'] as String? ?? '',
      estCost: _parseDouble(json['est_cost'] ?? json['estCost']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value.isNaN ? 0.0 : value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.isNaN == true ? 0.0 : (parsed ?? 0.0);
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'estCost': estCost,
    };
  }
}

class SearchSuggestionsRequest {
  final String region;
  final String season;
  final int servings;
  final int budget;
  final int? spicePreference;
  final List<String>? pantryIds;
  final List<String>? excludeAllergens;
  final int? maxTime;
  final int? limit;

  SearchSuggestionsRequest({
    required this.region,
    required this.season,
    required this.servings,
    required this.budget,
    this.spicePreference,
    this.pantryIds,
    this.excludeAllergens,
    this.maxTime,
    this.limit,
  });

  factory SearchSuggestionsRequest.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionsRequest(
      region: json['region'] as String,
      season: json['season'] as String,
      servings: json['servings'] as int,
      budget: json['budget'] as int,
      spicePreference:
          json['spice_pref'] as int? ?? json['spicePreference'] as int?,
      pantryIds: json['pantry_ids'] != null
          ? List<String>.from(json['pantry_ids'])
          : json['pantryIds'] != null
          ? List<String>.from(json['pantryIds'])
          : null,
      excludeAllergens: json['exclude_allergens'] != null
          ? List<String>.from(json['exclude_allergens'])
          : json['excludeAllergens'] != null
          ? List<String>.from(json['excludeAllergens'])
          : null,
      maxTime: json['max_time'] as int? ?? json['maxTime'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'season': season,
      'servings': servings,
      'budget': budget,
      'spice_preference': spicePreference,
      'pantry_ids': pantryIds,
      'exclude_allergens': excludeAllergens,
      'max_time': maxTime,
      'limit': limit,
    };
  }
}
