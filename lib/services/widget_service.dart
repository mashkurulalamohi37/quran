import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/services/prayer_service.dart';

class WidgetService {
  static const List<String> _hijriMonthsBengali = [
    'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
    'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান',
    'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
  ];

  static String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return "$h:$m $suffix";
  }

  /// Calculates the next prayer and updates the home widget.
  static Future<void> updateWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read location settings from SharedPreferences (same keys as SettingsService)
      final isAuto = prefs.getBool('isAutomaticLocation') ?? false;
      final distName = prefs.getString('selectedDistrict') ?? 'ঢাকা';
      final calcMethod = prefs.getString('calculationMethod') ?? 'KARACHI';
      final madhab = prefs.getString('madhab') ?? 'HANAFI';
      final cachedLat = prefs.getDouble('cachedLatitude');
      final cachedLng = prefs.getDouble('cachedLongitude');

      double lat = 23.8103;
      double lng = 90.4125;

      if (isAuto && cachedLat != null && cachedLng != null) {
        lat = cachedLat;
        lng = cachedLng;
      } else {
        final dist = PrayerService.getDistrictByName(distName);
        lat = dist.latitude;
        lng = dist.longitude;
      }

      final prayers = PrayerService.calculate(
        lat: lat,
        lng: lng,
        method: calcMethod,
        madhab: madhab,
      );

      final now = DateTime.now();

      // Find the next upcoming prayer
      PrayerInfo? next;
      // We look at today's prayers
      for (final p in prayers.all) {
        if (p.time.isAfter(now)) {
          next = p;
          break;
        }
      }

      // If all of today's prayers passed, the next is tomorrow's Fajr
      if (next == null) {
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayers = PrayerService.calculate(
          lat: lat,
          lng: lng,
          method: calcMethod,
          madhab: madhab,
          date: tomorrow,
        );
        next = tomorrowPrayers.fajr;
      }

      // ── Calculate Hijri date ──
      final hijri = HijriCalendar.fromDate(now);
      final hijriStr = "${_toBengaliNum(hijri.hDay)} ${_hijriMonthsBengali[hijri.hMonth - 1]} ${_toBengaliNum(hijri.hYear)} হিজরি";

      // ── Formulate countdown ──
      final diff = next.time.difference(now);
      String countdownStr = "";
      if (diff.inHours > 0) {
        countdownStr = "${_toBengaliNum(diff.inHours)} ঘণ্টা ${_toBengaliNum(diff.inMinutes % 60)} মিনিট বাকি";
      } else {
        countdownStr = "${_toBengaliNum(diff.inMinutes)} মিনিট বাকি";
      }

      // Save data for the android widget
      await HomeWidget.saveWidgetData<String>('hijri_date', hijriStr);
      await HomeWidget.saveWidgetData<String>('prayer_name', next.banglaName);
      await HomeWidget.saveWidgetData<String>('prayer_time', _fmtTime(next.time));
      await HomeWidget.saveWidgetData<String>('countdown', countdownStr);

      // Trigger native widget rebuild
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetProvider',
        androidName: 'PrayerWidgetProvider',
      );
      if (kDebugMode) {
        print("Home screen widget updated successfully: ${next.banglaName} at ${_fmtTime(next.time)}");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("Failed to update widget: $e\n$stack");
      }
    }
  }
}
