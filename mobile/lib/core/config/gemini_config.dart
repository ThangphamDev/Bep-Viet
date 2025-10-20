import 'dart:io';

class GeminiConfig {
  // Gemini AI Configuration
  // API key được đọc từ file .env hoặc environment variables
  static String get geminiApiKey =>
      _getEnvValue('GEMINI_API_KEY', 'AIzaSyBZ4UVKR8pzfvVV3STOf411cP3lSlgIluc');
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Model Configuration
  static const String modelName = 'gemini-2.0-flash-exp';
  static const int maxTokens = 1000;
  static const double temperature = 0.7;

  // API Endpoints
  static String get generateContentUrl =>
      '$geminiApiUrl/models/$modelName:generateContent?key=$geminiApiKey';

  // Prompt Templates
  static const String nutritionAdvisorPrompt = '''
Bạn là một chuyên gia dinh dưỡng AI của ứng dụng BepViet. 
Nhiệm vụ: Tư vấn dinh dưỡng và sức khỏe cho người dùng Việt Nam.

Quy tắc:
1. Trả lời bằng tiếng Việt
2. Đưa ra lời khuyên cụ thể, thực tế
3. Phù hợp với văn hóa ẩm thực Việt Nam
4. An toàn và khoa học
5. Ngắn gọn, dễ hiểu

Ngữ cảnh: {context}
Câu hỏi: {question}

Hãy trả lời:''';

  static const String recipeSuggestionPrompt = '''
Bạn là chuyên gia ẩm thực AI của BepViet.
Nhiệm vụ: Gợi ý món ăn phù hợp cho người dùng.

Thông tin người dùng:
- Vùng miền: {region}
- Khẩu vị: {taste}
- Hạn chế: {restrictions}
- Ngân sách: {budget}
- Số người: {servings}

Hãy gợi ý 3-5 món ăn phù hợp:''';

  static const String healthAdvisoryPrompt = '''
Bạn là chuyên gia sức khỏe AI của BepViet.
Nhiệm vụ: Đưa ra cảnh báo và lời khuyên sức khỏe.

Thông tin thành viên gia đình:
- Tuổi: {age}
- Tình trạng sức khỏe: {health_conditions}
- Dị ứng: {allergies}
- Chế độ ăn: {diet_restrictions}

Món ăn: {recipe_name}
Nguyên liệu: {ingredients}

Hãy phân tích và đưa ra cảnh báo:''';

  // Helper method to read environment variables
  static String _getEnvValue(String key, String defaultValue) {
    try {
      print('Looking for $key...');

      // Try to read from environment variables first
      final envValue = Platform.environment[key];
      if (envValue != null && envValue.isNotEmpty) {
        print('Found $key in environment: ${envValue.substring(0, 10)}...');
        return envValue;
      }

      // Fallback to reading from .env file
      final envFile = File('.env');
      print('Checking .env file exists: ${envFile.existsSync()}');

      if (envFile.existsSync()) {
        final content = envFile.readAsStringSync();
        print('Env file content: $content');
        final lines = content.split('\n');
        for (final line in lines) {
          if (line.trim().startsWith('$key=')) {
            final value = line.trim().substring('$key='.length);
            print('Found $key in .env: ${value.substring(0, 10)}...');
            return value.trim();
          }
        }
      }

      print('Using default value for $key');
      return defaultValue;
    } catch (e) {
      print('Error reading env value for $key: $e');
      return defaultValue;
    }
  }
}
