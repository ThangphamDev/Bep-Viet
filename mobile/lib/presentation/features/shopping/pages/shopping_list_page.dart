import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/presentation/features/shopping/cubit/shopping_list_cubit.dart';
import 'package:bepviet_mobile/presentation/features/planner/cubit/meal_plan_cubit.dart';
import 'package:bepviet_mobile/presentation/features/pantry/cubit/pantry_cubit.dart';
import 'package:bepviet_mobile/data/models/shopping_list_model.dart';
import 'package:bepviet_mobile/data/models/meal_plan_model.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/data/sources/remote/api_service.dart';
import 'package:bepviet_mobile/data/sources/remote/auth_service.dart';
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
        // Load current week's meal plan so we can generate shopping list from it
        context.read<MealPlanCubit>().loadMealPlans();
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
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (state.shoppingLists.isEmpty) {
            return _buildEmptyState();
          }

          // Show the selected list or the newest one
          final selectedList =
              state.selectedList ??
              (state.shoppingLists.isNotEmpty
                  ? (state.shoppingLists
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
                        .first
                  : null);

          if (selectedList == null) {
            return _buildEmptyState();
          }

          return _buildShoppingListView(selectedList, state.shoppingLists);
        },
      ),
      floatingActionButton: BlocBuilder<MealPlanCubit, MealPlanState>(
        builder: (context, mealPlanState) {
          final hasMealPlan =
              mealPlanState.currentPlan != null &&
              mealPlanState.currentPlan!.meals.isNotEmpty;

          return FloatingActionButton.extended(
            onPressed: hasMealPlan
                ? () => _generateShoppingListFromMealPlan(
                    mealPlanState.currentPlan!,
                  )
                : null,
            backgroundColor: hasMealPlan ? AppTheme.primaryGreen : Colors.grey,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Từ kế hoạch'),
            tooltip: hasMealPlan
                ? 'Tạo danh sách mua sắm từ kế hoạch bữa ăn (${mealPlanState.currentPlan!.meals.length} món)'
                : 'Chưa có kế hoạch bữa ăn cho tuần này',
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
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
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
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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

  Widget _buildListSelectorDropdown(
    ShoppingListModel selectedList,
    List<ShoppingListModel> allLists,
  ) {
    // Sort lists by creation date (newest first)
    final sortedLists = [...allLists]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (sortedLists.length <= 1) {
      // Don't show dropdown if only one list
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.list_alt, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedList.id,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final newList = sortedLists.firstWhere(
                      (list) => list.id == newValue,
                    );
                    context.read<ShoppingListCubit>().selectShoppingList(
                      newList,
                    );
                  }
                },
                items: sortedLists.map<DropdownMenuItem<String>>((list) {
                  final completionPercentage = _getCompletionPercentage(list);
                  return DropdownMenuItem<String>(
                    value: list.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                list.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${list.items.length} món • $completionPercentage% hoàn thành',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListView(
    ShoppingListModel selectedList,
    List<ShoppingListModel> allLists,
  ) {
    // Group items by store section
    final Map<String, List<ShoppingItem>> itemsBySection = {};
    for (final item in selectedList.items) {
      final section = item.storeSectionName ?? 'Khác';
      if (!itemsBySection.containsKey(section)) {
        itemsBySection[section] = [];
      }
      itemsBySection[section]!.add(item);
    }

    // Define section order for better shopping experience
    final sectionOrder = [
      'Rau củ quả',
      'Thịt, cá, hải sản',
      'Trứng, sữa',
      'Gia vị, ướp',
      'Đồ khô',
      'Đồ uống',
      'Đồ đông lạnh',
      'Khác',
    ];

    // Sort sections by predefined order
    final sortedSections = itemsBySection.entries.toList()
      ..sort((a, b) {
        int indexA = sectionOrder.indexOf(a.key);
        int indexB = sectionOrder.indexOf(b.key);
        if (indexA == -1) indexA = sectionOrder.length;
        if (indexB == -1) indexB = sectionOrder.length;
        return indexA.compareTo(indexB);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildListSelectorDropdown(selectedList, allLists),
        const SizedBox(height: 16),
        _buildListHeader(selectedList),
        const SizedBox(height: 16),

        // Build sections
        ...sortedSections.map((entry) {
          final sectionName = entry.key;
          final sectionItems = entry.value;
          final uncheckedItems = sectionItems
              .where((item) => !item.isChecked)
              .toList();
          final checkedItems = sectionItems
              .where((item) => item.isChecked)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uncheckedItems.isNotEmpty || checkedItems.isNotEmpty) ...[
                _buildStoreSectionHeader(
                  sectionName,
                  uncheckedItems.length,
                  checkedItems.length,
                ),
                const SizedBox(height: 8),

                // Unchecked items
                ...uncheckedItems.map(
                  (item) => _buildShoppingItemWithPantryInfo(item, false),
                ),

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
                    children: checkedItems
                        .map(
                          (item) =>
                              _buildShoppingItemWithPantryInfo(item, true),
                        )
                        .toList(),
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          if (checkedItems > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addCheckedItemsToPantry(list),
                icon: const Icon(Icons.kitchen, size: 20),
                label: Text('Lưu $checkedItems món đã mua vào tủ lạnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStoreSectionHeader(
    String sectionName,
    int uncheckedCount,
    int checkedCount,
  ) {
    final totalCount = uncheckedCount + checkedCount;
    final completionPercentage = totalCount > 0
        ? ((checkedCount / totalCount) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.15),
            AppTheme.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _getSectionIcon(sectionName),
              color: AppTheme.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Còn $uncheckedCount món',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: completionPercentage == 100
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: completionPercentage == 100
                    ? Colors.green
                    : Colors.orange,
                width: 1.5,
              ),
            ),
            child: Text(
              '$completionPercentage%',
              style: TextStyle(
                fontSize: 13,
                color: completionPercentage == 100
                    ? Colors.green[700]
                    : Colors.orange[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String sectionName) {
    final lowerName = sectionName.toLowerCase();

    if (lowerName.contains('rau') ||
        lowerName.contains('củ') ||
        lowerName.contains('quả')) {
      return Icons.eco;
    } else if (lowerName.contains('thịt') ||
        lowerName.contains('cá') ||
        lowerName.contains('hải sản')) {
      return Icons.set_meal;
    } else if (lowerName.contains('trứng') || lowerName.contains('sữa')) {
      return Icons.egg;
    } else if (lowerName.contains('gia vị') || lowerName.contains('ướp')) {
      return Icons.restaurant;
    } else if (lowerName.contains('khô')) {
      return Icons.grain;
    } else if (lowerName.contains('uống')) {
      return Icons.local_drink;
    } else if (lowerName.contains('đông lạnh')) {
      return Icons.ac_unit;
    } else {
      return Icons.shopping_basket;
    }
  }

  Widget _buildShoppingItemWithPantryInfo(ShoppingItem item, bool isChecked) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, pantryState) {
        // Find pantry item with same ingredient
        final pantryItem = pantryState.pantryItems
            .where(
              (p) =>
                  p.ingredientName.toLowerCase() ==
                  item.ingredientName.toLowerCase(),
            )
            .firstOrNull;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isChecked
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
        content: Text(
          'Bạn có chắc chắn muốn xóa "${item.ingredientName}" khỏi danh sách?',
        ),
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
              title: const Text(
                'Xóa danh sách',
                style: TextStyle(color: Colors.red),
              ),
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
    final ingredientNameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'kg');
    final notesController = TextEditingController();
    String selectedIngredientId = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm món hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ingredientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên nguyên liệu *',
                    hintText: 'Ví dụ: Cà chua',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  onChanged: (value) {
                    selectedIngredientId = ''; // Reset ID when typing manually
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng *',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị *',
                          hintText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    hintText: 'Ví dụ: Chín vừa, không quá chua',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final ingredientName = ingredientNameController.text.trim();
                final quantityStr = quantityController.text.trim();
                final unit = unitController.text.trim();

                if (ingredientName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên nguyên liệu'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final quantity = double.tryParse(quantityStr);
                if (quantity == null || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập số lượng hợp lệ'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (unit.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đơn vị'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Create DTO and add item
                final dto = AddShoppingItemDto(
                  ingredientId: selectedIngredientId.isEmpty
                      ? 'manual-${DateTime.now().millisecondsSinceEpoch}'
                      : selectedIngredientId,
                  ingredientName: ingredientName,
                  quantity: quantity,
                  unit: unit,
                  notes: notesController.text.trim().isNotEmpty
                      ? notesController.text.trim()
                      : null,
                );

                context.read<ShoppingListCubit>().addItemToShoppingList(
                  listId,
                  dto,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm'),
            ),
          ],
        ),
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

    // Show date selection dialog
    final selectedDates = await showDialog<List<String>>(
      context: context,
      builder: (context) => _SelectDatesDialog(mealPlan: mealPlan),
    );

    if (selectedDates == null || selectedDates.isEmpty || !mounted || _disposed)
      return;

    // Use a different approach - overlay loading instead of dialog
    OverlayEntry? overlayEntry;

    try {
      // Show loading overlay
      if (mounted && !_disposed) {
        overlayEntry = OverlayEntry(
          builder: (context) => Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryGreen),
                  SizedBox(height: 16),
                  Text(
                    'Đang tạo danh sách mua sắm...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
        Overlay.of(context).insert(overlayEntry);
      }

      // Get meals from selected dates
      final selectedMeals = mealPlan.meals
          .where(
            (meal) =>
                selectedDates.contains(meal.date) && meal.recipeId != null,
          )
          .toList();

      // Generate shopping list from selected meals
      await _generateShoppingListFromMeals(selectedMeals, selectedDates);

      // Remove loading overlay
      if (mounted && !_disposed && overlayEntry != null) {
        overlayEntry.remove();
        overlayEntry = null;
      }

      // Show success message
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã tạo danh sách mua sắm từ kế hoạch bữa ăn thành công!',
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 3),
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _addCheckedItemsToPantry(ShoppingListModel list) async {
    final checkedItems = list.items.where((item) => item.isChecked).toList();

    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có món nào đã mua'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu vào tủ lạnh'),
        content: Text(
          'Bạn muốn lưu ${checkedItems.length} món đã mua vào tủ lạnh?\n\n'
          'Các món này sẽ được thêm vào tủ lạnh với số lượng mặc định.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    OverlayEntry? overlayEntry;
    int successCount = 0;
    int errorCount = 0;

    try {
      overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang lưu ${checkedItems.length} món vào tủ lạnh...',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(overlayEntry);

      // Add each item to pantry
      for (final item in checkedItems) {
        try {
          final dto = AddPantryItemDto(
            ingredientId: item.ingredientId,
            quantity: item.quantity,
            unit: item.unit,
            expiryDate: null, // User can update later
            purchaseDate: DateTime.now(),
            location: PantryLocation.fridge.value,
            notes: null, // Don't set notes to allow merging duplicate items
          );

          await context.read<PantryCubit>().addPantryItem(dto);
          successCount++;
        } catch (e) {
          print('Failed to add ${item.ingredientName} to pantry: $e');
          errorCount++;
        }
      }

      // Remove overlay
      if (mounted && overlayEntry != null) {
        overlayEntry.remove();
      }

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount > 0
                  ? 'Đã lưu $successCount món vào tủ lạnh${errorCount > 0 ? ' ($errorCount món lỗi)' : ''}'
                  : 'Không thể lưu món nào vào tủ lạnh',
            ),
            backgroundColor: successCount > 0
                ? AppTheme.successColor
                : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted && overlayEntry != null) {
        overlayEntry.remove();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateShoppingListFromMeals(
    List<MealSlot> meals,
    List<String> selectedDates,
  ) async {
    try {
      final apiService = context.read<ApiService>();
      final authService = context.read<AuthService>();
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('Bạn cần đăng nhập để tạo danh sách mua sắm');
      }

      // Aggregate ingredients from all selected meals
      final Map<String, Map<String, dynamic>> ingredientsMap = {};

      for (final meal in meals) {
        if (meal.recipeId == null) continue;

        // Fetch recipe ingredients
        final response = await apiService.getRecipeIngredientsRaw(
          meal.recipeId!,
        );
        final ingredients = response['data'] as List<dynamic>? ?? [];

        for (final ingredient in ingredients) {
          final ingredientId = ingredient['ingredient_id'].toString();
          final quantity =
              double.tryParse(ingredient['quantity']?.toString() ?? '0') ?? 0.0;
          final scaledQuantity = quantity * meal.servings;

          if (ingredientsMap.containsKey(ingredientId)) {
            // Add to existing quantity
            ingredientsMap[ingredientId]!['quantity'] += scaledQuantity;
          } else {
            // Add new ingredient
            ingredientsMap[ingredientId] = {
              'ingredient_id': ingredientId,
              'ingredient_name': ingredient['ingredient_name'],
              'quantity': scaledQuantity,
              'unit': ingredient['unit'],
              'recipes': <String>[meal.recipeName ?? 'Món ăn'],
            };
          }

          // Add recipe name to list
          if (!ingredientsMap[ingredientId]!['recipes'].contains(
            meal.recipeName,
          )) {
            ingredientsMap[ingredientId]!['recipes'].add(
              meal.recipeName ?? 'Món ăn',
            );
          }
        }
      }

      if (ingredientsMap.isEmpty) {
        throw Exception('Không tìm thấy nguyên liệu nào từ các món đã chọn');
      }

      // Create shopping list
      final dateRange = selectedDates.length == 1
          ? _formatDateShort(selectedDates.first)
          : '${_formatDateShort(selectedDates.first)} - ${_formatDateShort(selectedDates.last)}';

      final createDto = CreateShoppingListDto(
        name: 'Mua sắm $dateRange',
        description: 'Từ kế hoạch bữa ăn (${meals.length} món)',
      );

      final newListId = await apiService.createShoppingList(token, createDto);

      // Add items to shopping list
      for (final ingredientData in ingredientsMap.values) {
        final recipes = ingredientData['recipes'] as List<String>;
        final addItemDto = AddShoppingItemDto(
          ingredientId: ingredientData['ingredient_id'],
          ingredientName: ingredientData['ingredient_name'],
          quantity: ingredientData['quantity'],
          unit: ingredientData['unit'],
          notes: 'Cho: ${recipes.join(', ')}',
        );

        try {
          await apiService.addItemToShoppingList(token, newListId, addItemDto);
        } catch (e) {
          print('Failed to add ${ingredientData['ingredient_name']}: $e');
        }
      }

      // Reload shopping lists to show the new one
      await context.read<ShoppingListCubit>().loadShoppingLists();

      // Load and select the newly created shopping list
      final newList = await apiService.getShoppingListById(token, newListId);
      if (mounted && !_disposed) {
        context.read<ShoppingListCubit>().selectShoppingList(newList);
      }

      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã tạo danh sách mua sắm với ${ingredientsMap.length} nguyên liệu từ ${meals.length} món!',
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatDateShort(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateStr;
    }
  }

  int _getCompletionPercentage(ShoppingListModel list) {
    if (list.items.isEmpty) return 0;
    final checkedItems = list.items.where((item) => item.isChecked).length;
    return ((checkedItems / list.items.length) * 100).round();
  }
}

// Dialog to select dates from meal plan
class _SelectDatesDialog extends StatefulWidget {
  final MealPlanModel mealPlan;

  const _SelectDatesDialog({required this.mealPlan});

  @override
  State<_SelectDatesDialog> createState() => _SelectDatesDialogState();
}

class _SelectDatesDialogState extends State<_SelectDatesDialog> {
  final Set<String> _selectedDates = {};
  late Map<String, List<MealSlot>> _mealsByDate;

  @override
  void initState() {
    super.initState();
    // Group meals by date
    _mealsByDate = {};
    for (final meal in widget.mealPlan.meals) {
      if (meal.recipeId != null) {
        if (!_mealsByDate.containsKey(meal.date)) {
          _mealsByDate[meal.date] = [];
        }
        _mealsByDate[meal.date]!.add(meal);
      }
    }
    // Select all dates by default
    _selectedDates.addAll(_mealsByDate.keys);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final weekday = [
        'CN',
        'T2',
        'T3',
        'T4',
        'T5',
        'T6',
        'T7',
      ][date.weekday % 7];
      return '$weekday, ${date.day}/${date.month}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '🌞';
      case MealType.dinner:
        return '🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _mealsByDate.keys.toList()..sort();
    final totalMeals = _selectedDates.fold<int>(
      0,
      (sum, date) => sum + (_mealsByDate[date]?.length ?? 0),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn ngày mua sắm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chọn các ngày bạn muốn tạo danh sách mua sắm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Select all toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedDates.length == _mealsByDate.length,
                    tristate: true,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedDates.addAll(_mealsByDate.keys);
                        } else {
                          _selectedDates.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chọn tất cả ($totalMeals món)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sortedDates.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final meals = _mealsByDate[date]!;
                  final isSelected = _selectedDates.contains(date);

                  return CheckboxListTile(
                    value: isSelected,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedDates.add(date);
                        } else {
                          _selectedDates.remove(date);
                        }
                      });
                    },
                    title: Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        ...meals.map(
                          (meal) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  _getMealTypeIcon(meal.mealType),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    meal.recipeName ?? 'Món ăn',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Text(
                                  '${meal.servings} phần',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _selectedDates.isEmpty
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(_selectedDates.toList()),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text('Tạo ($totalMeals món)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
