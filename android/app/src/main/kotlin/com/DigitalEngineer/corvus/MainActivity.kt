package com.DigitalEngineer.corvus

import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.security.channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "preventScreenshots") {
                val prevent = call.argument<Boolean>("prevent") ?: false
                if (prevent) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else if (call.method == "isUsbDebuggingEnabled") {
                val adbEnabled = Settings.Global.getInt(contentResolver, Settings.Global.ADB_ENABLED, 0)
                result.success(adbEnabled == 1)
            } else {
                result.notImplemented()
            }
        }
    }
}
