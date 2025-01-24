package com.example.detoxapp



import UsageStatsHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.app.AppOpsManager


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val usageStatsHelper=UsageStatsHelper(this)

    fun checkUsageStatsPermission():Boolean {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
    )

        if (mode != AppOpsManager.MODE_ALLOWED) {
            // Wenn Berechtigung nicht gewährt wurde, den Benutzer zu den Einstellungen weiterleiten
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
            
        }
        if(mode==AppOpsManager.MODE_ALLOWED){
            return true
        }
        else return false 
        
    }



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
                "getPermission"->{
                   result.success(checkUsageStatsPermission())
                }
                else -> result.notImplemented()
            }
        }
    }
}
