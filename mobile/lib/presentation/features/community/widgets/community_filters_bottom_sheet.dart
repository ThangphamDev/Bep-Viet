import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class CommunityFiltersBottomSheet extends StatefulWidget {
  final Function(String?, String?, int?) onFiltersChanged;
  final VoidCallback onClearFilters;
  final String? initialRegion;
  final String? initialDifficulty;
  final int? initialMaxTime;

  const CommunityFiltersBottomSheet({
    super.key,
    required this.onFiltersChanged,
    required this.onClearFilters,
    this.initialRegion,
    this.initialDifficulty,
    this.initialMaxTime,
  });

  @override
  State<CommunityFiltersBottomSheet> createState() => _CommunityFiltersBottomSheetState();
}

class _CommunityFiltersBottomSheetState extends State<CommunityFiltersBottomSheet> {
  String? _selectedRegion;
  String? _selectedDifficulty;
  int? _maxTime;

  final List<Map<String, dynamic>> _regions = [
    {'code': 'BAC', 'name': 'Miền Bắc'},
    {'code': 'TRUNG', 'name': 'Miền Trung'},
    {'code': 'NAM', 'name': 'Miền Nam'},
  ];

  final List<Map<String, dynamic>> _difficulties = [
    {'code': 'DE', 'name': 'Dễ'},
    {'code': 'TRUNG_BINH', 'name': 'Trung bình'},
    {'code': 'KHO', 'name': 'Khó'},
  ];

  final List<Map<String, dynamic>> _timeOptions = [
    {'value': 15, 'label': '≤ 15 phút'},
    {'value': 30, 'label': '≤ 30 phút'},
    {'value': 60, 'label': '≤ 1 giờ'},
    {'value': 120, 'label': '≤ 2 giờ'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialRegion;
    _selectedDifficulty = widget.initialDifficulty;
    _maxTime = widget.initialMaxTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_hasActiveFilters())
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_getActiveFilterCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Region filter
                  _buildFilterSection(
                    title: 'Vùng miền',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _regions.map((region) {
                        final isSelected = _selectedRegion == region['code'];
                        return _buildFilterChip(
                          label: region['name'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedRegion = isSelected ? null : region['code'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Difficulty filter
                  _buildFilterSection(
                    title: 'Độ khó',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _difficulties.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty['code'];
                        return _buildFilterChip(
                          label: difficulty['name'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedDifficulty = isSelected ? null : difficulty['code'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time filter
                  _buildFilterSection(
                    title: 'Thời gian nấu',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _timeOptions.map((time) {
                        final isSelected = _maxTime == time['value'];
                        return _buildFilterChip(
                          label: time['label'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _maxTime = isSelected ? null : time['value'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Clear filters button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasActiveFilters() ? () {
                      setState(() {
                        _selectedRegion = null;
                        _selectedDifficulty = null;
                        _maxTime = null;
                      });
                      widget.onClearFilters();
                    } : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Xóa bộ lọc'),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Apply filters button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersChanged(_selectedRegion, _selectedDifficulty, _maxTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedRegion != null || _selectedDifficulty != null || _maxTime != null;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedRegion != null) count++;
    if (_selectedDifficulty != null) count++;
    if (_maxTime != null) count++;
    return count;
  }
}
