class PantryItemModel {
  final String id;
  final String ingredientId;
  final String ingredientName;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime purchaseDate;
  final String location; // fridge, freezer, pantry, counter
  final String? imageUrl;
  final String status; // fresh, expiring_soon, expired
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItemModel({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.purchaseDate,
    required this.location,
    this.imageUrl,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  int get daysUntilExpiry {
    if (expiryDate == null) return 999;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  double get freshnessPercentage {
    if (expiryDate == null) return 100.0;
    
    final totalDays = expiryDate!.difference(purchaseDate).inDays;
    final daysPassed = DateTime.now().difference(purchaseDate).inDays;
    
    if (totalDays <= 0) return 0.0;
    final freshness = ((totalDays - daysPassed) / totalDays) * 100;
    return freshness.clamp(0.0, 100.0);
  }

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      id: json['id']?.toString() ?? '',
      ingredientId: json['ingredient_id']?.toString() ?? json['ingredientId']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? json['ingredientName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      quantity: _parseDouble(json['quantity']) ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : json['expiryDate'] != null
              ? DateTime.parse(json['expiryDate'])
              : null,
      purchaseDate: DateTime.parse(json['purchase_date'] ?? json['purchaseDate']),
      location: json['location']?.toString() ?? 'fridge',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      status: json['status']?.toString() ?? 'fresh',
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
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
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PantryItemModel copyWith({
    String? id,
    String? ingredientId,
    String? ingredientName,
    String? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? purchaseDate,
    String? location,
    String? imageUrl,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItemModel(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Request models
class CreatePantryItemRequest {
  final String ingredientId;
  final String ingredientName;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime purchaseDate;
  final String location;
  final String? imageUrl;
  final String? notes;

  CreatePantryItemRequest({
    required this.ingredientId,
    required this.ingredientName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.purchaseDate,
    required this.location,
    this.imageUrl,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }
}

class UpdatePantryItemRequest {
  final String? ingredientName;
  final String? category;
  final double? quantity;
  final String? unit;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final String? location;
  final String? imageUrl;
  final String? notes;

  UpdatePantryItemRequest({
    this.ingredientName,
    this.category,
    this.quantity,
    this.unit,
    this.expiryDate,
    this.purchaseDate,
    this.location,
    this.imageUrl,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredientName': ingredientName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }
}

class UsePantryItemRequest {
  final double usedQuantity;
  final String? notes;

  UsePantryItemRequest({
    required this.usedQuantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'usedQuantity': usedQuantity,
      'notes': notes,
    };
  }
}

// Filter and query models
class PantryFilterOptions {
  final String? category;
  final String? location;
  final String? status;
  final String? sortBy; // expiry_date, name, purchase_date, quantity
  final bool? isAscending;

  PantryFilterOptions({
    this.category,
    this.location,
    this.status,
    this.sortBy,
    this.isAscending,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
      if (sortBy != null) 'sort_by': sortBy,
      if (isAscending != null) 'ascending': isAscending,
    };
  }
}