package com.banglaquran.quran;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.appwidget.AppWidgetManager;
import android.widget.RemoteViews;
import es.antonborri.home_widget.HomeWidgetProvider;

public class PrayerWidgetProvider extends HomeWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds, SharedPreferences widgetData) {
        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.prayer_widget);

            // Fetch values sent from Flutter
            String hijriDate = widgetData.getString("hijri_date", "—");
            String prayerName = widgetData.getString("prayer_name", "—");
            String prayerTime = widgetData.getString("prayer_time", "—");
            String countdown = widgetData.getString("countdown", "");

            views.setTextViewText(R.id.widget_hijri_date, hijriDate);
            views.setTextViewText(R.id.widget_prayer_name, prayerName);
            views.setTextViewText(R.id.widget_prayer_time, prayerTime);
            views.setTextViewText(R.id.widget_countdown, countdown);

            // Setup click intent to open the app (standard Android PendingIntent)
            Intent intent = new Intent(context, MainActivity.class);
            PendingIntent pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent);

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}
