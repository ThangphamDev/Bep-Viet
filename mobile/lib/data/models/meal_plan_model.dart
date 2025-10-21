class MealPlanModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int servings;
  final String? region;
  final double? budget;
  final List<MealPlanDayModel> days;
  final double? totalCost;
  final Map<String, dynamic>? nutritionSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlanModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.servings,
    this.region,
    this.budget,
    required this.days,
    this.totalCost,
    this.nutritionSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      servings: _parseInt(json['servings']) ?? 4,
      region: json['region']?.toString(),
      budget: _parseDouble(json['budget']),
      days: json['days'] != null
          ? (json['days'] as List)
              .map((e) => MealPlanDayModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      totalCost: _parseDouble(json['total_cost'] ?? json['totalCost']),
      nutritionSummary: json['nutrition_summary'] ?? json['nutritionSummary'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'servings': servings,
      'region': region,
      'budget': budget,
      'days': days.map((e) => e.toJson()).toList(),
      'totalCost': totalCost,
      'nutritionSummary': nutritionSummary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MealPlanDayModel {
  final String dayOfWeek;
  final DateTime date;
  final List<MealSlotModel> meals;

  MealPlanDayModel({
    required this.dayOfWeek,
    required this.date,
    required this.meals,
  });

  factory MealPlanDayModel.fromJson(Map<String, dynamic> json) {
    return MealPlanDayModel(
      dayOfWeek: json['day_of_week'] ?? json['dayOfWeek'] ?? '',
      date: DateTime.parse(json['date']),
      meals: json['meals'] != null
          ? (json['meals'] as List)
              .map((e) => MealSlotModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'date': date.toIso8601String(),
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }
}

class MealSlotModel {
  final String mealType; // breakfast, lunch, dinner
  final String? recipeId;
  final String? recipeName;
  final String? recipeImage;
  final int? cookTime;
  final int? servings;
  final double? estimatedCost;

  MealSlotModel({
    required this.mealType,
    this.recipeId,
    this.recipeName,
    this.recipeImage,
    this.cookTime,
    this.servings,
    this.estimatedCost,
  });

  factory MealSlotModel.fromJson(Map<String, dynamic> json) {
    return MealSlotModel(
      mealType: json['meal_type'] ?? json['mealType'] ?? '',
      recipeId: json['recipe_id']?.toString() ?? json['recipeId']?.toString(),
      recipeName: json['recipe_name']?.toString() ?? json['recipeName']?.toString(),
      recipeImage: json['recipe_image']?.toString() ?? json['recipeImage']?.toString(),
      cookTime: MealPlanModel._parseInt(json['cook_time'] ?? json['cookTime']),
      servings: MealPlanModel._parseInt(json['servings']),
      estimatedCost: MealPlanModel._parseDouble(json['estimated_cost'] ?? json['estimatedCost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImage': recipeImage,
      'cookTime': cookTime,
      'servings': servings,
      'estimatedCost': estimatedCost,
    };
  }
}

// Request models
class CreateMealPlanRequest {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int servings;
  final String? region;
  final double? budget;
  final List<String>? preferredMealTypes;
  final Map<String, dynamic>? nutritionPreferences;

  CreateMealPlanRequest({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.servings,
    this.region,
    this.budget,
    this.preferredMealTypes,
    this.nutritionPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'servings': servings,
      'region': region,
      'budget': budget,
      'preferredMealTypes': preferredMealTypes,
      'nutritionPreferences': nutritionPreferences,
    };
  }
}