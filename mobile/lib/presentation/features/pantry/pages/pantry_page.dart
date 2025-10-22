import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/presentation/features/pantry/cubit/pantry_cubit.dart';

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
        title: const Text(
          'Quản lý tủ kho',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
        bottom: TabBar(
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

        // Location filter chips
        _buildLocationFilters(state),

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

  Widget _buildLocationFilters(PantryState state) {
    final locations = [
      {'value': 'all', 'label': 'Tất cả', 'icon': Icons.all_inclusive},
      {'value': 'fridge', 'label': 'Tủ lạnh', 'icon': Icons.kitchen},
      {'value': 'freezer', 'label': 'Tủ đông', 'icon': Icons.ac_unit},
      {'value': 'pantry', 'label': 'Tủ kho', 'icon': Icons.inventory_2},
      {'value': 'cabinet', 'label': 'Tủ bếp', 'icon': Icons.kitchen},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isSelected = state.selectedLocation == location['value'];
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    location['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(location['label'] as String),
                ],
              ),
              selectedColor: AppTheme.primaryGreen,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (selected) {
                context.read<PantryCubit>().setLocationFilter(
                  location['value'] as String,
                );
              },
            ),
          );
        },
      ),
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
      return _buildEmptyState();
    }

    // Group filtered items by location
    final Map<String, List<PantryItemModel>> groupedItems = {};
    for (final item in filteredItems) {
      final location = PantryLocation.values
          .firstWhere((loc) => loc.value == item.location, orElse: () => PantryLocation.pantry)
          .displayName;
      
      if (!groupedItems.containsKey(location)) {
        groupedItems[location] = [];
      }
      groupedItems[location]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, sectionIndex) {
        final location = groupedItems.keys.elementAt(sectionIndex);
        final items = groupedItems[location]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIndex > 0) const SizedBox(height: 16),
            Text(
              location,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => _buildPantryItemCard(item)),
          ],
        );
      },
    );
  }

  Widget _buildPantryItemCard(PantryItemModel item) {
    final daysUntilExpiry = item.daysUntilExpiry;
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;
    final isLowStock = item.isLowStock;

    Color statusColor = AppTheme.textSecondary;
    String statusText = 'Tốt';
    
    if (isExpired) {
      statusColor = AppTheme.errorColor;
      statusText = 'Hết hạn';
    } else if (isExpiringSoon) {
      statusColor = AppTheme.warningColor;
      statusText = 'Sắp hết hạn';
    } else if (isLowStock) {
      statusColor = AppTheme.warningColor;
      statusText = 'Sắp hết';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showItemDetailsDialog(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Item image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLocationIcon(item.location),
                  color: AppTheme.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ingredientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.currentQuantity} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpired 
                              ? 'Hết hạn ${(-daysUntilExpiry).abs()} ngày trước'
                              : daysUntilExpiry == 0
                                  ? 'Hết hạn hôm nay'
                                  : 'Còn $daysUntilExpiry ngày',
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status and actions
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showConsumeDialog(item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showEditItemDialog(item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),
        ...items.map((item) => _buildPantryItemCard(item)),
      ],
    );
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
        const SizedBox(height: 16),

        // Location breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phân bố theo vị trí',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...PantryLocation.values.map((location) {
                  final count = stats.itemsByLocation[location.value] ?? 0;
                  return _buildLocationStat(location, count, stats.totalItems);
                }),
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

  Widget _buildLocationStat(PantryLocation location, int count, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getLocationIcon(location.value),
            size: 20,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(location.displayName),
          ),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tủ kho của bạn đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm nguyên liệu đầu tiên của bạn',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm nguyên liệu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getLocationIcon(String location) {
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
        String actualIngredientName;
        
        // Check if user selected from autocomplete suggestions
        if (_selectedIngredientId != null) {
          ingredientId = _selectedIngredientId!;
          actualIngredientName = ingredientName;
          print('Using selected ingredient: $actualIngredientName with ID: $ingredientId');
        } else {
          // Search for existing ingredient
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
            // No ingredients found, show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không tìm thấy nguyên liệu "$ingredientName" trong hệ thống.\nVui lòng thử tìm kiếm với tên khác hoặc liên hệ quản trị viên để thêm nguyên liệu mới.'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            return;
          }
        }
        
        final dto = AddPantryItemDto(
          ingredientId: ingredientId,
          quantity: double.parse(_quantityController.text),
          unit: _selectedUnit,
          expiryDate: _expiryDate,
          purchaseDate: _purchaseDate ?? DateTime.now(),
          location: _selectedLocation.value,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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
                
                // Location selection
                DropdownButtonFormField<PantryLocation>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Vị trí lưu trữ',
                    border: OutlineInputBorder(),
                  ),
                  items: PantryLocation.values.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLocation = value!);
                  },
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
    _expiryDate = widget.item.expiryDate;
    _purchaseDate = widget.item.purchaseDate;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa: ${widget.item.ingredientName}'),
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
                
                // Location selection
                DropdownButtonFormField<PantryLocation>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Vị trí lưu trữ',
                    border: OutlineInputBorder(),
                  ),
                  items: PantryLocation.values.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLocation = value!);
                  },
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
    return AlertDialog(
      title: Text(item.ingredientName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số lượng: ${item.currentQuantity} ${item.unit}'),
          Text('Vị trí: ${PantryLocation.values.firstWhere((loc) => loc.value == item.location).displayName}'),
          if (item.expiryDate != null)
            Text('Hạn sử dụng: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}'),
          if (item.notes != null)
            Text('Ghi chú: ${item.notes}'),
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

  Future<void> _consumeItem() async {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);
      
      try {
        await context.read<PantryCubit>().consumePantryItem(widget.item.id, quantity);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã sử dụng $quantity ${widget.item.unit} ${widget.item.ingredientName}'),
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
      title: Text('Sử dụng: ${widget.item.ingredientName}'),
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
