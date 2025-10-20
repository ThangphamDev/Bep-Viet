import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bepviet_mobile/core/config/gemini_config.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Gửi tin nhắn đến Gemini AI và nhận phản hồi
  Future<String> sendMessage(String message, {String? context}) async {
    try {
      final prompt = context != null
          ? GeminiConfig.nutritionAdvisorPrompt
                .replaceAll('{context}', context)
                .replaceAll('{question}', message)
          : message;

      final response = await http.post(
        Uri.parse(GeminiConfig.generateContentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': GeminiConfig.temperature,
            'maxOutputTokens': GeminiConfig.maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Không thể tạo phản hồi.';
      } else {
        return 'Lỗi kết nối: ${response.statusCode}';
      }
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  /// Gợi ý món ăn dựa trên thông tin người dùng
  Future<String> suggestRecipes({
    required String region,
    required String taste,
    required String restrictions,
    required String budget,
    required int servings,
  }) async {
    try {
      final prompt = GeminiConfig.recipeSuggestionPrompt
          .replaceAll('{region}', region)
          .replaceAll('{taste}', taste)
          .replaceAll('{restrictions}', restrictions)
          .replaceAll('{budget}', budget)
          .replaceAll('{servings}', servings.toString());

      final response = await http.post(
        Uri.parse(GeminiConfig.generateContentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 1500},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Không thể tạo gợi ý.';
      } else {
        return 'Lỗi kết nối: ${response.statusCode}';
      }
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  /// Kiểm tra cảnh báo sức khỏe cho món ăn
  Future<String> checkHealthAdvisory({
    required String recipeName,
    required String ingredients,
    required int age,
    required String healthConditions,
    required String allergies,
    required String dietRestrictions,
  }) async {
    try {
      final prompt = GeminiConfig.healthAdvisoryPrompt
          .replaceAll('{recipe_name}', recipeName)
          .replaceAll('{ingredients}', ingredients)
          .replaceAll('{age}', age.toString())
          .replaceAll('{health_conditions}', healthConditions)
          .replaceAll('{allergies}', allergies)
          .replaceAll('{diet_restrictions}', dietRestrictions);

      final response = await http.post(
        Uri.parse(GeminiConfig.generateContentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 800},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Không thể phân tích.';
      } else {
        return 'Lỗi kết nối: ${response.statusCode}';
      }
    } catch (e) {
      return 'Lỗi: ${e.toString()}';
    }
  }

  /// Tư vấn dinh dưỡng chung
  Future<String> getNutritionAdvice(String question) async {
    return await sendMessage(question, context: 'Tư vấn dinh dưỡng');
  }

  /// Gợi ý thực đơn theo tuần
  Future<String> suggestWeeklyMenu({
    required String region,
    required int familySize,
    required String budget,
    required String preferences,
  }) async {
    final message =
        '''
Gợi ý thực đơn tuần cho gia đình:
- Vùng miền: $region
- Số người: $familySize
- Ngân sách: $budget
- Sở thích: $preferences

Hãy tạo thực đơn 7 ngày với 3 bữa/ngày, phù hợp với văn hóa Việt Nam.
''';

    return await sendMessage(message, context: 'Gợi ý thực đơn tuần');
  }
}
