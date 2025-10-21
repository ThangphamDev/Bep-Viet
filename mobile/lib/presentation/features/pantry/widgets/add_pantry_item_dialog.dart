import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class AddPantryItemDialog extends StatefulWidget {
  final VoidCallback onAdded;

  const AddPantryItemDialog({
    super.key,
    required this.onAdded,
  });

  @override
  State<AddPantryItemDialog> createState() => _AddPantryItemDialogState();
}

class _AddPantryItemDialogState extends State<AddPantryItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = 'vegetables';
  String _selectedUnit = 'gram';
  String _selectedLocation = 'fridge';
  DateTime? _expiryDate;

  final List<Map<String, String>> _categories = [
    {'code': 'meat', 'name': 'Thịt, cá', 'icon': '🥩'},
    {'code': 'vegetables', 'name': 'Rau củ', 'icon': '🥬'},
    {'code': 'fruits', 'name': 'Trái cây', 'icon': '🍎'},
    {'code': 'dairy', 'name': 'Sữa, trứng', 'icon': '🥛'},
    {'code': 'grains', 'name': 'Ngũ cốc', 'icon': '🌾'},
    {'code': 'spices', 'name': 'Gia vị', 'icon': '🧂'},
  ];

  final List<Map<String, String>> _units = [
    {'code': 'gram', 'name': 'gram'},
    {'code': 'kg', 'name': 'kg'},
    {'code': 'piece', 'name': 'cái/quả'},
    {'code': 'liter', 'name': 'lít'},
    {'code': 'ml', 'name': 'ml'},
    {'code': 'package', 'name': 'gói'},
    {'code': 'box', 'name': 'hộp'},
  ];

  final List<Map<String, String>> _locations = [
    {'code': 'fridge', 'name': 'Tủ lạnh'},
    {'code': 'freezer', 'name': 'Ngăn đông'},
    {'code': 'pantry', 'name': 'Tủ khô'},
    {'code': 'counter', 'name': 'Bàn bếp'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Thêm nguyên liệu mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name input
                    _buildSectionTitle('Tên nguyên liệu'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: Thịt bò, Cà chua',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    _buildSectionTitle('Loại nguyên liệu'),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                    const SizedBox(height: 16),

                    // Quantity and unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Số lượng'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '500',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Đơn vị'),
                              const SizedBox(height: 8),
                              _buildUnitSelector(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location
                    _buildSectionTitle('Vị trí lưu trữ'),
                    const SizedBox(height: 8),
                    _buildLocationSelector(),
                    const SizedBox(height: 16),

                    // Expiry date
                    _buildSectionTitle('Ngày hết hạn'),
                    const SizedBox(height: 8),
                    _buildExpiryDateSelector(),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addItem,
                            child: const Text('Thêm vào tủ lạnh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category['code'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category['code']!;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryGreen 
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category['icon']!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  category['name']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? AppTheme.primaryGreen 
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: _units.map((unit) {
        return DropdownMenuItem(
          value: unit['code'],
          child: Text(unit['name']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUnit = value!;
        });
      },
    );
  }

  Widget _buildLocationSelector() {
    return Row(
      children: _locations.map((location) {
        final isSelected = _selectedLocation == location['code'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocation = location['code']!;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryGreen 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                location['name']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpiryDateSelector() {
    return GestureDetector(
      onTap: _selectExpiryDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _expiryDate != null
                    ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                    : 'Chọn ngày hết hạn',
                style: TextStyle(
                  fontSize: 16,
                  color: _expiryDate != null 
                      ? AppTheme.textPrimary 
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập tên nguyên liệu');
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số lượng');
      return;
    }

    if (_expiryDate == null) {
      _showErrorSnackBar('Vui lòng chọn ngày hết hạn');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "${_nameController.text}" vào tủ lạnh'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Call callback
      widget.onAdded();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}