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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc gợi ý',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Region Selection
          _buildSectionTitle('Vùng miền'),
          const SizedBox(height: 8),
          _buildRegionSelector(),
          const SizedBox(height: 16),

          // Season Selection
          _buildSectionTitle('Mùa'),
          const SizedBox(height: 8),
          _buildSeasonSelector(),
          const SizedBox(height: 16),

          // Servings
          _buildSectionTitle('Số người ăn'),
          const SizedBox(height: 8),
          _buildServingsSlider(),
          const SizedBox(height: 16),

          // Budget
          _buildSectionTitle('Ngân sách'),
          const SizedBox(height: 8),
          _buildBudgetSlider(),
          const SizedBox(height: 16),

          // Spice Preference
          _buildSectionTitle('Độ cay'),
          const SizedBox(height: 8),
          _buildSpicePreferenceSlider(),
          const SizedBox(height: 16),

          // Max Time
          _buildSectionTitle('Thời gian tối đa'),
          const SizedBox(height: 8),
          _buildMaxTimeSlider(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Row(
      children: AppConstants.regionNames.entries.map((entry) {
        final isSelected = selectedRegion == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onRegionChanged(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeasonSelector() {
    return Row(
      children: AppConstants.seasonNames.entries.map((entry) {
        final isSelected = selectedSeason == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSeasonChanged(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServingsSlider() {
    return Column(
      children: [
        Slider(
          value: servings.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) => onServingsChanged(value.round()),
        ),
        Text(
          '$servings người',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      children: [
        Slider(
          value: budget.toDouble(),
          min: 10000,
          max: 200000,
          divisions: 19,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) => onBudgetChanged(value.round()),
        ),
        Text(
          '${(budget / 1000).round()}k VNĐ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpicePreferenceSlider() {
    return Column(
      children: [
        Slider(
          value: spicePreference.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) => onSpicePreferenceChanged(value.round()),
        ),
        Text(
          AppConstants.spiceLevelNames[spicePreference] ?? 'Vừa cay',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMaxTimeSlider() {
    return Column(
      children: [
        Slider(
          value: maxTime.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          activeColor: AppTheme.primaryGreen,
          onChanged: (value) => onMaxTimeChanged(value.round()),
        ),
        Text(
          '$maxTime phút',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
