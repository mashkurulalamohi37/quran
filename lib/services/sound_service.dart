import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/services/settings_service.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('com.banglaquran.quran/sound_mode');

  Timer? _autoTimer;
  bool _isMutedByApp = false;

  /// Check if DND permission is granted. Required for Android 6.0+ to set Silent.
  static Future<bool> checkDndPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('checkDndPermission');
      return granted;
    } catch (_) {
      return true;
    }
  }

  /// Open DND access settings.
  static Future<void> openDndSettings() async {
    try {
      await _channel.invokeMethod('openDndSettings');
    } catch (_) {}
  }

  /// Set Ringer Mode: 0 = Silent, 1 = Vibrate, 2 = Normal.
  static Future<void> setRingerMode(int mode) async {
    try {
      await _channel.invokeMethod('setRingerMode', {'mode': mode});
    } catch (_) {}
  }

  /// Get current Ringer Mode: 0 = Silent, 1 = Vibrate, 2 = Normal.
  static Future<int> getRingerMode() async {
    try {
      final int mode = await _channel.invokeMethod('getRingerMode');
      return mode;
    } catch (_) {
      return 2; // Default Normal
    }
  }

  /// Start automatic monitoring timer (runs every 60 seconds)
  void startMonitoring(SettingsService settings) {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      checkAndApplySilentMode(settings);
    });
    // Run immediately
    checkAndApplySilentMode(settings);
  }

  /// Stop monitoring timer
  void stopMonitoring() {
    _autoTimer?.cancel();
  }

  /// Evaluates location/time constraints and mutes/unmutes the device accordingly.
  Future<void> checkAndApplySilentMode(SettingsService settings) async {
    if (settings.silentModeType == 'none') {
      if (_isMutedByApp) {
        await setRingerMode(2); // Restore to Normal
        _isMutedByApp = false;
      }
      return;
    }

    final hasDnd = await checkDndPermission();
    if (!hasDnd) return; // Cannot mute without permission

    bool shouldMute = false;

    if (settings.silentModeType == 'gps' && settings.hasMosqueRegistered) {
      final pos = await PrayerService.getPosition();
      if (pos != null) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          settings.mosqueLat,
          settings.mosqueLng,
        );
        if (dist <= settings.mosqueRadius) {
          shouldMute = true;
        }
      }
    } else if (settings.silentModeType == 'time') {
      // Calculate coordinates for prayer times
      double lat = 23.8103;
      double lng = 90.4125;
      if (settings.isAutomaticLocation) {
        final pos = await PrayerService.getPosition();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        } else {
          final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
          lat = dist.latitude;
          lng = dist.longitude;
        }
      } else {
        final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
        lat = dist.latitude;
        lng = dist.longitude;
      }

      final prayers = PrayerService.calculate(
        lat: lat,
        lng: lng,
        method: settings.calculationMethod,
        madhab: settings.madhab,
      );

      final now = DateTime.now();
      // We check Dhuhr, Asr, Maghrib, Isha, and Fajr
      final timesToCheck = [
        prayers.fajr.time,
        prayers.dhuhr.time,
        prayers.asr.time,
        prayers.maghrib.time,
        prayers.isha.time,
      ];

      for (final t in timesToCheck) {
        final end = t.add(Duration(minutes: settings.silentDuration));
        if (now.isAfter(t) && now.isBefore(end)) {
          shouldMute = true;
          break;
        }
      }
    }

    if (shouldMute) {
      if (!_isMutedByApp) {
        final currentRinger = await getRingerMode();
        if (currentRinger == 2) { // Only mute if currently Normal
          await setRingerMode(0); // Set to Silent
          _isMutedByApp = true;
        }
      }
    } else {
      if (_isMutedByApp) {
        await setRingerMode(2); // Restore Normal
        _isMutedByApp = false;
      }
    }
  }
}
