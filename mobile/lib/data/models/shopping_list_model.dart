class ShoppingListModel {
  final String id;
  final String name;
  final String status; // pending, in_progress, completed
  final String storeType; // traditional_market, supermarket, convenience_store
  final double? estimatedCost;
  final double? actualCost;
  final int completedItems;
  final int totalItems;
  final bool isShared;
  final List<String>? sharedWith;
  final List<ShoppingItemModel> items;
  final String? mealPlanId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListModel({
    required this.id,
    required this.name,
    required this.status,
    required this.storeType,
    this.estimatedCost,
    this.actualCost,
    required this.completedItems,
    required this.totalItems,
    required this.isShared,
    this.sharedWith,
    required this.items,
    this.mealPlanId,
    required this.createdAt,
    required this.updatedAt,
  });

  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (completedItems / totalItems) * 100;
  }

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      storeType: json['store_type']?.toString() ?? json['storeType']?.toString() ?? 'traditional_market',
      estimatedCost: _parseDouble(json['estimated_cost'] ?? json['estimatedCost']),
      actualCost: _parseDouble(json['actual_cost'] ?? json['actualCost']),
      completedItems: _parseInt(json['completed_items'] ?? json['completedItems']) ?? 0,
      totalItems: _parseInt(json['total_items'] ?? json['totalItems']) ?? 0,
      isShared: json['is_shared'] ?? json['isShared'] ?? false,
      sharedWith: json['shared_with'] != null
          ? List<String>.from(json['shared_with'])
          : json['sharedWith'] != null
              ? List<String>.from(json['sharedWith'])
              : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => ShoppingItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      mealPlanId: json['meal_plan_id']?.toString() ?? json['mealPlanId']?.toString(),
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
      'status': status,
      'storeType': storeType,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'completedItems': completedItems,
      'totalItems': totalItems,
      'isShared': isShared,
      'sharedWith': sharedWith,
      'items': items.map((e) => e.toJson()).toList(),
      'mealPlanId': mealPlanId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ShoppingItemModel {
  final String id;
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final bool isCompleted;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? notes;
  final String? category;

  ShoppingItemModel({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.isCompleted,
    this.estimatedPrice,
    this.actualPrice,
    this.notes,
    this.category,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id']?.toString() ?? '',
      ingredientId: json['ingredient_id']?.toString() ?? json['ingredientId']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? json['ingredientName']?.toString() ?? '',
      quantity: ShoppingListModel._parseDouble(json['quantity']) ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      estimatedPrice: ShoppingListModel._parseDouble(json['estimated_price'] ?? json['estimatedPrice']),
      actualPrice: ShoppingListModel._parseDouble(json['actual_price'] ?? json['actualPrice']),
      notes: json['notes']?.toString(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'isCompleted': isCompleted,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'notes': notes,
      'category': category,
    };
  }
}

// Request models
class CreateShoppingListRequest {
  final String name;
  final String storeType;
  final String? source; // manual, meal_plan, pantry
  final String? mealPlanId;
  final bool checkPantry;
  final List<ShoppingItemRequest>? items;

  CreateShoppingListRequest({
    required this.name,
    required this.storeType,
    this.source,
    this.mealPlanId,
    required this.checkPantry,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'storeType': storeType,
      'source': source,
      'mealPlanId': mealPlanId,
      'checkPantry': checkPantry,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}

class ShoppingItemRequest {
  final String ingredientId;
  final double quantity;
  final String unit;
  final String? notes;

  ShoppingItemRequest({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }
}

class UpdateShoppingItemRequest {
  final bool? isCompleted;
  final double? actualPrice;
  final String? notes;

  UpdateShoppingItemRequest({
    this.isCompleted,
    this.actualPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'isCompleted': isCompleted,
      'actualPrice': actualPrice,
      'notes': notes,
    };
  }
}