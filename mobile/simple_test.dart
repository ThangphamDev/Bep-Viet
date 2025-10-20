import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 SIMPLE GEMINI TEST');
  print('====================');

  const apiKey = 'AIzaSyBZ4UVKR8pzfvVV3STOf411cP3lSlgIluc';
  const model = 'gemini-2.0-flash';
  const url =
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

  print('API Key: ${apiKey.substring(0, 10)}...');
  print('Model: $model');
  print('URL: $url');
  print('');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': 'Xin chào! Bạn có thể giúp tôi tư vấn về dinh dưỡng không?'},
        ],
      },
    ],
    'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 500},
  };

  try {
    print('📡 Sending request...');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('📡 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ SUCCESS!');

      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final candidate = data['candidates'][0];
        if (candidate['content'] != null &&
            candidate['content']['parts'] != null) {
          final parts = candidate['content']['parts'];
          if (parts.isNotEmpty) {
            print('🤖 AI Response:');
            print(parts[0]['text']);
          }
        }
      }
    } else {
      print('❌ ERROR: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}


