import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/models/notification_model.dart';
import 'package:bepviet_mobile/data/sources/remote/websocket_service.dart';
import 'package:bepviet_mobile/data/sources/local/push_notification_service.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final WebSocketService _webSocketService;
  final PushNotificationService _pushNotificationService;
  StreamSubscription? _notificationSubscription;

  NotificationsCubit({
    required WebSocketService webSocketService,
    required PushNotificationService pushNotificationService,
  }) : _webSocketService = webSocketService,
       _pushNotificationService = pushNotificationService,
       super(const NotificationsInitial()) {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationSubscription = _webSocketService.notificationStream.listen((
      data,
    ) {
      try {
        final notification = NotificationModel.fromJson(data);
        _addNotification(notification);
      } catch (e) {
        print('Error parsing notification: $e');
      }
    });
  }

  void _addNotification(NotificationModel notification) {
    final currentState = state;

    // Show push notification
    _pushNotificationService.showNotification(notification);

    if (currentState is NotificationsLoaded) {
      final updatedList = [notification, ...currentState.notifications];
      final unreadCount = updatedList.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: updatedList,
          unreadCount: unreadCount,
        ),
      );
    } else {
      emit(
        NotificationsLoaded(
          notifications: [notification],
          unreadCount: notification.isRead ? 0 : 1,
        ),
      );
    }
  }

  void loadNotifications(List<NotificationModel> notifications) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    emit(
      NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ),
    );
  }

  Future<void> fetchHistory() async {
    try {
      final historyData = await _webSocketService.getHistory();
      final notifications = historyData
          .map((data) {
            try {
              return NotificationModel.fromJson(data);
            } catch (e) {
              print('Error parsing notification: $e');
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();

      loadNotifications(notifications);
      print('✅ Loaded ${notifications.length} notifications from history');
    } catch (e) {
      print('❌ Error fetching notification history: $e');
    }
  }

  void markAsRead(String notificationId) {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      final unreadCount = updatedList.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: updatedList,
          unreadCount: unreadCount,
        ),
      );

      // Notify server
      _webSocketService.markAsRead(notificationId);
    }
  }

  void markAllAsRead() {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      emit(NotificationsLoaded(notifications: updatedList, unreadCount: 0));
    }
  }

  void removeNotification(String notificationId) {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final unreadCount = updatedList.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: updatedList,
          unreadCount: unreadCount,
        ),
      );
    }
  }

  void clearAll() {
    emit(const NotificationsLoaded(notifications: [], unreadCount: 0));
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
