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

            // Get actual widget dimensions
            try {
                val options = appWidgetManager.getAppWidgetOptions(widgetId)
                val minW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 400)
                val minH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 200)

                // Save dimensions for Dart renderer
                val editor = widgetData.edit()
                editor.putInt("widget_width", minW)
                editor.putInt("widget_height", minH)
                editor.apply()

                // Dynamic font size based on width
                val fontSizePx = (minW * 0.15f).coerceIn(30f, 120f)

                // Dynamic margins: 5% horizontal, 5.5% vertical
                val marginStartPx = (minW * 0.05f).toInt()
                val marginTopPx = (minH * 0.055f).toInt()

                // setTextSize via reflection
                val setTextSize = RemoteViews::class.java.getMethod(
                    "setTextSize",
                    Int::class.javaPrimitiveType,
                    Int::class.javaPrimitiveType,
                    Float::class.javaPrimitiveType
                )
                setTextSize.invoke(views, R.id.native_time, TypedValue.COMPLEX_UNIT_PX, fontSizePx)

                // setViewLayoutMargin via reflection (API 31+)
                try {
                    val setViewLayoutMargin = RemoteViews::class.java.getMethod(
                        "setViewLayoutMargin",
                        Int::class.javaPrimitiveType,
                        Int::class.javaPrimitiveType,
                        Float::class.javaPrimitiveType,
                        Int::class.javaPrimitiveType
                    )
                    val absolute = 1
                    setViewLayoutMargin.invoke(views, R.id.native_time, 0, marginStartPx.toFloat(), absolute)
                    setViewLayoutMargin.invoke(views, R.id.native_time, 1, marginTopPx.toFloat(), absolute)
                } catch (_: Exception) {}
            } catch (e: Exception) {
                Log.w("ZTimeWidget", "Dynamic sizing failed", e)
            }

            // Calendar tap → open system calendar
            try {
                val calendarIntent = Intent(Intent.ACTION_VIEW).apply {
                    data = CalendarContract.CONTENT_URI
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, calendarIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                views.setOnClickPendingIntent(R.id.widget_image, pendingIntent)
            } catch (e: Exception) {
                Log.w("ZTimeWidget", "Calendar PendingIntent failed", e)
            }

            // Load Flutter-rendered background
            val filePath = widgetData.getString("widget_png", null)
            if (filePath == null) {
                Log.w("ZTimeWidget", "No widget_png path")
            } else {
                try {
                    val file = File(filePath)
                    if (!file.exists()) {
                        Log.w("ZTimeWidget", "PNG not found: $filePath")
                    } else {
                        val bitmap = BitmapFactory.decodeFile(filePath)
                        if (bitmap == null) {
                            Log.e("ZTimeWidget", "decodeFile null: $filePath")
                        } else {
                            views.setImageViewBitmap(R.id.widget_image, bitmap)
                            val wPx = bitmap.width
                            val hPx = bitmap.height
                            Log.d("ZTimeWidget", "PNG ${wPx}x${hPx}")
                        }
                    }
                } catch (e: Exception) {
                    Log.e("ZTimeWidget", "Load image failed", e)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
