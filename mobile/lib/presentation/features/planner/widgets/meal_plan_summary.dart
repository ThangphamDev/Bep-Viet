import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class MealPlanSummary extends StatelessWidget {
  final DateTime weekStart;

  const MealPlanSummary({
    super.key,
    required this.weekStart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cost Summary Card
          _buildCostSummaryCard(),
          const SizedBox(height: 16),
          
          // Nutrition Summary Card
          _buildNutritionSummaryCard(),
          const SizedBox(height: 16),
          
          // Shopping List Preview Card
          _buildShoppingPreviewCard(),
          const SizedBox(height: 16),
          
          // Quick Actions
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildCostSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Chi phí tuần này',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCostItem('Tổng chi phí', '945,000đ', AppTheme.primaryGreen),
                _buildCostItem('Trung bình/ngày', '135,000đ', AppTheme.textSecondary),
                _buildCostItem('Tiết kiệm', '55,000đ', AppTheme.successColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_dining, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Cân bằng dinh dưỡng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutritionIndicator('Protein', 0.7, AppTheme.primaryGreen),
            const SizedBox(height: 8),
            _buildNutritionIndicator('Rau củ', 0.6, AppTheme.successColor),
            const SizedBox(height: 8),
            _buildNutritionIndicator('Tinh bột', 0.8, AppTheme.warningColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionIndicator(String label, double progress, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Cần mua sắm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to full shopping list
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildShoppingItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildShoppingItems() {
    final items = [
      {'name': 'Thịt bò', 'quantity': '0.5 kg', 'section': 'Quầy thịt'},
      {'name': 'Rau cải', 'quantity': '1 bó', 'section': 'Quầy rau'},
      {'name': 'Gạo', 'quantity': '2 kg', 'section': 'Khô'},
    ];

    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item['name']!),
          ),
          Text(
            item['quantity']!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item['section']!,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.refresh,
                label: 'Tạo lại kế hoạch',
                onTap: () {
                  // Regenerate meal plan
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                label: 'Chia sẻ',
                onTap: () {
                  // Share meal plan
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.download,
                label: 'Xuất PDF',
                onTap: () {
                  // Export to PDF
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.kitchen,
                label: 'Xem tủ lạnh',
                onTap: () {
                  // Navigate to pantry
                },
              ),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreenLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}