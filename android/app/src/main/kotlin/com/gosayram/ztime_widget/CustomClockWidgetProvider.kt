package com.gosayram.ztime_widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class CustomClockWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.custom_clock_widget)

            val filePath = widgetData.getString("widget_png", null)
            if (filePath == null) {
                Log.w("ZTimeWidget", "No widget_png path in SharedPreferences")
            } else {
                try {
                    val file = File(filePath)
                    if (!file.exists()) {
                        Log.w("ZTimeWidget", "PNG file not found: $filePath")
                    } else {
                        val bitmap = BitmapFactory.decodeFile(filePath)
                        if (bitmap == null) {
                            Log.e("ZTimeWidget", "BitmapFactory.decodeFile returned null for: $filePath")
                        } else {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                            Log.d("ZTimeWidget", "Loaded PNG ${bitmap.width}x${bitmap.height}")
                        }
                    }
                } catch (e: Exception) {
                    Log.e("ZTimeWidget", "Failed to load widget image", e)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
