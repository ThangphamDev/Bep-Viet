package com.bepviet.app.mobile

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "app_exit"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "exitApp") {
                // Kill app process completely
                finishAffinity()
                exitProcess(0)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
