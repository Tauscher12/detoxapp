package com.example.detoxapp

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.Context
import android.os.Build
import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageStats" -> {
                    val stats = getUsageStats()
                    result.success(stats)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageAccessPermission(): Boolean {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStats(): String {
        if (!hasUsageAccessPermission()) {
            return "Berechtigung nicht erteilt. Bitte aktivieren Sie die Berechtigung in den Einstellungen."
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 24 * 60 * 60 * 1000 // Letzte 24 Stunden
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        if (usageStatsList.isNullOrEmpty()) {
            return "Keine Daten verfügbar."
        }

        val dateFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        val result = StringBuilder()
        for (stats in usageStatsList) {
            if (stats.getLastTimeVisible()!=0L&&!isSystemApp(stats.packageName)) {
                println(isSystemApp(stats.packageName))
                result.append("App: ${stats.packageName};")
                result.append("Nutzungsdauer: ${stats.totalTimeInForeground / 1000}s;")
                result.append("------")
            }
        }
        return result.toString()
    }
   

private fun isSystemApp(packageName: String): Boolean {
    return try {
        val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
        val appInfo: ApplicationInfo? = packageInfo.applicationInfo
        appInfo?.flags?.and(ApplicationInfo.FLAG_SYSTEM) != 0
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }
}

}