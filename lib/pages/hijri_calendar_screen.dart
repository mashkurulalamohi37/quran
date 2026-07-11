import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:quran/theme/app_theme.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late int _currentYear;
  late int _currentMonth;
  late HijriCalendar _todayHijri;

  static const List<String> _hijriMonthsArabic = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const List<String> _hijriMonthsBengali = [
    'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
    'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান',
    'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
  ];

  static const List<String> _weekdaysBengali = [
    'রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি'
  ];

  static const Map<int, List<String>> _islamicEvents = {
    1: ["১০ মুহাররম: পবিত্র আশুরা (আশুরা দিবস)"],
    3: ["১২ রবিউল আউয়াল: পবিত্র ঈদে মিলাদুন্নবী (সা.)"],
    7: ["২৭ রজব: পবিত্র শবে মিরাজ"],
    8: ["১৫ শাবান: পবিত্র শবে বরাত"],
    9: ["১ রমজান: পবিত্র রমজান মাস শুরু", "শেষ দশক: পবিত্র লাইলাতুল কদর"],
    10: ["১ শাওয়াল: পবিত্র ঈদুল ফিতর"],
    12: ["৯ জিলহজ: পবিত্র আরাফাত দিবস", "১০ জিলহজ: পবিত্র ঈদুল আজহা"],
  };

  @override
  void initState() {
    super.initState();
    _todayHijri = HijriCalendar.now();
    _currentYear = _todayHijri.hYear;
    _currentMonth = _todayHijri.hMonth;
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Days in current Hijri month
    final calendarHelper = HijriCalendar();
    calendarHelper.hYear = _currentYear;
    calendarHelper.hMonth = _currentMonth;
    calendarHelper.hDay = 1;
    final totalDays = calendarHelper.getDaysInMonth(_currentYear, _currentMonth);

    // Find the Gregorian weekday of day 1 of the Hijri month to set the offset
    final firstDayGregorian = calendarHelper.hijriToGregorian(_currentYear, _currentMonth, 1);
    
    // Mapping: Sunday (7) -> 0, Monday (1) -> 1, ..., Saturday (6) -> 6
    final startOffset = firstDayGregorian.weekday == DateTime.sunday ? 0 : firstDayGregorian.weekday;

    // Events for current month
    final events = _islamicEvents[_currentMonth] ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("হিজরি ক্যালেন্ডার"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Header Control bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.emerald),
                  onPressed: _prevMonth,
                ),
                Column(
                  children: [
                    Text(
                      _hijriMonthsArabic[_currentMonth - 1],
                      style: const TextStyle(
                        fontFamily: 'Lateef',
                        fontSize: 28,
                        color: AppColors.emerald,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "${_hijriMonthsBengali[_currentMonth - 1]} ${_toBengaliNum(_currentYear)} হিজরি",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.emerald),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // ── Weekday Labels ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdaysBengali.map((day) {
                final isWeekend = day == 'শুক্র';
                return SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isWeekend
                          ? Colors.red
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Calendar Days Grid ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: startOffset + totalDays,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (ctx, index) {
                if (index < startOffset) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - startOffset + 1;
                final isToday = _todayHijri.hYear == _currentYear &&
                    _todayHijri.hMonth == _currentMonth &&
                    _todayHijri.hDay == dayNum;

                // Find corresponding Gregorian date
                final gregDate = calendarHelper.hijriToGregorian(_currentYear, _currentMonth, dayNum);

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.emerald.withValues(alpha: 0.15)
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
                          ? AppColors.emerald
                          : (isDark ? Colors.white10 : Colors.black12),
                      width: isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _toBengaliNum(dayNum),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? AppColors.emerald
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${gregDate.day}",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Events Section ──
          if (events.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_note_rounded, color: AppColors.emerald, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "ইসলামিক দিবস ও উৎসব",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  ...events.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          "• $e",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
