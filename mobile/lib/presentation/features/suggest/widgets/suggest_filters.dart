import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/constants/app_constants.dart';

/// 🎨 Redesigned Filters Widget
/// - Better visual hierarchy
/// - Budget increased to 1 million
/// - Modern card-based design
class SuggestFiltersWidget extends StatelessWidget {
  final String selectedRegion;
  final String selectedSeason;
  final int servings;
  final int budget;
  final int spicePreference;
  final int maxTime;
  final Function(String) onRegionChanged;
  final Function(String) onSeasonChanged;
  final Function(int) onServingsChanged;
  final Function(int) onBudgetChanged;
  final Function(int) onSpicePreferenceChanged;
  final Function(int) onMaxTimeChanged;

  const SuggestFiltersWidget({
    super.key,
    required this.selectedRegion,
    required this.selectedSeason,
    required this.servings,
    required this.budget,
    required this.spicePreference,
    required this.maxTime,
    required this.onRegionChanged,
    required this.onSeasonChanged,
    required this.onServingsChanged,
    required this.onBudgetChanged,
    required this.onSpicePreferenceChanged,
    required this.onMaxTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🎨 Modern Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withOpacity(0.1),
                AppTheme.primaryGreen.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bộ lọc nâng cao',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tùy chỉnh gợi ý theo sở thích của bạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🌸 Season Selection
        _buildSectionHeader('Mùa', Icons.wb_sunny_outlined),
        const SizedBox(height: 12),
        _buildSeasonSelector(),

        const SizedBox(height: 24),

        // 👥 Servings
        _buildEnhancedSlider(
          icon: Icons.people_outline,
          label: 'Số người ăn',
          value: servings.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          displayValue: '$servings người',
          hint: 'Điều chỉnh khẩu phần',
          onChanged: (val) => onServingsChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // 💰 Budget (INCREASED TO 1 MILLION)
        _buildEnhancedSlider(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Ngân sách',
          value: budget.toDouble(),
          min: 10000,
          max: 1000000, // ✨ NEW: 1 triệu đồng
          divisions: 99,
          displayValue: _formatBudget(budget),
          hint: _getBudgetHint(budget),
          onChanged: (val) => onBudgetChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // 🌶️ Spice Level
        _buildEnhancedSlider(
          icon: Icons.local_fire_department_outlined,
          label: 'Độ cay',
          value: spicePreference.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          displayValue:
              AppConstants.spiceLevelNames[spicePreference] ?? 'Vừa cay',
          hint: _getSpiceHint(spicePreference),
          onChanged: (val) => onSpicePreferenceChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // ⏱️ Max Time
        _buildEnhancedSlider(
          icon: Icons.schedule_outlined,
          label: 'Thời gian nấu',
          value: maxTime.toDouble(),
          min: 15,
          max: 180, // ✨ NEW: Increased to 180 minutes (3 hours)
          divisions: 11,
          displayValue: _formatTime(maxTime),
          hint: _getTimeHint(maxTime),
          onChanged: (val) => onMaxTimeChanged(val.round()),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  // 💰 Format budget display
  String _formatBudget(int budget) {
    if (budget >= 1000000) {
      return '${(budget / 1000000).toStringAsFixed(1)}tr đ';
    } else if (budget >= 1000) {
      return '${(budget / 1000).round()}k đ';
    }
    return '$budget đ';
  }

  // 💡 Get budget hint
  String _getBudgetHint(int budget) {
    if (budget < 50000) return 'Tiết kiệm';
    if (budget < 150000) return 'Vừa phải';
    if (budget < 300000) return 'Thoải mái';
    if (budget < 600000) return 'Sang trọng';
    return 'Cao cấp';
  }

  // ⏱️ Format time display
  String _formatTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '${hours}h';
      return '${hours}h ${mins}p';
    }
    return '$minutes phút';
  }

  // 💡 Get time hint
  String _getTimeHint(int minutes) {
    if (minutes <= 30) return 'Nhanh gọn';
    if (minutes <= 60) return 'Trung bình';
    if (minutes <= 120) return 'Chậm rãi';
    return 'Món phức tạp';
  }

  // 💡 Get spice hint
  String _getSpiceHint(int level) {
    if (level == 0) return 'Không cay';
    if (level <= 2) return 'Nhẹ nhàng';
    if (level == 3) return 'Vừa phải';
    if (level == 4) return 'Khá cay';
    return 'Rất cay';
  }

  // 📝 Section Header
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // 🌸 Season Selector (Grid Layout)
  Widget _buildSeasonSelector() {
    final seasons = [
      {'key': 'XUAN', 'label': 'Xuân', 'icon': '🌸'},
      {'key': 'HA', 'label': 'Hạ', 'icon': '☀️'},
      {'key': 'THU', 'label': 'Thu', 'icon': '🍂'},
      {'key': 'DONG', 'label': 'Đông', 'icon': '❄️'},
    ];

    return Row(
      children: seasons.map((season) {
        final isSelected = selectedSeason == season['key'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSeasonChanged(season['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      season['icon'] as String,
                      style: TextStyle(fontSize: isSelected ? 26 : 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      season['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ✨ Enhanced Slider with Hints
  Widget _buildEnhancedSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required String hint,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Header with icon, label, and value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.15),
                          AppTheme.primaryGreen.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 🎚️ Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryGreen,
              inactiveTrackColor: AppTheme.primaryGreen.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: AppTheme.primaryGreen.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 8,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
