// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityRecipe _$CommunityRecipeFromJson(Map<String, dynamic> json) {
  return _CommunityRecipe.fromJson(json);
}

/// @nodoc
mixin _$CommunityRecipe {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  @JsonKey(name: 'description_md')
  String? get descriptionMd => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_min')
  int? get timeMin => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_hint')
  int? get costHint => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String? get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String? get authorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_count')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'rating_count')
  int get ratingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_rating', fromJson: _parseDouble)
  double get avgRating => throw _privateConstructorUsedError;
  List<CommunityRecipeIngredient>? get ingredients =>
      throw _privateConstructorUsedError;
  List<CommunityRecipeStep>? get steps => throw _privateConstructorUsedError;
  List<RecipeComment>? get comments => throw _privateConstructorUsedError;
  RecipeRatings? get ratings => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityRecipeCopyWith<CommunityRecipe> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityRecipeCopyWith<$Res> {
  factory $CommunityRecipeCopyWith(
          CommunityRecipe value, $Res Function(CommunityRecipe) then) =
      _$CommunityRecipeCopyWithImpl<$Res, CommunityRecipe>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? region,
      @JsonKey(name: 'description_md') String? descriptionMd,
      String? difficulty,
      @JsonKey(name: 'time_min') int? timeMin,
      @JsonKey(name: 'cost_hint') int? costHint,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'author_id') String? authorId,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'rating_count') int ratingCount,
      @JsonKey(name: 'avg_rating', fromJson: _parseDouble) double avgRating,
      List<CommunityRecipeIngredient>? ingredients,
      List<CommunityRecipeStep>? steps,
      List<RecipeComment>? comments,
      RecipeRatings? ratings});

  $RecipeRatingsCopyWith<$Res>? get ratings;
}

/// @nodoc
class _$CommunityRecipeCopyWithImpl<$Res, $Val extends CommunityRecipe>
    implements $CommunityRecipeCopyWith<$Res> {
  _$CommunityRecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? region = freezed,
    Object? descriptionMd = freezed,
    Object? difficulty = freezed,
    Object? timeMin = freezed,
    Object? costHint = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? authorName = freezed,
    Object? authorId = freezed,
    Object? commentCount = null,
    Object? ratingCount = null,
    Object? avgRating = null,
    Object? ingredients = freezed,
    Object? steps = freezed,
    Object? comments = freezed,
    Object? ratings = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionMd: freezed == descriptionMd
          ? _value.descriptionMd
          : descriptionMd // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      timeMin: freezed == timeMin
          ? _value.timeMin
          : timeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      costHint: freezed == costHint
          ? _value.costHint
          : costHint // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipeIngredient>?,
      steps: freezed == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipeStep>?,
      comments: freezed == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<RecipeComment>?,
      ratings: freezed == ratings
          ? _value.ratings
          : ratings // ignore: cast_nullable_to_non_nullable
              as RecipeRatings?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RecipeRatingsCopyWith<$Res>? get ratings {
    if (_value.ratings == null) {
      return null;
    }

    return $RecipeRatingsCopyWith<$Res>(_value.ratings!, (value) {
      return _then(_value.copyWith(ratings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityRecipeImplCopyWith<$Res>
    implements $CommunityRecipeCopyWith<$Res> {
  factory _$$CommunityRecipeImplCopyWith(_$CommunityRecipeImpl value,
          $Res Function(_$CommunityRecipeImpl) then) =
      __$$CommunityRecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? region,
      @JsonKey(name: 'description_md') String? descriptionMd,
      String? difficulty,
      @JsonKey(name: 'time_min') int? timeMin,
      @JsonKey(name: 'cost_hint') int? costHint,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'author_id') String? authorId,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'rating_count') int ratingCount,
      @JsonKey(name: 'avg_rating', fromJson: _parseDouble) double avgRating,
      List<CommunityRecipeIngredient>? ingredients,
      List<CommunityRecipeStep>? steps,
      List<RecipeComment>? comments,
      RecipeRatings? ratings});

  @override
  $RecipeRatingsCopyWith<$Res>? get ratings;
}

/// @nodoc
class __$$CommunityRecipeImplCopyWithImpl<$Res>
    extends _$CommunityRecipeCopyWithImpl<$Res, _$CommunityRecipeImpl>
    implements _$$CommunityRecipeImplCopyWith<$Res> {
  __$$CommunityRecipeImplCopyWithImpl(
      _$CommunityRecipeImpl _value, $Res Function(_$CommunityRecipeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? region = freezed,
    Object? descriptionMd = freezed,
    Object? difficulty = freezed,
    Object? timeMin = freezed,
    Object? costHint = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? authorName = freezed,
    Object? authorId = freezed,
    Object? commentCount = null,
    Object? ratingCount = null,
    Object? avgRating = null,
    Object? ingredients = freezed,
    Object? steps = freezed,
    Object? comments = freezed,
    Object? ratings = freezed,
  }) {
    return _then(_$CommunityRecipeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionMd: freezed == descriptionMd
          ? _value.descriptionMd
          : descriptionMd // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      timeMin: freezed == timeMin
          ? _value.timeMin
          : timeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      costHint: freezed == costHint
          ? _value.costHint
          : costHint // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String?,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      ingredients: freezed == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipeIngredient>?,
      steps: freezed == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipeStep>?,
      comments: freezed == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<RecipeComment>?,
      ratings: freezed == ratings
          ? _value.ratings
          : ratings // ignore: cast_nullable_to_non_nullable
              as RecipeRatings?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityRecipeImpl implements _CommunityRecipe {
  const _$CommunityRecipeImpl(
      {required this.id,
      required this.title,
      this.region,
      @JsonKey(name: 'description_md') this.descriptionMd,
      this.difficulty,
      @JsonKey(name: 'time_min') this.timeMin,
      @JsonKey(name: 'cost_hint') this.costHint,
      this.status,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'author_name') this.authorName,
      @JsonKey(name: 'author_id') this.authorId,
      @JsonKey(name: 'comment_count') this.commentCount = 0,
      @JsonKey(name: 'rating_count') this.ratingCount = 0,
      @JsonKey(name: 'avg_rating', fromJson: _parseDouble) this.avgRating = 0.0,
      final List<CommunityRecipeIngredient>? ingredients,
      final List<CommunityRecipeStep>? steps,
      final List<RecipeComment>? comments,
      this.ratings})
      : _ingredients = ingredients,
        _steps = steps,
        _comments = comments;

  factory _$CommunityRecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityRecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? region;
  @override
  @JsonKey(name: 'description_md')
  final String? descriptionMd;
  @override
  final String? difficulty;
  @override
  @JsonKey(name: 'time_min')
  final int? timeMin;
  @override
  @JsonKey(name: 'cost_hint')
  final int? costHint;
  @override
  final String? status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'author_name')
  final String? authorName;
  @override
  @JsonKey(name: 'author_id')
  final String? authorId;
  @override
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @override
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @override
  @JsonKey(name: 'avg_rating', fromJson: _parseDouble)
  final double avgRating;
  final List<CommunityRecipeIngredient>? _ingredients;
  @override
  List<CommunityRecipeIngredient>? get ingredients {
    final value = _ingredients;
    if (value == null) return null;
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<CommunityRecipeStep>? _steps;
  @override
  List<CommunityRecipeStep>? get steps {
    final value = _steps;
    if (value == null) return null;
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<RecipeComment>? _comments;
  @override
  List<RecipeComment>? get comments {
    final value = _comments;
    if (value == null) return null;
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final RecipeRatings? ratings;

  @override
  String toString() {
    return 'CommunityRecipe(id: $id, title: $title, region: $region, descriptionMd: $descriptionMd, difficulty: $difficulty, timeMin: $timeMin, costHint: $costHint, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, authorName: $authorName, authorId: $authorId, commentCount: $commentCount, ratingCount: $ratingCount, avgRating: $avgRating, ingredients: $ingredients, steps: $steps, comments: $comments, ratings: $ratings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityRecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.descriptionMd, descriptionMd) ||
                other.descriptionMd == descriptionMd) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.timeMin, timeMin) || other.timeMin == timeMin) &&
            (identical(other.costHint, costHint) ||
                other.costHint == costHint) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.ratings, ratings) || other.ratings == ratings));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        region,
        descriptionMd,
        difficulty,
        timeMin,
        costHint,
        status,
        createdAt,
        updatedAt,
        authorName,
        authorId,
        commentCount,
        ratingCount,
        avgRating,
        const DeepCollectionEquality().hash(_ingredients),
        const DeepCollectionEquality().hash(_steps),
        const DeepCollectionEquality().hash(_comments),
        ratings
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityRecipeImplCopyWith<_$CommunityRecipeImpl> get copyWith =>
      __$$CommunityRecipeImplCopyWithImpl<_$CommunityRecipeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityRecipeImplToJson(
      this,
    );
  }
}

abstract class _CommunityRecipe implements CommunityRecipe {
  const factory _CommunityRecipe(
      {required final String id,
      required final String title,
      final String? region,
      @JsonKey(name: 'description_md') final String? descriptionMd,
      final String? difficulty,
      @JsonKey(name: 'time_min') final int? timeMin,
      @JsonKey(name: 'cost_hint') final int? costHint,
      final String? status,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'author_name') final String? authorName,
      @JsonKey(name: 'author_id') final String? authorId,
      @JsonKey(name: 'comment_count') final int commentCount,
      @JsonKey(name: 'rating_count') final int ratingCount,
      @JsonKey(name: 'avg_rating', fromJson: _parseDouble)
      final double avgRating,
      final List<CommunityRecipeIngredient>? ingredients,
      final List<CommunityRecipeStep>? steps,
      final List<RecipeComment>? comments,
      final RecipeRatings? ratings}) = _$CommunityRecipeImpl;

  factory _CommunityRecipe.fromJson(Map<String, dynamic> json) =
      _$CommunityRecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get region;
  @override
  @JsonKey(name: 'description_md')
  String? get descriptionMd;
  @override
  String? get difficulty;
  @override
  @JsonKey(name: 'time_min')
  int? get timeMin;
  @override
  @JsonKey(name: 'cost_hint')
  int? get costHint;
  @override
  String? get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'author_name')
  String? get authorName;
  @override
  @JsonKey(name: 'author_id')
  String? get authorId;
  @override
  @JsonKey(name: 'comment_count')
  int get commentCount;
  @override
  @JsonKey(name: 'rating_count')
  int get ratingCount;
  @override
  @JsonKey(name: 'avg_rating', fromJson: _parseDouble)
  double get avgRating;
  @override
  List<CommunityRecipeIngredient>? get ingredients;
  @override
  List<CommunityRecipeStep>? get steps;
  @override
  List<RecipeComment>? get comments;
  @override
  RecipeRatings? get ratings;
  @override
  @JsonKey(ignore: true)
  _$$CommunityRecipeImplCopyWith<_$CommunityRecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityRecipeIngredient _$CommunityRecipeIngredientFromJson(
    Map<String, dynamic> json) {
  return _CommunityRecipeIngredient.fromJson(json);
}

/// @nodoc
mixin _$CommunityRecipeIngredient {
  String get id => throw _privateConstructorUsedError;
  String get ingredientName => throw _privateConstructorUsedError;
  String? get quantity => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityRecipeIngredientCopyWith<CommunityRecipeIngredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityRecipeIngredientCopyWith<$Res> {
  factory $CommunityRecipeIngredientCopyWith(CommunityRecipeIngredient value,
          $Res Function(CommunityRecipeIngredient) then) =
      _$CommunityRecipeIngredientCopyWithImpl<$Res, CommunityRecipeIngredient>;
  @useResult
  $Res call({String id, String ingredientName, String? quantity, String? note});
}

/// @nodoc
class _$CommunityRecipeIngredientCopyWithImpl<$Res,
        $Val extends CommunityRecipeIngredient>
    implements $CommunityRecipeIngredientCopyWith<$Res> {
  _$CommunityRecipeIngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientName = null,
    Object? quantity = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ingredientName: null == ingredientName
          ? _value.ingredientName
          : ingredientName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityRecipeIngredientImplCopyWith<$Res>
    implements $CommunityRecipeIngredientCopyWith<$Res> {
  factory _$$CommunityRecipeIngredientImplCopyWith(
          _$CommunityRecipeIngredientImpl value,
          $Res Function(_$CommunityRecipeIngredientImpl) then) =
      __$$CommunityRecipeIngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String ingredientName, String? quantity, String? note});
}

/// @nodoc
class __$$CommunityRecipeIngredientImplCopyWithImpl<$Res>
    extends _$CommunityRecipeIngredientCopyWithImpl<$Res,
        _$CommunityRecipeIngredientImpl>
    implements _$$CommunityRecipeIngredientImplCopyWith<$Res> {
  __$$CommunityRecipeIngredientImplCopyWithImpl(
      _$CommunityRecipeIngredientImpl _value,
      $Res Function(_$CommunityRecipeIngredientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientName = null,
    Object? quantity = freezed,
    Object? note = freezed,
  }) {
    return _then(_$CommunityRecipeIngredientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ingredientName: null == ingredientName
          ? _value.ingredientName
          : ingredientName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityRecipeIngredientImpl implements _CommunityRecipeIngredient {
  const _$CommunityRecipeIngredientImpl(
      {required this.id,
      required this.ingredientName,
      this.quantity,
      this.note});

  factory _$CommunityRecipeIngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityRecipeIngredientImplFromJson(json);

  @override
  final String id;
  @override
  final String ingredientName;
  @override
  final String? quantity;
  @override
  final String? note;

  @override
  String toString() {
    return 'CommunityRecipeIngredient(id: $id, ingredientName: $ingredientName, quantity: $quantity, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityRecipeIngredientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ingredientName, ingredientName) ||
                other.ingredientName == ingredientName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, ingredientName, quantity, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityRecipeIngredientImplCopyWith<_$CommunityRecipeIngredientImpl>
      get copyWith => __$$CommunityRecipeIngredientImplCopyWithImpl<
          _$CommunityRecipeIngredientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityRecipeIngredientImplToJson(
      this,
    );
  }
}

abstract class _CommunityRecipeIngredient implements CommunityRecipeIngredient {
  const factory _CommunityRecipeIngredient(
      {required final String id,
      required final String ingredientName,
      final String? quantity,
      final String? note}) = _$CommunityRecipeIngredientImpl;

  factory _CommunityRecipeIngredient.fromJson(Map<String, dynamic> json) =
      _$CommunityRecipeIngredientImpl.fromJson;

  @override
  String get id;
  @override
  String get ingredientName;
  @override
  String? get quantity;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$CommunityRecipeIngredientImplCopyWith<_$CommunityRecipeIngredientImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CommunityRecipeStep _$CommunityRecipeStepFromJson(Map<String, dynamic> json) {
  return _CommunityRecipeStep.fromJson(json);
}

/// @nodoc
mixin _$CommunityRecipeStep {
  String get id => throw _privateConstructorUsedError;
  int get orderNo => throw _privateConstructorUsedError;
  String get contentMd => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityRecipeStepCopyWith<CommunityRecipeStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityRecipeStepCopyWith<$Res> {
  factory $CommunityRecipeStepCopyWith(
          CommunityRecipeStep value, $Res Function(CommunityRecipeStep) then) =
      _$CommunityRecipeStepCopyWithImpl<$Res, CommunityRecipeStep>;
  @useResult
  $Res call({String id, int orderNo, String contentMd});
}

/// @nodoc
class _$CommunityRecipeStepCopyWithImpl<$Res, $Val extends CommunityRecipeStep>
    implements $CommunityRecipeStepCopyWith<$Res> {
  _$CommunityRecipeStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? contentMd = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNo: null == orderNo
          ? _value.orderNo
          : orderNo // ignore: cast_nullable_to_non_nullable
              as int,
      contentMd: null == contentMd
          ? _value.contentMd
          : contentMd // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityRecipeStepImplCopyWith<$Res>
    implements $CommunityRecipeStepCopyWith<$Res> {
  factory _$$CommunityRecipeStepImplCopyWith(_$CommunityRecipeStepImpl value,
          $Res Function(_$CommunityRecipeStepImpl) then) =
      __$$CommunityRecipeStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int orderNo, String contentMd});
}

/// @nodoc
class __$$CommunityRecipeStepImplCopyWithImpl<$Res>
    extends _$CommunityRecipeStepCopyWithImpl<$Res, _$CommunityRecipeStepImpl>
    implements _$$CommunityRecipeStepImplCopyWith<$Res> {
  __$$CommunityRecipeStepImplCopyWithImpl(_$CommunityRecipeStepImpl _value,
      $Res Function(_$CommunityRecipeStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNo = null,
    Object? contentMd = null,
  }) {
    return _then(_$CommunityRecipeStepImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNo: null == orderNo
          ? _value.orderNo
          : orderNo // ignore: cast_nullable_to_non_nullable
              as int,
      contentMd: null == contentMd
          ? _value.contentMd
          : contentMd // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityRecipeStepImpl implements _CommunityRecipeStep {
  const _$CommunityRecipeStepImpl(
      {required this.id, required this.orderNo, required this.contentMd});

  factory _$CommunityRecipeStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityRecipeStepImplFromJson(json);

  @override
  final String id;
  @override
  final int orderNo;
  @override
  final String contentMd;

  @override
  String toString() {
    return 'CommunityRecipeStep(id: $id, orderNo: $orderNo, contentMd: $contentMd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityRecipeStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNo, orderNo) || other.orderNo == orderNo) &&
            (identical(other.contentMd, contentMd) ||
                other.contentMd == contentMd));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, orderNo, contentMd);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityRecipeStepImplCopyWith<_$CommunityRecipeStepImpl> get copyWith =>
      __$$CommunityRecipeStepImplCopyWithImpl<_$CommunityRecipeStepImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityRecipeStepImplToJson(
      this,
    );
  }
}

abstract class _CommunityRecipeStep implements CommunityRecipeStep {
  const factory _CommunityRecipeStep(
      {required final String id,
      required final int orderNo,
      required final String contentMd}) = _$CommunityRecipeStepImpl;

  factory _CommunityRecipeStep.fromJson(Map<String, dynamic> json) =
      _$CommunityRecipeStepImpl.fromJson;

  @override
  String get id;
  @override
  int get orderNo;
  @override
  String get contentMd;
  @override
  @JsonKey(ignore: true)
  _$$CommunityRecipeStepImplCopyWith<_$CommunityRecipeStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeComment _$RecipeCommentFromJson(Map<String, dynamic> json) {
  return _RecipeComment.fromJson(json);
}

/// @nodoc
mixin _$RecipeComment {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeCommentCopyWith<RecipeComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCommentCopyWith<$Res> {
  factory $RecipeCommentCopyWith(
          RecipeComment value, $Res Function(RecipeComment) then) =
      _$RecipeCommentCopyWithImpl<$Res, RecipeComment>;
  @useResult
  $Res call(
      {String id,
      String content,
      int likes,
      DateTime createdAt,
      String authorName});
}

/// @nodoc
class _$RecipeCommentCopyWithImpl<$Res, $Val extends RecipeComment>
    implements $RecipeCommentCopyWith<$Res> {
  _$RecipeCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? likes = null,
    Object? createdAt = null,
    Object? authorName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeCommentImplCopyWith<$Res>
    implements $RecipeCommentCopyWith<$Res> {
  factory _$$RecipeCommentImplCopyWith(
          _$RecipeCommentImpl value, $Res Function(_$RecipeCommentImpl) then) =
      __$$RecipeCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      int likes,
      DateTime createdAt,
      String authorName});
}

/// @nodoc
class __$$RecipeCommentImplCopyWithImpl<$Res>
    extends _$RecipeCommentCopyWithImpl<$Res, _$RecipeCommentImpl>
    implements _$$RecipeCommentImplCopyWith<$Res> {
  __$$RecipeCommentImplCopyWithImpl(
      _$RecipeCommentImpl _value, $Res Function(_$RecipeCommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? likes = null,
    Object? createdAt = null,
    Object? authorName = null,
  }) {
    return _then(_$RecipeCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeCommentImpl implements _RecipeComment {
  const _$RecipeCommentImpl(
      {required this.id,
      required this.content,
      this.likes = 0,
      required this.createdAt,
      required this.authorName});

  factory _$RecipeCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  @JsonKey()
  final int likes;
  @override
  final DateTime createdAt;
  @override
  final String authorName;

  @override
  String toString() {
    return 'RecipeComment(id: $id, content: $content, likes: $likes, createdAt: $createdAt, authorName: $authorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, content, likes, createdAt, authorName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeCommentImplCopyWith<_$RecipeCommentImpl> get copyWith =>
      __$$RecipeCommentImplCopyWithImpl<_$RecipeCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeCommentImplToJson(
      this,
    );
  }
}

abstract class _RecipeComment implements RecipeComment {
  const factory _RecipeComment(
      {required final String id,
      required final String content,
      final int likes,
      required final DateTime createdAt,
      required final String authorName}) = _$RecipeCommentImpl;

  factory _RecipeComment.fromJson(Map<String, dynamic> json) =
      _$RecipeCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  int get likes;
  @override
  DateTime get createdAt;
  @override
  String get authorName;
  @override
  @JsonKey(ignore: true)
  _$$RecipeCommentImplCopyWith<_$RecipeCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeRatings _$RecipeRatingsFromJson(Map<String, dynamic> json) {
  return _RecipeRatings.fromJson(json);
}

/// @nodoc
mixin _$RecipeRatings {
  double get average => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<RecipeRating>? get details => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeRatingsCopyWith<RecipeRatings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeRatingsCopyWith<$Res> {
  factory $RecipeRatingsCopyWith(
          RecipeRatings value, $Res Function(RecipeRatings) then) =
      _$RecipeRatingsCopyWithImpl<$Res, RecipeRatings>;
  @useResult
  $Res call({double average, int count, List<RecipeRating>? details});
}

/// @nodoc
class _$RecipeRatingsCopyWithImpl<$Res, $Val extends RecipeRatings>
    implements $RecipeRatingsCopyWith<$Res> {
  _$RecipeRatingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? count = null,
    Object? details = freezed,
  }) {
    return _then(_value.copyWith(
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as List<RecipeRating>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeRatingsImplCopyWith<$Res>
    implements $RecipeRatingsCopyWith<$Res> {
  factory _$$RecipeRatingsImplCopyWith(
          _$RecipeRatingsImpl value, $Res Function(_$RecipeRatingsImpl) then) =
      __$$RecipeRatingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double average, int count, List<RecipeRating>? details});
}

/// @nodoc
class __$$RecipeRatingsImplCopyWithImpl<$Res>
    extends _$RecipeRatingsCopyWithImpl<$Res, _$RecipeRatingsImpl>
    implements _$$RecipeRatingsImplCopyWith<$Res> {
  __$$RecipeRatingsImplCopyWithImpl(
      _$RecipeRatingsImpl _value, $Res Function(_$RecipeRatingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? average = null,
    Object? count = null,
    Object? details = freezed,
  }) {
    return _then(_$RecipeRatingsImpl(
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<RecipeRating>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeRatingsImpl implements _RecipeRatings {
  const _$RecipeRatingsImpl(
      {this.average = 0.0, this.count = 0, final List<RecipeRating>? details})
      : _details = details;

  factory _$RecipeRatingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeRatingsImplFromJson(json);

  @override
  @JsonKey()
  final double average;
  @override
  @JsonKey()
  final int count;
  final List<RecipeRating>? _details;
  @override
  List<RecipeRating>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RecipeRatings(average: $average, count: $count, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeRatingsImpl &&
            (identical(other.average, average) || other.average == average) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, average, count,
      const DeepCollectionEquality().hash(_details));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeRatingsImplCopyWith<_$RecipeRatingsImpl> get copyWith =>
      __$$RecipeRatingsImplCopyWithImpl<_$RecipeRatingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeRatingsImplToJson(
      this,
    );
  }
}

abstract class _RecipeRatings implements RecipeRatings {
  const factory _RecipeRatings(
      {final double average,
      final int count,
      final List<RecipeRating>? details}) = _$RecipeRatingsImpl;

  factory _RecipeRatings.fromJson(Map<String, dynamic> json) =
      _$RecipeRatingsImpl.fromJson;

  @override
  double get average;
  @override
  int get count;
  @override
  List<RecipeRating>? get details;
  @override
  @JsonKey(ignore: true)
  _$$RecipeRatingsImplCopyWith<_$RecipeRatingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeRating _$RecipeRatingFromJson(Map<String, dynamic> json) {
  return _RecipeRating.fromJson(json);
}

/// @nodoc
mixin _$RecipeRating {
  int get stars => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeRatingCopyWith<RecipeRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeRatingCopyWith<$Res> {
  factory $RecipeRatingCopyWith(
          RecipeRating value, $Res Function(RecipeRating) then) =
      _$RecipeRatingCopyWithImpl<$Res, RecipeRating>;
  @useResult
  $Res call({int stars, DateTime createdAt, String authorName});
}

/// @nodoc
class _$RecipeRatingCopyWithImpl<$Res, $Val extends RecipeRating>
    implements $RecipeRatingCopyWith<$Res> {
  _$RecipeRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stars = null,
    Object? createdAt = null,
    Object? authorName = null,
  }) {
    return _then(_value.copyWith(
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeRatingImplCopyWith<$Res>
    implements $RecipeRatingCopyWith<$Res> {
  factory _$$RecipeRatingImplCopyWith(
          _$RecipeRatingImpl value, $Res Function(_$RecipeRatingImpl) then) =
      __$$RecipeRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int stars, DateTime createdAt, String authorName});
}

/// @nodoc
class __$$RecipeRatingImplCopyWithImpl<$Res>
    extends _$RecipeRatingCopyWithImpl<$Res, _$RecipeRatingImpl>
    implements _$$RecipeRatingImplCopyWith<$Res> {
  __$$RecipeRatingImplCopyWithImpl(
      _$RecipeRatingImpl _value, $Res Function(_$RecipeRatingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stars = null,
    Object? createdAt = null,
    Object? authorName = null,
  }) {
    return _then(_$RecipeRatingImpl(
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeRatingImpl implements _RecipeRating {
  const _$RecipeRatingImpl(
      {required this.stars, required this.createdAt, required this.authorName});

  factory _$RecipeRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeRatingImplFromJson(json);

  @override
  final int stars;
  @override
  final DateTime createdAt;
  @override
  final String authorName;

  @override
  String toString() {
    return 'RecipeRating(stars: $stars, createdAt: $createdAt, authorName: $authorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeRatingImpl &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, stars, createdAt, authorName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeRatingImplCopyWith<_$RecipeRatingImpl> get copyWith =>
      __$$RecipeRatingImplCopyWithImpl<_$RecipeRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeRatingImplToJson(
      this,
    );
  }
}

abstract class _RecipeRating implements RecipeRating {
  const factory _RecipeRating(
      {required final int stars,
      required final DateTime createdAt,
      required final String authorName}) = _$RecipeRatingImpl;

  factory _RecipeRating.fromJson(Map<String, dynamic> json) =
      _$RecipeRatingImpl.fromJson;

  @override
  int get stars;
  @override
  DateTime get createdAt;
  @override
  String get authorName;
  @override
  @JsonKey(ignore: true)
  _$$RecipeRatingImplCopyWith<_$RecipeRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCommunityRecipeRequest _$CreateCommunityRecipeRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateCommunityRecipeRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCommunityRecipeRequest {
  String get title => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  @JsonKey(name: 'description_md')
  String get descriptionMd => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_min')
  int get timeMin => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_hint')
  int? get costHint => throw _privateConstructorUsedError;
  String? get imageBase64 => throw _privateConstructorUsedError;
  List<CreateIngredientRequest> get ingredients =>
      throw _privateConstructorUsedError;
  List<CreateStepRequest> get steps => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateCommunityRecipeRequestCopyWith<CreateCommunityRecipeRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCommunityRecipeRequestCopyWith<$Res> {
  factory $CreateCommunityRecipeRequestCopyWith(
          CreateCommunityRecipeRequest value,
          $Res Function(CreateCommunityRecipeRequest) then) =
      _$CreateCommunityRecipeRequestCopyWithImpl<$Res,
          CreateCommunityRecipeRequest>;
  @useResult
  $Res call(
      {String title,
      String region,
      @JsonKey(name: 'description_md') String descriptionMd,
      String difficulty,
      @JsonKey(name: 'time_min') int timeMin,
      @JsonKey(name: 'cost_hint') int? costHint,
      String? imageBase64,
      List<CreateIngredientRequest> ingredients,
      List<CreateStepRequest> steps});
}

/// @nodoc
class _$CreateCommunityRecipeRequestCopyWithImpl<$Res,
        $Val extends CreateCommunityRecipeRequest>
    implements $CreateCommunityRecipeRequestCopyWith<$Res> {
  _$CreateCommunityRecipeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? region = null,
    Object? descriptionMd = null,
    Object? difficulty = null,
    Object? timeMin = null,
    Object? costHint = freezed,
    Object? imageBase64 = freezed,
    Object? ingredients = null,
    Object? steps = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionMd: null == descriptionMd
          ? _value.descriptionMd
          : descriptionMd // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      timeMin: null == timeMin
          ? _value.timeMin
          : timeMin // ignore: cast_nullable_to_non_nullable
              as int,
      costHint: freezed == costHint
          ? _value.costHint
          : costHint // ignore: cast_nullable_to_non_nullable
              as int?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<CreateIngredientRequest>,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<CreateStepRequest>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateCommunityRecipeRequestImplCopyWith<$Res>
    implements $CreateCommunityRecipeRequestCopyWith<$Res> {
  factory _$$CreateCommunityRecipeRequestImplCopyWith(
          _$CreateCommunityRecipeRequestImpl value,
          $Res Function(_$CreateCommunityRecipeRequestImpl) then) =
      __$$CreateCommunityRecipeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String region,
      @JsonKey(name: 'description_md') String descriptionMd,
      String difficulty,
      @JsonKey(name: 'time_min') int timeMin,
      @JsonKey(name: 'cost_hint') int? costHint,
      String? imageBase64,
      List<CreateIngredientRequest> ingredients,
      List<CreateStepRequest> steps});
}

/// @nodoc
class __$$CreateCommunityRecipeRequestImplCopyWithImpl<$Res>
    extends _$CreateCommunityRecipeRequestCopyWithImpl<$Res,
        _$CreateCommunityRecipeRequestImpl>
    implements _$$CreateCommunityRecipeRequestImplCopyWith<$Res> {
  __$$CreateCommunityRecipeRequestImplCopyWithImpl(
      _$CreateCommunityRecipeRequestImpl _value,
      $Res Function(_$CreateCommunityRecipeRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? region = null,
    Object? descriptionMd = null,
    Object? difficulty = null,
    Object? timeMin = null,
    Object? costHint = freezed,
    Object? imageBase64 = freezed,
    Object? ingredients = null,
    Object? steps = null,
  }) {
    return _then(_$CreateCommunityRecipeRequestImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionMd: null == descriptionMd
          ? _value.descriptionMd
          : descriptionMd // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      timeMin: null == timeMin
          ? _value.timeMin
          : timeMin // ignore: cast_nullable_to_non_nullable
              as int,
      costHint: freezed == costHint
          ? _value.costHint
          : costHint // ignore: cast_nullable_to_non_nullable
              as int?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<CreateIngredientRequest>,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<CreateStepRequest>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCommunityRecipeRequestImpl
    implements _CreateCommunityRecipeRequest {
  const _$CreateCommunityRecipeRequestImpl(
      {required this.title,
      required this.region,
      @JsonKey(name: 'description_md') required this.descriptionMd,
      required this.difficulty,
      @JsonKey(name: 'time_min') required this.timeMin,
      @JsonKey(name: 'cost_hint') this.costHint,
      this.imageBase64,
      required final List<CreateIngredientRequest> ingredients,
      required final List<CreateStepRequest> steps})
      : _ingredients = ingredients,
        _steps = steps;

  factory _$CreateCommunityRecipeRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateCommunityRecipeRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String region;
  @override
  @JsonKey(name: 'description_md')
  final String descriptionMd;
  @override
  final String difficulty;
  @override
  @JsonKey(name: 'time_min')
  final int timeMin;
  @override
  @JsonKey(name: 'cost_hint')
  final int? costHint;
  @override
  final String? imageBase64;
  final List<CreateIngredientRequest> _ingredients;
  @override
  List<CreateIngredientRequest> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<CreateStepRequest> _steps;
  @override
  List<CreateStepRequest> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  String toString() {
    return 'CreateCommunityRecipeRequest(title: $title, region: $region, descriptionMd: $descriptionMd, difficulty: $difficulty, timeMin: $timeMin, costHint: $costHint, imageBase64: $imageBase64, ingredients: $ingredients, steps: $steps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCommunityRecipeRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.descriptionMd, descriptionMd) ||
                other.descriptionMd == descriptionMd) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.timeMin, timeMin) || other.timeMin == timeMin) &&
            (identical(other.costHint, costHint) ||
                other.costHint == costHint) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality().equals(other._steps, _steps));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      region,
      descriptionMd,
      difficulty,
      timeMin,
      costHint,
      imageBase64,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_steps));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCommunityRecipeRequestImplCopyWith<
          _$CreateCommunityRecipeRequestImpl>
      get copyWith => __$$CreateCommunityRecipeRequestImplCopyWithImpl<
          _$CreateCommunityRecipeRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCommunityRecipeRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateCommunityRecipeRequest
    implements CreateCommunityRecipeRequest {
  const factory _CreateCommunityRecipeRequest(
          {required final String title,
          required final String region,
          @JsonKey(name: 'description_md') required final String descriptionMd,
          required final String difficulty,
          @JsonKey(name: 'time_min') required final int timeMin,
          @JsonKey(name: 'cost_hint') final int? costHint,
          final String? imageBase64,
          required final List<CreateIngredientRequest> ingredients,
          required final List<CreateStepRequest> steps}) =
      _$CreateCommunityRecipeRequestImpl;

  factory _CreateCommunityRecipeRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCommunityRecipeRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get region;
  @override
  @JsonKey(name: 'description_md')
  String get descriptionMd;
  @override
  String get difficulty;
  @override
  @JsonKey(name: 'time_min')
  int get timeMin;
  @override
  @JsonKey(name: 'cost_hint')
  int? get costHint;
  @override
  String? get imageBase64;
  @override
  List<CreateIngredientRequest> get ingredients;
  @override
  List<CreateStepRequest> get steps;
  @override
  @JsonKey(ignore: true)
  _$$CreateCommunityRecipeRequestImplCopyWith<
          _$CreateCommunityRecipeRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateIngredientRequest _$CreateIngredientRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateIngredientRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateIngredientRequest {
  String get name => throw _privateConstructorUsedError;
  String? get quantity => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateIngredientRequestCopyWith<CreateIngredientRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateIngredientRequestCopyWith<$Res> {
  factory $CreateIngredientRequestCopyWith(CreateIngredientRequest value,
          $Res Function(CreateIngredientRequest) then) =
      _$CreateIngredientRequestCopyWithImpl<$Res, CreateIngredientRequest>;
  @useResult
  $Res call({String name, String? quantity, String? note});
}

/// @nodoc
class _$CreateIngredientRequestCopyWithImpl<$Res,
        $Val extends CreateIngredientRequest>
    implements $CreateIngredientRequestCopyWith<$Res> {
  _$CreateIngredientRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateIngredientRequestImplCopyWith<$Res>
    implements $CreateIngredientRequestCopyWith<$Res> {
  factory _$$CreateIngredientRequestImplCopyWith(
          _$CreateIngredientRequestImpl value,
          $Res Function(_$CreateIngredientRequestImpl) then) =
      __$$CreateIngredientRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? quantity, String? note});
}

/// @nodoc
class __$$CreateIngredientRequestImplCopyWithImpl<$Res>
    extends _$CreateIngredientRequestCopyWithImpl<$Res,
        _$CreateIngredientRequestImpl>
    implements _$$CreateIngredientRequestImplCopyWith<$Res> {
  __$$CreateIngredientRequestImplCopyWithImpl(
      _$CreateIngredientRequestImpl _value,
      $Res Function(_$CreateIngredientRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = freezed,
    Object? note = freezed,
  }) {
    return _then(_$CreateIngredientRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateIngredientRequestImpl implements _CreateIngredientRequest {
  const _$CreateIngredientRequestImpl(
      {required this.name, this.quantity, this.note});

  factory _$CreateIngredientRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateIngredientRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? quantity;
  @override
  final String? note;

  @override
  String toString() {
    return 'CreateIngredientRequest(name: $name, quantity: $quantity, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateIngredientRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateIngredientRequestImplCopyWith<_$CreateIngredientRequestImpl>
      get copyWith => __$$CreateIngredientRequestImplCopyWithImpl<
          _$CreateIngredientRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateIngredientRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateIngredientRequest implements CreateIngredientRequest {
  const factory _CreateIngredientRequest(
      {required final String name,
      final String? quantity,
      final String? note}) = _$CreateIngredientRequestImpl;

  factory _CreateIngredientRequest.fromJson(Map<String, dynamic> json) =
      _$CreateIngredientRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get quantity;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$CreateIngredientRequestImplCopyWith<_$CreateIngredientRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateStepRequest _$CreateStepRequestFromJson(Map<String, dynamic> json) {
  return _CreateStepRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStepRequest {
  @JsonKey(name: 'order_no')
  int get orderNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'content_md')
  String get contentMd => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateStepRequestCopyWith<CreateStepRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStepRequestCopyWith<$Res> {
  factory $CreateStepRequestCopyWith(
          CreateStepRequest value, $Res Function(CreateStepRequest) then) =
      _$CreateStepRequestCopyWithImpl<$Res, CreateStepRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_no') int orderNo,
      @JsonKey(name: 'content_md') String contentMd});
}

/// @nodoc
class _$CreateStepRequestCopyWithImpl<$Res, $Val extends CreateStepRequest>
    implements $CreateStepRequestCopyWith<$Res> {
  _$CreateStepRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderNo = null,
    Object? contentMd = null,
  }) {
    return _then(_value.copyWith(
      orderNo: null == orderNo
          ? _value.orderNo
          : orderNo // ignore: cast_nullable_to_non_nullable
              as int,
      contentMd: null == contentMd
          ? _value.contentMd
          : contentMd // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateStepRequestImplCopyWith<$Res>
    implements $CreateStepRequestCopyWith<$Res> {
  factory _$$CreateStepRequestImplCopyWith(_$CreateStepRequestImpl value,
          $Res Function(_$CreateStepRequestImpl) then) =
      __$$CreateStepRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_no') int orderNo,
      @JsonKey(name: 'content_md') String contentMd});
}

/// @nodoc
class __$$CreateStepRequestImplCopyWithImpl<$Res>
    extends _$CreateStepRequestCopyWithImpl<$Res, _$CreateStepRequestImpl>
    implements _$$CreateStepRequestImplCopyWith<$Res> {
  __$$CreateStepRequestImplCopyWithImpl(_$CreateStepRequestImpl _value,
      $Res Function(_$CreateStepRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderNo = null,
    Object? contentMd = null,
  }) {
    return _then(_$CreateStepRequestImpl(
      orderNo: null == orderNo
          ? _value.orderNo
          : orderNo // ignore: cast_nullable_to_non_nullable
              as int,
      contentMd: null == contentMd
          ? _value.contentMd
          : contentMd // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStepRequestImpl implements _CreateStepRequest {
  const _$CreateStepRequestImpl(
      {@JsonKey(name: 'order_no') required this.orderNo,
      @JsonKey(name: 'content_md') required this.contentMd});

  factory _$CreateStepRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStepRequestImplFromJson(json);

  @override
  @JsonKey(name: 'order_no')
  final int orderNo;
  @override
  @JsonKey(name: 'content_md')
  final String contentMd;

  @override
  String toString() {
    return 'CreateStepRequest(orderNo: $orderNo, contentMd: $contentMd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStepRequestImpl &&
            (identical(other.orderNo, orderNo) || other.orderNo == orderNo) &&
            (identical(other.contentMd, contentMd) ||
                other.contentMd == contentMd));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, orderNo, contentMd);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStepRequestImplCopyWith<_$CreateStepRequestImpl> get copyWith =>
      __$$CreateStepRequestImplCopyWithImpl<_$CreateStepRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStepRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateStepRequest implements CreateStepRequest {
  const factory _CreateStepRequest(
          {@JsonKey(name: 'order_no') required final int orderNo,
          @JsonKey(name: 'content_md') required final String contentMd}) =
      _$CreateStepRequestImpl;

  factory _CreateStepRequest.fromJson(Map<String, dynamic> json) =
      _$CreateStepRequestImpl.fromJson;

  @override
  @JsonKey(name: 'order_no')
  int get orderNo;
  @override
  @JsonKey(name: 'content_md')
  String get contentMd;
  @override
  @JsonKey(ignore: true)
  _$$CreateStepRequestImplCopyWith<_$CreateStepRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddCommentRequest _$AddCommentRequestFromJson(Map<String, dynamic> json) {
  return _AddCommentRequest.fromJson(json);
}

/// @nodoc
mixin _$AddCommentRequest {
  String get content => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AddCommentRequestCopyWith<AddCommentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddCommentRequestCopyWith<$Res> {
  factory $AddCommentRequestCopyWith(
          AddCommentRequest value, $Res Function(AddCommentRequest) then) =
      _$AddCommentRequestCopyWithImpl<$Res, AddCommentRequest>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$AddCommentRequestCopyWithImpl<$Res, $Val extends AddCommentRequest>
    implements $AddCommentRequestCopyWith<$Res> {
  _$AddCommentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddCommentRequestImplCopyWith<$Res>
    implements $AddCommentRequestCopyWith<$Res> {
  factory _$$AddCommentRequestImplCopyWith(_$AddCommentRequestImpl value,
          $Res Function(_$AddCommentRequestImpl) then) =
      __$$AddCommentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$AddCommentRequestImplCopyWithImpl<$Res>
    extends _$AddCommentRequestCopyWithImpl<$Res, _$AddCommentRequestImpl>
    implements _$$AddCommentRequestImplCopyWith<$Res> {
  __$$AddCommentRequestImplCopyWithImpl(_$AddCommentRequestImpl _value,
      $Res Function(_$AddCommentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$AddCommentRequestImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddCommentRequestImpl implements _AddCommentRequest {
  const _$AddCommentRequestImpl({required this.content});

  factory _$AddCommentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddCommentRequestImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'AddCommentRequest(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCommentRequestImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCommentRequestImplCopyWith<_$AddCommentRequestImpl> get copyWith =>
      __$$AddCommentRequestImplCopyWithImpl<_$AddCommentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddCommentRequestImplToJson(
      this,
    );
  }
}

abstract class _AddCommentRequest implements AddCommentRequest {
  const factory _AddCommentRequest({required final String content}) =
      _$AddCommentRequestImpl;

  factory _AddCommentRequest.fromJson(Map<String, dynamic> json) =
      _$AddCommentRequestImpl.fromJson;

  @override
  String get content;
  @override
  @JsonKey(ignore: true)
  _$$AddCommentRequestImplCopyWith<_$AddCommentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddRatingRequest _$AddRatingRequestFromJson(Map<String, dynamic> json) {
  return _AddRatingRequest.fromJson(json);
}

/// @nodoc
mixin _$AddRatingRequest {
  int get stars => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AddRatingRequestCopyWith<AddRatingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddRatingRequestCopyWith<$Res> {
  factory $AddRatingRequestCopyWith(
          AddRatingRequest value, $Res Function(AddRatingRequest) then) =
      _$AddRatingRequestCopyWithImpl<$Res, AddRatingRequest>;
  @useResult
  $Res call({int stars});
}

/// @nodoc
class _$AddRatingRequestCopyWithImpl<$Res, $Val extends AddRatingRequest>
    implements $AddRatingRequestCopyWith<$Res> {
  _$AddRatingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stars = null,
  }) {
    return _then(_value.copyWith(
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddRatingRequestImplCopyWith<$Res>
    implements $AddRatingRequestCopyWith<$Res> {
  factory _$$AddRatingRequestImplCopyWith(_$AddRatingRequestImpl value,
          $Res Function(_$AddRatingRequestImpl) then) =
      __$$AddRatingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int stars});
}

/// @nodoc
class __$$AddRatingRequestImplCopyWithImpl<$Res>
    extends _$AddRatingRequestCopyWithImpl<$Res, _$AddRatingRequestImpl>
    implements _$$AddRatingRequestImplCopyWith<$Res> {
  __$$AddRatingRequestImplCopyWithImpl(_$AddRatingRequestImpl _value,
      $Res Function(_$AddRatingRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stars = null,
  }) {
    return _then(_$AddRatingRequestImpl(
      stars: null == stars
          ? _value.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddRatingRequestImpl implements _AddRatingRequest {
  const _$AddRatingRequestImpl({required this.stars});

  factory _$AddRatingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddRatingRequestImplFromJson(json);

  @override
  final int stars;

  @override
  String toString() {
    return 'AddRatingRequest(stars: $stars)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddRatingRequestImpl &&
            (identical(other.stars, stars) || other.stars == stars));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, stars);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddRatingRequestImplCopyWith<_$AddRatingRequestImpl> get copyWith =>
      __$$AddRatingRequestImplCopyWithImpl<_$AddRatingRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddRatingRequestImplToJson(
      this,
    );
  }
}

abstract class _AddRatingRequest implements AddRatingRequest {
  const factory _AddRatingRequest({required final int stars}) =
      _$AddRatingRequestImpl;

  factory _AddRatingRequest.fromJson(Map<String, dynamic> json) =
      _$AddRatingRequestImpl.fromJson;

  @override
  int get stars;
  @override
  @JsonKey(ignore: true)
  _$$AddRatingRequestImplCopyWith<_$AddRatingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityFilters _$CommunityFiltersFromJson(Map<String, dynamic> json) {
  return _CommunityFilters.fromJson(json);
}

/// @nodoc
mixin _$CommunityFilters {
  String? get region => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  int? get maxTime => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityFiltersCopyWith<CommunityFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityFiltersCopyWith<$Res> {
  factory $CommunityFiltersCopyWith(
          CommunityFilters value, $Res Function(CommunityFilters) then) =
      _$CommunityFiltersCopyWithImpl<$Res, CommunityFilters>;
  @useResult
  $Res call(
      {String? region,
      String? difficulty,
      int? maxTime,
      String? search,
      int? limit});
}

/// @nodoc
class _$CommunityFiltersCopyWithImpl<$Res, $Val extends CommunityFilters>
    implements $CommunityFiltersCopyWith<$Res> {
  _$CommunityFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? difficulty = freezed,
    Object? maxTime = freezed,
    Object? search = freezed,
    Object? limit = freezed,
  }) {
    return _then(_value.copyWith(
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      maxTime: freezed == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityFiltersImplCopyWith<$Res>
    implements $CommunityFiltersCopyWith<$Res> {
  factory _$$CommunityFiltersImplCopyWith(_$CommunityFiltersImpl value,
          $Res Function(_$CommunityFiltersImpl) then) =
      __$$CommunityFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? region,
      String? difficulty,
      int? maxTime,
      String? search,
      int? limit});
}

/// @nodoc
class __$$CommunityFiltersImplCopyWithImpl<$Res>
    extends _$CommunityFiltersCopyWithImpl<$Res, _$CommunityFiltersImpl>
    implements _$$CommunityFiltersImplCopyWith<$Res> {
  __$$CommunityFiltersImplCopyWithImpl(_$CommunityFiltersImpl _value,
      $Res Function(_$CommunityFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? region = freezed,
    Object? difficulty = freezed,
    Object? maxTime = freezed,
    Object? search = freezed,
    Object? limit = freezed,
  }) {
    return _then(_$CommunityFiltersImpl(
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      maxTime: freezed == maxTime
          ? _value.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as int?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityFiltersImpl implements _CommunityFilters {
  const _$CommunityFiltersImpl(
      {this.region, this.difficulty, this.maxTime, this.search, this.limit});

  factory _$CommunityFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityFiltersImplFromJson(json);

  @override
  final String? region;
  @override
  final String? difficulty;
  @override
  final int? maxTime;
  @override
  final String? search;
  @override
  final int? limit;

  @override
  String toString() {
    return 'CommunityFilters(region: $region, difficulty: $difficulty, maxTime: $maxTime, search: $search, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityFiltersImpl &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, region, difficulty, maxTime, search, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityFiltersImplCopyWith<_$CommunityFiltersImpl> get copyWith =>
      __$$CommunityFiltersImplCopyWithImpl<_$CommunityFiltersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityFiltersImplToJson(
      this,
    );
  }
}

abstract class _CommunityFilters implements CommunityFilters {
  const factory _CommunityFilters(
      {final String? region,
      final String? difficulty,
      final int? maxTime,
      final String? search,
      final int? limit}) = _$CommunityFiltersImpl;

  factory _CommunityFilters.fromJson(Map<String, dynamic> json) =
      _$CommunityFiltersImpl.fromJson;

  @override
  String? get region;
  @override
  String? get difficulty;
  @override
  int? get maxTime;
  @override
  String? get search;
  @override
  int? get limit;
  @override
  @JsonKey(ignore: true)
  _$$CommunityFiltersImplCopyWith<_$CommunityFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityResponse _$CommunityResponseFromJson(Map<String, dynamic> json) {
  return _CommunityResponse.fromJson(json);
}

/// @nodoc
mixin _$CommunityResponse {
  bool get success => throw _privateConstructorUsedError;
  List<CommunityRecipe> get data => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityResponseCopyWith<CommunityResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityResponseCopyWith<$Res> {
  factory $CommunityResponseCopyWith(
          CommunityResponse value, $Res Function(CommunityResponse) then) =
      _$CommunityResponseCopyWithImpl<$Res, CommunityResponse>;
  @useResult
  $Res call({bool success, List<CommunityRecipe> data, String? message});
}

/// @nodoc
class _$CommunityResponseCopyWithImpl<$Res, $Val extends CommunityResponse>
    implements $CommunityResponseCopyWith<$Res> {
  _$CommunityResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipe>,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityResponseImplCopyWith<$Res>
    implements $CommunityResponseCopyWith<$Res> {
  factory _$$CommunityResponseImplCopyWith(_$CommunityResponseImpl value,
          $Res Function(_$CommunityResponseImpl) then) =
      __$$CommunityResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<CommunityRecipe> data, String? message});
}

/// @nodoc
class __$$CommunityResponseImplCopyWithImpl<$Res>
    extends _$CommunityResponseCopyWithImpl<$Res, _$CommunityResponseImpl>
    implements _$$CommunityResponseImplCopyWith<$Res> {
  __$$CommunityResponseImplCopyWithImpl(_$CommunityResponseImpl _value,
      $Res Function(_$CommunityResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? message = freezed,
  }) {
    return _then(_$CommunityResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CommunityRecipe>,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityResponseImpl implements _CommunityResponse {
  const _$CommunityResponseImpl(
      {required this.success,
      required final List<CommunityRecipe> data,
      this.message})
      : _data = data;

  factory _$CommunityResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityResponseImplFromJson(json);

  @override
  final bool success;
  final List<CommunityRecipe> _data;
  @override
  List<CommunityRecipe> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final String? message;

  @override
  String toString() {
    return 'CommunityResponse(success: $success, data: $data, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success,
      const DeepCollectionEquality().hash(_data), message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityResponseImplCopyWith<_$CommunityResponseImpl> get copyWith =>
      __$$CommunityResponseImplCopyWithImpl<_$CommunityResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityResponseImplToJson(
      this,
    );
  }
}

abstract class _CommunityResponse implements CommunityResponse {
  const factory _CommunityResponse(
      {required final bool success,
      required final List<CommunityRecipe> data,
      final String? message}) = _$CommunityResponseImpl;

  factory _CommunityResponse.fromJson(Map<String, dynamic> json) =
      _$CommunityResponseImpl.fromJson;

  @override
  bool get success;
  @override
  List<CommunityRecipe> get data;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$CommunityResponseImplCopyWith<_$CommunityResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityDetailResponse _$CommunityDetailResponseFromJson(
    Map<String, dynamic> json) {
  return _CommunityDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$CommunityDetailResponse {
  bool get success => throw _privateConstructorUsedError;
  CommunityRecipe get data => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityDetailResponseCopyWith<CommunityDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityDetailResponseCopyWith<$Res> {
  factory $CommunityDetailResponseCopyWith(CommunityDetailResponse value,
          $Res Function(CommunityDetailResponse) then) =
      _$CommunityDetailResponseCopyWithImpl<$Res, CommunityDetailResponse>;
  @useResult
  $Res call({bool success, CommunityRecipe data, String? message});

  $CommunityRecipeCopyWith<$Res> get data;
}

/// @nodoc
class _$CommunityDetailResponseCopyWithImpl<$Res,
        $Val extends CommunityDetailResponse>
    implements $CommunityDetailResponseCopyWith<$Res> {
  _$CommunityDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CommunityRecipe,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CommunityRecipeCopyWith<$Res> get data {
    return $CommunityRecipeCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityDetailResponseImplCopyWith<$Res>
    implements $CommunityDetailResponseCopyWith<$Res> {
  factory _$$CommunityDetailResponseImplCopyWith(
          _$CommunityDetailResponseImpl value,
          $Res Function(_$CommunityDetailResponseImpl) then) =
      __$$CommunityDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, CommunityRecipe data, String? message});

  @override
  $CommunityRecipeCopyWith<$Res> get data;
}

/// @nodoc
class __$$CommunityDetailResponseImplCopyWithImpl<$Res>
    extends _$CommunityDetailResponseCopyWithImpl<$Res,
        _$CommunityDetailResponseImpl>
    implements _$$CommunityDetailResponseImplCopyWith<$Res> {
  __$$CommunityDetailResponseImplCopyWithImpl(
      _$CommunityDetailResponseImpl _value,
      $Res Function(_$CommunityDetailResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? message = freezed,
  }) {
    return _then(_$CommunityDetailResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CommunityRecipe,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityDetailResponseImpl implements _CommunityDetailResponse {
  const _$CommunityDetailResponseImpl(
      {required this.success, required this.data, this.message});

  factory _$CommunityDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityDetailResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final CommunityRecipe data;
  @override
  final String? message;

  @override
  String toString() {
    return 'CommunityDetailResponse(success: $success, data: $data, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityDetailResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityDetailResponseImplCopyWith<_$CommunityDetailResponseImpl>
      get copyWith => __$$CommunityDetailResponseImplCopyWithImpl<
          _$CommunityDetailResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityDetailResponseImplToJson(
      this,
    );
  }
}

abstract class _CommunityDetailResponse implements CommunityDetailResponse {
  const factory _CommunityDetailResponse(
      {required final bool success,
      required final CommunityRecipe data,
      final String? message}) = _$CommunityDetailResponseImpl;

  factory _CommunityDetailResponse.fromJson(Map<String, dynamic> json) =
      _$CommunityDetailResponseImpl.fromJson;

  @override
  bool get success;
  @override
  CommunityRecipe get data;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$CommunityDetailResponseImplCopyWith<_$CommunityDetailResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
