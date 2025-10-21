import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class CreateMealPlanDialog extends StatefulWidget {
  final DateTime weekStart;
  final VoidCallback onCreated;

  const CreateMealPlanDialog({
    super.key,
    required this.weekStart,
    required this.onCreated,
  });

  @override
  State<CreateMealPlanDialog> createState() => _CreateMealPlanDialogState();
}

class _CreateMealPlanDialogState extends State<CreateMealPlanDialog> {
  String _selectedRegion = 'NAM';
  double _budgetPerMeal = 50000;
  int _servings = 2;
  bool _nutritionBalance = true;
  bool _avoidRepeat = true;
  int _maxCookingTime = 60;

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
                  Icons.auto_fix_high,
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tạo kế hoạch ăn tự động',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Region Selection
            _buildSectionTitle('Vùng miền'),
            const SizedBox(height: 8),
            _buildRegionSelector(),
            const SizedBox(height: 16),

            // Budget Setting
            _buildSectionTitle('Ngân sách mỗi bữa'),
            const SizedBox(height: 8),
            _buildBudgetSlider(),
            const SizedBox(height: 16),

            // Servings Setting
            _buildSectionTitle('Số khẩu phần'),
            const SizedBox(height: 8),
            _buildServingsSelector(),
            const SizedBox(height: 16),

            // Cooking Time Setting
            _buildSectionTitle('Thời gian nấu tối đa'),
            const SizedBox(height: 8),
            _buildCookingTimeSlider(),
            const SizedBox(height: 16),

            // Options
            _buildSectionTitle('Tùy chọn'),
            const SizedBox(height: 8),
            _buildOptionsSection(),
            const SizedBox(height: 24),

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
                    onPressed: _createMealPlan,
                    child: const Text('Tạo kế hoạch'),
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

  Widget _buildRegionSelector() {
    final regions = [
      {'code': 'BAC', 'name': 'Miền Bắc'},
      {'code': 'TRUNG', 'name': 'Miền Trung'},
      {'code': 'NAM', 'name': 'Miền Nam'},
    ];

    return Row(
      children: regions.map((region) {
        final isSelected = _selectedRegion == region['code'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedRegion = region['code']!;
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
                region['name']!,
                textAlign: TextAlign.center,
                style: TextStyle(
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

  Widget _buildBudgetSlider() {
    return Column(
      children: [
        Slider(
          value: _budgetPerMeal,
          min: 20000,
          max: 100000,
          divisions: 16,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) {
            setState(() {
              _budgetPerMeal = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('20,000đ', style: TextStyle(fontSize: 12)),
            Text(
              '${_budgetPerMeal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const Text('100,000đ', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildServingsSelector() {
    return Row(
      children: [1, 2, 3, 4, 5, 6].map((serving) {
        final isSelected = _servings == serving;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _servings = serving;
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
                '$serving',
                textAlign: TextAlign.center,
                style: TextStyle(
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

  Widget _buildCookingTimeSlider() {
    return Column(
      children: [
        Slider(
          value: _maxCookingTime.toDouble(),
          min: 15,
          max: 120,
          divisions: 21,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) {
            setState(() {
              _maxCookingTime = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('15 phút', style: TextStyle(fontSize: 12)),
            Text(
              '$_maxCookingTime phút',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const Text('120 phút', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        _buildSwitchOption(
          'Cân bằng dinh dưỡng',
          'Tự động cân bằng protein, rau củ, tinh bột',
          _nutritionBalance,
          (value) {
            setState(() {
              _nutritionBalance = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildSwitchOption(
          'Tránh lặp món',
          'Không lặp lại món đã ăn trong 2 tuần gần đây',
          _avoidRepeat,
          (value) {
            setState(() {
              _avoidRepeat = value;
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

  void _createMealPlan() {
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
        const SnackBar(
          content: Text('Kế hoạch ăn đã được tạo thành công!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Call callback
      widget.onCreated();
    });
  }
}