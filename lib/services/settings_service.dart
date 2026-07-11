import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/services/notification_service.dart';
import 'package:quran/services/widget_service.dart';

class SettingsService extends ChangeNotifier {
  // ── Display ──
  static const _keyDarkMode = 'isDarkMode';
  static const _keyArabicFontSize = 'arabicFontSize';
  static const _keyTranslationFontSize = 'translationFontSize';

  // ── Last Read ──
  static const _keyLastReadSurahId = 'lastReadSurahId';
  static const _keyLastReadAyahIndex = 'lastReadAyahIndex';
  static const _keyLastReadSurahName = 'lastReadSurahName';
  static const _keyLastReadSurahBangla = 'lastReadSurahBangla';

  // ── Reading Stats ──
  static const _keyStreak = 'readingStreak';
  static const _keyLastReadDate = 'lastReadDate';
  static const _keyTotalAyahsRead = 'totalAyahsRead';
  static const _keySurahsStarted = 'surahsStarted'; // comma-separated IDs

  // ── Notifications ──
  static const _keyNotificationsEnabled = 'notificationsEnabled';
  static const _keyNotificationHour = 'notificationHour';
  static const _keyNotificationMinute = 'notificationMinute';

  // ── Prayer Notifications ──
  static const _keyPrayerNotifEnabled = 'prayerNotifEnabled';
  static const _keyNotifyFajr = 'notifyFajr';
  static const _keyNotifyDhuhr = 'notifyDhuhr';
  static const _keyNotifyAsr = 'notifyAsr';
  static const _keyNotifyMaghrib = 'notifyMaghrib';
  static const _keyNotifyIsha = 'notifyIsha';
  static const _keyShowKaborWarning = 'showKaborWarning';

  // ── Location & Calculation ──
  static const _keyIsAutomaticLocation = 'isAutomaticLocation';
  static const _keySelectedDistrict = 'selectedDistrict';
  static const _keyCalculationMethod = 'calculationMethod';
  static const _keyMadhab = 'madhab';

  // ── Auto Silent Mode ──
  static const _keySilentModeType = 'silentModeType';
  static const _keySilentDuration = 'silentDuration';
  static const _keyMosqueLat = 'mosqueLat';
  static const _keyMosqueLng = 'mosqueLng';
  static const _keyMosqueRadius = 'mosqueRadius';

  // ── Hajj & Umrah ──
  static const _keyCompletedHajjSteps = 'completedHajjSteps';
  static const _keyCompletedUmrahSteps = 'completedUmrahSteps';

  // ── Ramadan ──
  static const _keyRamadanDeeds = 'ramadanDeedsData';

  // ── Musafir ──
  static const _keyIsMusafir = 'isMusafir';

  // ── Tabligh Chilla ──
  static const _keyIsChillaActive = 'isChillaActive';
  static const _keyChillaDuration = 'chillaDuration';
  static const _keyChillaDaysCompleted = 'chillaDaysCompleted';
  static const _keyChillaStartDate = 'chillaStartDate';
  static const _keyChillaDailyDeeds = 'chillaDailyDeedsData';

  // ── Itikaf ──
  static const _keyIsItikafActive = 'isItikafActive';
  static const _keyItikafDaysCompleted = 'itikafDaysCompleted';
  static const _keyItikafStartDate = 'itikafStartDate';
  static const _keyItikafDailyDeeds = 'itikafDailyDeedsData';

  // ── Nafal Fasting ──
  static const _keyShawwalFasts = 'shawwalFastsCount';
  static const _keyArafahFast = 'arafahFastCompleted';
  static const _keyAshuraFasts = 'ashuraFastsData';
  static const _keyWeeklyNafalFasts = 'weeklyNafalFastsCount';

  // ── Cached Location ──
  static const _keyCachedLat = 'cachedLatitude';
  static const _keyCachedLng = 'cachedLongitude';

  // ── Quran Khatam Planner ──
  static const _keyIsKhatamActive = 'isKhatamActive';
  static const _keyKhatamTargetDays = 'khatamTargetDays';
  static const _keyKhatamStartDate = 'khatamStartDate';
  static const _keyKhatamCompletedDays = 'khatamCompletedDaysData';

  // ── State ──
  bool _isDarkMode = false;
  double _arabicFontSize = 36.0;
  double _translationFontSize = 18.0;
  int _lastReadSurahId = 0;
  int _lastReadAyahIndex = 0;
  String _lastReadSurahName = '';
  String _lastReadSurahBangla = '';

  int _streak = 0;
  int _totalAyahsRead = 0;
  Set<int> _surahsStarted = {};

  bool _notificationsEnabled = false;
  int _notificationHour = 6;
  int _notificationMinute = 0;

  bool _prayerNotifEnabled = true;
  bool _notifyFajr = true;
  bool _notifyDhuhr = true;
  bool _notifyAsr = true;
  bool _notifyMaghrib = true;
  bool _notifyIsha = true;
  bool _showKaborWarning = true;

  bool _isAutomaticLocation = true;
  String _selectedDistrict = 'Dhaka';
  String _calculationMethod = 'muslim_world_league';
  String _madhab = 'hanafi';

  String _silentModeType = 'none';
  int _silentDuration = 20;
  double _mosqueLat = 0.0;
  double _mosqueLng = 0.0;
  double _mosqueRadius = 100.0;

  Set<String> _completedHajjSteps = {};
  Set<String> _completedUmrahSteps = {};

  Map<String, List<String>> _ramadanDeeds = {};

  bool _isMusafir = false;

  bool _isChillaActive = false;
  int _chillaDuration = 3;
  int _chillaDaysCompleted = 0;
  String _chillaStartDate = '';
  Map<String, List<String>> _chillaDailyDeeds = {};

  bool _isItikafActive = false;
  int _itikafDaysCompleted = 0;
  String _itikafStartDate = '';
  Map<String, List<String>> _itikafDailyDeeds = {};

  int _shawwalFastsCount = 0;
  bool _arafahFastCompleted = false;
  Set<String> _ashuraFastsCompleted = {};
  int _weeklyNafalFastsCount = 0;

  double? _cachedLatitude;
  double? _cachedLongitude;

  bool _isKhatamActive = false;
  int _khatamTargetDays = 30;
  String _khatamStartDate = '';
  Set<int> _khatamCompletedDays = {};

  // ── Getters ──
  bool get isDarkMode => _isDarkMode;
  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  int get lastReadSurahId => _lastReadSurahId;
  int get lastReadAyahIndex => _lastReadAyahIndex;
  String get lastReadSurahName => _lastReadSurahName;
  String get lastReadSurahBangla => _lastReadSurahBangla;
  bool get hasLastRead => _lastReadSurahId > 0;

  int get streak => _streak;
  int get totalAyahsRead => _totalAyahsRead;
  int get surahsStartedCount => _surahsStarted.length;
  Set<int> get surahsStarted => Set.unmodifiable(_surahsStarted);

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationHour => _notificationHour;
  int get notificationMinute => _notificationMinute;

  bool get prayerNotifEnabled => _prayerNotifEnabled;
  bool get notifyFajr => _notifyFajr;
  bool get notifyDhuhr => _notifyDhuhr;
  bool get notifyAsr => _notifyAsr;
  bool get notifyMaghrib => _notifyMaghrib;
  bool get notifyIsha => _notifyIsha;
  bool get showKaborWarning => _showKaborWarning;

  bool get isAutomaticLocation => _isAutomaticLocation;
  String get selectedDistrict => _selectedDistrict;
  String get calculationMethod => _calculationMethod;
  String get madhab => _madhab;

  String get silentModeType => _silentModeType;
  int get silentDuration => _silentDuration;
  double get mosqueLat => _mosqueLat;
  double get mosqueLng => _mosqueLng;
  double get mosqueRadius => _mosqueRadius;
  bool get hasMosqueRegistered => _mosqueLat != 0.0 && _mosqueLng != 0.0;

  Set<String> get completedHajjSteps => _completedHajjSteps;
  Set<String> get completedUmrahSteps => _completedUmrahSteps;

  bool get isMusafir => _isMusafir;

  bool get isChillaActive => _isChillaActive;
  int get chillaDuration => _chillaDuration;
  int get chillaDaysCompleted => _chillaDaysCompleted;
  String get chillaStartDate => _chillaStartDate;

  bool get isItikafActive => _isItikafActive;
  int get itikafDaysCompleted => _itikafDaysCompleted;
  String get itikafStartDate => _itikafStartDate;

  int get shawwalFastsCount => _shawwalFastsCount;
  bool get arafahFastCompleted => _arafahFastCompleted;
  Set<String> get ashuraFastsCompleted => _ashuraFastsCompleted;
  int get weeklyNafalFastsCount => _weeklyNafalFastsCount;

  double? get cachedLatitude => _cachedLatitude;
  double? get cachedLongitude => _cachedLongitude;

  bool get isKhatamActive => _isKhatamActive;
  int get khatamTargetDays => _khatamTargetDays;
  String get khatamStartDate => _khatamStartDate;
  Set<int> get khatamCompletedDays => _khatamCompletedDays;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // ── Load ──
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    _arabicFontSize = prefs.getDouble(_keyArabicFontSize) ?? 36.0;
    _translationFontSize = prefs.getDouble(_keyTranslationFontSize) ?? 18.0;
    _lastReadSurahId = prefs.getInt(_keyLastReadSurahId) ?? 0;
    _lastReadAyahIndex = prefs.getInt(_keyLastReadAyahIndex) ?? 0;
    _lastReadSurahName = prefs.getString(_keyLastReadSurahName) ?? '';
    _lastReadSurahBangla = prefs.getString(_keyLastReadSurahBangla) ?? '';

    _streak = prefs.getInt(_keyStreak) ?? 0;
    _totalAyahsRead = prefs.getInt(_keyTotalAyahsRead) ?? 0;
    final surahsRaw = prefs.getString(_keySurahsStarted) ?? '';
    _surahsStarted = surahsRaw.isEmpty
        ? {}
        : surahsRaw.split(',').map(int.parse).toSet();

    _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? false;
    _notificationHour = prefs.getInt(_keyNotificationHour) ?? 6;
    _notificationMinute = prefs.getInt(_keyNotificationMinute) ?? 0;

    _prayerNotifEnabled = prefs.getBool(_keyPrayerNotifEnabled) ?? true;
    _notifyFajr = prefs.getBool(_keyNotifyFajr) ?? true;
    _notifyDhuhr = prefs.getBool(_keyNotifyDhuhr) ?? true;
    _notifyAsr = prefs.getBool(_keyNotifyAsr) ?? true;
    _notifyMaghrib = prefs.getBool(_keyNotifyMaghrib) ?? true;
    _notifyIsha = prefs.getBool(_keyNotifyIsha) ?? true;
    _showKaborWarning = prefs.getBool(_keyShowKaborWarning) ?? true;

    _isAutomaticLocation = prefs.getBool(_keyIsAutomaticLocation) ?? true;
    _selectedDistrict = prefs.getString(_keySelectedDistrict) ?? 'Dhaka';
    _calculationMethod = prefs.getString(_keyCalculationMethod) ?? 'muslim_world_league';
    _madhab = prefs.getString(_keyMadhab) ?? 'hanafi';

    _silentModeType = prefs.getString(_keySilentModeType) ?? 'none';
    _silentDuration = prefs.getInt(_keySilentDuration) ?? 20;
    _mosqueLat = prefs.getDouble(_keyMosqueLat) ?? 0.0;
    _mosqueLng = prefs.getDouble(_keyMosqueLng) ?? 0.0;
    _mosqueRadius = prefs.getDouble(_keyMosqueRadius) ?? 100.0;

    _completedHajjSteps = (prefs.getStringList(_keyCompletedHajjSteps) ?? []).toSet();
    _completedUmrahSteps = (prefs.getStringList(_keyCompletedUmrahSteps) ?? []).toSet();

    final ramadanRaw = prefs.getString(_keyRamadanDeeds) ?? '';
    if (ramadanRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(ramadanRaw) as Map<String, dynamic>;
        _ramadanDeeds = decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
      } catch (_) {
        _ramadanDeeds = {};
      }
    } else {
      _ramadanDeeds = {};
    }

    _isMusafir = prefs.getBool(_keyIsMusafir) ?? false;

    _isChillaActive = prefs.getBool(_keyIsChillaActive) ?? false;
    _chillaDuration = prefs.getInt(_keyChillaDuration) ?? 3;
    _chillaDaysCompleted = prefs.getInt(_keyChillaDaysCompleted) ?? 0;
    _chillaStartDate = prefs.getString(_keyChillaStartDate) ?? '';
    final chillaRaw = prefs.getString(_keyChillaDailyDeeds) ?? '';
    if (chillaRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(chillaRaw) as Map<String, dynamic>;
        _chillaDailyDeeds = decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
      } catch (_) {
        _chillaDailyDeeds = {};
      }
    } else {
      _chillaDailyDeeds = {};
    }

    _isItikafActive = prefs.getBool(_keyIsItikafActive) ?? false;
    _itikafDaysCompleted = prefs.getInt(_keyItikafDaysCompleted) ?? 0;
    _itikafStartDate = prefs.getString(_keyItikafStartDate) ?? '';
    final itikafRaw = prefs.getString(_keyItikafDailyDeeds) ?? '';
    if (itikafRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(itikafRaw) as Map<String, dynamic>;
        _itikafDailyDeeds = decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
      } catch (_) {
        _itikafDailyDeeds = {};
      }
    } else {
      _itikafDailyDeeds = {};
    }

    _shawwalFastsCount = prefs.getInt(_keyShawwalFasts) ?? 0;
    _arafahFastCompleted = prefs.getBool(_keyArafahFast) ?? false;
    _ashuraFastsCompleted = (prefs.getStringList(_keyAshuraFasts) ?? []).toSet();
    _weeklyNafalFastsCount = prefs.getInt(_keyWeeklyNafalFasts) ?? 0;

    _cachedLatitude = prefs.getDouble(_keyCachedLat);
    _cachedLongitude = prefs.getDouble(_keyCachedLng);

    _isKhatamActive = prefs.getBool(_keyIsKhatamActive) ?? false;
    _khatamTargetDays = prefs.getInt(_keyKhatamTargetDays) ?? 30;
    _khatamStartDate = prefs.getString(_keyKhatamStartDate) ?? '';
    _khatamCompletedDays = (prefs.getStringList(_keyKhatamCompletedDays) ?? [])
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toSet();

    // Update streak on load
    _updateStreak(prefs);

    // Update Android Home Screen widget
    await WidgetService.updateWidget();

    notifyListeners();
  }

  void _updateStreak(SharedPreferences prefs) {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    final lastStr = prefs.getString(_keyLastReadDate) ?? '';

    if (lastStr == todayStr) return; // Already counted today

    if (lastStr.isNotEmpty) {
      final last = DateTime.tryParse(lastStr);
      if (last != null) {
        final diff = today.difference(last).inDays;
        if (diff == 1) {
          _streak++;
        } else if (diff > 1) {
          _streak = 1; // Streak broken
        }
      }
    } else {
      _streak = 1;
    }

    prefs.setString(_keyLastReadDate, todayStr);
    prefs.setInt(_keyStreak, _streak);
  }

  // ── Display settings ──
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size.clamp(24.0, 60.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyArabicFontSize, _arabicFontSize);
    notifyListeners();
  }

  Future<void> setTranslationFontSize(double size) async {
    _translationFontSize = size.clamp(12.0, 28.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTranslationFontSize, _translationFontSize);
    notifyListeners();
  }

  // ── Last Read ──
  Future<void> saveLastRead({
    required int surahId,
    required int ayahIndex,
    required String surahName,
    required String surahBangla,
  }) async {
    _lastReadSurahId = surahId;
    _lastReadAyahIndex = ayahIndex;
    _lastReadSurahName = surahName;
    _lastReadSurahBangla = surahBangla;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastReadSurahId, surahId);
    await prefs.setInt(_keyLastReadAyahIndex, ayahIndex);
    await prefs.setString(_keyLastReadSurahName, surahName);
    await prefs.setString(_keyLastReadSurahBangla, surahBangla);
    notifyListeners();
  }

  Future<void> clearLastRead() async {
    _lastReadSurahId = 0;
    _lastReadAyahIndex = 0;
    _lastReadSurahName = '';
    _lastReadSurahBangla = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastReadSurahId);
    await prefs.remove(_keyLastReadAyahIndex);
    await prefs.remove(_keyLastReadSurahName);
    await prefs.remove(_keyLastReadSurahBangla);
    notifyListeners();
  }

  // ── Reading Stats ──
  Future<void> incrementAyahsRead({required int surahId}) async {
    _totalAyahsRead++;
    _surahsStarted.add(surahId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalAyahsRead, _totalAyahsRead);
    await prefs.setString(
        _keySurahsStarted, _surahsStarted.join(','));
    notifyListeners();
  }

  Future<void> resetStats() async {
    _streak = 0;
    _totalAyahsRead = 0;
    _surahsStarted = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, 0);
    await prefs.setInt(_keyTotalAyahsRead, 0);
    await prefs.setString(_keySurahsStarted, '');
    await prefs.remove(_keyLastReadDate);
    notifyListeners();
  }

  // ── Notifications ──
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
    notifyListeners();
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    _notificationHour = hour;
    _notificationMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNotificationHour, hour);
    await prefs.setInt(_keyNotificationMinute, minute);
    notifyListeners();
  }

  // ── Prayer Notifications Setters ──
  Future<void> setPrayerNotifEnabled(bool enabled) async {
    _prayerNotifEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrayerNotifEnabled, enabled);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setNotifyFajr(bool value) async {
    _notifyFajr = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyFajr, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setNotifyDhuhr(bool value) async {
    _notifyDhuhr = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyDhuhr, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setNotifyAsr(bool value) async {
    _notifyAsr = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyAsr, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setNotifyMaghrib(bool value) async {
    _notifyMaghrib = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyMaghrib, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setNotifyIsha(bool value) async {
    _notifyIsha = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyIsha, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setShowKaborWarning(bool value) async {
    _showKaborWarning = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowKaborWarning, value);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> updatePrayerNotifications() async {
    if (!_prayerNotifEnabled) {
      await NotificationService.cancelPrayerNotifications();
      return;
    }

    double lat = 23.8103;
    double lng = 90.4125;

    if (_isAutomaticLocation) {
      if (_cachedLatitude != null && _cachedLongitude != null) {
        lat = _cachedLatitude!;
        lng = _cachedLongitude!;
      } else {
        final dist = PrayerService.getDistrictByName(_selectedDistrict);
        lat = dist.latitude;
        lng = dist.longitude;
      }
    } else {
      final dist = PrayerService.getDistrictByName(_selectedDistrict);
      lat = dist.latitude;
      lng = dist.longitude;
    }

    final prayers = PrayerService.calculate(
      lat: lat,
      lng: lng,
      method: _calculationMethod,
      madhab: _madhab,
    );

    final times = {
      PrayerNotifId.fajr: prayers.fajr.time,
      PrayerNotifId.dhuhr: prayers.dhuhr.time,
      PrayerNotifId.asr: prayers.asr.time,
      PrayerNotifId.maghrib: prayers.maghrib.time,
      PrayerNotifId.isha: prayers.isha.time,
    };

    final enabledMap = {
      PrayerNotifId.fajr: _notifyFajr,
      PrayerNotifId.dhuhr: _notifyDhuhr,
      PrayerNotifId.asr: _notifyAsr,
      PrayerNotifId.maghrib: _notifyMaghrib,
      PrayerNotifId.isha: _notifyIsha,
    };

    await NotificationService.schedulePrayerNotifications(
      prayerTimes: times,
      enabledMap: enabledMap,
      includeKaborWarning: _showKaborWarning,
    );

    // Update Android Home Screen widget
    await WidgetService.updateWidget();
  }

  Future<void> setAutomaticLocation(bool isAuto) async {
    _isAutomaticLocation = isAuto;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAutomaticLocation, isAuto);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setSelectedDistrict(String district) async {
    _selectedDistrict = district;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedDistrict, district);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setCalculationMethod(String method) async {
    _calculationMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCalculationMethod, method);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setMadhab(String madhab) async {
    _madhab = madhab;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMadhab, madhab);
    await updatePrayerNotifications();
    notifyListeners();
  }

  Future<void> setSilentModeType(String type) async {
    _silentModeType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySilentModeType, type);
    notifyListeners();
  }

  Future<void> setSilentDuration(int duration) async {
    _silentDuration = duration;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySilentDuration, duration);
    notifyListeners();
  }

  Future<void> saveMosqueLocation(double lat, double lng) async {
    _mosqueLat = lat;
    _mosqueLng = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMosqueLat, lat);
    await prefs.setDouble(_keyMosqueLng, lng);
    notifyListeners();
  }

  Future<void> setMosqueRadius(double radius) async {
    _mosqueRadius = radius;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMosqueRadius, radius);
    notifyListeners();
  }

  Future<void> toggleHajjStep(String stepId) async {
    if (_completedHajjSteps.contains(stepId)) {
      _completedHajjSteps.remove(stepId);
    } else {
      _completedHajjSteps.add(stepId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedHajjSteps, _completedHajjSteps.toList());
    notifyListeners();
  }

  Future<void> toggleUmrahStep(String stepId) async {
    if (_completedUmrahSteps.contains(stepId)) {
      _completedUmrahSteps.remove(stepId);
    } else {
      _completedUmrahSteps.add(stepId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedUmrahSteps, _completedUmrahSteps.toList());
    notifyListeners();
  }

  Future<void> resetHajjUmrahProgress() async {
    _completedHajjSteps.clear();
    _completedUmrahSteps.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletedHajjSteps);
    await prefs.remove(_keyCompletedUmrahSteps);
    notifyListeners();
  }

  List<String> getRamadanDeeds(int dayIndex) {
    return _ramadanDeeds['day_$dayIndex'] ?? [];
  }

  Future<void> toggleRamadanDeed(int dayIndex, String deedId) async {
    final key = 'day_$dayIndex';
    final list = List<String>.from(_ramadanDeeds[key] ?? []);
    if (list.contains(deedId)) {
      list.remove(deedId);
    } else {
      list.add(deedId);
    }
    _ramadanDeeds[key] = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRamadanDeeds, jsonEncode(_ramadanDeeds));
    notifyListeners();
  }

  Future<void> resetRamadanTracker() async {
    _ramadanDeeds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRamadanDeeds);
    notifyListeners();
  }

  Future<void> setMusafir(bool value) async {
    _isMusafir = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsMusafir, value);
    notifyListeners();
  }

  List<String> getChillaDeeds(int dayIndex) {
    return _chillaDailyDeeds['day_$dayIndex'] ?? [];
  }

  Future<void> startChilla(int duration) async {
    _isChillaActive = true;
    _chillaDuration = duration;
    _chillaDaysCompleted = 0;
    final now = DateTime.now();
    _chillaStartDate = '${now.day}/${now.month}/${now.year}';
    _chillaDailyDeeds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsChillaActive, true);
    await prefs.setInt(_keyChillaDuration, duration);
    await prefs.setInt(_keyChillaDaysCompleted, 0);
    await prefs.setString(_keyChillaStartDate, _chillaStartDate);
    await prefs.remove(_keyChillaDailyDeeds);
    notifyListeners();
  }

  Future<void> stopChilla() async {
    _isChillaActive = false;
    _chillaDuration = 3;
    _chillaDaysCompleted = 0;
    _chillaStartDate = '';
    _chillaDailyDeeds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsChillaActive, false);
    await prefs.setInt(_keyChillaDuration, 3);
    await prefs.setInt(_keyChillaDaysCompleted, 0);
    await prefs.setString(_keyChillaStartDate, '');
    await prefs.remove(_keyChillaDailyDeeds);
    notifyListeners();
  }

  Future<void> toggleChillaDeed(int dayIndex, String deedId) async {
    final key = 'day_$dayIndex';
    final list = List<String>.from(_chillaDailyDeeds[key] ?? []);
    if (list.contains(deedId)) {
      list.remove(deedId);
    } else {
      list.add(deedId);
    }
    _chillaDailyDeeds[key] = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChillaDailyDeeds, jsonEncode(_chillaDailyDeeds));
    notifyListeners();
  }

  Future<void> incrementChillaDay() async {
    if (_chillaDaysCompleted < _chillaDuration) {
      _chillaDaysCompleted++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyChillaDaysCompleted, _chillaDaysCompleted);
      notifyListeners();
    }
  }

  Future<void> decrementChillaDay() async {
    if (_chillaDaysCompleted > 0) {
      _chillaDaysCompleted--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyChillaDaysCompleted, _chillaDaysCompleted);
      notifyListeners();
    }
  }

  List<String> getItikafDeeds(int dayIndex) {
    return _itikafDailyDeeds['day_$dayIndex'] ?? [];
  }

  Future<void> startItikaf() async {
    _isItikafActive = true;
    _itikafDaysCompleted = 0;
    final now = DateTime.now();
    _itikafStartDate = '${now.day}/${now.month}/${now.year}';
    _itikafDailyDeeds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsItikafActive, true);
    await prefs.setInt(_keyItikafDaysCompleted, 0);
    await prefs.setString(_keyItikafStartDate, _itikafStartDate);
    await prefs.remove(_keyItikafDailyDeeds);
    notifyListeners();
  }

  Future<void> stopItikaf() async {
    _isItikafActive = false;
    _itikafDaysCompleted = 0;
    _itikafStartDate = '';
    _itikafDailyDeeds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsItikafActive, false);
    await prefs.setInt(_keyItikafDaysCompleted, 0);
    await prefs.setString(_keyItikafStartDate, '');
    await prefs.remove(_keyItikafDailyDeeds);
    notifyListeners();
  }

  Future<void> toggleItikafDeed(int dayIndex, String deedId) async {
    final key = 'day_$dayIndex';
    final list = List<String>.from(_itikafDailyDeeds[key] ?? []);
    if (list.contains(deedId)) {
      list.remove(deedId);
    } else {
      list.add(deedId);
    }
    _itikafDailyDeeds[key] = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyItikafDailyDeeds, jsonEncode(_itikafDailyDeeds));
    notifyListeners();
  }

  Future<void> incrementItikafDay() async {
    if (_itikafDaysCompleted < 10) {
      _itikafDaysCompleted++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyItikafDaysCompleted, _itikafDaysCompleted);
      notifyListeners();
    }
  }

  Future<void> decrementItikafDay() async {
    if (_itikafDaysCompleted > 0) {
      _itikafDaysCompleted--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyItikafDaysCompleted, _itikafDaysCompleted);
      notifyListeners();
    }
  }

  Future<void> setShawwalFastsCount(int count) async {
    _shawwalFastsCount = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShawwalFasts, count);
    notifyListeners();
  }

  Future<void> toggleArafahFast(bool value) async {
    _arafahFastCompleted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyArafahFast, value);
    notifyListeners();
  }

  Future<void> toggleAshuraFast(String day) async {
    final list = _ashuraFastsCompleted.toSet();
    if (list.contains(day)) {
      list.remove(day);
    } else {
      list.add(day);
    }
    _ashuraFastsCompleted = list;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAshuraFasts, list.toList());
    notifyListeners();
  }

  Future<void> incrementWeeklyNafalFasts() async {
    _weeklyNafalFastsCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklyNafalFasts, _weeklyNafalFastsCount);
    notifyListeners();
  }

  Future<void> decrementWeeklyNafalFasts() async {
    if (_weeklyNafalFastsCount > 0) {
      _weeklyNafalFastsCount--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyWeeklyNafalFasts, _weeklyNafalFastsCount);
      notifyListeners();
    }
  }

  Future<void> resetNafalFasting() async {
    _shawwalFastsCount = 0;
    _arafahFastCompleted = false;
    _ashuraFastsCompleted.clear();
    _weeklyNafalFastsCount = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyShawwalFasts);
    await prefs.remove(_keyArafahFast);
    await prefs.remove(_keyAshuraFasts);
    await prefs.remove(_keyWeeklyNafalFasts);
    notifyListeners();
  }

  Future<void> updateCachedLocation(double lat, double lng) async {
    _cachedLatitude = lat;
    _cachedLongitude = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyCachedLat, lat);
    await prefs.setDouble(_keyCachedLng, lng);
    notifyListeners();
  }

  Future<void> startKhatamPlan(int targetDays) async {
    _isKhatamActive = true;
    _khatamTargetDays = targetDays;
    final now = DateTime.now();
    _khatamStartDate = '${now.day}/${now.month}/${now.year}';
    _khatamCompletedDays.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsKhatamActive, true);
    await prefs.setInt(_keyKhatamTargetDays, targetDays);
    await prefs.setString(_keyKhatamStartDate, _khatamStartDate);
    await prefs.remove(_keyKhatamCompletedDays);
    notifyListeners();
  }

  Future<void> stopKhatamPlan() async {
    _isKhatamActive = false;
    _khatamTargetDays = 30;
    _khatamStartDate = '';
    _khatamCompletedDays.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsKhatamActive, false);
    await prefs.setInt(_keyKhatamTargetDays, 30);
    await prefs.setString(_keyKhatamStartDate, '');
    await prefs.remove(_keyKhatamCompletedDays);
    notifyListeners();
  }

  Future<void> toggleKhatamDay(int dayIndex) async {
    final set = _khatamCompletedDays.toSet();
    if (set.contains(dayIndex)) {
      set.remove(dayIndex);
    } else {
      set.add(dayIndex);
    }
    _khatamCompletedDays = set;

    final prefs = await SharedPreferences.getInstance();
    final stringList = set.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyKhatamCompletedDays, stringList);
    notifyListeners();
  }
}
