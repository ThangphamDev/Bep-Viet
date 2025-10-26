import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bepviet_mobile/data/models/notification_model.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String)? onNotificationTap;

  /// Initialize push notifications
  Future<void> initialize({Function(String)? onNotificationTap}) async {
    if (_isInitialized) return;

    this.onNotificationTap = onNotificationTap;

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          this.onNotificationTap?.call(response.payload!);
        }
      },
    );

    // Request permissions for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
    print('✅ Push Notifications initialized');
  }

  /// Show notification from NotificationModel
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      print('⚠️ Push Notifications not initialized');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'bepviet_notifications',
      'Bếp Việt Notifications',
      channelDescription: 'Notifications from Bếp Việt app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        notification.body,
        contentTitle: notification.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: notification.id,
    );

    print('📬 Push notification shown: ${notification.title}');
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
