import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import '../../../../data/models/community_recipe.dart';

class CommunityFeedCard extends StatelessWidget {
  final CommunityRecipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isLiked;

  const CommunityFeedCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Render nothing; this file is deprecated.
    // return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildImage(),
            _buildContent(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
              ),
            ),
            child: Center(
              child: Text(
                (recipe.authorName ?? 'N').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.authorName ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeAgo(recipe.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(
              Icons.more_horiz,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        image: DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/400/200?random=${recipe.id}',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Region badge
          if (recipe.region != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRegionName(recipe.region!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Difficulty badge
          if (recipe.difficulty != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(recipe.difficulty!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDifficultyIcon(recipe.difficulty!),
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDifficultyName(recipe.difficulty!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Description
          if (recipe.descriptionMd != null && recipe.descriptionMd!.isNotEmpty)
            Text(
              recipe.descriptionMd!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 12),

          // Recipe info
          Row(
            children: [
              if (recipe.timeMin != null) ...[
                _buildInfoChip(
                  icon: Icons.access_time,
                  text: '${recipe.timeMin} phút',
                ),
                const SizedBox(width: 12),
              ],
              if (recipe.costHint != null) ...[
                _buildInfoChip(
                  icon: Icons.attach_money,
                  text: _getCostLevel(recipe.costHint!),
                ),
                const SizedBox(width: 12),
              ],
              _buildInfoChip(
                icon: Icons.star,
                text:
                    '${(recipe.avgRating ?? 0).toStringAsFixed(1)} (${recipe.ratingCount})',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Like button
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : AppTheme.textSecondary,
            onTap: () => _handleLike(),
          ),
          const SizedBox(width: 16),

          // Comment button
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            onTap: () => _handleComment(),
          ),
          const SizedBox(width: 16),

          // Share button
          _buildActionButton(icon: Icons.share, onTap: () => _handleShare()),

          const Spacer(),

          // Save button
          _buildActionButton(
            icon: Icons.bookmark_border,
            onTap: () => _handleSave(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24, color: color ?? AppTheme.textSecondary),
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Vừa xong';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  String _getRegionName(String region) {
    switch (region) {
      case 'BAC':
        return 'Miền Bắc';
      case 'TRUNG':
        return 'Miền Trung';
      case 'NAM':
        return 'Miền Nam';
      default:
        return region;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'DE':
        return 'Dễ';
      case 'TRUNG_BINH':
        return 'Trung bình';
      case 'KHO':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'DE':
        return Icons.star_border;
      case 'TRUNG_BINH':
        return Icons.star_half;
      case 'KHO':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'DE':
        return Colors.green;
      case 'TRUNG_BINH':
        return Colors.orange;
      case 'KHO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCostLevel(int costHint) {
    switch (costHint) {
      case 1:
        return 'Rẻ';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Đắt';
      default:
        return 'Không xác định';
    }
  }

  void _showMoreOptions() {
    // TODO: Implement more options
  }

  void _handleLike() {
    // TODO: Implement like functionality
    // Call API to like/unlike recipe
    if (onLike != null) {
      onLike!();
    }
  }

  void _handleComment() {
    // TODO: Navigate to comment section or show comment dialog
    if (onComment != null) {
      onComment!();
    }
  }

  void _handleShare() {
    final shareText =
        '''
🍽️ ${recipe.title}

${recipe.descriptionMd ?? 'Công thức nấu ăn ngon từ cộng đồng Bếp Việt'}

👨‍🍳 Tác giả: ${recipe.authorName ?? 'Người dùng'}
⏱️ Thời gian: ${recipe.timeMin ?? 0} phút
⭐ Độ khó: ${_getDifficultyName(recipe.difficulty ?? 'DE')}
📍 Vùng miền: ${_getRegionName(recipe.region ?? 'BAC')}

Tải ứng dụng Bếp Việt để xem chi tiết công thức!
    ''';

    // TODO: Implement share using platform channels or native code
    debugPrint('Share: $shareText');
    // For now, just show a snackbar
  }

  void _handleSave() {
    // TODO: Implement save to favorites functionality
    // Show snackbar for now
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Đã lưu vào danh sách yêu thích')),
    // );
  }
}
