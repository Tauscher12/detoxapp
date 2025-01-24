package com.example.detoxapp

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable

class AppInfoFetcher(private val context: Context) {

    fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = context.packageManager
        val apps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        val appList = mutableListOf<Map<String, Any?>>()

        for (app in apps) {
            val appInfo = mutableMapOf<String, Any?>()
            appInfo["appName"] = app.loadLabel(packageManager).toString()
            appInfo["packageName"] = app.packageName

            try {
                val icon: Drawable = app.loadIcon(packageManager)
                val bitmap = (icon as BitmapDrawable).bitmap
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                appInfo["icon"] = stream.toByteArray()
            } catch (e: Exception) {
                appInfo["icon"] = null
            }

            appList.add(appInfo)
        }
        return appList
    }
}
