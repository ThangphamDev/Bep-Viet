import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class PantryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onUse;

  const PantryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String;
    final expiryDate = item['expiryDate'] as DateTime;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getStatusColor(status),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Item image or icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _getCategoryIcon(item['category']),
                      color: _getCategoryColor(item['category']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildStatusChip(status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['quantity']} ${item['unit']} • ${item['location']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit(item);
                          break;
                        case 'use':
                          onUse(item);
                          break;
                        case 'delete':
                          onDelete(item);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'use',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline),
                            SizedBox(width: 8),
                            Text('Sử dụng'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Expiry info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getExpiryText(daysUntilExpiry, status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Mua: ${_formatDate(item['purchaseDate'] as DateTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Progress bar for fresh items
              if (status == 'fresh') ...[
                const SizedBox(height: 8),
                _buildFreshnessIndicator(item),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'fresh':
        color = AppTheme.successColor;
        text = 'Tươi';
        break;
      case 'expiring_soon':
        color = Colors.orange;
        text = 'Sắp hết hạn';
        break;
      case 'expired':
        color = AppTheme.errorColor;
        text = 'Hết hạn';
        break;
      default:
        color = AppTheme.textSecondary;
        text = 'Không xác định';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFreshnessIndicator(Map<String, dynamic> item) {
    final purchaseDate = item['purchaseDate'] as DateTime;
    final expiryDate = item['expiryDate'] as DateTime;
    final now = DateTime.now();
    
    final totalDays = expiryDate.difference(purchaseDate).inDays;
    final daysPassed = now.difference(purchaseDate).inDays;
    final progress = (daysPassed / totalDays).clamp(0.0, 1.0);
    
    Color progressColor;
    if (progress < 0.5) {
      progressColor = AppTheme.successColor;
    } else if (progress < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppTheme.errorColor;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Độ tươi:',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${(100 - progress * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'fresh':
        return AppTheme.successColor;
      case 'expiring_soon':
        return Colors.orange;
      case 'expired':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'meat':
        return Colors.red.shade600;
      case 'vegetables':
        return Colors.green.shade600;
      case 'fruits':
        return Colors.orange.shade600;
      case 'dairy':
        return Colors.blue.shade600;
      case 'grains':
        return Colors.brown.shade600;
      case 'spices':
        return Colors.purple.shade600;
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'meat':
        return Icons.set_meal;
      case 'vegetables':
        return Icons.eco;
      case 'fruits':
        return Icons.apple;
      case 'dairy':
        return Icons.local_drink;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.spa;
      default:
        return Icons.food_bank;
    }
  }

  String _getExpiryText(int daysUntilExpiry, String status) {
    if (status == 'expired') {
      final daysPastExpiry = -daysUntilExpiry;
      if (daysPastExpiry == 1) {
        return 'Hết hạn 1 ngày trước';
      } else {
        return 'Hết hạn $daysPastExpiry ngày trước';
      }
    } else if (daysUntilExpiry == 0) {
      return 'Hết hạn hôm nay';
    } else if (daysUntilExpiry == 1) {
      return 'Hết hạn vào ngày mai';
    } else {
      return 'Còn $daysUntilExpiry ngày';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}