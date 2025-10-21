// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityRecipeImpl _$$CommunityRecipeImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityRecipeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      region: json['region'] as String?,
      descriptionMd: json['description_md'] as String?,
      difficulty: json['difficulty'] as String?,
      timeMin: (json['time_min'] as num?)?.toInt(),
      costHint: (json['cost_hint'] as num?)?.toInt(),
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      authorName: json['author_name'] as String?,
      authorId: json['author_id'] as String?,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      avgRating:
          json['avg_rating'] == null ? 0.0 : _parseDouble(json['avg_rating']),
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) =>
              CommunityRecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => CommunityRecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => RecipeComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      ratings: json['ratings'] == null
          ? null
          : RecipeRatings.fromJson(json['ratings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CommunityRecipeImplToJson(
        _$CommunityRecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'region': instance.region,
      'description_md': instance.descriptionMd,
      'difficulty': instance.difficulty,
      'time_min': instance.timeMin,
      'cost_hint': instance.costHint,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'author_name': instance.authorName,
      'author_id': instance.authorId,
      'comment_count': instance.commentCount,
      'rating_count': instance.ratingCount,
      'avg_rating': instance.avgRating,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
      'comments': instance.comments,
      'ratings': instance.ratings,
    };

_$CommunityRecipeIngredientImpl _$$CommunityRecipeIngredientImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityRecipeIngredientImpl(
      id: json['id'] as String,
      ingredientName: json['ingredientName'] as String,
      quantity: json['quantity'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$CommunityRecipeIngredientImplToJson(
        _$CommunityRecipeIngredientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredientName': instance.ingredientName,
      'quantity': instance.quantity,
      'note': instance.note,
    };

_$CommunityRecipeStepImpl _$$CommunityRecipeStepImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityRecipeStepImpl(
      id: json['id'] as String,
      orderNo: (json['orderNo'] as num).toInt(),
      contentMd: json['contentMd'] as String,
    );

Map<String, dynamic> _$$CommunityRecipeStepImplToJson(
        _$CommunityRecipeStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNo': instance.orderNo,
      'contentMd': instance.contentMd,
    };

_$RecipeCommentImpl _$$RecipeCommentImplFromJson(Map<String, dynamic> json) =>
    _$RecipeCommentImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorName: json['authorName'] as String,
    );

Map<String, dynamic> _$$RecipeCommentImplToJson(_$RecipeCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'likes': instance.likes,
      'createdAt': instance.createdAt.toIso8601String(),
      'authorName': instance.authorName,
    };

_$RecipeRatingsImpl _$$RecipeRatingsImplFromJson(Map<String, dynamic> json) =>
    _$RecipeRatingsImpl(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => RecipeRating.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RecipeRatingsImplToJson(_$RecipeRatingsImpl instance) =>
    <String, dynamic>{
      'average': instance.average,
      'count': instance.count,
      'details': instance.details,
    };

_$RecipeRatingImpl _$$RecipeRatingImplFromJson(Map<String, dynamic> json) =>
    _$RecipeRatingImpl(
      stars: (json['stars'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorName: json['authorName'] as String,
    );

Map<String, dynamic> _$$RecipeRatingImplToJson(_$RecipeRatingImpl instance) =>
    <String, dynamic>{
      'stars': instance.stars,
      'createdAt': instance.createdAt.toIso8601String(),
      'authorName': instance.authorName,
    };

_$CreateCommunityRecipeRequestImpl _$$CreateCommunityRecipeRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateCommunityRecipeRequestImpl(
      title: json['title'] as String,
      region: json['region'] as String,
      descriptionMd: json['descriptionMd'] as String,
      difficulty: json['difficulty'] as String,
      timeMin: (json['timeMin'] as num).toInt(),
      costHint: (json['costHint'] as num?)?.toInt(),
      imageBase64: json['imageBase64'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) =>
              CreateIngredientRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => CreateStepRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CreateCommunityRecipeRequestImplToJson(
        _$CreateCommunityRecipeRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'region': instance.region,
      'descriptionMd': instance.descriptionMd,
      'difficulty': instance.difficulty,
      'timeMin': instance.timeMin,
      'costHint': instance.costHint,
      'imageBase64': instance.imageBase64,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
    };

_$CreateIngredientRequestImpl _$$CreateIngredientRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateIngredientRequestImpl(
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$CreateIngredientRequestImplToJson(
        _$CreateIngredientRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'note': instance.note,
    };

_$CreateStepRequestImpl _$$CreateStepRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateStepRequestImpl(
      orderNo: (json['orderNo'] as num).toInt(),
      contentMd: json['contentMd'] as String,
    );

Map<String, dynamic> _$$CreateStepRequestImplToJson(
        _$CreateStepRequestImpl instance) =>
    <String, dynamic>{
      'orderNo': instance.orderNo,
      'contentMd': instance.contentMd,
    };

_$AddCommentRequestImpl _$$AddCommentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AddCommentRequestImpl(
      content: json['content'] as String,
    );

Map<String, dynamic> _$$AddCommentRequestImplToJson(
        _$AddCommentRequestImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

_$AddRatingRequestImpl _$$AddRatingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AddRatingRequestImpl(
      stars: (json['stars'] as num).toInt(),
    );

Map<String, dynamic> _$$AddRatingRequestImplToJson(
        _$AddRatingRequestImpl instance) =>
    <String, dynamic>{
      'stars': instance.stars,
    };

_$CommunityFiltersImpl _$$CommunityFiltersImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityFiltersImpl(
      region: json['region'] as String?,
      difficulty: json['difficulty'] as String?,
      maxTime: (json['maxTime'] as num?)?.toInt(),
      search: json['search'] as String?,
      limit: (json['limit'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CommunityFiltersImplToJson(
        _$CommunityFiltersImpl instance) =>
    <String, dynamic>{
      'region': instance.region,
      'difficulty': instance.difficulty,
      'maxTime': instance.maxTime,
      'search': instance.search,
      'limit': instance.limit,
    };

_$CommunityResponseImpl _$$CommunityResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityResponseImpl(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => CommunityRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CommunityResponseImplToJson(
        _$CommunityResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

_$CommunityDetailResponseImpl _$$CommunityDetailResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CommunityDetailResponseImpl(
      success: json['success'] as bool,
      data: CommunityRecipe.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CommunityDetailResponseImplToJson(
        _$CommunityDetailResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };
