import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/presentation/features/pantry/cubit/pantry_cubit.dart';
import 'package:bepviet_mobile/presentation/features/shopping/utils/ingredient_section_helper.dart';
import 'package:bepviet_mobile/presentation/features/pantry/widgets/pantry_widgets.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Multi-select state
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPantryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPantryData() {
    context.read<PantryCubit>().loadPantryItems();
    context.read<PantryCubit>().loadPantryStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text(
                'Đã chọn ${_selectedItemIds.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text(
                'Tủ lạnh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: _isSelectionMode
            ? [
                if (_selectedItemIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedItems,
                    tooltip: 'Xóa đã chọn',
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () {
                    context.push('/pantry/suggestions');
                  },
                  tooltip: 'Nấu gì từ tủ lạnh?',
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddItemDialog(),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(),
                ),
              ],
        bottom: _isSelectionMode 
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Cần chú ý'),
                  Tab(text: 'Thống kê'),
                ],
              ),
      ),
      body: BlocConsumer<PantryCubit, PantryState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            context.read<PantryCubit>().clearError();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllItemsTab(state),
              _buildAttentionNeededTab(state),
              _buildStatsTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllItemsTab(PantryState state) {
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceColor,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nguyên liệu...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    // Real-time search implementation
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sort),
                  color: AppTheme.primaryGreen,
                  onPressed: () => _showSortDialog(),
                ),
              ),
            ],
          ),
        ),

        // Items list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadPantryData(),
            child: _buildItemsList(state),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(PantryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter items based on search query
    List<PantryItemModel> filteredItems = state.pantryItems;
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filteredItems = state.pantryItems.where((item) =>
        item.ingredientName.toLowerCase().contains(lowerQuery) ||
        (item.notes?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();
    }

    if (filteredItems.isEmpty) {
      return PantryEmptyState(onAddItem: _showAddItemDialog);
    }

    // Group items theo store section
    final Map<String, List<PantryItemModel>> itemsBySection = {};
    for (final item in filteredItems) {
      // Phân loại bằng rule-based
      final section = IngredientSectionHelper.classifyIngredient(item.ingredientName);
      
      // Background: AI classify và cache
      _classifyWithAIInBackground(item.ingredientName);
      
      if (!itemsBySection.containsKey(section)) {
        itemsBySection[section] = [];
      }
      itemsBySection[section]!.add(item);
    }

    // Sort sections theo thứ tự logic
    final sortedSections = itemsBySection.keys.toList()
      ..sort((a, b) => 
        IngredientSectionHelper.getSectionOrder(a).compareTo(
          IngredientSectionHelper.getSectionOrder(b)
        )
      );

    // Build list với sections
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSections.fold<int>(
        0, 
        (sum, section) => sum + 1 + itemsBySection[section]!.length
      ),
      itemBuilder: (context, index) {
        int currentIndex = 0;
        for (final section in sortedSections) {
          // Section header
          if (index == currentIndex) {
            return PantrySectionHeader(
              sectionName: section,
              itemCount: itemsBySection[section]!.length,
            );
          }
          currentIndex++;

          // Items in section
          final sectionItems = itemsBySection[section]!;
          if (index < currentIndex + sectionItems.length) {
            final itemIndex = index - currentIndex;
            final item = sectionItems[itemIndex];
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PantryItemCard(
                item: item,
                isSelectionMode: _isSelectionMode,
                isSelected: _selectedItemIds.contains(item.id),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleItemSelection(item.id);
                  } else {
                    _showItemDetailsDialog(item);
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _enterSelectionMode(item.id);
                  }
                },
                onConsume: () => _showConsumeDialog(item),
                onEdit: () => _showEditItemDialog(item),
                onDelete: () => _showDeleteItemDialog(item),
                onSelectionChanged: (value) => _toggleItemSelection(item.id),
              ),
            );
          }
          currentIndex += sectionItems.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Classify ingredient bằng AI trong background và cache kết quả
  void _classifyWithAIInBackground(String ingredientName) {
    IngredientSectionHelper.classifyWithCache(ingredientName).then((section) {
      // Kết quả đã được cache, lần sau sẽ dùng ngay
    }).catchError((error) {
      // Silent fail
    });
  }

  Widget _buildAttentionNeededTab(PantryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final expiredItems = context.read<PantryCubit>().expiredItems;
    final expiringSoonItems = context.read<PantryCubit>().expiringSoonItems;
    final lowStockItems = context.read<PantryCubit>().lowStockItems;

    if (expiredItems.isEmpty && expiringSoonItems.isEmpty && lowStockItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tất cả nguyên liệu đều ổn!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Không có nguyên liệu nào cần chú ý',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (expiredItems.isNotEmpty) ...[
          _buildAttentionSection(
            'Đã hết hạn (${expiredItems.length})',
            expiredItems,
            AppTheme.errorColor,
            Icons.warning,
          ),
          const SizedBox(height: 16),
        ],
        if (expiringSoonItems.isNotEmpty) ...[
          _buildAttentionSection(
            'Sắp hết hạn (${expiringSoonItems.length})',
            expiringSoonItems,
            AppTheme.warningColor,
            Icons.schedule,
          ),
          const SizedBox(height: 16),
        ],
        if (lowStockItems.isNotEmpty) ...[
          _buildAttentionSection(
            'Sắp hết (${lowStockItems.length})',
            lowStockItems,
            AppTheme.warningColor,
            Icons.inventory,
          ),
        ],
      ],
    );
  }

  Widget _buildAttentionSection(
    String title,
    List<PantryItemModel> items,
    Color color,
    IconData icon,
  ) {
    // Group items theo section
    final Map<String, List<PantryItemModel>> itemsBySection = {};
    for (final item in items) {
      final section = IngredientSectionHelper.classifyIngredient(item.ingredientName);
      _classifyWithAIInBackground(item.ingredientName);
      
      if (!itemsBySection.containsKey(section)) {
        itemsBySection[section] = [];
      }
      itemsBySection[section]!.add(item);
    }

    // Sort sections
    final sortedSections = itemsBySection.keys.toList()
      ..sort((a, b) => 
        IngredientSectionHelper.getSectionOrder(a).compareTo(
          IngredientSectionHelper.getSectionOrder(b)
        )
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attention category header
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Items grouped by section
        ...sortedSections.expand((section) => [
          PantrySectionHeader(
            sectionName: section,
            itemCount: itemsBySection[section]!.length,
          ),
          ...itemsBySection[section]!.map((item) => 
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PantryItemCard(
                item: item,
                isSelectionMode: _isSelectionMode,
                isSelected: _selectedItemIds.contains(item.id),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleItemSelection(item.id);
                  } else {
                    _showItemDetailsDialog(item);
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _enterSelectionMode(item.id);
                  }
                },
                onConsume: () => _showConsumeDialog(item),
                onEdit: () => _showEditItemDialog(item),
                onDelete: () => _showDeleteItemDialog(item),
                onSelectionChanged: (value) => _toggleItemSelection(item.id),
              ),
            )
          ),
        ]),
      ],
    );
  }

  // Helper method for location icon
  IconData _getLocationIcon(String? location) {
    return PantryColors.getLocationIcon(location);
  }

  Widget _buildStatsTab(PantryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = state.stats;
    if (stats == null) {
      return const Center(
        child: Text('Chưa có dữ liệu thống kê'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tổng nguyên liệu',
                '${stats.totalItems}',
                Icons.inventory_2,
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Cần chú ý',
                '${stats.expiredItems + stats.expiringItems + stats.lowStockItems}',
                Icons.warning,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Expiry stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê hạn sử dụng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressStat(
                  'Đã hết hạn',
                  stats.expiredItems,
                  stats.totalItems,
                  AppTheme.errorColor,
                ),
                const SizedBox(height: 12),
                _buildProgressStat(
                  'Sắp hết hạn',
                  stats.expiringItems,
                  stats.totalItems,
                  AppTheme.warningColor,
                ),
                const SizedBox(height: 12),
                _buildProgressStat(
                  'Sắp hết',
                  stats.lowStockItems,
                  stats.totalItems,
                  AppTheme.warningColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper methods (location icon already moved to PantryColors)
  IconData _getLocationIcon_OLD(String location) {
    switch (location) {
      case 'fridge':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.inventory_2;
      case 'cabinet':
        return Icons.kitchen;
      default:
        return Icons.inventory;
    }
  }

  // Selection mode methods
  void _enterSelectionMode(String itemId) {
    setState(() {
      _isSelectionMode = true;
      _selectedItemIds.add(itemId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
        // Exit selection mode if no items selected
        if (_selectedItemIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _deleteSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;

    final itemCount = _selectedItemIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa $itemCount nguyên liệu đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final cubit = context.read<PantryCubit>();
      
      // Delete all selected items without reloading after each one
      for (final itemId in _selectedItemIds) {
        await cubit.deletePantryItem(itemId, reloadAfter: false);
      }
      
      // Exit selection mode
      _exitSelectionMode();
      
      // Reload data only once at the end
      _loadPantryData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa $itemCount nguyên liệu'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Dialog methods
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddItemDialog(),
    );
  }

  void _showEditItemDialog(PantryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(item: item),
    );
  }

  void _showItemDetailsDialog(PantryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailsDialog(item: item),
    );
  }

  void _showConsumeDialog(PantryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => _ConsumeItemDialog(item: item),
    );
  }

  void _showDeleteItemDialog(PantryItemModel item) {
    // Extract real name from notes if it's a manual entry
    String displayName = item.ingredientName;
    if (item.ingredientName == 'Khác' && item.notes != null) {
      final match = RegExp(r'^Tên:\s*(.+?)(?:\.\s*(.*))?$').firstMatch(item.notes!);
      if (match != null) {
        displayName = match.group(1)!.trim();
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nguyên liệu'),
        content: Text(
          'Bạn có chắc muốn xóa "$displayName" khỏi tủ lạnh?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<PantryCubit>().deletePantryItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Đã xóa "$displayName"'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const _FilterDialog(),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => const _SortDialog(),
    );
  }
}

// Dialog widgets would be implemented here
class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedUnit = 'g';
  PantryLocation _selectedLocation = PantryLocation.fridge;
  DateTime? _expiryDate;
  DateTime? _purchaseDate;

  // Autocomplete variables
  List<Map<String, dynamic>> _ingredientSuggestions = [];
  bool _showSuggestions = false;
  String? _selectedIngredientId;

  final List<String> _units = ['g', 'kg', 'ml', 'l', 'cái', 'gói', 'lon', 'thìa', 'chén'];

  @override
  void initState() {
    super.initState();
    // Listen to search text changes for autocomplete
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (text.isNotEmpty) {
        _searchIngredients(text);
      } else {
        setState(() {
          _showSuggestions = false;
          _selectedIngredientId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _searchIngredients(String query) async {
    if (query.length < 2) {
      setState(() {
        _ingredientSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    
    try {
      final apiService = context.read<ApiService>();
      final results = await apiService.searchIngredients(query);
      setState(() {
        _ingredientSuggestions = results.take(5).toList(); // Limit to 5 suggestions
        _showSuggestions = results.isNotEmpty;
      });
    } catch (e) {
      print('Error searching ingredients: $e');
      setState(() {
        _ingredientSuggestions = [];
        _showSuggestions = false;
      });
    }
  }
  
  void _selectIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      _searchController.text = ingredient['name'];
      _selectedIngredientId = ingredient['id'].toString();
      _showSuggestions = false;
      _ingredientSuggestions = [];
    });
  }

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      final ingredientName = _searchController.text.trim();
      
      try {
        String ingredientId;
        String actualIngredientName = ingredientName;
        String? additionalNotes;
        
        // Common ingredient IDs as fallback (in case search fails)
        const Map<String, String> commonIngredients = {
          'cà chua': 'dc03d9f1c0917264ffa0665ba9ebc5d604fa4425',
          'thịt gà': 'a1234567890abcdef1234567890abcdef1234567', // Will be replaced with actual search
          'khác': '21edf513abbc3a5a90be6ae55935d8794a13c261',
        };
        
        const String defaultIngredientId = '21edf513abbc3a5a90be6ae55935d8794a13c261'; // "Khác"
        
        // Check if user selected from autocomplete suggestions
        if (_selectedIngredientId != null && _selectedIngredientId!.isNotEmpty) {
          ingredientId = _selectedIngredientId!;
          print('Using selected ingredient: $actualIngredientName with ID: $ingredientId');
        } else {
          // Try to search for existing ingredient
          try {
            final apiService = context.read<ApiService>();
            final searchResults = await apiService.searchIngredients(ingredientName);
            
            if (searchResults.isNotEmpty) {
              // Try to find exact match first
              Map<String, dynamic>? exactMatch;
              try {
                exactMatch = searchResults.firstWhere(
                  (ingredient) => ingredient['name'].toString().toLowerCase() == ingredientName.toLowerCase(),
                );
              } catch (e) {
                // No exact match found, use first result
                exactMatch = searchResults.first;
              }
              
              ingredientId = exactMatch['id'].toString();
              actualIngredientName = exactMatch['name'].toString();
              print('Found existing ingredient: $actualIngredientName with ID: $ingredientId');
            } else {
              // No ingredients found, try common ingredients map first
              final lowerName = ingredientName.toLowerCase();
              if (commonIngredients.containsKey(lowerName)) {
                ingredientId = commonIngredients[lowerName]!;
                print('Using common ingredient ID for: $ingredientName');
              } else {
                // Use default "Khác" ID and save real name in notes
                ingredientId = defaultIngredientId;
                additionalNotes = 'Tên: $ingredientName';
                print('No ingredient found, using default ID for: $ingredientName');
              }
            }
          } catch (searchError) {
            // Search API failed, try common ingredients map first
            print('Search failed: $searchError, trying common ingredients');
            final lowerName = ingredientName.toLowerCase();
            if (commonIngredients.containsKey(lowerName)) {
              ingredientId = commonIngredients[lowerName]!;
              print('Using common ingredient ID for: $ingredientName');
            } else {
              // Use default "Khác" ID and save real name in notes
              ingredientId = defaultIngredientId;
              additionalNotes = 'Tên: $ingredientName';
              print('Using default ID after search failed for: $ingredientName');
            }
          }
        }
        
        // Combine user notes with ingredient name if needed
        String finalNotes = _notesController.text.trim();
        if (additionalNotes != null) {
          finalNotes = finalNotes.isNotEmpty 
              ? '$additionalNotes. $finalNotes' 
              : additionalNotes;
        }
        
        final dto = AddPantryItemDto(
          ingredientId: ingredientId,
          quantity: double.parse(_quantityController.text),
          unit: _selectedUnit,
          expiryDate: _expiryDate,
          purchaseDate: _purchaseDate ?? DateTime.now(),
          location: _selectedLocation.value,
          notes: finalNotes.isNotEmpty ? finalNotes : null,
        );

        print('DTO to send: ${dto.toJson()}');

        await context.read<PantryCubit>().addPantryItem(dto);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm "$actualIngredientName" vào tủ lạnh thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error adding pantry item: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm nguyên liệu: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nguyên liệu'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ingredient name input with autocomplete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Tên nguyên liệu',
                        border: OutlineInputBorder(),
                        hintText: 'Nhập tên nguyên liệu...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên nguyên liệu';
                        }
                        return null;
                      },
                    ),
                    // Autocomplete suggestions
                    if (_showSuggestions && _ingredientSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ingredientSuggestions.length,
                          itemBuilder: (context, index) {
                            final ingredient = _ingredientSuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(ingredient['name'] ?? ''),
                              subtitle: ingredient['category_name'] != null 
                                  ? Text(ingredient['category_name'], style: const TextStyle(fontSize: 12))
                                  : null,
                              onTap: () => _selectIngredient(ingredient),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Quantity and unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Số lượng phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                        isExpanded: true,
                        items: _units.map((unit) {
                          return DropdownMenuItem(
                            value: unit, 
                            child: Text(
                              unit,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedUnit = value!);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Purchase date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _purchaseDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày mua',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _purchaseDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_purchaseDate!)
                          : 'Chọn ngày mua',
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Expiry date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) {
                      setState(() => _expiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hạn sử dụng (tuỳ chọn)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expiryDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                          : 'Chọn hạn sử dụng',
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  final PantryItemModel item;
  
  const _EditItemDialog({required this.item});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedUnit = 'g';
  PantryLocation _selectedLocation = PantryLocation.fridge;
  DateTime? _expiryDate;
  DateTime? _purchaseDate;

  final List<String> _units = ['g', 'kg', 'ml', 'l', 'cái', 'gói', 'lon', 'thìa', 'chén'];

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.item.currentQuantity.toString();
    _selectedUnit = widget.item.unit;
    _selectedLocation = PantryLocation.values.firstWhere(
      (loc) => loc.value == widget.item.location,
      orElse: () => PantryLocation.fridge,
    );
    
    // Auto-calculate expiry date if not set: purchase date + 7 days
    _purchaseDate = widget.item.purchaseDate;
    if (widget.item.expiryDate != null) {
      _expiryDate = widget.item.expiryDate;
    } else if (_purchaseDate != null) {
      // Auto-calculate: purchase date + 7 days
      _expiryDate = _purchaseDate!.add(const Duration(days: 7));
    }
    
    _notesController.text = widget.item.notes ?? '';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      final dto = UpdatePantryItemDto(
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        purchaseDate: _purchaseDate,
        location: _selectedLocation.value,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      try {
        await context.read<PantryCubit>().updatePantryItem(widget.item.id, dto);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật nguyên liệu thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String get _displayName {
    if (widget.item.ingredientName == 'Khác' && widget.item.notes != null) {
      final match = RegExp(r'^Tên:\s*(.+?)(?:\.\s*(.*))?$').firstMatch(widget.item.notes!);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }
    return widget.item.ingredientName;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa: $_displayName'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity and unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Số lượng phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        ),
                        isExpanded: true,
                        items: _units.map((unit) {
                          return DropdownMenuItem(
                            value: unit, 
                            child: Text(
                              unit,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedUnit = value!);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Purchase date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _purchaseDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày mua',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _purchaseDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_purchaseDate!)
                          : 'Chọn ngày mua',
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Expiry date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) {
                      setState(() => _expiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hạn sử dụng (tuỳ chọn)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expiryDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                          : 'Chọn hạn sử dụng',
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _updateItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cập nhật'),
        ),
      ],
    );
  }
}

class _ItemDetailsDialog extends StatelessWidget {
  final PantryItemModel item;
  
  const _ItemDetailsDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    // Extract real name from notes if it's a manual entry
    String displayName = item.ingredientName;
    String? displayNotes = item.notes;
    
    if (item.ingredientName == 'Khác' && item.notes != null) {
      final match = RegExp(r'^Tên:\s*(.+?)(?:\.\s*(.*))?$').firstMatch(item.notes!);
      if (match != null) {
        displayName = match.group(1)!.trim();
        displayNotes = match.group(2)?.trim();
      }
    }
    
    return AlertDialog(
      title: Text(displayName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số lượng: ${item.currentQuantity} ${item.unit}'),
          if (item.expiryDate != null)
            Text('Hạn sử dụng: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}'),
          if (displayNotes != null && displayNotes.isNotEmpty)
            Text('Ghi chú: $displayNotes'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class _ConsumeItemDialog extends StatefulWidget {
  final PantryItemModel item;
  
  const _ConsumeItemDialog({required this.item});

  @override
  State<_ConsumeItemDialog> createState() => _ConsumeItemDialogState();
}

class _ConsumeItemDialogState extends State<_ConsumeItemDialog> {
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  String get _displayName {
    if (widget.item.ingredientName == 'Khác' && widget.item.notes != null) {
      final match = RegExp(r'^Tên:\s*(.+?)(?:\.\s*(.*))?$').firstMatch(widget.item.notes!);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }
    return widget.item.ingredientName;
  }

  Future<void> _consumeItem() async {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);
      
      try {
        await context.read<PantryCubit>().consumePantryItem(widget.item.id, quantity);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã sử dụng $quantity ${widget.item.unit} $_displayName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sử dụng: $_displayName'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hiện có: ${widget.item.currentQuantity} ${widget.item.unit}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Số lượng sử dụng (${widget.item.unit})',
                border: const OutlineInputBorder(),
                suffixText: widget.item.unit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Số lượng phải lớn hơn 0';
                }
                if (quantity > widget.item.currentQuantity) {
                  return 'Không đủ số lượng (chỉ có ${widget.item.currentQuantity} ${widget.item.unit})';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 8),
            
            // Quick selection buttons
            Wrap(
              spacing: 8,
              children: [
                _buildQuickButton('25%', widget.item.currentQuantity * 0.25),
                _buildQuickButton('50%', widget.item.currentQuantity * 0.5),
                _buildQuickButton('75%', widget.item.currentQuantity * 0.75),
                _buildQuickButton('Tất cả', widget.item.currentQuantity),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _consumeItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sử dụng'),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, double value) {
    return OutlinedButton(
      onPressed: () {
        _quantityController.text = value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryGreen,
        side: const BorderSide(color: AppTheme.primaryGreen),
      ),
      child: Text(label),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog();

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Bộ lọc'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show expired items
              CheckboxListTile(
                title: const Text('Hiển thị món hết hạn'),
                value: state.showExpired,
                onChanged: (value) {
                  context.read<PantryCubit>().toggleShowExpired(value ?? false);
                },
                activeColor: AppTheme.primaryGreen,
              ),
              
              // Show low stock items
              CheckboxListTile(
                title: const Text('Hiển thị món sắp hết'),
                value: state.showLowStock,
                onChanged: (value) {
                  context.read<PantryCubit>().toggleShowLowStock(value ?? false);
                },
                activeColor: AppTheme.primaryGreen,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã áp dụng bộ lọc'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }
}

class _SortDialog extends StatefulWidget {
  const _SortDialog();

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  final List<Map<String, String>> _sortOptions = [
    {'value': 'expiry_date', 'label': 'Ngày hết hạn'},
    {'value': 'name', 'label': 'Tên nguyên liệu'},
    {'value': 'quantity', 'label': 'Số lượng'},
    {'value': 'created_at', 'label': 'Ngày thêm'},
    {'value': 'location', 'label': 'Vị trí'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Sắp xếp theo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _sortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option['label']!),
                value: option['value']!,
                groupValue: state.sortBy,
                onChanged: (value) {
                  if (value != null) {
                    context.read<PantryCubit>().setSortBy(value);
                  }
                },
                activeColor: AppTheme.primaryGreen,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
