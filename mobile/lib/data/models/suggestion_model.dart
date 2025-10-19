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
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      recipeImageUrl: json['recipeImageUrl'] as String?,
      variantRegion: json['variantRegion'] as String,
      totalCost: (json['totalCost'] as num).toDouble(),
      seasonScore: (json['seasonScore'] as num).toDouble(),
      reason: json['reason'] as String,
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (e) =>
                      SuggestionItemModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] as int?,
    );
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
      ingredientId: json['ingredientId'] as String,
      ingredientName: json['ingredientName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      estCost: (json['estCost'] as num).toDouble(),
    );
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
      spicePreference: json['spicePreference'] as int?,
      pantryIds: json['pantryIds'] != null
          ? List<String>.from(json['pantryIds'])
          : null,
      excludeAllergens: json['excludeAllergens'] != null
          ? List<String>.from(json['excludeAllergens'])
          : null,
      maxTime: json['maxTime'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'season': season,
      'servings': servings,
      'budget': budget,
      'spicePreference': spicePreference,
      'pantryIds': pantryIds,
      'excludeAllergens': excludeAllergens,
      'maxTime': maxTime,
      'limit': limit,
    };
  }
}
