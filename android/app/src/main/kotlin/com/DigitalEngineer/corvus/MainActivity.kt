package com.DigitalEngineer.corvus

import android.view.WindowManager
import android.os.Handler
import android.os.Looper
import android.os.Debug
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.security.channel"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL, StandardMethodCodec.INSTANCE)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "preventScreenshots" -> {
                    val prevent = call.argument<Boolean>("prevent") ?: false
                    Handler(Looper.getMainLooper()).post {
                        if (prevent) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(true)
                }
                "isUsbDebuggingEnabled" -> {
                    val isDebug = Debug.isDebuggerConnected()
                    result.success(isDebug)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }
}