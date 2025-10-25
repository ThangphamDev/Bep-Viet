import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

/// Service để lấy gợi ý món ăn dựa trên nguyên liệu trong tủ lạnh
class PantrySuggestionsService {
  final ApiService _apiService;
  final AuthService _authService;

  PantrySuggestionsService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  /// Lấy danh sách món ăn gợi ý từ nguyên liệu có sẵn
  Future<PantrySuggestionsResult> getSuggestions({int limit = 20}) async {
    final token = _authService.accessToken;
    if (token == null) {
      return PantrySuggestionsResult(
        success: false,
        message: 'Bạn cần đăng nhập để sử dụng chức năng này',
        recipes: [],
        pantryItems: [],
      );
    }

    try {
      print('🔍 Fetching pantry suggestions with limit: $limit');
      final response = await _apiService.getPantrySuggestions(token, limit);
      
      print('📦 API Response: $response');
      print('📦 Data type: ${response['data'].runtimeType}');
      print('📦 Data: ${response['data']}');
      print('📦 Pantry items type: ${response['pantry_items'].runtimeType}');
      print('📦 Pantry items: ${response['pantry_items']}');
      
      final recipes = (response['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final pantryItems = (response['pantry_items'] as List? ?? []).cast<Map<String, dynamic>>();
      
      print('✅ Parsed ${recipes.length} recipes and ${pantryItems.length} pantry items');
      
      return PantrySuggestionsResult(
        success: true,
        message: response['message'] as String? ?? '',
        recipes: recipes,
        pantryItems: pantryItems,
      );
    } catch (e) {
      print('❌ Error fetching pantry suggestions: $e');
      return PantrySuggestionsResult(
        success: false,
        message: 'Lỗi khi tải gợi ý: ${e.toString()}',
        recipes: [],
        pantryItems: [],
      );
    }
  }
}

class PantrySuggestionsResult {
  final bool success;
  final String message;
  final List<Map<String, dynamic>> recipes;
  final List<Map<String, dynamic>> pantryItems;

  PantrySuggestionsResult({
    required this.success,
    required this.message,
    required this.recipes,
    required this.pantryItems,
  });

  int get totalPantryItems => pantryItems.length;
}

class RecipeSuggestion {
  final String recipeId;
  final String nameVi;
  final String? nameEn;
  final String? mealType;
  final String? difficulty;
  final int? cookTimeMin;
  final String? spiceLevel;
  final double? ratingAvg;
  final String? imageUrl;
  final int pantryMatchCount;

  RecipeSuggestion({
    required this.recipeId,
    required this.nameVi,
    this.nameEn,
    this.mealType,
    this.difficulty,
    this.cookTimeMin,
    this.spiceLevel,
    this.ratingAvg,
    this.imageUrl,
    required this.pantryMatchCount,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) {
    return RecipeSuggestion(
      recipeId: json['recipe_id'] as String,
      nameVi: json['name_vi'] as String,
      nameEn: json['name_en'] as String?,
      mealType: json['meal_type'] as String?,
      difficulty: json['difficulty'] as String?,
      cookTimeMin: json['cook_time_min'] as int?,
      spiceLevel: json['spice_level'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      pantryMatchCount: json['pantry_match_count'] as int? ?? 0,
    );
  }
}

