import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/advisory_page.dart';

class AdvisoryCard extends StatelessWidget {
  final AdvisoryItem advisory;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;
  final bool showActions;

  const AdvisoryCard({
    super.key,
    required this.advisory,
    this.onTap,
    this.onMarkAsRead,
    this.onDismiss,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppConfig.defaultPadding + 4),
          border: Border.all(
            color: advisory.isRead
                ? Colors.grey.shade200
                : _getAdvisoryColor(advisory.type).withOpacity(0.3),
            width: advisory.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConfig.smallPadding),
                  decoration: BoxDecoration(
                    color: _getAdvisoryColor(advisory.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                  ),
                  child: Icon(
                    _getAdvisoryIcon(advisory.type),
                    color: _getAdvisoryColor(advisory.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConfig.smallPadding + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisory.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: advisory.isRead
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppConfig.smallPadding / 4),
                      Text(
                        '${advisory.memberName} • ${advisory.recipeName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!advisory.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConfig.smallPadding + 4),

            // Description
            Text(
              advisory.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: advisory.isRead
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConfig.smallPadding + 4),

            // Footer
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.smallPadding,
                    vertical: AppConfig.smallPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      advisory.priority,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConfig.smallPadding),
                  ),
                  child: Text(
                    _getPriorityText(advisory.priority),
                    style: TextStyle(
                      color: _getPriorityColor(advisory.priority),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(advisory.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            // Actions (if showActions is true)
            if (showActions && !advisory.isRead) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMarkAsRead,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Đã đọc'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConfig.smallPadding),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Bỏ qua'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAdvisoryColor(AdvisoryType type) {
    switch (type) {
      case AdvisoryType.allergy:
        return AppTheme.errorColor;
      case AdvisoryType.health:
        return AppTheme.warningColor;
      case AdvisoryType.spice:
        return AppTheme.infoColor;
    }
  }

  IconData _getAdvisoryIcon(AdvisoryType type) {
    switch (type) {
      case AdvisoryType.allergy:
        return Icons.warning_amber;
      case AdvisoryType.health:
        return Icons.health_and_safety;
      case AdvisoryType.spice:
        return Icons.local_fire_department;
    }
  }

  Color _getPriorityColor(AdvisoryPriority priority) {
    switch (priority) {
      case AdvisoryPriority.high:
        return AppTheme.errorColor;
      case AdvisoryPriority.medium:
        return AppTheme.warningColor;
      case AdvisoryPriority.low:
        return AppTheme.infoColor;
    }
  }

  String _getPriorityText(AdvisoryPriority priority) {
    switch (priority) {
      case AdvisoryPriority.high:
        return 'Ưu tiên cao';
      case AdvisoryPriority.medium:
        return 'Ưu tiên trung bình';
      case AdvisoryPriority.low:
        return 'Ưu tiên thấp';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
