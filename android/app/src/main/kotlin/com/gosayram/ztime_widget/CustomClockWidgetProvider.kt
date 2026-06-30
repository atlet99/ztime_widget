package com.gosayram.ztime_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Bundle
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
            renderWidget(context, appWidgetManager, widgetId, widgetData)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        newOptions: Bundle
    ) {
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            .let { sp ->
                val editor = sp.edit()
                saveDimensions(newOptions, editor)
                editor.apply()
                sp
            }
        renderWidget(context, appWidgetManager, widgetId, widgetData)
    }

    private fun saveDimensions(options: Bundle, editor: SharedPreferences.Editor) {
        val maxW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 0)
        val maxH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
        val minW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 400)
        val minH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 200)

        // Use MAX (actual allocated size) when available, fall back to MIN
        val widgetW = if (maxW > 0) maxW else minW
        val widgetH = if (maxH > 0) maxH else minH

        editor.putInt("widget_width", widgetW)
        editor.putInt("widget_height", widgetH)
    }

    private fun renderWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.custom_clock_widget)

        // Get actual widget dimensions
        try {
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val editor = widgetData.edit()
            saveDimensions(options, editor)
            editor.apply()

            val maxW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 0)
            val maxH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
            val minW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 400)
            val minH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 200)
            val widgetW = if (maxW > 0) maxW else minW
            val widgetH = if (maxH > 0) maxH else minH

            // Dynamic font size based on width
            val fontSizePx = (widgetW * 0.15f).coerceIn(30f, 120f)

            // Dynamic margins: 5% horizontal, 5.5% vertical
            val marginStartPx = (widgetW * 0.05f).toInt()
            val marginTopPx = (widgetH * 0.055f).toInt()

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

        // Calendar tap → open system calendar at today's date
        try {
            val todayStart = java.util.Calendar.getInstance().apply {
                set(java.util.Calendar.HOUR_OF_DAY, 0)
                set(java.util.Calendar.MINUTE, 0)
                set(java.util.Calendar.SECOND, 0)
                set(java.util.Calendar.MILLISECOND, 0)
            }.timeInMillis

            val calendarIntent = Intent(Intent.ACTION_VIEW).apply {
                data = CalendarContract.CONTENT_URI
                putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, todayStart)
                putExtra(CalendarContract.EXTRA_EVENT_END_TIME, todayStart + 86400000)
                putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, true)
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
                        Log.d("ZTimeWidget", "PNG ${bitmap.width}x${bitmap.height}")
                    }
                }
            } catch (e: Exception) {
                Log.e("ZTimeWidget", "Load image failed", e)
            }
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
