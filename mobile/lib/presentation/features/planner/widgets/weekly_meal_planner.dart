import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class WeeklyMealPlanner extends StatefulWidget {
  final DateTime weekStart;

  const WeeklyMealPlanner({
    super.key,
    required this.weekStart,
  });

  @override
  State<WeeklyMealPlanner> createState() => _WeeklyMealPlannerState();
}

class _WeeklyMealPlannerState extends State<WeeklyMealPlanner> {
  final List<String> _weekDays = [
    'Thứ 2',
    'Thứ 3', 
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật'
  ];

  final List<String> _mealSlots = ['Sáng', 'Trưa', 'Tối'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Meal Plan Grid
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                // Header with meal slots
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Day column header
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Ngày',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Meal slot headers
                      ..._mealSlots.map((slot) => Expanded(
                        child: Text(
                          slot,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                // Meal plan content
                Expanded(
                  child: ListView.builder(
                    itemCount: _weekDays.length,
                    itemBuilder: (context, dayIndex) {
                      final currentDate = widget.weekStart.add(Duration(days: dayIndex));
                      return _buildDayRow(dayIndex, currentDate);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateMealPlan,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Tạo tự động'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _createShoppingList,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Tạo danh sách mua'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(int dayIndex, DateTime date) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primaryGreenLight.withOpacity(0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Day label
            Container(
              width: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekDays[dayIndex],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppTheme.primaryGreen : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Meal slots
            ..._mealSlots.asMap().entries.map((entry) {
              int slotIndex = entry.key;
              return Expanded(
                child: _buildMealSlot(dayIndex, slotIndex, date),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSlot(int dayIndex, int slotIndex, DateTime date) {
    // Mock data - replace with actual meal plan data
    final hasMeal = (dayIndex + slotIndex) % 3 == 0;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          right: slotIndex < _mealSlots.length - 1
              ? BorderSide(color: Colors.grey.shade200, width: 1)
              : BorderSide.none,
        ),
      ),
      child: GestureDetector(
        onTap: () => _showMealOptions(dayIndex, slotIndex, date),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: hasMeal 
                ? AppTheme.primaryGreenLight.withOpacity(0.2)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasMeal 
                  ? AppTheme.primaryGreen.withOpacity(0.3)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: hasMeal 
              ? _buildMealCard()
              : _buildEmptyMealSlot(),
        ),
      ),
    );
  }

  Widget _buildMealCard() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phở Bò',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            '30 phút',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          Spacer(),
          Text(
            '45,000đ',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealSlot() {
    return const Center(
      child: Icon(
        Icons.add,
        color: AppTheme.textTertiary,
        size: 20,
      ),
    );
  }

  void _showMealOptions(int dayIndex, int slotIndex, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealOptionsSheet(dayIndex, slotIndex, date),
    );
  }

  Widget _buildMealOptionsSheet(int dayIndex, int slotIndex, DateTime date) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn món ăn - ${_weekDays[dayIndex]} ${_mealSlots[slotIndex]}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // Mock data
              itemBuilder: (context, index) => _buildRecipeCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreenLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.restaurant,
            color: AppTheme.primaryGreen,
          ),
        ),
        title: Text('Món ăn ${index + 1}'),
        subtitle: const Text('30 phút • Dễ • 45,000đ'),
        trailing: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
        onTap: () {
          Navigator.pop(context);
          // Add meal to plan
        },
      ),
    );
  }

  void _generateMealPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo kế hoạch tự động'),
        content: const Text('Bạn có muốn tạo kế hoạch ăn tự động cho tuần này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate meal plan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tạo kế hoạch ăn...')),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _createShoppingList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo danh sách mua sắm'),
        content: const Text('Tạo danh sách mua sắm từ kế hoạch ăn tuần này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create shopping list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo danh sách mua sắm!')),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}