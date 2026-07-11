import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerInfo {
  final String name;
  final String banglaName;
  final DateTime time;
  final String icon;

  const PrayerInfo({
    required this.name,
    required this.banglaName,
    required this.time,
    required this.icon,
  });
}

class DailyPrayers {
  final PrayerInfo fajr;
  final PrayerInfo sunrise;
  final PrayerInfo dhuhr;
  final PrayerInfo asr;
  final PrayerInfo maghrib;
  final PrayerInfo isha;
  final DateTime calculatedAt;

  const DailyPrayers({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.calculatedAt,
  });

  List<PrayerInfo> get all =>
      [fajr, sunrise, dhuhr, asr, maghrib, isha];

  /// Returns the next prayer after now, or null if all passed today.
  PrayerInfo? nextPrayer() {
    final now = DateTime.now();
    for (final p in all) {
      if (p.time.isAfter(now)) return p;
    }
    return null;
  }

  /// Duration remaining until next prayer.
  Duration? timeUntilNext() {
    final next = nextPrayer();
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }
}

class District {
  final String nameBn;
  final String nameEn;
  final double latitude;
  final double longitude;

  const District({
    required this.nameBn,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });
}

class CalculationMethodInfo {
  final String key;
  final String name;
  const CalculationMethodInfo(this.key, this.name);
}

class PrayerService {
  /// All 64 Districts of Bangladesh with coordinates
  static const List<District> bdDistricts = [
    District(nameBn: 'ঢাকা', nameEn: 'Dhaka', latitude: 23.8103, longitude: 90.4125),
    District(nameBn: 'চট্টগ্রাম', nameEn: 'Chittagong', latitude: 22.3569, longitude: 91.7832),
    District(nameBn: 'সিলেট', nameEn: 'Sylhet', latitude: 24.8949, longitude: 91.8687),
    District(nameBn: 'রাজশাহী', nameEn: 'Rajshahi', latitude: 24.3636, longitude: 88.6241),
    District(nameBn: 'খুলনা', nameEn: 'Khulna', latitude: 22.8456, longitude: 89.5403),
    District(nameBn: 'বরিশাল', nameEn: 'Barisal', latitude: 22.7010, longitude: 90.3535),
    District(nameBn: 'রংপুর', nameEn: 'Rangpur', latitude: 25.7508, longitude: 89.2467),
    District(nameBn: 'ময়মনসিংহ', nameEn: 'Mymensingh', latitude: 24.7471, longitude: 90.4203),
    District(nameBn: 'কুমিল্লা', nameEn: 'Comilla', latitude: 23.4682, longitude: 91.1785),
    District(nameBn: 'গাজীপুর', nameEn: 'Gazipur', latitude: 24.0023, longitude: 90.4264),
    District(nameBn: 'নারায়ণগঞ্জ', nameEn: 'Narayanganj', latitude: 23.6238, longitude: 90.5000),
    District(nameBn: 'বগুড়া', nameEn: 'Bogura', latitude: 24.8481, longitude: 89.3730),
    District(nameBn: 'যশোর', nameEn: 'Jashore', latitude: 23.1664, longitude: 89.2081),
    District(nameBn: 'ফেনী', nameEn: 'Feni', latitude: 23.0159, longitude: 91.3976),
    District(nameBn: 'কক্সবাজার', nameEn: 'Cox\'s Bazar', latitude: 21.4272, longitude: 92.0058),
    District(nameBn: 'দিনাজপুর', nameEn: 'Dinajpur', latitude: 25.6217, longitude: 88.6354),
    District(nameBn: 'টাঙ্গাইল', nameEn: 'Tangail', latitude: 24.2513, longitude: 89.9167),
    District(nameBn: 'কুষ্টিয়া', nameEn: 'Kushtia', latitude: 23.9014, longitude: 89.1204),
    District(nameBn: 'পাবনা', nameEn: 'Pabna', latitude: 24.0150, longitude: 89.2424),
    District(nameBn: 'নোয়াখালী', nameEn: 'Noakhali', latitude: 22.8696, longitude: 91.0990),
    District(nameBn: 'সিরাজগঞ্জ', nameEn: 'Sirajganj', latitude: 24.4533, longitude: 89.7000),
    District(nameBn: 'ফরিদপুর', nameEn: 'Faridpur', latitude: 23.6071, longitude: 89.8429),
    District(nameBn: 'জামালপুর', nameEn: 'Jamalpur', latitude: 24.9375, longitude: 89.9375),
    District(nameBn: 'চাঁদপুর', nameEn: 'Chandpur', latitude: 23.2333, longitude: 90.6500),
    District(nameBn: 'মাদারীপুর', nameEn: 'Madaripur', latitude: 23.1681, longitude: 90.1872),
    District(nameBn: 'শরীয়তপুর', nameEn: 'Shariatpur', latitude: 23.2423, longitude: 90.3444),
    District(nameBn: 'কিশোরগঞ্জ', nameEn: 'Kishoreganj', latitude: 24.4392, longitude: 90.7811),
    District(nameBn: 'নেত্রকোণা', nameEn: 'Netrokona', latitude: 24.8700, longitude: 90.7300),
    District(nameBn: 'শেরপুর', nameEn: 'Sherpur', latitude: 25.0189, longitude: 90.0175),
    District(nameBn: 'মুন্সিগঞ্জ', nameEn: 'Munshiganj', latitude: 23.5435, longitude: 90.5308),
    District(nameBn: 'মানিকগঞ্জ', nameEn: 'Manikganj', latitude: 23.8644, longitude: 89.9967),
    District(nameBn: 'রাজবাড়ী', nameEn: 'Rajbari', latitude: 23.7574, longitude: 89.6500),
    District(nameBn: 'গোপালগঞ্জ', nameEn: 'Gopalganj', latitude: 23.0050, longitude: 89.8267),
    District(nameBn: 'ব্রাহ্মণবাড়িয়া', nameEn: 'Brahmanbaria', latitude: 23.9578, longitude: 91.1119),
    District(nameBn: 'লক্ষ্মীপুর', nameEn: 'Lakshmipur', latitude: 22.9426, longitude: 90.8417),
    District(nameBn: 'রাঙ্গামাটি', nameEn: 'Rangamati', latitude: 22.6500, longitude: 92.1750),
    District(nameBn: 'বান্দরবান', nameEn: 'Bandarban', latitude: 22.1953, longitude: 92.2184),
    District(nameBn: 'খাগড়াছড়ি', nameEn: 'Khagrachhari', latitude: 23.1192, longitude: 91.9922),
    District(nameBn: 'বাগেরহাট', nameEn: 'Bagerhat', latitude: 22.6516, longitude: 89.7859),
    District(nameBn: 'সাতক্ষীরা', nameEn: 'Satkhira', latitude: 22.7185, longitude: 89.0705),
    District(nameBn: 'নড়াইল', nameEn: 'Narail', latitude: 23.1725, longitude: 89.5126),
    District(nameBn: 'মাগুরা', nameEn: 'Magura', latitude: 23.4875, longitude: 89.4199),
    District(nameBn: 'ঝিনাইদহ', nameEn: 'Jhenaidah', latitude: 23.5450, longitude: 89.1726),
    District(nameBn: 'মেহেরপুর', nameEn: 'Meherpur', latitude: 23.7622, longitude: 88.6318),
    District(nameBn: 'চুয়াডাঙ্গা', nameEn: 'Chuadanga', latitude: 23.6408, longitude: 88.8519),
    District(nameBn: 'নাটোর', nameEn: 'Natore', latitude: 24.4102, longitude: 88.9818),
    District(nameBn: 'নওগাঁ', nameEn: 'Naogaon', latitude: 24.8053, longitude: 88.9549),
    District(nameBn: 'জয়পুরহাট', nameEn: 'Joypurhat', latitude: 25.1010, longitude: 89.0270),
    District(nameBn: 'চাঁপাইনবাবগঞ্জ', nameEn: 'Chapainawabganj', latitude: 24.5963, longitude: 88.2718),
    District(nameBn: 'গাইবান্ধা', nameEn: 'Gaibandha', latitude: 25.3288, longitude: 89.5426),
    District(nameBn: 'কুড়িগ্রাম', nameEn: 'Kurigram', latitude: 25.8072, longitude: 89.6295),
    District(nameBn: 'লালমনিরহাট', nameEn: 'Lalmonirhat', latitude: 25.9126, longitude: 89.4486),
    District(nameBn: 'নীলফামারী', nameEn: 'Nilphamari', latitude: 25.9417, longitude: 88.8444),
    District(nameBn: 'পঞ্চগড়', nameEn: 'Panchagarh', latitude: 26.3411, longitude: 88.5541),
    District(nameBn: 'ঠাকুরগাঁও', nameEn: 'Thakurgaon', latitude: 26.0333, longitude: 88.4667),
    District(nameBn: 'হবিগঞ্জ', nameEn: 'Habiganj', latitude: 24.3749, longitude: 91.4133),
    District(nameBn: 'মৌলভীবাজার', nameEn: 'Moulvibazar', latitude: 24.4829, longitude: 91.7600),
    District(nameBn: 'সুনামগঞ্জ', nameEn: 'Sunamganj', latitude: 25.0664, longitude: 91.3992),
    District(nameBn: 'ভোলা', nameEn: 'Bhola', latitude: 22.6859, longitude: 90.6440),
    District(nameBn: 'পটুয়াখালী', nameEn: 'Patuakhali', latitude: 22.3597, longitude: 90.3297),
    District(nameBn: 'পিরোজপুর', nameEn: 'Pirojpur', latitude: 22.5791, longitude: 89.9753),
    District(nameBn: 'ঝালকাঠি', nameEn: 'Jhalokati', latitude: 22.6406, longitude: 90.1989),
    District(nameBn: 'বরগুনা', nameEn: 'Barguna', latitude: 22.1500, longitude: 90.1200),
  ];

  static const List<CalculationMethodInfo> calculationMethods = [
    CalculationMethodInfo('muslim_world_league', 'Muslim World League (MWL)'),
    CalculationMethodInfo('karachi', 'University of Islamic Sciences, Karachi'),
    CalculationMethodInfo('isna', 'Islamic Society of North America (ISNA)'),
    CalculationMethodInfo('egypt', 'Egyptian General Authority of Survey'),
    CalculationMethodInfo('makkah', 'Umm Al-Qura University, Makkah'),
    CalculationMethodInfo('dubai', 'Dubai Administration'),
    CalculationMethodInfo('kuwait', 'Kuwait Government'),
    CalculationMethodInfo('qatar', 'Qatar Government'),
    CalculationMethodInfo('singapore', 'MUIS Singapore'),
    CalculationMethodInfo('turkey', 'Turkey Diyanet'),
  ];

  static District getDistrictByName(String nameEn) {
    return bdDistricts.firstWhere(
      (d) => d.nameEn.toLowerCase() == nameEn.toLowerCase(),
      orElse: () => bdDistricts.first, // Fallback to Dhaka
    );
  }

  /// Request location permission and get current position.
  static Future<Position?> getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calculate prayer times for today given coordinates and custom parameters.
  static DailyPrayers calculate({
    required double lat,
    required double lng,
    required String method,
    required String madhab,
    DateTime? date,
  }) {
    final coordinates = Coordinates(lat, lng);
    
    CalculationParameters params;
    switch (method) {
      case 'karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'isna':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'egypt':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'makkah':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'turkey':
        params = CalculationMethod.turkey.getParameters();
        break;
      case 'muslim_world_league':
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
    }

    params.madhab = madhab == 'shafi' ? Madhab.shafi : Madhab.hanafi;

    final now = DateTime.now();
    final targetDate = date ?? now;
    final dateComponents = DateComponents(targetDate.year, targetDate.month, targetDate.day);
    final pt = PrayerTimes(coordinates, dateComponents, params);

    return DailyPrayers(
      fajr: PrayerInfo(
          name: 'Fajr',
          banglaName: 'ফজর',
          time: pt.fajr,
          icon: '🌙'),
      sunrise: PrayerInfo(
          name: 'Sunrise',
          banglaName: 'সূর্যোদয়',
          time: pt.sunrise,
          icon: '🌅'),
      dhuhr: PrayerInfo(
          name: 'Dhuhr',
          banglaName: 'যোহর',
          time: pt.dhuhr,
          icon: '☀️'),
      asr: PrayerInfo(
          name: 'Asr',
          banglaName: 'আসর',
          time: pt.asr,
          icon: '🌤️'),
      maghrib: PrayerInfo(
          name: 'Maghrib',
          banglaName: 'মাগরিব',
          time: pt.maghrib,
          icon: '🌇'),
      isha: PrayerInfo(
          name: 'Isha',
          banglaName: 'এশা',
          time: pt.isha,
          icon: '🌟'),
      calculatedAt: now,
    );
  }

  /// Format a DateTime as 12-hour Bangla time (e.g., "৫:৩০ AM")
  static String formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format Duration as countdown (e.g., "২ ঘণ্টা ১৫ মিনিট")
  static String formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h ঘণ্টা $m মিনিট পরে';
    return '$m মিনিট পরে';
  }
}
