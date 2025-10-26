import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';
import 'package:bepviet_mobile/data/models/notification_model.dart';
import 'package:bepviet_mobile/presentation/features/notifications/cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () {
                    context.read<NotificationsCubit>().markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all, size: 20),
                  label: const Text('Đánh dấu tất cả đã đọc'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reload
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có thông báo nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationsCubit>().removeNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thông báo'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        color: notification.isRead
            ? Colors.white
            : AppTheme.primaryGreen.withOpacity(0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.isRead
                ? Colors.grey[300]
                : AppTheme.primaryGreen.withOpacity(0.2),
            child: Text(
              notification.iconByType,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.body.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                notification.timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? const Icon(Icons.circle, color: AppTheme.primaryGreen, size: 12)
              : null,
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationsCubit>().markAsRead(notification.id);
            }
            _handleNotificationTap(context, notification);
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'RECIPE_PROMOTED_TO_OFFICIAL':
        if (notification.payload != null &&
            notification.payload!['recipeId'] != null) {
          // Navigate to recipe detail
          // context.go('/recipes/${notification.payload!['recipeId']}');
          print('Navigate to recipe: ${notification.payload!['recipeId']}');
        }
        break;
      case 'COMMENT_RECEIVED':
      case 'RATING_RECEIVED':
        if (notification.payload != null &&
            notification.payload!['recipeId'] != null) {
          // Navigate to recipe detail
          print('Navigate to recipe: ${notification.payload!['recipeId']}');
        }
        break;
      case 'ACCOUNT_BLOCKED':
      case 'ACCOUNT_UNBLOCKED':
        // Show dialog or navigate to account page
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        break;
      default:
        print('Unhandled notification type: ${notification.type}');
    }
  }
}
