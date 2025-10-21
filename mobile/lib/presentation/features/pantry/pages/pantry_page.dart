import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/presentation/features/pantry/widgets/pantry_item_card.dart';
import 'package:bepviet_mobile/presentation/features/pantry/widgets/add_pantry_item_dialog.dart';
import 'package:bepviet_mobile/presentation/features/pantry/widgets/pantry_category_filter.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _selectedSortBy = 'expiry_date';

  final List<Map<String, dynamic>> _pantryItems = [
    {
      'id': 1,
      'name': 'Thịt bò',
      'category': 'meat',
      'quantity': 500,
      'unit': 'gram',
      'expiryDate': DateTime.now().add(const Duration(days: 2)),
      'purchaseDate': DateTime.now().subtract(const Duration(days: 3)),
      'location': 'Ngăn đông',
      'image': null,
      'status': 'expiring_soon',
    },
    {
      'id': 2,
      'name': 'Cà chua',
      'category': 'vegetables',
      'quantity': 8,
      'unit': 'quả',
      'expiryDate': DateTime.now().add(const Duration(days: 5)),
      'purchaseDate': DateTime.now().subtract(const Duration(days: 1)),
      'location': 'Tủ lạnh',
      'image': null,
      'status': 'fresh',
    },
    {
      'id': 3,
      'name': 'Gạo ST25',
      'category': 'grains',
      'quantity': 2,
      'unit': 'kg',
      'expiryDate': DateTime.now().add(const Duration(days: 90)),
      'purchaseDate': DateTime.now().subtract(const Duration(days: 10)),
      'location': 'Tủ khô',
      'image': null,
      'status': 'fresh',
    },
    {
      'id': 4,
      'name': 'Sữa tươi',
      'category': 'dairy',
      'quantity': 1,
      'unit': 'hộp',
      'expiryDate': DateTime.now().subtract(const Duration(days: 1)),
      'purchaseDate': DateTime.now().subtract(const Duration(days: 7)),
      'location': 'Tủ lạnh',
      'image': null,
      'status': 'expired',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tủ lạnh của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Sắp hết hạn'),
            Tab(text: 'Đã hết hạn'),
          ],
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
        ),
      ),
      body: Column(
        children: [
          // Quick stats
          _buildQuickStats(),
          
          // Category filter
          PantryCategoryFilter(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllItemsTab(),
                _buildExpiringItemsTab(),
                _buildExpiredItemsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalItems = _pantryItems.length;
    final expiringItems = _pantryItems.where((item) => 
        item['status'] == 'expiring_soon').length;
    final expiredItems = _pantryItems.where((item) => 
        item['status'] == 'expired').length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tổng số',
              totalItems.toString(),
              Icons.inventory,
              AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Sắp hết hạn',
              expiringItems.toString(),
              Icons.warning,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Đã hết hạn',
              expiredItems.toString(),
              Icons.error,
              AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsTab() {
    final filteredItems = _getFilteredItems();
    
    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return PantryItemCard(
          item: filteredItems[index],
          onEdit: _editItem,
          onDelete: _deleteItem,
          onUse: _useItem,
        );
      },
    );
  }

  Widget _buildExpiringItemsTab() {
    final expiringItems = _pantryItems.where((item) =>
        item['status'] == 'expiring_soon').toList();

    if (expiringItems.isEmpty) {
      return _buildEmptyExpiringState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expiringItems.length,
      itemBuilder: (context, index) {
        return PantryItemCard(
          item: expiringItems[index],
          onEdit: _editItem,
          onDelete: _deleteItem,
          onUse: _useItem,
        );
      },
    );
  }

  Widget _buildExpiredItemsTab() {
    final expiredItems = _pantryItems.where((item) =>
        item['status'] == 'expired').toList();

    if (expiredItems.isEmpty) {
      return _buildEmptyExpiredState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expiredItems.length,
      itemBuilder: (context, index) {
        return PantryItemCard(
          item: expiredItems[index],
          onEdit: _editItem,
          onDelete: _deleteItem,
          onUse: _useItem,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tủ lạnh đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm nguyên liệu để bắt đầu quản lý',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm nguyên liệu'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpiringState() {
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
            'Tuyệt vời!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có nguyên liệu nào sắp hết hạn',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_very_satisfied,
            size: 64,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Hoàn hảo!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có nguyên liệu nào hết hạn',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    List<Map<String, dynamic>> filtered = _pantryItems;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) =>
          item['category'] == _selectedCategory).toList();
    }

    // Sort
    filtered.sort((a, b) {
      switch (_selectedSortBy) {
        case 'expiry_date':
          return (a['expiryDate'] as DateTime)
              .compareTo(b['expiryDate'] as DateTime);
        case 'name':
          return (a['name'] as String)
              .compareTo(b['name'] as String);
        case 'purchase_date':
          return (b['purchaseDate'] as DateTime)
              .compareTo(a['purchaseDate'] as DateTime);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Ngày hết hạn', 'expiry_date'),
              _buildSortOption('Tên nguyên liệu', 'name'),
              _buildSortOption('Ngày mua', 'purchase_date'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: _selectedSortBy == value
          ? const Icon(Icons.check, color: AppTheme.primaryGreen)
          : null,
      onTap: () {
        setState(() {
          _selectedSortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showSearchDialog() {
    // TODO: Implement search dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng tìm kiếm đang phát triển')),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPantryItemDialog(
        onAdded: () {
          setState(() {
            // Refresh items
          });
        },
      ),
    );
  }

  void _editItem(Map<String, dynamic> item) {
    // TODO: Implement edit item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa ${item['name']}')),
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nguyên liệu'),
        content: Text('Bạn có chắc muốn xóa ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pantryItems.removeWhere((i) => i['id'] == item['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${item['name']}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _useItem(Map<String, dynamic> item) {
    // TODO: Implement use item (reduce quantity)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sử dụng ${item['name']}')),
    );
  }
}
