import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:bepviet_mobile/core/config/app_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect to WebSocket server
  void connect(String accessToken) {
    if (_socket?.connected == true) {
      print('🔌 WebSocket already connected');
      return;
    }

    final url = AppConfig.ngrokBaseUrl.replaceAll('/api', '');

    print('🔌 Connecting to WebSocket: $url/notifications');

    _socket = IO.io(
      '$url/notifications',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': 'Bearer $accessToken'})
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ WebSocket connected');
    });

    _socket!.onDisconnect((_) {
      print('🔌 WebSocket disconnected');
    });

    _socket!.onConnectError((error) {
      print('❌ WebSocket connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ WebSocket error: $error');
    });

    // Listen for connection confirmation
    _socket!.on('connected', (data) {
      print('📢 Connection confirmed: $data');
    });

    // Listen for notifications
    _socket!.on('notification', (data) {
      print('📩 Received notification: $data');
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });

    // Listen for broadcasts
    _socket!.on('broadcast', (data) {
      print('📢 Received broadcast: $data');
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });

    _socket!.connect();
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    if (_socket?.connected == true) {
      print('🔌 Disconnecting WebSocket');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    }
  }

  /// Subscribe to notifications
  void subscribe() {
    if (_socket?.connected == true) {
      _socket!.emit('subscribe');
      print('📬 Subscribed to notifications');
    } else {
      print('❌ Cannot subscribe: Not connected');
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getHistory() async {
    if (_socket?.connected != true) {
      print('❌ Cannot get history: Not connected');
      return [];
    }

    try {
      final completer = Completer<List<Map<String, dynamic>>>();

      _socket!.emitWithAck(
        'get_history',
        null,
        ack: (data) {
          if (data != null && data is Map && data['success'] == true) {
            final notifications =
                (data['notifications'] as List?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];
            completer.complete(notifications);
          } else {
            completer.complete([]);
          }
        },
      );

      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Get history timeout');
          return [];
        },
      );
    } catch (e) {
      print('❌ Error getting history: $e');
      return [];
    }
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    if (_socket?.connected == true) {
      _socket!.emit('mark_read', {'notificationId': notificationId});
      print('✅ Marked notification as read: $notificationId');
    }
  }

  /// Reconnect with new token
  void reconnect(String newAccessToken) {
    disconnect();
    Future.delayed(const Duration(milliseconds: 500), () {
      connect(newAccessToken);
    });
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
