package com.afnanquran.app;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Build;
import android.provider.Settings;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.afnanquran.app/sound_mode";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

                switch (call.method) {
                    case "checkDndPermission":
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(notificationManager.isNotificationPolicyAccessGranted());
                        } else {
                            result.success(true);
                        }
                        break;
                    case "openDndSettings":
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Intent intent = new Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS);
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intent);
                            result.success(true);
                        } else {
                            result.success(false);
                        }
                        break;
                    case "setRingerMode":
                        Integer mode = call.argument("mode");
                        if (mode != null) {
                            try {
                                if (mode == 0) {
                                    audioManager.setRingerMode(AudioManager.RINGER_MODE_SILENT);
                                } else if (mode == 1) {
                                    audioManager.setRingerMode(AudioManager.RINGER_MODE_VIBRATE);
                                } else {
                                    audioManager.setRingerMode(AudioManager.RINGER_MODE_NORMAL);
                                }
                                result.success(true);
                            } catch (SecurityException e) {
                                result.error("SECURITY_EXCEPTION", "Permission not granted for Do Not Disturb settings", null);
                            }
                        } else {
                            result.error("INVALID_ARGUMENTS", "Mode argument cannot be null", null);
                        }
                        break;
                    case "getRingerMode":
                        int currentMode = audioManager.getRingerMode();
                        if (currentMode == AudioManager.RINGER_MODE_SILENT) {
                            result.success(0);
                        } else if (currentMode == AudioManager.RINGER_MODE_VIBRATE) {
                            result.success(1);
                        } else {
                            result.success(2);
                        }
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }
}
