import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class CommunityFiltersWidget extends StatefulWidget {
  final Function(String?, String?, int?) onFiltersChanged;
  final VoidCallback onClearFilters;

  const CommunityFiltersWidget({
    super.key,
    required this.onFiltersChanged,
    required this.onClearFilters,
  });

  @override
  State<CommunityFiltersWidget> createState() => _CommunityFiltersWidgetState();
}

class _CommunityFiltersWidgetState extends State<CommunityFiltersWidget> {
  String? _selectedRegion;
  String? _selectedDifficulty;
  int? _maxTime;
  bool _isExpanded = false;

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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Filter header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Filter content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Region filter
                  _buildFilterSection(
                    title: 'Vùng miền',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _regions.map((region) {
                        final isSelected = _selectedRegion == region['code'];
                        return _buildFilterChip(
                          label: region['name'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedRegion = isSelected ? null : region['code'];
                            });
                            _notifyFiltersChanged();
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
                      spacing: 8,
                      runSpacing: 8,
                      children: _difficulties.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty['code'];
                        return _buildFilterChip(
                          label: difficulty['name'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedDifficulty = isSelected ? null : difficulty['code'];
                            });
                            _notifyFiltersChanged();
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
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeOptions.map((time) {
                        final isSelected = _maxTime == time['value'];
                        return _buildFilterChip(
                          label: time['label'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _maxTime = isSelected ? null : time['value'];
                            });
                            _notifyFiltersChanged();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Clear filters button
                  if (_hasActiveFilters())
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedRegion = null;
                            _selectedDifficulty = null;
                            _maxTime = null;
                          });
                          widget.onClearFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: BorderSide(color: AppTheme.borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Xóa bộ lọc'),
                      ),
                    ),
                ],
              ),
            ),
          ],
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

  void _notifyFiltersChanged() {
    widget.onFiltersChanged(_selectedRegion, _selectedDifficulty, _maxTime);
  }
}