class PantryItemModel {
  final String id;
  final String userId;
  final String ingredientId;
  final String ingredientName;
  final String? ingredientImage;
  final double currentQuantity;
  final double originalQuantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final String location; // 'fridge', 'freezer', 'pantry', 'cabinet'
  final String? notes;
  final bool isLowStock;
  final bool isExpired;
  final int daysUntilExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItemModel({
    required this.id,
    required this.userId,
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImage,
    required this.currentQuantity,
    required this.originalQuantity,
    required this.unit,
    this.expiryDate,
    this.purchaseDate,
    required this.location,
    this.notes,
    required this.isLowStock,
    required this.isExpired,
    required this.daysUntilExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      id: json['id'],
      userId: json['user_id'],
      ingredientId: json['ingredient_id'],
      ingredientName: json['ingredient_name'],
      ingredientImage: json['ingredient_image'],
      currentQuantity: double.parse(json['current_quantity'].toString()),
      originalQuantity: double.parse(json['original_quantity'].toString()),
      unit: json['unit'],
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.parse(json['purchase_date']) 
          : null,
      location: json['location'],
      notes: json['notes'],
      isLowStock: json['is_low_stock'] ?? false,
      isExpired: json['is_expired'] ?? false,
      daysUntilExpiry: json['days_until_expiry'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'ingredient_image': ingredientImage,
      'current_quantity': currentQuantity,
      'original_quantity': originalQuantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'purchase_date': purchaseDate?.toIso8601String(),
      'location': location,
      'notes': notes,
      'is_low_stock': isLowStock,
      'is_expired': isExpired,
      'days_until_expiry': daysUntilExpiry,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isExpiringSoon => !isExpired && daysUntilExpiry <= 3 && daysUntilExpiry > 0;
  double get usagePercentage => originalQuantity > 0 
      ? ((originalQuantity - currentQuantity) / originalQuantity * 100).clamp(0, 100)
      : 0;
  
  String get statusText {
    if (isExpired) return 'Đã hết hạn';
    if (isExpiringSoon) return 'Sắp hết hạn';
    if (isLowStock) return 'Sắp hết';
    return 'Tốt';
  }

  PantryItemModel copyWith({
    String? id,
    String? userId,
    String? ingredientId,
    String? ingredientName,
    String? ingredientImage,
    double? currentQuantity,
    double? originalQuantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? purchaseDate,
    String? location,
    String? notes,
    bool? isLowStock,
    bool? isExpired,
    int? daysUntilExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      ingredientImage: ingredientImage ?? this.ingredientImage,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      originalQuantity: originalQuantity ?? this.originalQuantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isLowStock: isLowStock ?? this.isLowStock,
      isExpired: isExpired ?? this.isExpired,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PantryStatsModel {
  final int totalItems;
  final int expiredItems;
  final int expiringItems;
  final int lowStockItems;
  final double totalValue;
  final Map<String, int> itemsByLocation;
  final Map<String, int> itemsByCategory;

  PantryStatsModel({
    required this.totalItems,
    required this.expiredItems,
    required this.expiringItems,
    required this.lowStockItems,
    required this.totalValue,
    required this.itemsByLocation,
    required this.itemsByCategory,
  });

  factory PantryStatsModel.fromJson(Map<String, dynamic> json) {
    return PantryStatsModel(
      totalItems: json['total_items'] ?? 0,
      expiredItems: json['expired_items'] ?? 0,
      expiringItems: json['expiring_items'] ?? 0,
      lowStockItems: json['low_stock_items'] ?? 0,
      totalValue: double.parse(json['total_value']?.toString() ?? '0'),
      itemsByLocation: Map<String, int>.from(json['items_by_location'] ?? {}),
      itemsByCategory: Map<String, int>.from(json['items_by_category'] ?? {}),
    );
  }
}

// Request DTOs
class AddPantryItemDto {
  final String ingredientId;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final String location;
  final String? notes;

  AddPantryItemDto({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.purchaseDate,
    required this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'purchase_date': purchaseDate?.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }
}

class UpdatePantryItemDto {
  final double? quantity;
  final String? unit;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final String? location;
  final String? notes;

  UpdatePantryItemDto({
    this.quantity,
    this.unit,
    this.expiryDate,
    this.purchaseDate,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (quantity != null) json['quantity'] = quantity;
    if (unit != null) json['unit'] = unit;
    if (expiryDate != null) json['expiry_date'] = expiryDate!.toIso8601String();
    if (purchaseDate != null) json['purchase_date'] = purchaseDate!.toIso8601String();
    if (location != null) json['location'] = location;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}

class ConsumePantryItemDto {
  final String ingredientId;
  final double quantity;

  ConsumePantryItemDto({
    required this.ingredientId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'quantity': quantity,
    };
  }
}

enum PantryLocation {
  fridge('Tủ lạnh', 'fridge'),
  freezer('Ngăn đông', 'freezer'),
  pantry('Tủ kho', 'pantry'),
  cabinet('Tủ bếp', 'cabinet');

  const PantryLocation(this.displayName, this.value);
  final String displayName;
  final String value;
}