package com.example.detoxapp

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.graphics.drawable.BitmapDrawable
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream
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
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val iconData = getAppIcon(packageName)
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

    private fun hasUsageAccessPermission(): Boolean {
        val appOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
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

        val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 24 * 60 * 60 * 1000 // Letzte 24 Stunden
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val dateFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        val result = StringBuilder()
        for (stats in usageStatsList) {
            println("App: ${stats.packageName}; Nutzungsdauer: ${stats.totalTimeInForeground / 1000}s ${stats.getLastTimeVisible()} ${isSystemApp(stats.packageName)}" )

            if (stats.getLastTimeVisible() != 0L&&stats.totalTimeInForeground >0) {
                result.append("App: ${stats.packageName}; Nutzungsdauer: ${stats.totalTimeInForeground / 1000}s;------")
            }
        }
        return result.toString()
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val icon = packageManager.getApplicationIcon(packageName)
            when (icon) {
                is AdaptiveIconDrawable -> {
                    // Convert AdaptiveIconDrawable to Bitmap
                    val bitmap = Bitmap.createBitmap(icon.intrinsicWidth, icon.intrinsicHeight, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    icon.setBounds(0, 0, canvas.width, canvas.height)
                    icon.draw(canvas)
                    bitmapToByteArray(bitmap)
                }
                is BitmapDrawable -> {
                    bitmapToByteArray(icon.bitmap)
                }
                else -> null
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun bitmapToByteArray(bitmap: Bitmap): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
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
