import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// TODO: Uncomment khi share_plus được fix
// import 'package:share_plus/share_plus.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/community_recipe.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class CommunityFeedCardNew extends StatefulWidget {
  final CommunityRecipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditOptions;
  final Function(String recipeId, String comment)? onComment;
  final Function(String recipeId, int stars)? onRating;
  final Function(String recipeId)? onShare;

  const CommunityFeedCardNew({
    super.key,
    required this.recipe,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showEditOptions = false,
    this.onComment,
    this.onRating,
    this.onShare,
  });

  @override
  State<CommunityFeedCardNew> createState() => _CommunityFeedCardNewState();
}

class _CommunityFeedCardNewState extends State<CommunityFeedCardNew> {
  int _shareCount = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shareCount = 0; // Initialize share count
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
            // Only add spacing if there's an image
            if (widget.recipe.imageUrl != null && widget.recipe.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImage(context),
            ],
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
        if (widget.recipe.authorName != null && widget.recipe.authorName!.isNotEmpty) {
          displayName = widget.recipe.authorName!;
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
                      if (widget.recipe.status == 'APPROVED')
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: AppTheme.primaryGreen,
                        ),
                    ],
                  ),
                  Text(
                    _formatTimeAgo(widget.recipe.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // More options
            if (widget.showEditOptions)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      widget.onEdit?.call();
                      break;
                    case 'delete':
                      widget.onDelete?.call();
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
          widget.recipe.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
        if (widget.recipe.descriptionMd != null && widget.recipe.descriptionMd!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.recipe.descriptionMd!,
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
    // Only show image if available
    if (widget.recipe.imageUrl == null || widget.recipe.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: widget.recipe.imageUrl!.startsWith('data:image')
            ? Image.memory(
                Uri.parse(widget.recipe.imageUrl!).data!.contentAsBytes(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.restaurant, size: 60, color: Colors.grey.shade400),
                  );
                },
              )
            : Image.network(
                widget.recipe.imageUrl!,
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
    final timeLabel = (widget.recipe.timeMin != null && widget.recipe.timeMin! > 0)
        ? '${widget.recipe.timeMin} phút'
        : '—';
    final regionLabel = (widget.recipe.region != null && widget.recipe.region!.isNotEmpty)
        ? _getRegionName(widget.recipe.region!)
        : '—';
    final difficultyLabel = (widget.recipe.difficulty != null && widget.recipe.difficulty!.isNotEmpty)
        ? _getDifficultyName(widget.recipe.difficulty!)
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
    final commentCount = widget.recipe.commentCount;
    final ratingCount = widget.recipe.ratingCount;
    final avgRating = widget.recipe.avgRating;

    return Column(
      children: [
        // Main action buttons
        Row(
          children: [
            _buildActionButton(
              icon: Icons.star_outline,
              label: ratingCount > 0 ? '${avgRating?.toStringAsFixed(1) ?? '0.0'} ($ratingCount)' : '',
              color: Colors.amber,
              onTap: _showRatingDialog,
            ),
            const SizedBox(width: 20),
            _buildActionButton(
              icon: Icons.mode_comment_outlined,
              label: commentCount > 0 ? '$commentCount' : '',
              color: Colors.grey.shade700,
              onTap: _showCommentDialog,
            ),
            const SizedBox(width: 20),
            _buildActionButton(
              icon: Icons.share_outlined,
              label: _shareCount > 0 ? '$_shareCount' : '',
              color: Colors.grey.shade700,
              onTap: _handleShare,
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  void _showRatingDialog() {
    int selectedRating = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Đánh giá công thức'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn số sao:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedRating > 0 ? () {
                widget.onRating?.call(widget.recipe.id, selectedRating);
                Navigator.pop(context);
              } : null,
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleShare() {
    setState(() {
      _shareCount++;
    });
    // TODO: Uncomment khi share_plus được fix
    // Share.share('Xem công thức: ${widget.recipe.title}');
    
    // Tạm thời hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ đang được cập nhật'),
        duration: Duration(seconds: 2),
      ),
    );
    widget.onShare?.call(widget.recipe.id);
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bình luận'),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            hintText: 'Viết bình luận của bạn...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                widget.onComment?.call(widget.recipe.id, _commentController.text.trim());
                _commentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
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
      case 'BAC':
      case 'NORTH':
        return 'Miền Bắc';
      case 'TRUNG':
      case 'CENTRAL':
        return 'Miền Trung';
      case 'NAM':
      case 'SOUTH':
        return 'Miền Nam';
      default:
        return region;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'DE':
      case 'EASY':
        return 'Dễ';
      case 'TRUNG_BINH':
      case 'MEDIUM':
        return 'Trung bình';
      case 'KHO':
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }
}
