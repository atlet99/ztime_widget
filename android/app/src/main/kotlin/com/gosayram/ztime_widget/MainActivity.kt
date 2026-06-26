package com.gosayram.ztime_widget

import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.gosayram.ztime_widget/date_change"
    private var receiver: DateChangeReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Check if day changed while app was closed, notify Flutter immediately
        if (DateChangeReceiver.needsRerender(this)) {
            flutterEngine.dartExecutor.binaryMessenger.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onDayChanged", null)
            }
        }

        // MethodChannel: Flutter ←→ Kotlin
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "markRendered" -> {
                        DateChangeReceiver.markRendered(this)
                        result.success(null)
                    }
                    "needsRerender" -> {
                        result.success(DateChangeReceiver.needsRerender(this))
                    }
                    else -> result.notImplemented()
                }
            }

        // Register BroadcastReceiver for ACTION_TIME_TICK
        receiver = DateChangeReceiver()
        val filter = IntentFilter(Intent.ACTION_TIME_TICK)
        registerReceiver(receiver, filter)
    }

    override fun onDestroy() {
        receiver?.let { unregisterReceiver(it) }
        super.onDestroy()
    }
}
