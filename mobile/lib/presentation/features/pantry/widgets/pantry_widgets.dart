import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/pantry_item_model.dart';
import 'package:bepviet_mobile/presentation/features/shopping/utils/ingredient_section_helper.dart';

// Extension for Color manipulation
extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

/// Helper class for pantry UI colors
class PantryColors {
  static Color getSectionColor(String sectionName) {
    final lowerName = sectionName.toLowerCase();
    if (lowerName.contains('rau củ quả')) return const Color(0xFF4CAF50); // Green
    if (lowerName.contains('thịt, cá, hải sản')) return const Color(0xFFE91E63); // Pink
    if (lowerName.contains('trứng, sữa')) return const Color(0xFFFFA726); // Orange
    if (lowerName.contains('gia vị, ướp')) return const Color(0xFFAB47BC); // Purple
    if (lowerName.contains('đồ khô')) return const Color(0xFF8D6E63); // Brown
    if (lowerName.contains('đồ uống')) return const Color(0xFF42A5F5); // Blue
    if (lowerName.contains('đồ đông lạnh')) return const Color(0xFF26C6DA); // Cyan
    return const Color(0xFF78909C); // Blue Grey for 'Khác'
  }

  static IconData getLocationIcon(String? location) {
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
        return Icons.inventory_2;
    }
  }
}

/// Section header widget với gradient và colors
class PantrySectionHeader extends StatelessWidget {
  final String sectionName;
  final int itemCount;

  const PantrySectionHeader({
    super.key,
    required this.sectionName,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final sectionColor = PantryColors.getSectionColor(sectionName);
    
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            sectionColor.withOpacity(0.12),
            sectionColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sectionColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: sectionColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon với background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sectionColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              IngredientSectionHelper.getSectionIcon(sectionName),
              size: 20,
              color: sectionColor,
            ),
          ),
          const SizedBox(width: 12),
          // Section name
          Expanded(
            child: Text(
              sectionName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: sectionColor.darken(0.3),
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Item count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sectionColor,
                  sectionColor.darken(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: sectionColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$itemCount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantry item card widget
class PantryItemCard extends StatelessWidget {
  final PantryItemModel item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onConsume;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?>? onSelectionChanged;

  const PantryItemCard({
    super.key,
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onConsume,
    required this.onEdit,
    required this.onDelete,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = item.daysUntilExpiry;
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;
    final isLowStock = item.isLowStock;

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

    final sectionColor = PantryColors.getSectionColor(
      IngredientSectionHelper.classifyIngredient(item.ingredientName)
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            statusColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selection checkbox
                if (isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: onSelectionChanged,
                    activeColor: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                ],
                // Item image/icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sectionColor.withOpacity(0.25),
                        sectionColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sectionColor.withOpacity(0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: sectionColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: item.ingredientImage != null && item.ingredientImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.ingredientImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                IngredientSectionHelper.getSectionIcon(
                                  IngredientSectionHelper.classifyIngredient(item.ingredientName)
                                ),
                                color: sectionColor,
                                size: 34,
                              );
                            },
                          ),
                        )
                      : Icon(
                          IngredientSectionHelper.getSectionIcon(
                            IngredientSectionHelper.classifyIngredient(item.ingredientName)
                          ),
                          color: sectionColor,
                          size: 34,
                        ),
                ),
                const SizedBox(width: 14),
                
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item name
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Quantity với icon
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: AppTheme.primaryGreen.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${item.currentQuantity} ${item.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          // Location badge (nếu có)
                          if (item.location != null && item.location!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PantryColors.getLocationIcon(item.location),
                                      size: 9,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        item.location!,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Expiry info với gradient background
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.15),
                              statusColor.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpired ? Icons.warning_rounded : Icons.schedule_rounded,
                              size: 13,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpired 
                                  ? 'Hết hạn ${(-daysUntilExpiry).abs()} ngày'
                                  : daysUntilExpiry == 0
                                      ? 'Hết hạn hôm nay'
                                      : 'Còn $daysUntilExpiry ngày',
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge and actions (hide in selection mode)
                if (!isSelectionMode)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge với gradient
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor,
                              statusColor.darken(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Action buttons với gradient
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Consume button
                          PantryActionButton(
                            icon: Icons.remove_circle_rounded,
                            color: AppTheme.primaryGreen,
                            onTap: onConsume,
                          ),
                          const SizedBox(width: 6),
                          // Edit button
                          PantryActionButton(
                            icon: Icons.edit_rounded,
                            color: const Color(0xFF2196F3),
                            onTap: onEdit,
                          ),
                          const SizedBox(width: 6),
                          // Delete button
                          PantryActionButton(
                            icon: Icons.delete_rounded,
                            color: const Color(0xFFEF5350),
                            onTap: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action button widget
class PantryActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PantryActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Empty state widget
class PantryEmptyState extends StatelessWidget {
  final VoidCallback onAddItem;

  const PantryEmptyState({
    super.key,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon với gradient background
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.15),
                    AppTheme.primaryGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.kitchen_outlined,
                size: 70,
                color: AppTheme.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Tủ lạnh trống rỗng',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'Hãy thêm nguyên liệu để quản lý\ntủ lạnh của bạn hiệu quả hơn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Gradient button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddItem,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreen.darken(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Thêm nguyên liệu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

