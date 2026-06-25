package com.gosayram.ztime_widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
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

            // home_widget.saveFile() stores the file path string, not Base64.
            val filePath = widgetData.getString("widget_png", null)
            if (filePath != null) {
                try {
                    val file = File(filePath)
                    if (file.exists()) {
                        val bitmap = BitmapFactory.decodeFile(filePath)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                        }
                    }
                } catch (_: Exception) {
                    // Fallback: show empty widget
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
