import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class CreateShoppingListDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const CreateShoppingListDialog({
    super.key,
    required this.onCreated,
  });

  @override
  State<CreateShoppingListDialog> createState() => _CreateShoppingListDialogState();
}

class _CreateShoppingListDialogState extends State<CreateShoppingListDialog> {
  final _titleController = TextEditingController();
  String _selectedSource = 'manual';
  String _selectedStore = 'traditional_market';
  bool _includeFromPantry = true;

  @override
  void dispose() {
    _titleController.dispose();
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.add_shopping_cart,
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tạo danh sách mua sắm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title input
            _buildSectionTitle('Tên danh sách'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Mua sắm tuần này',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Source selection
            _buildSectionTitle('Tạo từ'),
            const SizedBox(height: 8),
            _buildSourceSelector(),
            const SizedBox(height: 16),

            // Store type selection
            if (_selectedSource != 'pantry') ...[
              _buildSectionTitle('Loại cửa hàng'),
              const SizedBox(height: 8),
              _buildStoreTypeSelector(),
              const SizedBox(height: 16),
            ],

            // Options
            if (_selectedSource == 'meal_plan') ...[
              _buildSectionTitle('Tùy chọn'),
              const SizedBox(height: 8),
              _buildOptionsSection(),
              const SizedBox(height: 16),
            ],

            // Action Buttons
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
                    onPressed: _createShoppingList,
                    child: const Text('Tạo danh sách'),
                  ),
                ),
              ],
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

  Widget _buildSourceSelector() {
    final sources = [
      {
        'code': 'manual',
        'name': 'Tạo thủ công',
        'icon': Icons.edit,
        'description': 'Thêm từng mục một cách thủ công'
      },
      {
        'code': 'meal_plan',
        'name': 'Từ kế hoạch ăn',
        'icon': Icons.restaurant_menu,
        'description': 'Tạo từ kế hoạch ăn đã có'
      },
      {
        'code': 'pantry',
        'name': 'Từ tủ lạnh',
        'icon': Icons.kitchen,
        'description': 'Dựa trên nguyên liệu sắp hết'
      },
    ];

    return Column(
      children: sources.map((source) {
        final isSelected = _selectedSource == source['code'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSource = source['code'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryGreen 
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  source['icon'] as IconData,
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppTheme.primaryGreen 
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        source['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStoreTypeSelector() {
    final storeTypes = [
      {
        'code': 'traditional_market',
        'name': 'Chợ truyền thống',
        'icon': Icons.store,
      },
      {
        'code': 'supermarket',
        'name': 'Siêu thị',
        'icon': Icons.local_grocery_store,
      },
      {
        'code': 'convenience_store',
        'name': 'Cửa hàng tiện lợi',
        'icon': Icons.storefront,
      },
    ];

    return Row(
      children: storeTypes.map((store) {
        final isSelected = _selectedStore == store['code'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStore = store['code'] as String;
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
              child: Column(
                children: [
                  Icon(
                    store['icon'] as IconData,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        _buildSwitchOption(
          'Kiểm tra tủ lạnh',
          'Loại bỏ nguyên liệu đã có trong tủ lạnh',
          _includeFromPantry,
          (value) {
            setState(() {
              _includeFromPantry = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  void _createShoppingList() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên danh sách'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
          content: Text('Đã tạo danh sách "${_titleController.text}"'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Call callback
      widget.onCreated();
    });
  }
}