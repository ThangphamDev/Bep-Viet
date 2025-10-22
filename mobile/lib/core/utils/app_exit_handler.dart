import 'dart:io';
import 'package:flutter/services.dart';

/// Handler để thoát app hoàn toàn
class AppExitHandler {
  static const MethodChannel _channel = MethodChannel('app_exit');

  /// Thoát app hoàn toàn (kill process)
  static Future<void> exitApp() async {
    try {
      if (Platform.isAndroid) {
        // Android: Kill app process
        await _channel.invokeMethod('exitApp');
      } else if (Platform.isIOS) {
        // iOS: Không cho phép force exit, chỉ minimize
        SystemNavigator.pop();
      } else {
        // Desktop/Web: Exit process
        exit(0);
      }
    } catch (e) {
      print('Error exiting app: $e');
      // Fallback: Force exit
      exit(0);
    }
  }
}

