import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';

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
    this.selectedRegion = 'NAM',
    this.selectedSeason = 'HA',
    this.servings = 2,
    this.budget = 50000,
    this.spicePreference = 2,
    this.maxTime = 45,
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
  SuggestCubit() : super(SuggestState()) {
    // Load sample data on initialization
    _loadSampleSuggestions();
  }

  void _loadSampleSuggestions() {
    // Sample suggestions data
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
      SuggestionModel(
        recipeId: 'recipe_4',
        recipeName: 'Cơm cháy chà bông',
        recipeImageUrl: null,
        variantRegion: 'NAM',
        totalCost: 35000,
        seasonScore: 85,
        reason: 'Món ăn dân dã miền Nam, dễ làm và ngon miệng',
        items: [
          SuggestionItemModel(
            ingredientId: 'rice',
            ingredientName: 'Cơm nguội',
            quantity: 300,
            unit: 'g',
            estCost: 5000,
          ),
          SuggestionItemModel(
            ingredientId: 'pork_floss',
            ingredientName: 'Chà bông',
            quantity: 100,
            unit: 'g',
            estCost: 20000,
          ),
          SuggestionItemModel(
            ingredientId: 'scallion',
            ingredientName: 'Hành lá',
            quantity: 2,
            unit: 'cây',
            estCost: 2000,
          ),
        ],
        prepTimeMinutes: 10,
        cookTimeMinutes: 20,
        servings: 2,
        difficulty: 1,
      ),
      SuggestionModel(
        recipeId: 'recipe_5',
        recipeName: 'Bánh xèo',
        recipeImageUrl: null,
        variantRegion: 'NAM',
        totalCost: 42000,
        seasonScore: 90,
        reason: 'Bánh xèo giòn tan, đậm đà hương vị miền Tây',
        items: [
          SuggestionItemModel(
            ingredientId: 'rice_flour',
            ingredientName: 'Bột gạo',
            quantity: 200,
            unit: 'g',
            estCost: 8000,
          ),
          SuggestionItemModel(
            ingredientId: 'coconut_milk',
            ingredientName: 'Nước cốt dừa',
            quantity: 100,
            unit: 'ml',
            estCost: 5000,
          ),
          SuggestionItemModel(
            ingredientId: 'shrimp',
            ingredientName: 'Tôm',
            quantity: 150,
            unit: 'g',
            estCost: 20000,
          ),
        ],
        prepTimeMinutes: 15,
        cookTimeMinutes: 25,
        servings: 2,
        difficulty: 2,
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
        pantryIds: state.pantryIds.isNotEmpty ? state.pantryIds : null,
        excludeAllergens: state.excludeAllergens.isNotEmpty
            ? state.excludeAllergens
            : null,
        maxTime: state.maxTime,
      );

      // For now, just simulate API call with sample data
      await Future.delayed(const Duration(seconds: 1));

      // Filter sample data based on current filters
      final filteredSuggestions = _filterSampleSuggestions(request);

      emit(
        state.copyWith(suggestions: filteredSuggestions, isSearching: false),
      );
    } catch (e) {
      emit(state.copyWith(isSearching: false, error: e.toString()));
    }
  }

  List<SuggestionModel> _filterSampleSuggestions(
    SearchSuggestionsRequest request,
  ) {
    // This is a simple filter - in real app, this would be done by the API
    final allSuggestions = [
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
        ],
        prepTimeMinutes: 25,
        cookTimeMinutes: 45,
        servings: 2,
        difficulty: 3,
      ),
    ];

    // Simple filtering logic
    return allSuggestions.where((suggestion) {
      // Filter by region
      if (request.region != suggestion.variantRegion) return false;

      // Filter by budget
      if (suggestion.totalCost > request.budget) return false;

      // Filter by servings (simple check)
      if (suggestion.servings != request.servings) return false;

      return true;
    }).toList();
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
