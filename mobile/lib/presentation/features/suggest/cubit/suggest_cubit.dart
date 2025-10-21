import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';

class SuggestState {
  final List<SuggestionModel> suggestions;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String selectedRegion;
  final String selectedSeason;
  final int servings;
  final int budget;
  final int spicePreference;
  final int maxTime;
  final List<String> pantryIds;
  final List<String> excludeAllergens;

  SuggestState({
    this.suggestions = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.selectedRegion = 'BAC',
    this.selectedSeason = 'XUAN',
    this.servings = 4,
    this.budget = 100000,
    this.spicePreference = 2,
    this.maxTime = 60,
    this.pantryIds = const [],
    this.excludeAllergens = const [],
  });

  SuggestState copyWith({
    List<SuggestionModel>? suggestions,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? selectedRegion,
    String? selectedSeason,
    int? servings,
    int? budget,
    int? spicePreference,
    int? maxTime,
    List<String>? pantryIds,
    List<String>? excludeAllergens,
  }) {
    return SuggestState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      servings: servings ?? this.servings,
      budget: budget ?? this.budget,
      spicePreference: spicePreference ?? this.spicePreference,
      maxTime: maxTime ?? this.maxTime,
      pantryIds: pantryIds ?? this.pantryIds,
      excludeAllergens: excludeAllergens ?? this.excludeAllergens,
    );
  }
}

class SuggestCubit extends Cubit<SuggestState> {
  final ApiService _apiService;

  SuggestCubit(this._apiService) : super(SuggestState()) {
    // Load initial suggestions
    _loadInitialSuggestions();
  }

  Future<void> _loadInitialSuggestions() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Create initial request with default values
      final request = SearchSuggestionsRequest(
        region: state.selectedRegion,
        season: state.selectedSeason,
        servings: state.servings,
        budget: state.budget,
        spicePreference: state.spicePreference,
        pantryIds: state.pantryIds,
        excludeAllergens: state.excludeAllergens,
        maxTime: state.maxTime,
        limit: 50, // Limit to 50 suggestions
      );

      final suggestions = await _apiService.searchSuggestions(request);
      emit(state.copyWith(suggestions: suggestions, isLoading: false));
    } catch (e) {
      // If API fails, show sample data as fallback
      _loadSampleSuggestions();
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể kết nối API. Đang hiển thị dữ liệu mẫu.',
        ),
      );
    }
  }

  void _loadSampleSuggestions() {
    // Sample suggestions data as fallback
    final sampleSuggestions = [
      SuggestionModel(
        recipeId: 'recipe_1',
        recipeName: 'Cơm tấm sườn nướng',
        recipeImageUrl: null,
        variantRegion: 'NAM',
        totalCost: 45000,
        seasonScore: 95,
        reason: 'Món ăn đặc trưng miền Nam, nguyên liệu tươi ngon theo mùa',
        items: [
          SuggestionItemModel(
            ingredientId: 'rice',
            ingredientName: 'Gạo tấm',
            quantity: 200,
            unit: 'g',
            estCost: 8000,
          ),
          SuggestionItemModel(
            ingredientId: 'pork_ribs',
            ingredientName: 'Sườn heo',
            quantity: 300,
            unit: 'g',
            estCost: 25000,
          ),
          SuggestionItemModel(
            ingredientId: 'fish_sauce',
            ingredientName: 'Nước mắm',
            quantity: 2,
            unit: 'tbsp',
            estCost: 2000,
          ),
        ],
        prepTimeMinutes: 15,
        cookTimeMinutes: 30,
        servings: 2,
        difficulty: 2,
      ),
      SuggestionModel(
        recipeId: 'recipe_2',
        recipeName: 'Phở bò',
        recipeImageUrl: null,
        variantRegion: 'BAC',
        totalCost: 55000,
        seasonScore: 88,
        reason: 'Món ăn truyền thống miền Bắc, phù hợp thời tiết mát mẻ',
        items: [
          SuggestionItemModel(
            ingredientId: 'pho_noodles',
            ingredientName: 'Bánh phở',
            quantity: 400,
            unit: 'g',
            estCost: 12000,
          ),
          SuggestionItemModel(
            ingredientId: 'beef',
            ingredientName: 'Thịt bò',
            quantity: 200,
            unit: 'g',
            estCost: 30000,
          ),
          SuggestionItemModel(
            ingredientId: 'herbs',
            ingredientName: 'Rau thơm',
            quantity: 50,
            unit: 'g',
            estCost: 5000,
          ),
        ],
        prepTimeMinutes: 20,
        cookTimeMinutes: 60,
        servings: 2,
        difficulty: 3,
      ),
      SuggestionModel(
        recipeId: 'recipe_3',
        recipeName: 'Bún bò Huế',
        recipeImageUrl: null,
        variantRegion: 'TRUNG',
        totalCost: 48000,
        seasonScore: 92,
        reason: 'Đặc sản miền Trung, cay nồng đậm đà',
        items: [
          SuggestionItemModel(
            ingredientId: 'vermicelli',
            ingredientName: 'Bún tươi',
            quantity: 300,
            unit: 'g',
            estCost: 8000,
          ),
          SuggestionItemModel(
            ingredientId: 'beef_shank',
            ingredientName: 'Bắp bò',
            quantity: 250,
            unit: 'g',
            estCost: 28000,
          ),
          SuggestionItemModel(
            ingredientId: 'lemongrass',
            ingredientName: 'Sả',
            quantity: 3,
            unit: 'cây',
            estCost: 3000,
          ),
        ],
        prepTimeMinutes: 25,
        cookTimeMinutes: 45,
        servings: 2,
        difficulty: 3,
      ),
    ];

    emit(state.copyWith(suggestions: sampleSuggestions));
  }

  Future<void> searchSuggestions() async {
    emit(state.copyWith(isSearching: true, error: null));

    try {
      final request = SearchSuggestionsRequest(
        region: state.selectedRegion,
        season: state.selectedSeason,
        servings: state.servings,
        budget: state.budget,
        spicePreference: state.spicePreference,
        pantryIds: state.pantryIds,
        excludeAllergens: state.excludeAllergens,
        maxTime: state.maxTime,
        limit: 50, // Limit to 50 suggestions
      );

      final suggestions = await _apiService.searchSuggestions(request);
      emit(state.copyWith(suggestions: suggestions, isSearching: false));
    } catch (e) {
      // If API fails, show sample data as fallback
      _loadSampleSuggestions();
      emit(
        state.copyWith(
          isSearching: false,
          error: 'Không thể kết nối API. Đang hiển thị dữ liệu mẫu.',
        ),
      );
    }
  }

  void updateRegion(String region) {
    emit(state.copyWith(selectedRegion: region));
  }

  void updateSeason(String season) {
    emit(state.copyWith(selectedSeason: season));
  }

  void updateServings(int servings) {
    emit(state.copyWith(servings: servings));
  }

  void updateBudget(int budget) {
    emit(state.copyWith(budget: budget));
  }

  void updateSpicePreference(int spicePreference) {
    emit(state.copyWith(spicePreference: spicePreference));
  }

  void updateMaxTime(int maxTime) {
    emit(state.copyWith(maxTime: maxTime));
  }

  void addPantryItem(String ingredientId) {
    final pantryIds = List<String>.from(state.pantryIds);
    if (!pantryIds.contains(ingredientId)) {
      pantryIds.add(ingredientId);
      emit(state.copyWith(pantryIds: pantryIds));
    }
  }

  void removePantryItem(String ingredientId) {
    final pantryIds = List<String>.from(state.pantryIds);
    pantryIds.remove(ingredientId);
    emit(state.copyWith(pantryIds: pantryIds));
  }

  void addExcludeAllergen(String allergen) {
    final excludeAllergens = List<String>.from(state.excludeAllergens);
    if (!excludeAllergens.contains(allergen)) {
      excludeAllergens.add(allergen);
      emit(state.copyWith(excludeAllergens: excludeAllergens));
    }
  }

  void removeExcludeAllergen(String allergen) {
    final excludeAllergens = List<String>.from(state.excludeAllergens);
    excludeAllergens.remove(allergen);
    emit(state.copyWith(excludeAllergens: excludeAllergens));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
