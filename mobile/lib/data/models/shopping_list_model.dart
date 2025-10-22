class ShoppingListModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<ShoppingItem> items;
  final bool isShared;
  final List<SharedUser> sharedWith;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.items,
    required this.isShared,
    required this.sharedWith,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Danh sách mua sắm',
      description: json['description']?.toString(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ShoppingItem.fromJson(item))
          .toList() ?? [],
      isShared: _parseBool(json['is_shared']),
      sharedWith: (json['shared_with'] as List<dynamic>?)
          ?.map((user) => SharedUser.fromJson(user))
          .toList() ?? [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'is_shared': isShared,
      'shared_with': sharedWith.map((user) => user.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ShoppingItem {
  final String id;
  final String shoppingListId;
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final bool isChecked;
  final String? notes;
  final String? storeSectionId;
  final String? storeSectionName;
  final double? estimatedPrice;
  final int priority;

  ShoppingItem({
    required this.id,
    required this.shoppingListId,
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.isChecked,
    this.notes,
    this.storeSectionId,
    this.storeSectionName,
    this.estimatedPrice,
    required this.priority,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      shoppingListId: json['shopping_list_id']?.toString() ?? '',
      ingredientId: json['ingredient_id']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? 'Nguyên liệu',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? 'cái',
      isChecked: ShoppingListModel._parseBool(json['is_checked']),
      notes: json['notes']?.toString(),
      storeSectionId: json['store_section_id']?.toString(),
      storeSectionName: json['store_section_name']?.toString(),
      estimatedPrice: json['estimated_price']?.toDouble(),
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'is_checked': isChecked,
      'notes': notes,
      'store_section_id': storeSectionId,
      'store_section_name': storeSectionName,
      'estimated_price': estimatedPrice,
      'priority': priority,
    };
  }
}

class SharedUser {
  final String userId;
  final String userName;
  final String? userEmail;
  final String permission; // 'view' or 'edit'

  SharedUser({
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.permission,
  });

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    return SharedUser(
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      permission: json['permission']?.toString() ?? 'view',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'permission': permission,
    };
  }
}

class StoreSection {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;

  StoreSection({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
  });

  factory StoreSection.fromJson(Map<String, dynamic> json) {
    return StoreSection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'display_order': displayOrder,
    };
  }
}

// Request DTOs
class CreateShoppingListDto {
  final String name;
  final String? description;

  CreateShoppingListDto({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': name, // Backend expects 'title', not 'name'
      if (description != null) 'week_range': description, // Backend uses 'week_range' for description
    };
  }
}

class AddShoppingItemDto {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? notes;
  final String? section;
  final double? estimatedPrice;

  AddShoppingItemDto({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.notes,
    this.section,
    this.estimatedPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'quantity': quantity.toInt(), // Backend expects int, not double
      'unit': unit,
      if (notes != null) 'note': notes, // Backend uses 'note' (singular), not 'notes'
      if (section != null) 'store_section': section, // Backend uses 'store_section'
    };
  }
}

class UpdateShoppingItemDto {
  final double? quantity;
  final String? unit;
  final String? notes;
  final String? section;
  final double? estimatedPrice;
  final double? actualPrice;
  final bool? isPurchased;

  UpdateShoppingItemDto({
    this.quantity,
    this.unit,
    this.notes,
    this.section,
    this.estimatedPrice,
    this.actualPrice,
    this.isPurchased,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (quantity != null) json['quantity'] = quantity;
    if (unit != null) json['unit'] = unit;
    if (notes != null) json['notes'] = notes;
    if (section != null) json['section'] = section;
    if (estimatedPrice != null) json['estimated_price'] = estimatedPrice;
    if (actualPrice != null) json['actual_price'] = actualPrice;
    if (isPurchased != null) json['checked'] = isPurchased; // Backend expects 'checked', not 'is_purchased'
    return json;
  }
}

class AddItemDto {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? notes;
  final String? storeSectionId;
  final int priority;

  AddItemDto({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.notes,
    this.storeSectionId,
    this.priority = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'store_section_id': storeSectionId,
      'priority': priority,
    };
  }
}

class ShareListDto {
  final String email;
  final String permission; // 'view' or 'edit'

  ShareListDto({
    required this.email,
    required this.permission,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'permission': permission,
    };
  }
}