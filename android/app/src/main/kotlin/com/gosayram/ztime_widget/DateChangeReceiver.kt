package com.gosayram.ztime_widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

/**
 * Listens for system time ticks (every minute) and detects day changes.
 * When the day changes, stores a flag in SharedPreferences so the Flutter
 * side can re-render the widget PNG on next resume.
 *
 * This solves Use Case 2 (midnight rollover) without draining battery —
 * the receiver only fires once per minute and does minimal work.
 */
class DateChangeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_TIME_TICK) return

        val prefs = context.getSharedPreferences("ztime_widget_prefs", Context.MODE_PRIVATE)
        val today = java.text.SimpleDateFormat("yyyy-M-d", java.util.Locale.US).format(java.util.Date())
        val lastDate = prefs.getString("last_rendered_date", "")

        if (today != lastDate) {
            // Day changed — store flag so Flutter can re-render on next resume
            prefs.edit().putString("last_rendered_date", today).apply()
        }
    }

    companion object {
        /** Check if the widget needs re-rendering (day changed since last render). */
        fun needsRerender(context: Context): Boolean {
            val prefs = context.getSharedPreferences("ztime_widget_prefs", Context.MODE_PRIVATE)
            val today = java.text.SimpleDateFormat("yyyy-M-d", java.util.Locale.US).format(java.util.Date())
            val lastDate = prefs.getString("last_rendered_date", "")
            return today != lastDate
        }

        /** Mark the current date as rendered. */
        fun markRendered(context: Context) {
            val prefs = context.getSharedPreferences("ztime_widget_prefs", Context.MODE_PRIVATE)
            val today = java.text.SimpleDateFormat("yyyy-M-d", java.util.Locale.US).format(java.util.Date())
            prefs.edit().putString("last_rendered_date", today).apply()
        }
    }
}
