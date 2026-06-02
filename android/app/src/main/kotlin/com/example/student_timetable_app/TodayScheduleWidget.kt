package com.example.student_timetable_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

/**
 * Android Home Screen Widget that displays today's schedule.
 * Data is pushed from Flutter via home_widget package.
 */
class TodayScheduleWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is placed
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"

        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences =
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val title = prefs.getString("widget_title", "Lịch học hôm nay") ?: "Lịch học hôm nay"
            val date = prefs.getString("widget_date", "") ?: ""
            val schedule = prefs.getString("widget_schedule", "Đang tải...") ?: "Đang tải..."

            val views = RemoteViews(context.packageName, R.layout.widget_today_schedule)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_schedule, schedule)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
