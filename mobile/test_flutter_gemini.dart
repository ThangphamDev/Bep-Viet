import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 FLUTTER GEMINI API TEST');
  print('=' * 50);
  print('');

  // Test configuration
  const apiKey = 'AIzaSyBZ4UVKR8pzfvVV3STOf411cP3lSlgIluc';
  const model = 'gemini-2.0-flash';
  const baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  print('🔧 Configuration:');
  print('API Key: ${apiKey.substring(0, 10)}...');
  print('Model: $model');
  print('Base URL: $baseUrl');
  print('');

  // Test prompts
  final testPrompts = [
    'Xin chào! Bạn có thể giúp tôi tư vấn về dinh dưỡng không?',
    'Tôi bị cao huyết áp, nên ăn gì?',
    'Cách giảm cân an toàn?',
    'Trẻ em cần dinh dưỡng gì?',
    'Gợi ý thực đơn tuần cho gia đình 4 người',
  ];

  for (int i = 0; i < testPrompts.length; i++) {
    final prompt = testPrompts[i];
    print('📝 Test ${i + 1}: "${prompt}"');
    print('─' * 50);

    try {
      final response = await testGeminiAPI(apiKey, model, baseUrl, prompt);
      print('✅ SUCCESS!');
      print('🤖 AI Response:');
      print(response);
    } catch (error) {
      print('❌ ERROR: $error');
    }

    print('');
  }

  print('🎉 All tests completed!');
}

Future<String> testGeminiAPI(
  String apiKey,
  String model,
  String baseUrl,
  String prompt,
) async {
  final url = Uri.parse('$baseUrl/models/$model:generateContent?key=$apiKey');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': prompt},
        ],
      },
    ],
    'generationConfig': {
      'temperature': 0.7,
      'maxOutputTokens': 1000,
      'topP': 0.8,
      'topK': 10,
    },
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📡 Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null) {
          final parts = candidate['content']['parts'];
          if (parts.isNotEmpty) {
            return parts[0]['text'] ?? 'No text response';
          }
        }
      }

      return 'No valid response found';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    throw Exception('Request failed: $e');
  }
}


