import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/data/sources/remote/community_service.dart';
import 'package:bepviet_mobile/data/sources/remote/community_api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';

class CreateRecipePage extends StatefulWidget {
  final CommunityRecipe? editingRecipe;

  const CreateRecipePage({super.key, this.editingRecipe});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _costController = TextEditingController();

  String? _selectedRegion;
  String? _selectedDifficulty;

  final List<CreateIngredientRequest> _ingredients = [];
  final List<CreateStepRequest> _steps = [];

  // Controllers for ingredients and steps
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _stepControllers = [];

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingRecipe != null) {
      _initializeEditingData();
    }
  }

  void _initializeEditingData() {
    final recipe = widget.editingRecipe!;

    // Set basic fields
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.descriptionMd ?? '';
    _timeController.text = recipe.timeMin?.toString() ?? '';
    _costController.text = recipe.costHint?.toString() ?? '';
    _selectedRegion = recipe.region;
    _selectedDifficulty = recipe.difficulty;

    // Set image if available
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      // Note: We can't directly set the image from URL, user would need to re-select
    }

    // Set ingredients
    if (recipe.ingredients != null) {
      _ingredients.clear();
      _ingredientNameControllers.clear();
      _ingredientQuantityControllers.clear();

      for (var ingredient in recipe.ingredients!) {
        _ingredients.add(
          CreateIngredientRequest(
            name: ingredient.ingredientName,
            quantity: ingredient.quantity ?? '1 phần', // Default if null
            note: ingredient.note,
          ),
        );

        _ingredientNameControllers.add(
          TextEditingController(text: ingredient.ingredientName),
        );
        _ingredientQuantityControllers.add(
          TextEditingController(text: ingredient.quantity ?? ''),
        );
      }
    }

    // Set steps
    if (recipe.steps != null) {
      _steps.clear();
      _stepControllers.clear();

      for (var step in recipe.steps!) {
        _steps.add(
          CreateStepRequest(orderNo: step.orderNo, contentMd: step.contentMd),
        );

        _stepControllers.add(TextEditingController(text: step.contentMd));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _costController.dispose();

    // Dispose ingredient controllers
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn hình ảnh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.editingRecipe != null
              ? 'Chỉnh sửa công thức'
              : 'Tạo công thức',
        ),

        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: Text(
              widget.editingRecipe != null ? 'Cập nhật' : 'Lưu',

              style: TextStyle(
                color: _isLoading
                    ? AppTheme.textSecondary
                    : AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info section
              _buildSection(
                title: 'Thông tin cơ bản',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Tên công thức *',
                        hintText: 'Ví dụ: Phở Bò Hà Nội',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên công thức';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả *',
                        hintText: 'Mô tả ngắn gọn về công thức...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Image upload section
                    _buildImageUpload(),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRegion,
                            decoration: InputDecoration(
                              labelText: 'Vùng miền *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'BAC',
                                child: Text('Bắc'),
                              ),
                              DropdownMenuItem(
                                value: 'TRUNG',
                                child: Text('Trung'),
                              ),
                              DropdownMenuItem(
                                value: 'NAM',
                                child: Text('Nam'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRegion = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn vùng miền';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: InputDecoration(
                              labelText: 'Độ khó *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'DE', child: Text('Dễ')),
                              DropdownMenuItem(
                                value: 'TRUNG_BINH',
                                child: Text('Trung bình'),
                              ),
                              DropdownMenuItem(
                                value: 'KHO',
                                child: Text('Khó'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn độ khó';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Thời gian (phút) *',
                              hintText: '60',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập thời gian';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Vui lòng nhập số hợp lệ';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: InputDecoration(
                              labelText: 'Chi phí (VNĐ)',
                              hintText: '50000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ingredients section
              _buildSection(
                title: 'Nguyên liệu',
                icon: Icons.shopping_cart_outlined,
                child: Column(
                  children: [
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _ingredientNameControllers[index],

                                decoration: InputDecoration(
                                  labelText: 'Tên nguyên liệu',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _ingredients[index] = CreateIngredientRequest(
                                    name: value,
                                    quantity: ingredient.quantity,
                                    note: ingredient.note,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller:
                                    _ingredientQuantityControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Số lượng',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _ingredients[index] = CreateIngredientRequest(
                                    name: ingredient.name,
                                    quantity: value,
                                    note: ingredient.note,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _ingredients.removeAt(index);
                                  _ingredientNameControllers[index].dispose();
                                  _ingredientQuantityControllers[index]
                                      .dispose();
                                  _ingredientNameControllers.removeAt(index);
                                  _ingredientQuantityControllers.removeAt(
                                    index,
                                  );
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _ingredients.add(
                              CreateIngredientRequest(
                                name: '',
                                quantity: '',
                                note: '',
                              ),
                            );
                            _ingredientNameControllers.add(
                              TextEditingController(),
                            );
                            _ingredientQuantityControllers.add(
                              TextEditingController(),
                            );
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm nguyên liệu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Steps section
              _buildSection(
                title: 'Cách làm',
                icon: Icons.list_alt_outlined,
                child: Column(
                  children: [
                    ..._steps.asMap().entries.map((entry) {
                      final index = entry.key;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _stepControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Bước ${index + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _steps.removeAt(index);
                                  _stepControllers[index].dispose();
                                  _stepControllers.removeAt(index);
                                  // Update order numbers
                                  for (int i = 0; i < _steps.length; i++) {
                                    _steps[i] = CreateStepRequest(
                                      orderNo: i + 1,
                                      contentMd: _steps[i].contentMd,
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _steps.add(
                              CreateStepRequest(
                                orderNo: _steps.length + 1,
                                contentMd: '',
                              ),
                            );
                            _stepControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm bước'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.editingRecipe != null
                              ? 'Cập nhật công thức'
                              : 'Tạo công thức',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mô tả món ăn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn miền'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn độ khó'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập thời gian nấu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect data from TextFields
    final ingredients = <CreateIngredientRequest>[];
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      final name = _ingredientNameControllers[i].text.trim();
      final quantity = _ingredientQuantityControllers[i].text.trim();

      if (name.isNotEmpty) {
        ingredients.add(
          CreateIngredientRequest(
            name: name,
            quantity: quantity.isNotEmpty ? quantity : '1 phần',
            note: '',
          ),
        );
      }
    }

    final steps = <CreateStepRequest>[];
    for (int i = 0; i < _stepControllers.length; i++) {
      final content = _stepControllers[i].text.trim();

      if (content.isNotEmpty) {
        steps.add(CreateStepRequest(orderNo: i + 1, contentMd: content));
      }
    }

    // Validate ingredients and steps
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một nguyên liệu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một bước làm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final apiService = ApiService(dio);
      final authService = AuthService(apiService, prefs);

      // Setup AuthInterceptor để tự động refresh token
      apiService.setupAuthInterceptor(authService);

      final communityApiService = CommunityApiService(dio);
      final communityService = CommunityService(communityApiService);

      // Get JWT token
      final token = authService.accessToken;
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đăng nhập để tạo công thức'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // AuthInterceptor sẽ tự động gắn token, không cần gắn thủ công nữa

      // Upload image first if selected, or keep existing image for updates
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          final bytes = await _selectedImage!.readAsBytes();

          // Upload image using the upload endpoint
          imageUrl = await communityService.uploadImage(bytes, 'image/jpeg');
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi tải ảnh lên: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Continue without image
        }
      } else if (widget.editingRecipe != null) {
        // Keep existing image when updating
        imageUrl = widget.editingRecipe!.imageUrl;
        print('Keeping existing image: $imageUrl');
      } else {
        print('No image selected');
      }

      // Create request with uploaded image URL
      final request = CreateCommunityRecipeRequest(
        title: _titleController.text.trim(),
        region: _selectedRegion!,
        descriptionMd: _descriptionController.text.trim(),
        difficulty: _selectedDifficulty!,
        timeMin: int.parse(_timeController.text.trim()),
        costHint: _costController.text.trim().isNotEmpty
            ? int.tryParse(_costController.text.trim())
            : null,
        imageUrl: imageUrl,
        ingredients: ingredients,
        steps: steps,
      );

      // Debug: Log request data
      print('=== CREATE RECIPE REQUEST ===');
      print('Title: ${request.title}');
      print('Region: ${request.region}');
      print('Description: ${request.descriptionMd}');
      print('Difficulty: ${request.difficulty}');
      print('Time: ${request.timeMin}');
      print('Cost: ${request.costHint}');
      print('Ingredients count: ${request.ingredients.length}');
      print('Steps count: ${request.steps.length}');
      print('Has image: ${imageUrl != null}');
      print('Token: ${token.substring(0, 20)}...');
      print('=============================');

      if (widget.editingRecipe != null) {
        // Update existing recipe
        await communityService.updateCommunityRecipe(
          widget.editingRecipe!.id,
          request,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Công thức đã được cập nhật'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new recipe
        await communityService.createCommunityRecipe(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Công thức đã được tạo và đang chờ duyệt'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh món ăn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        if (_selectedImage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
              const SizedBox(width: 4),
              Text(
                'Đã chọn hình ảnh',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: AppTheme.primaryGreen.withOpacity(0.6),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhấn để chọn hình ảnh',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG (tối đa 2MB)',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
