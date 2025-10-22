import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class CommunityFeedCardNew extends StatelessWidget {
  final CommunityRecipe recipe;
  final VoidCallback? onTap;
  final bool isLiked;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditOptions;

  const CommunityFeedCardNew({
    super.key,
    required this.recipe,
    this.onTap,
    this.isLiked = false,
    this.onEdit,
    this.onDelete,
    this.showEditOptions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade100,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildContent(),
            const SizedBox(height: 12),
            _buildImage(context),
            const SizedBox(height: 12),
            _buildMetadata(),
            const SizedBox(height: 12),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String displayName = 'Người dùng';
        
        // Try to get name from recipe first, then from current user
        if (recipe.authorName != null && recipe.authorName!.isNotEmpty) {
          displayName = recipe.authorName!;
        } else if (state is AuthAuthenticated && state.user.name.isNotEmpty) {
          displayName = state.user.name;
        }
        
        final avatarChar = displayName.substring(0, 1).toUpperCase();
        
        return Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  avatarChar,
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (recipe.status == 'APPROVED')
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: AppTheme.primaryGreen,
                        ),
                    ],
                  ),
                  Text(
                    _formatTimeAgo(recipe.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // More options
            if (showEditOptions)
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
                        Icon(Icons.edit, size: 20, color: AppTheme.textPrimary),
                        SizedBox(width: 8),
                        Text('Sửa bài viết'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa bài viết', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
        if (recipe.descriptionMd != null && recipe.descriptionMd!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            recipe.descriptionMd!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Image.network(
          'https://picsum.photos/400/300?random=${recipe.id}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Icon(Icons.restaurant, size: 60, color: Colors.grey.shade400),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    // Always render three chips for a consistent layout across tabs
    final timeLabel = (recipe.timeMin != null && recipe.timeMin! > 0)
        ? '${recipe.timeMin} phút'
        : '—';
    final regionLabel = (recipe.region != null && recipe.region!.isNotEmpty)
        ? _getRegionName(recipe.region!)
        : '—';
    final difficultyLabel = (recipe.difficulty != null && recipe.difficulty!.isNotEmpty)
        ? _getDifficultyName(recipe.difficulty!)
        : '—';

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildMetaChip(
          icon: Icons.access_time_outlined,
          label: timeLabel,
          muted: timeLabel == '—',
        ),
        _buildMetaChip(
          icon: Icons.location_on_outlined,
          label: regionLabel,
          muted: regionLabel == '—',
        ),
        _buildMetaChip(
          icon: Icons.bar_chart_outlined,
          label: difficultyLabel,
          muted: difficultyLabel == '—',
        ),
      ],
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label, bool muted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: muted ? Colors.grey.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: muted ? Colors.grey.shade500 : Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: muted ? Colors.grey.shade500 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    // Simple action counts
    final likeCount = 0; // TODO: Get from recipe.ratings
    final commentCount = 0; // TODO: Get from recipe.comments

    return Row(
      children: [
        _buildActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: likeCount > 0 ? '$likeCount' : '',
          color: isLiked ? Colors.red : Colors.grey.shade700,
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          label: commentCount > 0 ? '$commentCount' : '',
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: '',
          color: Colors.grey.shade700,
          onTap: () {
            Share.share('Xem công thức: ${recipe.title}');
          },
        ),
        const Spacer(),
        _buildActionButton(
          icon: Icons.bookmark_border,
          label: '',
          color: Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _getRegionName(String region) {
    switch (region.toUpperCase()) {
      case 'NORTH':
        return 'Miền Bắc';
      case 'CENTRAL':
        return 'Miền Trung';
      case 'SOUTH':
        return 'Miền Nam';
      default:
        return region;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }
}
