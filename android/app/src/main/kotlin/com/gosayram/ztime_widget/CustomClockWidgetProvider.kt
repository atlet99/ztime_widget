package com.gosayram.ztime_widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.util.Base64
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CustomClockWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.custom_clock_widget)

            val imageBase64 = widgetData.getString("widget_png", null)
            if (imageBase64 != null) {
                try {
                    val imageBytes = Base64.decode(imageBase64, Base64.DEFAULT)
                    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                } catch (_: Exception) {
                    // Fallback: show empty widget
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
