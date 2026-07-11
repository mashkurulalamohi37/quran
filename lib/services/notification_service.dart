import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification IDs for each prayer
class PrayerNotifId {
  static const fajr = 101;
  static const dhuhr = 102;
  static const asr = 103;
  static const maghrib = 104;
  static const isha = 105;
  static const dailyQuran = 1;
}

class PrayerNotif {
  final int id;
  final String bangla;
  final String emoji;
  final String title;
  final String body;
  final String warning; // কবরের আজাব reminder

  const PrayerNotif({
    required this.id,
    required this.bangla,
    required this.emoji,
    required this.title,
    required this.body,
    required this.warning,
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'salah_reminders';
  static const _channelName = 'নামাজের রিমাইন্ডার';
  static const _channelDesc = 'পাঁচ ওয়াক্ত নামাজের সময়ে অনুস্মারক';

  static const _dailyChannelId = 'quran_daily';
  static const _dailyChannelName = 'Daily Quran Reminder';

  /// Prayer info with Islamic motivational messages
  static const List<PrayerNotif> _prayers = [
    PrayerNotif(
      id: PrayerNotifId.fajr,
      bangla: 'ফজর',
      emoji: '🌅',
      title: '🌅 ফজরের নামাজের সময় হয়েছে',
      body: 'الصَّلَاةُ خَيْرٌ مِّنَ النَّوْمِ\nনামাজ ঘুমের চেয়ে উত্তম। উঠুন, আল্লাহর ডাকে সাড়া দিন।',
      warning:
          'যে ফজরের নামাজ ছেড়ে দেয়, কবরে তার উপর শাস্তি নামে। আল্লাহকে ভয় করুন।',
    ),
    PrayerNotif(
      id: PrayerNotifId.dhuhr,
      bangla: 'যোহর',
      emoji: '🕌',
      title: '🕌 যোহরের নামাজের সময় হয়েছে',
      body: 'নামাজ কায়েম করুন। আল্লাহ্ তায়ালার ডাকে সাড়া দিন।',
      warning:
          'কবরের আজাব থেকে বাঁচতে নামাজ পড়ুন। নামাজ কবরে ঢাল হয়ে দাঁড়াবে।',
    ),
    PrayerNotif(
      id: PrayerNotifId.asr,
      bangla: 'আসর',
      emoji: '☀️',
      title: '☀️ আসরের নামাজের সময় হয়েছে',
      body: 'আসরের নামাজ রক্ষা করুন — এটি মধ্যবর্তী নামাজ। (সূরা বাকারা: ২৩৮)',
      warning:
          'যে আসরের নামাজ ছেড়ে দেয়, তার আমল নষ্ট হয়ে যায়। সাবধান হোন।',
    ),
    PrayerNotif(
      id: PrayerNotifId.maghrib,
      bangla: 'মাগরিব',
      emoji: '🌇',
      title: '🌇 মাগরিবের নামাজের সময় হয়েছে',
      body: 'সূর্য অস্ত গেছে। মাগরিব পড়ার সময় সংক্ষিপ্ত — দেরি করবেন না।',
      warning:
          'নামাজ কবরে আলো ছড়ায়। যে নামাজ পড়ে না তার কবর অন্ধকারে ডুবে যায়।',
    ),
    PrayerNotif(
      id: PrayerNotifId.isha,
      bangla: 'এশা',
      emoji: '🌙',
      title: '🌙 এশার নামাজের সময় হয়েছে',
      body: 'দিনের শেষ নামাজ। এশা ও ফজর মুনাফিকদের উপর সবচেয়ে কঠিন।',
      warning:
          'রাসূল (সাঃ) বলেছেন: কবরের প্রথম রাতটি সবচেয়ে কঠিন। নামাজ সেই রাতে সঙ্গী।',
    ),
  ];

  /// Daily Ayah pool — shown in rotation based on day of year
  static const List<String> _ayahs = [
    'নিশ্চয়ই কষ্টের সাথে স্বস্তি আছে। — সূরা আশ-শারহ: ৬',
    'আল্লাহ্ কোনো আত্মাকে তার সাধ্যের বাইরে ভার দেন না। — সূরা বাকারা: ২৮৬',
    'তোমরা আল্লাহকে স্মরণ করো, তিনি তোমাদের স্মরণ করবেন। — সূরা বাকারা: ১৫২',
    'নিশ্চয়ই আল্লাহ ধৈর্যশীলদের সাথে আছেন। — সূরা বাকারা: ১৫৩',
    'যে আল্লাহর উপর ভরসা করে, আল্লাহই তার জন্য যথেষ্ট। — সূরা তালাক: ৩',
  ];

  // ── Initialization ──────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ── Prayer Notifications ────────────────────────────────────────────────────

  /// Schedule all enabled prayer notifications.
  /// [prayerTimes] is a map of prayer name key → DateTime.
  /// [enabledMap] is a map of prayer ID → enabled (true/false).
  static Future<void> schedulePrayerNotifications({
    required Map<int, DateTime> prayerTimes,
    required Map<int, bool> enabledMap,
    bool includeKaborWarning = true,
  }) async {
    for (final prayer in _prayers) {
      await _plugin.cancel(prayer.id);
      await _plugin.cancel(prayer.id + 1000);

      final enabled = enabledMap[prayer.id] ?? true;
      if (!enabled) continue;

      final time = prayerTimes[prayer.id];
      if (time == null) continue;

      final now = tz.TZDateTime.now(tz.local);

      // ── 1. Schedule Exact Waqt Notification (includes grave reminder if enabled) ──
      final exactBody = includeKaborWarning
          ? '${prayer.body}\n\n⚠️ ${prayer.warning}'
          : prayer.body;

      final exactAndroidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(exactBody),
        enableVibration: true,
        playSound: true,
        ticker: prayer.title,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        color: const Color(0xFF2E7D32),
      );
      final exactDetails = NotificationDetails(android: exactAndroidDetails);

      var exactScheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (exactScheduled.isBefore(now)) {
        exactScheduled = exactScheduled.add(const Duration(days: 1));
      }

      try {
        await _plugin.zonedSchedule(
          prayer.id,
          prayer.title,
          exactBody,
          exactScheduled,
          exactDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ ${prayer.bangla} exact scheduled at ${exactScheduled.hour}:${exactScheduled.minute}');
      } catch (e) {
        debugPrint('❌ Error scheduling exact ${prayer.bangla}: $e');
      }

      // ── 2. Schedule 30-Minute Advance Notification ──
      final advanceAndroidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(prayer.body),
        enableVibration: true,
        playSound: true,
        ticker: '${prayer.emoji} ৩০ মিনিট পর ${prayer.bangla} ওয়াক্ত শুরু হবে',
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        color: const Color(0xFF2E7D32),
      );
      final advanceDetails = NotificationDetails(android: advanceAndroidDetails);

      var advanceScheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      advanceScheduled = advanceScheduled.subtract(const Duration(minutes: 30));
      if (advanceScheduled.isBefore(now)) {
        advanceScheduled = advanceScheduled.add(const Duration(days: 1));
      }

      final advanceTitle = '${prayer.emoji} ৩০ মিনিট পর ${prayer.bangla} ওয়াক্ত শুরু হবে';

      try {
        await _plugin.zonedSchedule(
          prayer.id + 1000,
          advanceTitle,
          prayer.body,
          advanceScheduled,
          advanceDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ ${prayer.bangla} advance scheduled 30m before Waqt at ${advanceScheduled.hour}:${advanceScheduled.minute}');
      } catch (e) {
        debugPrint('❌ Error scheduling advance ${prayer.bangla}: $e');
      }
    }
  }

  /// Cancel all prayer notifications.
  static Future<void> cancelPrayerNotifications() async {
    for (final p in _prayers) {
      await _plugin.cancel(p.id);
      await _plugin.cancel(p.id + 1000);
    }
  }

  /// Cancel a single prayer notification.
  static Future<void> cancelPrayer(int id) async {
    await _plugin.cancel(id);
  }

  // ── Daily Quran Reminder ────────────────────────────────────────────────────

  /// Schedule a daily Quran reminder at [hour]:[minute].
  static Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _plugin.cancel(PrayerNotifId.dailyQuran);

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final ayah = _ayahs[dayOfYear % _ayahs.length];

    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      _dailyChannelName,
      channelDescription: 'Daily Quran reading reminder',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      PrayerNotifId.dailyQuran,
      'বাংলা কুরআন ⭐',
      ayah,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Quran notification scheduled for $hour:$minute');
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
