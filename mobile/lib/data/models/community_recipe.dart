import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_recipe.freezed.dart';
part 'community_recipe.g.dart';

@freezed
class CommunityRecipe with _$CommunityRecipe {
  const factory CommunityRecipe({
    required String id,
    required String title,
    String? region,
    @JsonKey(name: 'description_md') String? descriptionMd,
    String? difficulty,
    @JsonKey(name: 'time_min') int? timeMin,
    @JsonKey(name: 'cost_hint') int? costHint,
    String? status,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'author_id') String? authorId,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'rating_count') @Default(0) int ratingCount,
    @JsonKey(name: 'avg_rating', fromJson: _parseDouble) @Default(0.0) double avgRating,
    List<CommunityRecipeIngredient>? ingredients,
    List<CommunityRecipeStep>? steps,
    List<RecipeComment>? comments,
    RecipeRatings? ratings,
  }) = _CommunityRecipe;

  factory CommunityRecipe.fromJson(Map<String, dynamic> json) =>
      _$CommunityRecipeFromJson(json);
}

// Helper function to parse double from string or number
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

@freezed
class CommunityRecipeIngredient with _$CommunityRecipeIngredient {
  const factory CommunityRecipeIngredient({
    required String id,
    required String ingredientName,
    String? quantity,
    String? note,
  }) = _CommunityRecipeIngredient;

  factory CommunityRecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$CommunityRecipeIngredientFromJson(json);
}

@freezed
class CommunityRecipeStep with _$CommunityRecipeStep {
  const factory CommunityRecipeStep({
    required String id,
    required int orderNo,
    required String contentMd,
  }) = _CommunityRecipeStep;

  factory CommunityRecipeStep.fromJson(Map<String, dynamic> json) =>
      _$CommunityRecipeStepFromJson(json);
}

@freezed
class RecipeComment with _$RecipeComment {
  const factory RecipeComment({
    required String id,
    required String content,
    @Default(0) int likes,
    required DateTime createdAt,
    required String authorName,
  }) = _RecipeComment;

  factory RecipeComment.fromJson(Map<String, dynamic> json) =>
      _$RecipeCommentFromJson(json);
}

@freezed
class RecipeRatings with _$RecipeRatings {
  const factory RecipeRatings({
    @Default(0.0) double average,
    @Default(0) int count,
    List<RecipeRating>? details,
  }) = _RecipeRatings;

  factory RecipeRatings.fromJson(Map<String, dynamic> json) =>
      _$RecipeRatingsFromJson(json);
}

@freezed
class RecipeRating with _$RecipeRating {
  const factory RecipeRating({
    required int stars,
    required DateTime createdAt,
    required String authorName,
  }) = _RecipeRating;

  factory RecipeRating.fromJson(Map<String, dynamic> json) =>
      _$RecipeRatingFromJson(json);
}

@freezed
class CreateCommunityRecipeRequest with _$CreateCommunityRecipeRequest {
  const factory CreateCommunityRecipeRequest({
    required String title,
    required String region,
    @JsonKey(name: 'description_md') required String descriptionMd,
    required String difficulty,
    @JsonKey(name: 'time_min') required int timeMin,
    @JsonKey(name: 'cost_hint') int? costHint,
    String? imageBase64,
    required List<CreateIngredientRequest> ingredients,
    required List<CreateStepRequest> steps,
  }) = _CreateCommunityRecipeRequest;

  factory CreateCommunityRecipeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommunityRecipeRequestFromJson(json);
}

@freezed
class CreateIngredientRequest with _$CreateIngredientRequest {
  const factory CreateIngredientRequest({
    required String name,
    String? quantity,
    String? note,
  }) = _CreateIngredientRequest;

  factory CreateIngredientRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateIngredientRequestFromJson(json);
}

@freezed
class CreateStepRequest with _$CreateStepRequest {
  const factory CreateStepRequest({
    @JsonKey(name: 'order_no') required int orderNo,
    @JsonKey(name: 'content_md') required String contentMd,
  }) = _CreateStepRequest;

  factory CreateStepRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStepRequestFromJson(json);
}

@freezed
class AddCommentRequest with _$AddCommentRequest {
  const factory AddCommentRequest({
    required String content,
  }) = _AddCommentRequest;

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCommentRequestFromJson(json);
}

@freezed
class AddRatingRequest with _$AddRatingRequest {
  const factory AddRatingRequest({
    required int stars,
  }) = _AddRatingRequest;

  factory AddRatingRequest.fromJson(Map<String, dynamic> json) =>
      _$AddRatingRequestFromJson(json);
}

@freezed
class CommunityFilters with _$CommunityFilters {
  const factory CommunityFilters({
    String? region,
    String? difficulty,
    int? maxTime,
    String? search,
    int? limit,
  }) = _CommunityFilters;

  factory CommunityFilters.fromJson(Map<String, dynamic> json) =>
      _$CommunityFiltersFromJson(json);
}

@freezed
class CommunityResponse with _$CommunityResponse {
  const factory CommunityResponse({
    required bool success,
    required List<CommunityRecipe> data,
    String? message,
  }) = _CommunityResponse;

  factory CommunityResponse.fromJson(Map<String, dynamic> json) =>
      _$CommunityResponseFromJson(json);
}

@freezed
class CommunityDetailResponse with _$CommunityDetailResponse {
  const factory CommunityDetailResponse({
    required bool success,
    required CommunityRecipe data,
    String? message,
  }) = _CommunityDetailResponse;

  factory CommunityDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CommunityDetailResponseFromJson(json);
}
