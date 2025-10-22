class MealPlanModel {
  final String id;
  final String userId;
  final String weekStartDate;
  final String name;
  final String? description;
  final List<MealSlot> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlanModel({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.name,
    this.description,
    required this.meals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    // Handle both backend formats
    List<MealSlot> meals = [];
    
    if (json['items'] != null) {
      // Backend format with 'items'
      meals = (json['items'] as List<dynamic>)
          .map((item) => MealSlot.fromJson(item))
          .toList();
    } else if (json['meals'] != null) {
      // Frontend format with 'meals'
      meals = (json['meals'] as List<dynamic>)
          .map((meal) => MealSlot.fromJson(meal))
          .toList();
    }

    return MealPlanModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      weekStartDate: json['week_start_date']?.toString() ?? '',
      name: json['name']?.toString() ?? json['note']?.toString() ?? 'Kế hoạch bữa ăn',
      description: json['description']?.toString() ?? json['note']?.toString(),
      meals: meals,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'week_start_date': weekStartDate,
      'name': name,
      'description': description,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MealSlot {
  final String id;
  final String mealPlanId;
  final String date;
  final MealType mealType;
  final String? recipeId;
  final String? recipeName;
  final String? recipeImage;
  final int servings;
  final DateTime? plannedTime;

  MealSlot({
    required this.id,
    required this.mealPlanId,
    required this.date,
    required this.mealType,
    this.recipeId,
    this.recipeName,
    this.recipeImage,
    required this.servings,
    this.plannedTime,
  });

  factory MealSlot.fromJson(Map<String, dynamic> json) {
    // Parse meal type properly
    String mealSlotString = (json['meal_slot'] ?? json['meal_type'] ?? 'breakfast').toString().toLowerCase();
    MealType mealType;
    switch (mealSlotString) {
      case 'breakfast':
        mealType = MealType.breakfast;
        break;
      case 'lunch':
        mealType = MealType.lunch;
        break;
      case 'dinner':
        mealType = MealType.dinner;
        break;
      case 'snack':
        mealType = MealType.snack;
        break;
      default:
        mealType = MealType.breakfast;
    }
    
    return MealSlot(
      id: json['id']?.toString() ?? '',
      mealPlanId: json['meal_plan_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      mealType: mealType,
      recipeId: json['recipe_id']?.toString(),
      recipeName: json['recipe_name']?.toString() ?? json['name_vi']?.toString() ?? json['name_en']?.toString(),
      recipeImage: json['recipe_image']?.toString() ?? json['image_url']?.toString(),
      servings: int.tryParse(json['servings']?.toString() ?? '1') ?? 1,
      plannedTime: json['planned_time'] != null 
          ? DateTime.tryParse(json['planned_time']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_plan_id': mealPlanId,
      'date': date,
      'meal_slot': mealType.name.toUpperCase(),
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'recipe_image': recipeImage,
      'servings': servings,
      'planned_time': plannedTime?.toIso8601String(),
    };
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

// Request DTOs
class CreateMealPlanDto {
  final String weekStartDate;
  final String? note;

  CreateMealPlanDto({
    required this.weekStartDate,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'week_start_date': weekStartDate,
      'note': note,
    };
  }
}

class AddMealDto {
  final String date;
  final String mealSlot;
  final String recipeId;
  final String? variantRegion;
  final int servings;

  AddMealDto({
    required this.date,
    required this.mealSlot,
    required this.recipeId,
    this.variantRegion,
    required this.servings,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'meal_slot': mealSlot,
      'recipe_id': recipeId,
      'variant_region': variantRegion,
      'servings': servings,
    };
  }
}

class QuickAddMealDto {
  final String recipeId;
  final String mealSlot;
  final int servings;
  final String? variantRegion;

  QuickAddMealDto({
    required this.recipeId,
    required this.mealSlot,
    required this.servings,
    this.variantRegion,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'meal_slot': mealSlot,
      'servings': servings,
      'variant_region': variantRegion,
    };
  }
}

class GenerateMealPlanDto {
  final String weekStartDate;
  final int servings;
  final List<String>? preferences;
  final List<String>? excludeIngredients;
  final String? budgetRange;

  GenerateMealPlanDto({
    required this.weekStartDate,
    required this.servings,
    this.preferences,
    this.excludeIngredients,
    this.budgetRange,
  });

  Map<String, dynamic> toJson() {
    return {
      'week_start_date': weekStartDate,
      'servings': servings,
      'preferences': preferences,
      'exclude_ingredients': excludeIngredients,
      'budget_range': budgetRange,
    };
  }
}