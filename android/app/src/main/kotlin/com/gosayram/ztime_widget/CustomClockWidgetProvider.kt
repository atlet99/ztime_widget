package com.gosayram.ztime_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.provider.CalendarContract
import android.util.Log
import android.util.TypedValue
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

            // Rule 4: Dynamic font size based on widget width
            try {
                val options = appWidgetManager.getAppWidgetOptions(widgetId)
                val minW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 400)
                val fontSizePx = (minW * 0.15f).coerceIn(40f, 120f)

                // setTextSize via reflection (API 31+ native, reflection for older)
                val setTextSize = RemoteViews::class.java.getMethod(
                    "setTextSize",
                    Int::class.javaPrimitiveType,
                    Int::class.javaPrimitiveType,
                    Float::class.javaPrimitiveType
                )
                setTextSize.invoke(views, R.id.native_time, TypedValue.COMPLEX_UNIT_PX, fontSizePx)
            } catch (e: Exception) {
                Log.w("ZTimeWidget", "Dynamic sizing failed, using XML defaults", e)
            }

            // Calendar tap → open system calendar (on the whole widget area)
            try {
                val calendarIntent = Intent(Intent.ACTION_VIEW).apply {
                    data = CalendarContract.CONTENT_URI
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    calendarIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                views.setOnClickPendingIntent(R.id.widget_image, pendingIntent)
            } catch (e: Exception) {
                Log.w("ZTimeWidget", "Calendar PendingIntent failed", e)
            }

            // Load Flutter-rendered background
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
