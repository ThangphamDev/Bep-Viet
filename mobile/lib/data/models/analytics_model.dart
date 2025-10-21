class UserAnalyticsModel {
  final int mealPlansCount;
  final int pantryItemsCount;
  final int shoppingListsCount;
  final int communityRecipesCount;
  final int ratingsGivenCount;

  const UserAnalyticsModel({
    this.mealPlansCount = 0,
    this.pantryItemsCount = 0,
    this.shoppingListsCount = 0,
    this.communityRecipesCount = 0,
    this.ratingsGivenCount = 0,
  });

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      mealPlansCount: json['meal_plans_count'] as int? ?? 0,
      pantryItemsCount: json['pantry_items_count'] as int? ?? 0,
      shoppingListsCount: json['shopping_lists_count'] as int? ?? 0,
      communityRecipesCount: json['community_recipes_count'] as int? ?? 0,
      ratingsGivenCount: json['ratings_given_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_plans_count': mealPlansCount,
      'pantry_items_count': pantryItemsCount,
      'shopping_lists_count': shoppingListsCount,
      'community_recipes_count': communityRecipesCount,
      'ratings_given_count': ratingsGivenCount,
    };
  }

  UserAnalyticsModel copyWith({
    int? mealPlansCount,
    int? pantryItemsCount,
    int? shoppingListsCount,
    int? communityRecipesCount,
    int? ratingsGivenCount,
  }) {
    return UserAnalyticsModel(
      mealPlansCount: mealPlansCount ?? this.mealPlansCount,
      pantryItemsCount: pantryItemsCount ?? this.pantryItemsCount,
      shoppingListsCount: shoppingListsCount ?? this.shoppingListsCount,
      communityRecipesCount:
          communityRecipesCount ?? this.communityRecipesCount,
      ratingsGivenCount: ratingsGivenCount ?? this.ratingsGivenCount,
    );
  }
}

class SystemAnalyticsModel {
  final int totalUsers;
  final int totalRecipes;
  final int totalCommunityRecipes;
  final int totalRatings;
  final int totalMealPlans;
  final int totalIngredients;
  final int totalPantryItems;
  final int totalShoppingLists;
  final List<TopRecipeModel> topRecipes;
  final List<RecentActivityModel> recentActivity;

  const SystemAnalyticsModel({
    this.totalUsers = 0,
    this.totalRecipes = 0,
    this.totalCommunityRecipes = 0,
    this.totalRatings = 0,
    this.totalMealPlans = 0,
    this.totalIngredients = 0,
    this.totalPantryItems = 0,
    this.totalShoppingLists = 0,
    this.topRecipes = const [],
    this.recentActivity = const [],
  });

  factory SystemAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SystemAnalyticsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      totalRecipes: json['total_recipes'] as int? ?? 0,
      totalCommunityRecipes: json['total_community_recipes'] as int? ?? 0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      totalMealPlans: json['total_meal_plans'] as int? ?? 0,
      totalIngredients: json['total_ingredients'] as int? ?? 0,
      totalPantryItems: json['total_pantry_items'] as int? ?? 0,
      totalShoppingLists: json['total_shopping_lists'] as int? ?? 0,
      topRecipes:
          (json['top_recipes'] as List<dynamic>?)
              ?.map((e) => TopRecipeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivity:
          (json['recent_activity'] as List<dynamic>?)
              ?.map(
                (e) => RecentActivityModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_recipes': totalRecipes,
      'total_community_recipes': totalCommunityRecipes,
      'total_ratings': totalRatings,
      'total_meal_plans': totalMealPlans,
      'total_ingredients': totalIngredients,
      'total_pantry_items': totalPantryItems,
      'total_shopping_lists': totalShoppingLists,
      'top_recipes': topRecipes.map((e) => e.toJson()).toList(),
      'recent_activity': recentActivity.map((e) => e.toJson()).toList(),
    };
  }

  SystemAnalyticsModel copyWith({
    int? totalUsers,
    int? totalRecipes,
    int? totalCommunityRecipes,
    int? totalRatings,
    int? totalMealPlans,
    int? totalIngredients,
    int? totalPantryItems,
    int? totalShoppingLists,
    List<TopRecipeModel>? topRecipes,
    List<RecentActivityModel>? recentActivity,
  }) {
    return SystemAnalyticsModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalRecipes: totalRecipes ?? this.totalRecipes,
      totalCommunityRecipes:
          totalCommunityRecipes ?? this.totalCommunityRecipes,
      totalRatings: totalRatings ?? this.totalRatings,
      totalMealPlans: totalMealPlans ?? this.totalMealPlans,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      totalPantryItems: totalPantryItems ?? this.totalPantryItems,
      totalShoppingLists: totalShoppingLists ?? this.totalShoppingLists,
      topRecipes: topRecipes ?? this.topRecipes,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

class TopRecipeModel {
  final String id;
  final String name;
  final double ratingAvg;
  final int ratingCount;

  const TopRecipeModel({
    required this.id,
    required this.name,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
  });

  factory TopRecipeModel.fromJson(Map<String, dynamic> json) {
    return TopRecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
    };
  }

  TopRecipeModel copyWith({
    String? id,
    String? name,
    double? ratingAvg,
    int? ratingCount,
  }) {
    return TopRecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

class RecentActivityModel {
  final String type;
  final String id;
  final String name;
  final DateTime createdAt;
  final String userName;

  const RecentActivityModel({
    required this.type,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.userName,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      type: json['type'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
    };
  }

  RecentActivityModel copyWith({
    String? type,
    String? id,
    String? name,
    DateTime? createdAt,
    String? userName,
  }) {
    return RecentActivityModel(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
    );
  }
}

class UserAnalyticsResponse {
  final bool success;
  final UserAnalyticsModel data;
  final String? message;

  const UserAnalyticsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory UserAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsResponse(
      success: json['success'] as bool,
      data: UserAnalyticsModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson(), 'message': message};
  }
}

class SystemAnalyticsResponse {
  final bool success;
  final SystemAnalyticsModel data;
  final String? message;

  const SystemAnalyticsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory SystemAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return SystemAnalyticsResponse(
      success: json['success'] as bool,
      data: SystemAnalyticsModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson(), 'message': message};
  }
}
