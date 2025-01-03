package com.example.detoxapp



import UsageStatsHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val usageStatsHelper=UsageStatsHelper(this)



        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageStats" -> {
                    val stats = usageStatsHelper.getUsageStats()
                    result.success(stats)
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val iconData = usageStatsHelper.getAppIcon(packageName)
                        if (iconData != null) {
                            result.success(iconData)
                        } else {
                            result.error("UNAVAILABLE", "Icon not available.", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is null.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
