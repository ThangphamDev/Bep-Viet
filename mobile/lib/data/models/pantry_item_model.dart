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
    // Backend returns: quantity (not current_quantity), expire_date (not expiry_date), batch_code (not notes)
    final quantity = double.tryParse(json['quantity']?.toString() ?? json['current_quantity']?.toString() ?? '0') ?? 0.0;
    
    // Parse expiry date
    final expiryDate = json['expire_date'] != null || json['expiry_date'] != null
        ? DateTime.tryParse(json['expire_date']?.toString() ?? json['expiry_date']?.toString() ?? '')
        : null;
    
    // Calculate isExpired and daysUntilExpiry on frontend (more accurate than backend)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Strip time for accurate comparison
    
    int calculatedDaysUntilExpiry = 0;
    bool calculatedIsExpired = false;
    
    if (expiryDate != null) {
      final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
      calculatedDaysUntilExpiry = expiryDay.difference(today).inDays;
      calculatedIsExpired = calculatedDaysUntilExpiry < 0;
    }
    
    return PantryItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      ingredientId: json['ingredient_id']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? 'Nguyên liệu',
      ingredientImage: json['ingredient_image']?.toString(),
      currentQuantity: quantity,
      originalQuantity: double.tryParse(json['original_quantity']?.toString() ?? '') ?? quantity,
      unit: json['unit']?.toString() ?? json['default_unit']?.toString() ?? 'g',
      expiryDate: expiryDate,
      // Use purchase_date if available, otherwise use created_at as purchase date
      purchaseDate: json['purchase_date'] != null 
          ? DateTime.tryParse(json['purchase_date']?.toString() ?? '')
          : DateTime.tryParse(json['created_at']?.toString() ?? ''),
      location: json['location']?.toString() ?? 'fridge',
      notes: json['batch_code']?.toString() ?? json['notes']?.toString(),
      isLowStock: json['is_low_stock'] == true || (json['status']?.toString() == 'low'),
      // Use calculated values instead of backend values for accuracy
      isExpired: calculatedIsExpired,
      daysUntilExpiry: calculatedDaysUntilExpiry,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
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
    final map = {
      'ingredient_id': ingredientId,
      'quantity': quantity.toInt(), // Backend expects integer, not double
      'unit': unit,
      'location': location,
    };
    
    // Only add optional fields if they have values
    if (expiryDate != null) {
      map['expire_date'] = expiryDate!.toIso8601String().split('T')[0];
    }
    final noteValue = notes;
    if (noteValue != null && noteValue.isNotEmpty) {
      map['batch_code'] = noteValue;
    }
    
    return map;
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
    // IMPORTANT: Backend UPDATE requires ALL fields (doesn't support partial updates)
    // Always send all fields with actual values from the dialog
    final json = <String, dynamic>{
      'quantity': quantity?.toInt() ?? 0,  // Backend requires integer
      'unit': unit ?? 'g',  // Provide default if somehow null
      'location': location ?? 'fridge',  // Provide default if somehow null
    };
    
    // Optional field expire_date - send as formatted date string or null
    if (expiryDate != null) {
      json['expire_date'] = expiryDate!.toIso8601String().split('T')[0];
    } else {
      // Don't send the field if null (let backend keep existing value)
      // Or send null explicitly if you want to clear it
      json['expire_date'] = null;
    }
    
    // batch_code - send the notes value (empty string is ok, preserves manual entry info)
    json['batch_code'] = notes ?? '';
    
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
      'quantity': quantity.toInt(), // Backend expects integer
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