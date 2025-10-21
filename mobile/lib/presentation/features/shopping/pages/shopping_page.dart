import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import '../widgets/shopping_list_card.dart';
import '../widgets/create_shopping_list_dialog.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Danh sách mua sắm'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: _showCreateShoppingListDialog,
            tooltip: 'Tạo danh sách mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Danh sách của tôi', icon: Icon(Icons.list)),
            Tab(text: 'Chia sẻ', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyListsTab(),
          _buildSharedListsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateShoppingListDialog,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Tạo danh sách'),
      ),
    );
  }

  Widget _buildMyListsTab() {
    return RefreshIndicator(
      onRefresh: _refreshLists,
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions
          _buildQuickActionsCard(),
          const SizedBox(height: 16),
          
          // Active Lists
          _buildSectionHeader('Danh sách đang hoạt động', Icons.shopping_cart),
          const SizedBox(height: 8),
          ..._buildActiveShoppingLists(),
          const SizedBox(height: 16),
          
          // Completed Lists
          _buildSectionHeader('Đã hoàn thành', Icons.check_circle),
          const SizedBox(height: 8),
          ..._buildCompletedShoppingLists(),
        ],
      ),
    );
  }

  Widget _buildSharedListsTab() {
    return RefreshIndicator(
      onRefresh: _refreshLists,
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shared with me
          _buildSectionHeader('Được chia sẻ với tôi', Icons.people),
          const SizedBox(height: 8),
          ..._buildSharedWithMeLists(),
          const SizedBox(height: 16),
          
          // I shared
          _buildSectionHeader('Tôi đã chia sẻ', Icons.share),
          const SizedBox(height: 8),
          ..._buildISharedLists(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  child: _buildQuickActionButton(
                    icon: Icons.restaurant_menu,
                    label: 'Từ kế hoạch ăn',
                    onTap: _createFromMealPlan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.kitchen,
                    label: 'Từ tủ lạnh',
                    onTap: _createFromPantry,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.store,
                    label: 'Theo chợ/siêu thị',
                    onTap: _createByStore,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Quét QR',
                    onTap: _scanQR,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreenLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 4),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActiveShoppingLists() {
    // Mock data - replace with actual data
    final activeLists = [
      {
        'id': '1',
        'title': 'Mua sắm tuần này',
        'itemCount': 12,
        'checkedCount': 5,
        'createdDate': '3 giờ trước',
        'totalCost': '245,000đ',
        'isShared': false,
      },
      {
        'id': '2',
        'title': 'Tiệc cuối tuần',
        'itemCount': 8,
        'checkedCount': 2,
        'createdDate': '1 ngày trước',
        'totalCost': '180,000đ',
        'isShared': true,
      },
    ];

    return activeLists.map((list) => ShoppingListCard(
      list: list,
      onTap: () => _openShoppingList(list['id'] as String),
      onEdit: () => _editShoppingList(list['id'] as String),
      onDelete: () => _deleteShoppingList(list['id'] as String),
      onShare: () => _shareShoppingList(list['id'] as String),
    )).toList();
  }

  List<Widget> _buildCompletedShoppingLists() {
    // Mock data - replace with actual data
    final completedLists = [
      {
        'id': '3',
        'title': 'Mua sắm tuần trước',
        'itemCount': 15,
        'checkedCount': 15,
        'createdDate': '1 tuần trước',
        'totalCost': '320,000đ',
        'isShared': false,
        'isCompleted': true,
      },
    ];

    return completedLists.map((list) => ShoppingListCard(
      list: list,
      onTap: () => _openShoppingList(list['id'] as String),
      onEdit: () => _editShoppingList(list['id'] as String),
      onDelete: () => _deleteShoppingList(list['id'] as String),
      onShare: () => _shareShoppingList(list['id'] as String),
    )).toList();
  }

  List<Widget> _buildSharedWithMeLists() {
    // Mock data - replace with actual data
    final sharedLists = [
      {
        'id': '4',
        'title': 'Mua sắm gia đình',
        'itemCount': 10,
        'checkedCount': 6,
        'createdDate': '2 giờ trước',
        'totalCost': '195,000đ',
        'isShared': true,
        'sharedBy': 'Nguyễn Văn A',
      },
    ];

    return sharedLists.map((list) => ShoppingListCard(
      list: list,
      onTap: () => _openShoppingList(list['id'] as String),
      onEdit: () => _editShoppingList(list['id'] as String),
      onDelete: () => _deleteShoppingList(list['id'] as String),
      onShare: () => _shareShoppingList(list['id'] as String),
    )).toList();
  }

  List<Widget> _buildISharedLists() {
    // Mock data - replace with actual data
    final iSharedLists = [
      {
        'id': '5',
        'title': 'Picnic công ty',
        'itemCount': 20,
        'checkedCount': 8,
        'createdDate': '1 ngày trước',
        'totalCost': '450,000đ',
        'isShared': true,
        'sharedWith': '3 người',
      },
    ];

    return iSharedLists.map((list) => ShoppingListCard(
      list: list,
      onTap: () => _openShoppingList(list['id'] as String),
      onEdit: () => _editShoppingList(list['id'] as String),
      onDelete: () => _deleteShoppingList(list['id'] as String),
      onShare: () => _shareShoppingList(list['id'] as String),
    )).toList();
  }

  Future<void> _refreshLists() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  void _showCreateShoppingListDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateShoppingListDialog(
        onCreated: () {
          setState(() {});
        },
      ),
    );
  }

  void _createFromMealPlan() {
    // Navigate to meal plan selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo danh sách từ kế hoạch ăn...')),
    );
  }

  void _createFromPantry() {
    // Navigate to pantry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo danh sách từ tủ lạnh...')),
    );
  }

  void _createByStore() {
    // Show store layout options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chọn layout cửa hàng...')),
    );
  }

  void _scanQR() {
    // Open QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mở máy quét QR...')),
    );
  }

  void _openShoppingList(String listId) {
    // Navigate to shopping list detail
    Navigator.pushNamed(context, '/shopping-list-detail', arguments: listId);
  }

  void _editShoppingList(String listId) {
    // Open edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa danh sách $listId')),
    );
  }

  void _deleteShoppingList(String listId) {
    // Show delete confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh sách'),
        content: const Text('Bạn có chắc muốn xóa danh sách này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa danh sách')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _shareShoppingList(String listId) {
    // Show share options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chia sẻ danh sách $listId')),
    );
  }
}