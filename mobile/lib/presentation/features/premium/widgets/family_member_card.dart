import 'package:flutter/material.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/family_profile_page.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FamilyMemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Text(
                member.name.split(' ').last[0],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: AppConfig.defaultPadding),

            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConfig.smallPadding / 2),
                  Text(
                    '${member.age} tuổi • ${member.role}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConfig.smallPadding),
                  Wrap(
                    spacing: AppConfig.smallPadding / 2,
                    runSpacing: AppConfig.smallPadding / 2,
                    children: [
                      if (member.allergies.isNotEmpty)
                        _buildInfoChip(
                          '${member.allergies.length} dị ứng',
                          AppTheme.errorColor,
                        ),
                      if (member.healthConditions.isNotEmpty)
                        _buildInfoChip(
                          '${member.healthConditions.length} tình trạng',
                          AppTheme.warningColor,
                        ),
                      if (member.dietaryRestrictions.isNotEmpty)
                        _buildInfoChip(
                          '${member.dietaryRestrictions.length} hạn chế',
                          AppTheme.infoColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppTheme.secondaryGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConfig.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.smallPadding),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
