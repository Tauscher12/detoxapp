
import android.content.Intent
import android.provider.Settings
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.os.Process
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*

class UsageStatsHelper(private val context: Context) {

    fun hasUsageAccessPermission(): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
    

    fun getUsageStats(): String {
        if (!hasUsageAccessPermission()) {
            return "Berechtigung nicht erteilt. Bitte aktivieren Sie die Berechtigung in den Einstellungen."
        }

        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        var startTime=calendar.timeInMillis
        var endTime=startTime+1000*60*60*24


        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val dateFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        val result = StringBuilder()
        for (stats in usageStatsList) {
           
            if (stats.getLastTimeVisible() != 0L && stats.totalTimeInForeground > 0) {
                result.append("App: ${stats.packageName}; Nutzungsdauer: ${stats.totalTimeInForeground / 1000}s;Date: ${startTime};------")
            }
        }
        return result.toString()
    }

    fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val icon = context.packageManager.getApplicationIcon(packageName)
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
            val packageInfo = context.packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
            val appInfo: ApplicationInfo? = packageInfo.applicationInfo
            appInfo?.flags?.and(ApplicationInfo.FLAG_SYSTEM) != 0
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}