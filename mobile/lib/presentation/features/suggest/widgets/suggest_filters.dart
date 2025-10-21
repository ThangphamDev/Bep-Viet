import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/constants/app_constants.dart';

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
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tùy chỉnh chi tiết',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Season Selection with Icons
        _buildSectionLabel('Mùa', Icons.wb_sunny_outlined),
        const SizedBox(height: 12),
        _buildSeasonSelector(),

        const SizedBox(height: 20),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 20),

        // Servings Slider
        _buildModernSlider(
          icon: Icons.people_outline,
          label: 'Số người ăn',
          value: servings.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          displayValue: '$servings người',
          onChanged: (val) => onServingsChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // Budget Slider
        _buildModernSlider(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Ngân sách',
          value: budget.toDouble(),
          min: 10000,
          max: 200000,
          divisions: 19,
          displayValue: '${(budget / 1000).round()}k VNĐ',
          onChanged: (val) => onBudgetChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // Spice Preference
        _buildModernSlider(
          icon: Icons.local_fire_department_outlined,
          label: 'Độ cay',
          value: spicePreference.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          displayValue:
              AppConstants.spiceLevelNames[spicePreference] ?? 'Vừa cay',
          onChanged: (val) => onSpicePreferenceChanged(val.round()),
        ),

        const SizedBox(height: 20),

        // Max Time
        _buildModernSlider(
          icon: Icons.schedule_outlined,
          label: 'Thời gian tối đa',
          value: maxTime.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          displayValue: '$maxTime phút',
          onChanged: (val) => onMaxTimeChanged(val.round()),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonSelector() {
    final seasons = [
      {
        'key': 'XUAN',
        'label': 'Mùa Xuân',
        'icon': '🌸',
        'color': const Color(0xFFFFB6C1),
      },
      {
        'key': 'HA',
        'label': 'Mùa Hạ',
        'icon': '☀️',
        'color': const Color(0xFFFFD700),
      },
      {
        'key': 'THU',
        'label': 'Mùa Thu',
        'icon': '🍂',
        'color': const Color(0xFFFF8C00),
      },
      {
        'key': 'DONG',
        'label': 'Mùa Đông',
        'icon': '❄️',
        'color': const Color(0xFF87CEEB),
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: seasons.map((season) {
        final isSelected = selectedSeason == season['key'];
        return GestureDetector(
          onTap: () => onSeasonChanged(season['key'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  season['icon'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  season['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryGreen,
              inactiveTrackColor: AppTheme.primaryGreen.withOpacity(0.2),
              thumbColor: AppTheme.primaryGreen,
              overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 6,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
