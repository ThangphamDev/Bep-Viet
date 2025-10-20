import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:dio/dio.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/image_analysis_widget.dart';
import 'package:bepviet_mobile/presentation/features/suggest/widgets/suggestion_card.dart';
import 'package:bepviet_mobile/data/models/suggestion_model.dart';

// Metadata cho mỗi suggestion với match score và advisory
// NOTE: Backend giờ đã tính sẵn requestMatchScore, ingredientMatchScore, matchScore
// và filter theo tags. Client chỉ cần hiển thị kết quả.
class _AiMeta {
  final SuggestionModel suggestion;
  final double matchScore; // Từ backend (finalScore)
  final List<String> missingIngredients;
  final String advisory;
  final List<String> tags; // Tags từ backend (Cháo, Súp, etc.)

  _AiMeta({
    required this.suggestion,
    required this.matchScore,
    required this.missingIngredients,
    required this.advisory,
    required this.tags,
  });
}

class AiSuggestPage extends StatefulWidget {
  const AiSuggestPage({super.key});

  @override
  State<AiSuggestPage> createState() => _AiSuggestPageState();
}

class _AiSuggestPageState extends State<AiSuggestPage> {
  late final ApiService _apiService;
  List<Map<String, dynamic>> _detectedIngredients = [];
  String _selectedRegion = 'BAC';
  int _spicePreference = 2; // 0-4
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<SuggestionModel> _aiSuggestions = [];
  List<_AiMeta> _aiMeta = [];
  String? _chatResponse; // Chatbot response text
  String? _generalAdvice; // General advice from Gemini

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // Build metadata - Backend đã tính sẵn scores
  // Client chỉ cần extract và hiển thị
  List<_AiMeta> _buildMeta(
    List<SuggestionModel> suggestions,
    List<String> detectedIds,
  ) {
    final userPrompt = _promptController.text.trim().toLowerCase();
    final hasUserPrompt = userPrompt.isNotEmpty;

    return suggestions.map((s) {
      // Use backend-calculated score if available
      final matchScore = s.matchScore ?? s.ingredientMatchScore ?? 0.5;
      final ingredientScore = s.ingredientMatchScore ?? matchScore;

      // Extract tags from backend
      final tags = s.tagNames?.split(',').map((t) => t.trim()).toList() ?? [];

      // Missing ingredients (simplified - based on items if available)
      final missing = <String>[];
      if (s.items != null && _detectedIngredients.isNotEmpty) {
        final detected = _detectedIngredients
            .map((e) => (e['name'] ?? '').toString().toLowerCase())
            .toList();

        for (var item in s.items!) {
          final itemName = item.ingredientName.toLowerCase();
          final isDetected = detected.any(
            (d) => itemName.contains(d) || d.contains(itemName),
          );
          if (!isDetected) {
            missing.add(item.ingredientName);
          }
        }
      }

      // Generate advisory based on backend reason or construct from tags/scores
      String advisory = s.reason;

      // Enhance advisory based on context
      if (hasUserPrompt) {
        // User có yêu cầu cụ thể
        if (s.requestMatchScore != null && s.requestMatchScore! >= 0.9) {
          advisory =
              '$advisory\n✅ Món này rất khớp với yêu cầu "${userPrompt.trim()}" của bạn!';
        } else if (s.requestMatchScore != null && s.requestMatchScore! < 0.6) {
          advisory =
              '$advisory\n⚠️ Món này không hoàn toàn khớp với "${userPrompt.trim()}", nhưng vẫn ngon!';
        }
      }

      if (ingredientScore >= 0.9) {
        advisory =
            '$advisory\n🎉 Bạn có đủ ${(ingredientScore * 100).toInt()}% nguyên liệu. Có thể nấu ngay!';
      } else if (missing.isNotEmpty) {
        advisory =
            '$advisory\n📝 Cần mua thêm: ${missing.take(3).join(', ')}${missing.length > 3 ? '...' : ''}';
      }

      return _AiMeta(
        suggestion: s,
        matchScore: matchScore,
        missingIngredients: missing.take(5).toList(),
        advisory: advisory.trim(),
        tags: tags,
      );
    }).toList();
  }

  Future<void> _runAiSuggest() async {
    if (_detectedIngredients.isEmpty) {
      setState(() => _error = 'Vui lòng nhận diện nguyên liệu trước.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _aiSuggestions = [];
      _chatResponse = null;
      _generalAdvice = null;
    });
    // Build ingredient ids once for both primary & fallback calls
    final ingredientIds = _detectedIngredients
        .map((e) => (e['id'] ?? e['ingredient_id'] ?? e['name']).toString())
        .toList();
    try {
      // Call CHATBOT endpoint instead of old ai-suggest
      final resp = await _apiService.getAiSuggestionsChatbot(
        ingredientIds: ingredientIds,
        region: _selectedRegion,
        spicePreference: _spicePreference,
        userPrompt: _promptController.text.trim().isEmpty
            ? null
            : _promptController.text.trim(),
        limit: 30,
      );

      if (resp['success'] == true && resp['data'] is Map) {
        final chatbotData = resp['data'] as Map<String, dynamic>;

        // Extract chatbot response
        final chatResponse = chatbotData['chatResponse'] as String?;
        final generalAdvice = chatbotData['generalAdvice'] as String?;
        final suggestions = chatbotData['suggestions'] as List?;

        if (suggestions != null && suggestions.isNotEmpty) {
          // Parse suggestions from chatbot response
          final parsedSuggestions = suggestions.map((s) {
            final map = s as Map<String, dynamic>;
            // Convert chatbot format to SuggestionModel (with full recipe data from backend)
            return SuggestionModel(
              recipeId: map['recipeId'] ?? '',
              recipeName: map['recipeName'] ?? 'Unknown',
              recipeImageUrl: map['image_url'] as String?, // ← Lấy từ backend
              variantRegion: map['base_region'] as String? ?? 'BAC',
              totalCost: 0,
              seasonScore: 0,
              reason: map['matchReason'] ?? map['reason'] ?? 'Món ngon',
              tagNames: (map['tags'] as List?)?.join(', '),
              ingredientMatchScore: (map['ingredientMatch'] ?? 0) / 100.0,
              cookTimeMinutes: map['cook_time_min'] as int?,
              difficulty: map['difficulty'] as int?,
            );
          }).toList();

          // Build meta for UI display
          final metaList = parsedSuggestions.asMap().entries.map((entry) {
            final s = entry.value;
            final rawData = suggestions[entry.key] as Map<String, dynamic>;

            return _AiMeta(
              suggestion: s,
              matchScore: s.ingredientMatchScore ?? 0.5,
              missingIngredients:
                  (rawData['missingIngredients'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              advisory: rawData['advisory'] ?? s.reason,
              tags: rawData['tags'] != null
                  ? (rawData['tags'] as List).map((e) => e.toString()).toList()
                  : [],
            );
          }).toList();

          setState(() {
            _chatResponse = chatResponse;
            _generalAdvice = generalAdvice;
            _aiSuggestions = parsedSuggestions;
            _aiMeta = metaList;
            _isLoading = false;
          });
        } else {
          setState(() {
            _chatResponse = chatResponse ?? 'Không tìm thấy món phù hợp';
            _error = 'Không có gợi ý nào';
            _isLoading = false;
          });
        }
      } else {
        // Fallback to backend suggestions search when AI not available
        final fallbackRequest = SearchSuggestionsRequest(
          region: _selectedRegion,
          season: 'XUAN',
          servings: 2,
          budget: 200000,
          spicePreference: _spicePreference,
          pantryIds: ingredientIds,
          excludeAllergens: const [],
          maxTime: 60,
          limit: 30,
        );
        final fallback = await _apiService.searchSuggestions(fallbackRequest);
        final allMeta = _buildMeta(fallback, ingredientIds);
        allMeta.sort((a, b) => b.matchScore.compareTo(a.matchScore));

        final topMeta = allMeta.take(5).toList();
        final alternatives = allMeta.skip(5).take(2).toList();

        setState(() {
          _aiSuggestions = topMeta.map((m) => m.suggestion).toList();
          _aiMeta = [...topMeta, ...alternatives];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Network/404 → fallback
      final fallbackRequest = SearchSuggestionsRequest(
        region: _selectedRegion,
        season: 'XUAN',
        servings: 2,
        budget: 200000,
        spicePreference: _spicePreference,
        pantryIds: ingredientIds,
        excludeAllergens: const [],
        maxTime: 60,
        limit: 30,
      );
      final fallback = await _apiService.searchSuggestions(fallbackRequest);
      final allMeta = _buildMeta(fallback, ingredientIds);
      allMeta.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      final topMeta = allMeta.take(5).toList();
      final alternatives = allMeta.skip(5).take(2).toList();

      setState(() {
        _aiSuggestions = topMeta.map((m) => m.suggestion).toList();
        _aiMeta = [...topMeta, ...alternatives];
        _isLoading = false;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gợi ý AI từ nguyên liệu'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Image analysis
            ImageAnalysisWidget(
              apiService: _apiService,
              onIngredientsDetected: (list) {
                setState(() {
                  _detectedIngredients = list;
                });
              },
              onClose: null,
            ),

            // Step 2: Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tune, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Bộ lọc gợi ý',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _regionChip('Miền Bắc', 'BAC'),
                        _regionChip('Miền Trung', 'TRUNG'),
                        _regionChip('Miền Nam', 'NAM'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Độ cay mong muốn',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Slider(
                      value: _spicePreference.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      activeColor: AppTheme.primaryGreen,
                      label: [
                        'Không cay',
                        'Ít cay',
                        'Vừa',
                        'Hơi cay',
                        'Cay',
                      ][_spicePreference],
                      onChanged: (v) => setState(() {
                        _spicePreference = v.round();
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText:
                            'Yêu cầu thêm (ví dụ: "ít dầu mỡ", "thêm ớt hiểm")',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAiSuggest,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          _isLoading ? 'Đang gợi ý...' : 'Gợi ý bằng AI',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Step 3: Chatbot Response
            if (_chatResponse != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _chatResponse!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Step 4: Results
            if (_aiSuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Gợi ý món ăn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_aiSuggestions.length, (index) {
                      final s = _aiSuggestions[index];
                      final m = _aiMeta[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Advisory Banner
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen.withOpacity(0.08),
                                    AppTheme.primaryGreen.withOpacity(0.03),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Gợi ý điều chỉnh',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryGreen,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${(m.matchScore * 100).round()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    m.advisory,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (m.missingIngredients.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Cần mua thêm:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: m.missingIngredients
                                          .take(4)
                                          .map(
                                            (name) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppTheme.primaryGreen
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 12,
                                                    color:
                                                        AppTheme.primaryGreen,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppTheme.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    if (m.missingIngredients.length > 4)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '+${m.missingIngredients.length - 4} nguyên liệu khác',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textTertiary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            // Recipe Card
                            SuggestionCard(suggestion: s, onTap: () {}),
                          ],
                        ),
                      );
                    }),

                    // Show alternatives if available
                    if (_aiMeta.length > _aiSuggestions.length) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Gợi ý thêm (khớp thấp hơn)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _aiMeta
                                  .skip(_aiSuggestions.length)
                                  .take(2)
                                  .map(
                                    (m) => Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: AppTheme.primaryGreen
                                            .withOpacity(0.2),
                                        child: Text(
                                          '${(m.matchScore * 100).round()}%',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      label: Text(m.suggestion.recipeName),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // General Advice (nếu có)
                    if (_generalAdvice != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _generalAdvice!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber.shade900,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _regionChip(String label, String code) {
    final isSelected = _selectedRegion == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedRegion = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
