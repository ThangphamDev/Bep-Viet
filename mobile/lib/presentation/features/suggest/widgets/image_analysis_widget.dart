import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';

class ImageAnalysisWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onIngredientsDetected;
  final VoidCallback? onClose;
  final ApiService apiService;

  const ImageAnalysisWidget({
    super.key,
    required this.onIngredientsDetected,
    required this.apiService,
    this.onClose,
  });

  @override
  State<ImageAnalysisWidget> createState() => _ImageAnalysisWidgetState();
}

class _ImageAnalysisWidgetState extends State<ImageAnalysisWidget>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _detectedIngredients = [];
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024, // Giảm từ 1920 xuống 1024
        maxHeight: 1024, // Giảm từ 1080 xuống 1024
        imageQuality: 70, // Giảm từ 85% xuống 70% để file nhỏ hơn
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _error = null;
          _detectedIngredients = [];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Không thể chọn ảnh: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call Gemini API to analyze image
      final result = await widget.apiService.analyzeImageBase64(base64Image);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null && data['ingredients'] is List) {
          final ingredients = (data['ingredients'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          setState(() {
            _detectedIngredients = ingredients;
            _isAnalyzing = false;
          });

          widget.onIngredientsDetected(ingredients);
        } else {
          throw Exception('Không tìm thấy nguyên liệu nào trong ảnh');
        }
      } else {
        final message = result['message'] ?? 'Không thể phân tích ảnh';
        throw Exception(message);
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi phân tích ảnh: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.primaryGreen.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nhận diện nguyên liệu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Image Preview
                    if (_selectedImage != null) ...[
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Action Buttons
                    if (_selectedImage == null) ...[
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        label: 'Chụp ảnh',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Chọn từ thư viện',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ] else ...[
                      // Analyze Button
                      if (!_isAnalyzing && _detectedIngredients.isEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _analyzeImage,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Phân tích nguyên liệu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      // Loading
                      if (_isAnalyzing)
                        Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Đang phân tích ảnh với Gemini AI...',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                      // Results
                      if (_detectedIngredients.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Nguyên liệu phát hiện:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._detectedIngredients.map((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          ingredient['name'],
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${ingredient['confidence']}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _detectedIngredients = [];
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Chọn lại'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryGreen,
                                  side: BorderSide(
                                    color: AppTheme.primaryGreen,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],

                    // Error Message
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
