import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/presentation/features/shopping/cubit/shopping_list_cubit.dart';
import 'package:bepviet_mobile/presentation/features/planner/cubit/meal_plan_cubit.dart';
import 'package:bepviet_mobile/presentation/features/pantry/cubit/pantry_cubit.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({Key? key}) : super(key: key);

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  bool _disposed = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_disposed) {
        context.read<ShoppingListCubit>().loadShoppingLists();
      }
    });
    // Also load pantry items to show availability info
    context.read<PantryCubit>().loadPantryItems();
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Danh sách mua sắm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(),
          ),
        ],
      ),
      body: BlocConsumer<ShoppingListCubit, ShoppingListState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ShoppingListCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (state.shoppingLists.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildListSelector(state),
              Expanded(
                child: _buildShoppingListView(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<MealPlanCubit, MealPlanState>(
        builder: (context, mealPlanState) {
          return FloatingActionButton.extended(
            onPressed: mealPlanState.currentPlan != null 
                ? () => _generateShoppingListFromMealPlan(mealPlanState.currentPlan!)
                : null,
            backgroundColor: mealPlanState.currentPlan != null 
                ? AppTheme.primaryGreen 
                : Colors.grey,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Từ kế hoạch'),
            tooltip: mealPlanState.currentPlan != null 
                ? 'Tạo danh sách mua sắm từ kế hoạch bữa ăn'
                : 'Không có kế hoạch bữa ăn',
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có danh sách mua sắm nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo danh sách đầu tiên của bạn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateListDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Tạo danh sách'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSelector(ShoppingListState state) {
    return Container(
      height: 80,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.shoppingLists.length,
        itemBuilder: (context, index) {
          final list = state.shoppingLists[index];
          final isSelected = state.selectedList?.id == list.id;
          final completionPercentage = _getCompletionPercentage(list);
          
          return GestureDetector(
            onTap: () => context.read<ShoppingListCubit>().selectShoppingList(list),
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    list.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${list.items.length} món',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white30 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: completionPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppTheme.successColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShoppingListView(ShoppingListState state) {
    if (state.selectedList == null) {
      return const Center(
        child: Text('Chọn một danh sách để xem chi tiết'),
      );
    }

    final list = state.selectedList!;
    
    // Group items by store section
    final Map<String, List<ShoppingItem>> itemsBySection = {};
    for (final item in list.items) {
      final section = item.storeSectionName ?? 'Khác';
      if (!itemsBySection.containsKey(section)) {
        itemsBySection[section] = [];
      }
      itemsBySection[section]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildListHeader(list),
        const SizedBox(height: 16),
        
        // Build sections
        ...itemsBySection.entries.map((entry) {
          final sectionName = entry.key;
          final sectionItems = entry.value;
          final uncheckedItems = sectionItems.where((item) => !item.isChecked).toList();
          final checkedItems = sectionItems.where((item) => item.isChecked).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uncheckedItems.isNotEmpty || checkedItems.isNotEmpty) ...[
                _buildStoreSectionHeader(sectionName, uncheckedItems.length, checkedItems.length),
                const SizedBox(height: 8),
                
                // Unchecked items
                ...uncheckedItems.map((item) => _buildShoppingItemWithPantryInfo(item, false)),
                
                // Checked items (collapsed by default)
                if (checkedItems.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: Text(
                      'Đã mua (${checkedItems.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    initiallyExpanded: false,
                    children: checkedItems.map((item) => _buildShoppingItemWithPantryInfo(item, true)).toList(),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildListHeader(ShoppingListModel list) {
    final completionPercentage = _getCompletionPercentage(list);
    final totalItems = list.items.length;
    final checkedItems = list.items.where((item) => item.isChecked).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (list.description != null)
                      Text(
                        list.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showListOptions(list),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ: $completionPercentage%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completionPercentage == 100 
                            ? AppTheme.successColor 
                            : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$checkedItems/$totalItems',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSectionHeader(String sectionName, int uncheckedCount, int checkedCount) {
    final totalCount = uncheckedCount + checkedCount;
    final completionPercentage = totalCount > 0 ? ((checkedCount / totalCount) * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getSectionIcon(sectionName),
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sectionName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          Text(
            '$checkedCount/$totalCount ($completionPercentage%)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'rau củ':
      case 'rau':
      case 'củ':
        return Icons.eco;
      case 'thịt':
      case 'hải sản':
        return Icons.restaurant;
      case 'gia vị':
      case 'đồ khô':
        return Icons.grain;
      case 'bánh kẹo':
      case 'đồ ngọt':
        return Icons.cake;
      case 'đồ uống':
        return Icons.local_drink;
      case 'sữa':
      case 'trứng':
        return Icons.breakfast_dining;
      default:
        return Icons.shopping_basket;
    }
  }

  Widget _buildShoppingItemWithPantryInfo(ShoppingItem item, bool isChecked) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, pantryState) {
        // Find pantry item with same ingredient
        final pantryItem = pantryState.pantryItems
            .where((p) => p.ingredientName.toLowerCase() == item.ingredientName.toLowerCase())
            .firstOrNull;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isChecked ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: isChecked,
              onChanged: (value) {
                context.read<ShoppingListCubit>().toggleItemChecked(
                  item.shoppingListId,
                  item.id,
                  value ?? false,
                );
              },
              activeColor: AppTheme.primaryGreen,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.ingredientName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                if (pantryItem != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Có: ${pantryItem.currentQuantity} ${pantryItem.unit}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.estimatedPrice != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '~${item.estimatedPrice!.toStringAsFixed(0)} VNĐ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditItemDialog(item);
                    break;
                  case 'delete':
                    _confirmDeleteItem(item);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(ShoppingItem item) {
    // TODO: Implement edit item dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chỉnh sửa đang phát triển')),
    );
  }

  void _confirmDeleteItem(ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.ingredientName}" khỏi danh sách?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ShoppingListCubit>().removeItemFromShoppingList(
                item.shoppingListId,
                item.id,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo danh sách mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên danh sách',
                hintText: 'Ví dụ: Mua sắm tuần này',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'Ghi chú về danh sách này',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                context.read<ShoppingListCubit>().createShoppingList(
                  CreateShoppingListDto(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isNotEmpty 
                        ? descController.text.trim() 
                        : null,
                  ),
                );
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showListOptions(ShoppingListModel list) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Thêm món hàng'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddItemDialog(list.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ'),
              onTap: () {
                Navigator.of(context).pop();
                _showShareDialog(list.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa danh sách', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDeleteList(list.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(String listId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm món hàng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chức năng thêm món hàng sẽ được phát triển trong tương lai.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(String listId) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ danh sách'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email người nhận',
            hintText: 'example@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                context.read<ShoppingListCubit>().shareShoppingList(
                  listId,
                  emailController.text.trim(),
                );
              }
            },
            child: const Text('Chia sẻ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteList(String listId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa danh sách này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ShoppingListCubit>().deleteShoppingList(listId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _generateShoppingListFromMealPlan(MealPlanModel mealPlan) async {
    if (_disposed || !mounted) return;
    
    // Use a different approach - overlay loading instead of dialog
    OverlayEntry? overlayEntry;
    
    try {
      // Show loading overlay
      if (mounted && !_disposed) {
        overlayEntry = OverlayEntry(
          builder: (context) => Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        );
        Overlay.of(context).insert(overlayEntry);
      }

      // Generate shopping list from meal plan
      await context.read<ShoppingListCubit>().generateShoppingListFromMealPlan(mealPlan.id);
      
      // Remove loading overlay
      if (mounted && !_disposed && overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }
      
      // Show success message
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo danh sách mua sắm từ kế hoạch bữa ăn thành công!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      // Remove loading overlay if still showing
      if (mounted && !_disposed && overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }
      
      // Show error message
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo danh sách mua sắm: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getCompletionPercentage(ShoppingListModel list) {
    if (list.items.isEmpty) return 0;
    final checkedItems = list.items.where((item) => item.isChecked).length;
    return ((checkedItems / list.items.length) * 100).round();
  }
}