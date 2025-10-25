class CommunityRecipe {
  final String id;
  final String title;
  final String? region;
  final String? descriptionMd;
  final String? difficulty;
  final int? timeMin;
  final int? costHint;
  final String? status;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? authorName;
  final String? authorId;
  final int commentCount;
  final int ratingCount;
  final double? avgRating;
  final List<CommunityRecipeIngredient>? ingredients;
  final List<CommunityRecipeStep>? steps;
  final List<RecipeComment>? comments;
  final RecipeRatings? ratings;

  CommunityRecipe({
    required this.id,
    required this.title,
    this.region,
    this.descriptionMd,
    this.difficulty,
    this.timeMin,
    this.costHint,
    this.status,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorId,
    this.commentCount = 0,
    this.ratingCount = 0,
    this.avgRating,
    this.ingredients,
    this.steps,
    this.comments,
    this.ratings,
  });

  factory CommunityRecipe.fromJson(Map<String, dynamic> json) {
    return CommunityRecipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      region: json['region']?.toString(),
      descriptionMd: json['description_md']?.toString(),
      difficulty: json['difficulty']?.toString(),
      timeMin: _parseInt(json['time_min']),
      costHint: _parseInt(json['cost_hint']),
      status: json['status']?.toString(),
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      authorName: json['author_name']?.toString(),
      authorId: json['author_id']?.toString(),
      commentCount: json['comments'] != null
          ? (json['comments'] as List).length
          : (_parseInt(json['comment_count']) ?? 0),
      ratingCount: json['ratings'] != null && json['ratings']['count'] != null
          ? _parseInt(json['ratings']['count']) ?? 0
          : (_parseInt(json['rating_count']) ?? 0),
      avgRating: json['ratings'] != null && json['ratings']['average'] != null
          ? _parseDouble(json['ratings']['average'])
          : _parseDouble(json['avg_rating']),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map(
                  (e) => CommunityRecipeIngredient.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map(
                  (e) =>
                      CommunityRecipeStep.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((e) => RecipeComment.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      ratings: json['ratings'] != null
          ? RecipeRatings.fromJson(json['ratings'] as Map<String, dynamic>)
          : null,
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
      'title': title,
      'region': region,
      'description_md': descriptionMd,
      'difficulty': difficulty,
      'time_min': timeMin,
      'cost_hint': costHint,
      'status': status,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'author_name': authorName,
      'author_id': authorId,
      'comment_count': commentCount,
      'rating_count': ratingCount,
      'avg_rating': avgRating,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'steps': steps?.map((e) => e.toJson()).toList(),
      'comments': comments?.map((e) => e.toJson()).toList(),
      'ratings': ratings?.toJson(),
    };
  }
}

class CommunityRecipeIngredient {
  final String id;
  final String ingredientName;
  final String? quantity;
  final String? note;

  CommunityRecipeIngredient({
    required this.id,
    required this.ingredientName,
    this.quantity,
    this.note,
  });

  factory CommunityRecipeIngredient.fromJson(Map<String, dynamic> json) {
    return CommunityRecipeIngredient(
      id: json['id']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? '',
      quantity: json['quantity']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_name': ingredientName,
      'quantity': quantity,
      'note': note,
    };
  }
}

class CommunityRecipeStep {
  final String id;
  final int orderNo;
  final String contentMd;

  CommunityRecipeStep({
    required this.id,
    required this.orderNo,
    required this.contentMd,
  });

  factory CommunityRecipeStep.fromJson(Map<String, dynamic> json) {
    return CommunityRecipeStep(
      id: json['id']?.toString() ?? '',
      orderNo: _parseInt(json['order_no']) ?? 0,
      contentMd: json['content_md']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'order_no': orderNo, 'content_md': contentMd};
  }
}

class RecipeComment {
  final String id;
  final String content;
  final int likes;
  final DateTime createdAt;
  final String authorName;

  RecipeComment({
    required this.id,
    required this.content,
    this.likes = 0,
    required this.createdAt,
    required this.authorName,
  });

  factory RecipeComment.fromJson(Map<String, dynamic> json) {
    return RecipeComment(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      likes: _parseInt(json['likes']) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorName: json['author_name']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'likes': likes,
      'created_at': createdAt.toIso8601String(),
      'author_name': authorName,
    };
  }
}

class RecipeRatings {
  final double average;
  final int count;
  final List<RecipeRating>? details;

  RecipeRatings({this.average = 0.0, this.count = 0, this.details});

  factory RecipeRatings.fromJson(Map<String, dynamic> json) {
    return RecipeRatings(
      average: _parseDouble(json['average']) ?? 0.0,
      count: _parseInt(json['count']) ?? 0,
      details: json['details'] != null
          ? (json['details'] as List)
                .map((e) => RecipeRating.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
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
      'average': average,
      'count': count,
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }
}

class RecipeRating {
  final int stars;
  final DateTime createdAt;
  final String authorName;
  final String authorId;

  RecipeRating({
    required this.stars,
    required this.createdAt,
    required this.authorName,
    required this.authorId,
  });

  factory RecipeRating.fromJson(Map<String, dynamic> json) {
    return RecipeRating(
      stars: _parseInt(json['stars']) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      authorName: json['author_name']?.toString() ?? '',
      authorId:
          json['author_id']?.toString() ?? json['user_id']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'created_at': createdAt.toIso8601String(),
      'author_name': authorName,
    };
  }
}

class CreateCommunityRecipeRequest {
  final String title;
  final String region;
  final String descriptionMd;
  final String difficulty;
  final int timeMin;
  final int? costHint;
  final String? imageUrl;
  final List<CreateIngredientRequest> ingredients;
  final List<CreateStepRequest> steps;

  CreateCommunityRecipeRequest({
    required this.title,
    required this.region,
    required this.descriptionMd,
    required this.difficulty,
    required this.timeMin,
    this.costHint,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
  });

  factory CreateCommunityRecipeRequest.fromJson(Map<String, dynamic> json) {
    return CreateCommunityRecipeRequest(
      title: json['title']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      descriptionMd: json['description_md']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      timeMin: _parseInt(json['time_min']) ?? 0,
      costHint: _parseInt(json['cost_hint']),
      imageUrl: json['image_url']?.toString(),
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map(
                  (e) => CreateIngredientRequest.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map(
                  (e) => CreateStepRequest.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'region': region,
      'description_md': descriptionMd,
      'difficulty': difficulty,
      'time_min': timeMin,
      'cost_hint': costHint,
      'image_url': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateIngredientRequest {
  final String name;
  final String quantity;
  final String? note;

  CreateIngredientRequest({
    required this.name,
    required this.quantity,
    this.note,
  });

  factory CreateIngredientRequest.fromJson(Map<String, dynamic> json) {
    return CreateIngredientRequest(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'note': note};
  }
}

class CreateStepRequest {
  final int orderNo;
  final String contentMd;

  CreateStepRequest({required this.orderNo, required this.contentMd});

  factory CreateStepRequest.fromJson(Map<String, dynamic> json) {
    return CreateStepRequest(
      orderNo: _parseInt(json['order_no']) ?? 0,
      contentMd: json['content_md']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {'order_no': orderNo, 'content_md': contentMd};
  }
}

class AddCommentRequest {
  final String content;

  AddCommentRequest({required this.content});

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) {
    return AddCommentRequest(content: json['content']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}

class AddRatingRequest {
  final int stars;

  AddRatingRequest({required this.stars});

  factory AddRatingRequest.fromJson(Map<String, dynamic> json) {
    return AddRatingRequest(stars: _parseInt(json['stars']) ?? 0);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {'stars': stars};
  }
}

class CommunityFilters {
  final String? region;
  final String? difficulty;
  final int? maxTime;
  final String? search;
  final int? limit;

  CommunityFilters({
    this.region,
    this.difficulty,
    this.maxTime,
    this.search,
    this.limit,
  });

  factory CommunityFilters.fromJson(Map<String, dynamic> json) {
    return CommunityFilters(
      region: json['region']?.toString(),
      difficulty: json['difficulty']?.toString(),
      maxTime: _parseInt(json['maxTime']) ?? _parseInt(json['max_time']),
      search: json['search']?.toString(),
      limit: _parseInt(json['limit']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'difficulty': difficulty,
      'max_time': maxTime,
      'search': search,
      'limit': limit,
    };
  }
}

class CommunityResponse {
  final bool success;
  final List<CommunityRecipe> data;
  final String? message;

  CommunityResponse({required this.success, required this.data, this.message});

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      success: json['success'] == true,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((e) => CommunityRecipe.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class CommunityDetailResponse {
  final bool success;
  final CommunityRecipe data;
  final String? message;

  CommunityDetailResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory CommunityDetailResponse.fromJson(Map<String, dynamic> json) {
    return CommunityDetailResponse(
      success: json['success'] == true,
      data: CommunityRecipe.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson(), 'message': message};
  }
}
