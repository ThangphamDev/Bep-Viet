import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/config/gemini_config.dart';

/// Helper để phân loại nguyên liệu vào các quầy hàng siêu thị
/// 
/// **3 CÁCH PHÂN LOẠI:**
/// 
/// 1. **Rule-based (classifyIngredient)** - Nhanh, sync, ~75% chính xác
///    - Dựa trên từ khóa trong tên nguyên liệu
///    - Instant, không cần internet
///    - Dùng khi cần tốc độ hoặc offline
/// 
/// 2. **AI-based (classifyWithAI)** - Chậm, async, ~95% chính xác
///    - Dùng Gemini AI để phân loại
///    - Hiểu context và ngữ nghĩa
///    - Cần internet, tốn ~1-2s và $0.001/call
/// 
/// 3. **Hybrid với cache (classifyWithCache)** - RECOMMENDED ⭐
///    - Check cache trước (instant nếu có)
///    - Nếu chưa có → AI classify → Save cache
///    - Lần sau instant và chính xác
///    - Best of both worlds!
/// 
/// **USAGE:**
/// ```dart
/// // Option 1: Rule-based (sync, instant)
/// final section = IngredientSectionHelper.classifyIngredient("Cà chua bi");
/// 
/// // Option 2: AI (async, chính xác)
/// final section = await IngredientSectionHelper.classifyWithAI("Snack khoai tây");
/// 
/// // Option 3: Hybrid với cache (async, recommended)
/// final section = await IngredientSectionHelper.classifyWithCache("Kem đánh bông");
/// ```
class IngredientSectionHelper {
  static const String _cachePrefix = 'ingredient_section_';
  
  /// Phân loại nguyên liệu dựa trên tên (Rule-based - nhanh)
  static String classifyIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase().trim();

    // Rau củ quả
    if (_matchKeywords(name, [
      'rau', 'củ', 'cải', 'bắp cải', 'xà lách', 'cải thảo',
      'cà chua', 'cà rốt', 'cà tím', 'cà',
      'khoai', 'bí', 'đậu', 'đỗ',
      'hành', 'tỏi', 'hẹ', 'gừng', 'riềng', 'sả',
      'ớt', 'chanh', 'cam', 'quả', 'trái',
      'chuối', 'táo', 'bưởi', 'dưa',
      'muống', 'ngót', 'mồng tơi', 'bí đỏ', 'bí ngô'
    ])) {
      return 'Rau củ quả';
    }

    // Thịt, cá, hải sản
    if (_matchKeywords(name, [
      'thịt', 'heo', 'lợn', 'bò', 'gà', 'vịt', 'ngan',
      'cá', 'tôm', 'mực', 'ghẹ', 'cua', 'ốc',
      'sườn', 'xương', 'chân', 'gan', 'tim', 'ba chỉ',
      'hải sản', 'tép', 'nghêu', 'sò'
    ])) {
      return 'Thịt, cá, hải sản';
    }

    // Trứng, sữa
    if (_matchKeywords(name, [
      'trứng', 'sữa', 'bơ', 'phô mai', 'cheese', 'cream',
      'yaourt', 'sữa chua', 'yogurt'
    ])) {
      return 'Trứng, sữa';
    }

    // Gia vị, nước chấm
    if (_matchKeywords(name, [
      'muối', 'đường', 'tiêu', 'bột',
      'nước mắm', 'nước tương', 'tương', 'mắm',
      'dầu', 'giấm', 'mật ong', 'hạt nêm',
      'bột canh', 'nước dùng',
      'me', 'nghệ', 'gia vị', 'hành khô', 'tỏi khô',
      'sa tế', 'tương ớt', 'mè', 'vừng'
    ])) {
      return 'Gia vị, ướp';
    }

    // Đồ khô
    if (_matchKeywords(name, [
      'gạo', 'cơm', 'mì', 'miến', 'bún', 'phở',
      'bánh', 'bánh phở', 'bánh tráng', 'hủ tiếu',
      'nếp', 'đậu khô', 'hạt', 'yến mạch',
      'ngô', 'bắp', 'bánh đa'
    ])) {
      return 'Đồ khô';
    }

    // Đồ uống
    if (_matchKeywords(name, [
      'nước', 'nước ngọt', 'coca', 'pepsi', 'trà', 'cà phê',
      'bia', 'rượu', 'nước ép', 'sinh tố', 'soda'
    ])) {
      return 'Đồ uống';
    }

    // Đồ đông lạnh
    if (_matchKeywords(name, [
      'đông lạnh', 'frozen', 'kem'
    ])) {
      return 'Đồ đông lạnh';
    }

    // Mặc định
    return 'Khác';
  }

  /// Kiểm tra tên có chứa bất kỳ từ khóa nào không
  static bool _matchKeywords(String name, List<String> keywords) {
    return keywords.any((keyword) => name.contains(keyword));
  }

  /// Lấy icon phù hợp cho từng quầy hàng
  static IconData getSectionIcon(String sectionName) {
    final lowerName = sectionName.toLowerCase();

    if (lowerName.contains('rau') ||
        lowerName.contains('củ') ||
        lowerName.contains('quả')) {
      return Icons.eco;
    } else if (lowerName.contains('thịt') ||
        lowerName.contains('cá') ||
        lowerName.contains('hải sản')) {
      return Icons.set_meal;
    } else if (lowerName.contains('trứng') || lowerName.contains('sữa')) {
      return Icons.egg;
    } else if (lowerName.contains('gia vị') || lowerName.contains('ướp')) {
      return Icons.restaurant;
    } else if (lowerName.contains('khô')) {
      return Icons.grain;
    } else if (lowerName.contains('uống')) {
      return Icons.local_drink;
    } else if (lowerName.contains('đông lạnh')) {
      return Icons.ac_unit;
    } else {
      return Icons.shopping_basket;
    }
  }

  /// Thứ tự sắp xếp các quầy hàng (theo logic đi chợ)
  static const List<String> sectionOrder = [
    'Rau củ quả',
    'Thịt, cá, hải sản',
    'Trứng, sữa',
    'Gia vị, ướp',
    'Đồ khô',
    'Đồ uống',
    'Đồ đông lạnh',
    'Khác',
  ];

  /// Lấy index thứ tự của section để sort
  static int getSectionOrder(String sectionName) {
    final index = sectionOrder.indexOf(sectionName);
    return index == -1 ? sectionOrder.length : index;
  }
  
  /// Phân loại bằng AI (Gemini) - sử dụng HTTP API
  static Future<String> classifyWithAI(String ingredientName) async {
    try {
      final prompt = '''
Bạn là chuyên gia phân loại nguyên liệu siêu thị tại Việt Nam.

Phân loại nguyên liệu sau vào ĐÚNG 1 quầy hàng:
1. Rau củ quả
2. Thịt, cá, hải sản
3. Trứng, sữa
4. Gia vị, ướp
5. Đồ khô
6. Đồ uống
7. Đồ đông lạnh
8. Khác

Nguyên liệu: "$ingredientName"

QUY TẮC QUAN TRỌNG:
- Rau/củ/quả TƯƠI → "Rau củ quả"
- Thịt/cá/hải sản TƯƠI hoặc chế biến → "Thịt, cá, hải sản"
- Trứng, sữa, bơ, phô mai, cream → "Trứng, sữa"
- Muối, đường, gia vị, nước mắm, tương, dầu ăn → "Gia vị, ướp"
- Gạo, mì, bún, bánh, đồ khô, snack → "Đồ khô"
- Nước ngọt, trà, cà phê, bia, rượu → "Đồ uống"
- Ice cream, đồ đông lạnh → "Đồ đông lạnh"
- Snack khoai tây → "Đồ khô" (không phải "Rau củ quả")
- Kem đánh bông/whipped cream → "Trứng, sữa" (không phải "Đồ đông lạnh")
- Khoai tây tươi → "Rau củ quả"

CHỈ TRẢ VỀ TÊN QUẦY (1 trong 8 tên trên), KHÔNG GIẢI THÍCH.

Ví dụ output: "Đồ khô"

Output:
''';
      
      // Call Gemini API using HTTP
      final response = await http.post(
        Uri.parse(GeminiConfig.generateContentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1, // Low temperature for consistent results
            'maxOutputTokens': 20, // Only need short answer
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            ?.toString()
            .trim() ?? 'Khác';
        
        // Validate result
        if (sectionOrder.contains(result)) {
          return result;
        } else {
          return classifyIngredient(ingredientName);
        }
      } else {
        return classifyIngredient(ingredientName);
      }
    } catch (e) {
      return classifyIngredient(ingredientName);
    }
  }
  
  /// Phân loại với cache (Hybrid: Cache → AI → Rule-based)
  static Future<String> classifyWithCache(String ingredientName) async {
    final normalizedName = ingredientName.toLowerCase().trim();
    
    // 1. Check cache first
    final cached = await _getCachedClassification(normalizedName);
    if (cached != null) {
      return cached;
    }
    
    // 2. Try AI classification
    try {
      final aiResult = await classifyWithAI(ingredientName);
      
      // Save to cache
      await _saveToCache(normalizedName, aiResult);
      
      return aiResult;
    } catch (e) {
      // 3. Fallback to rule-based
      final ruleResult = classifyIngredient(ingredientName);
      
      // Save to cache (even rule-based result)
      await _saveToCache(normalizedName, ruleResult);
      
      return ruleResult;
    }
  }
  
  /// Get cached classification
  static Future<String?> _getCachedClassification(String ingredientName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cachePrefix$ingredientName');
    } catch (e) {
      return null;
    }
  }
  
  /// Save classification to cache
  static Future<void> _saveToCache(String ingredientName, String section) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$ingredientName', section);
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Clear all cached classifications
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }
}

