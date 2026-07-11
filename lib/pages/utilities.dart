import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/pages/hajj_umrah.dart';
import 'package:quran/pages/prayer_times.dart';
import 'package:quran/pages/ramadan.dart';
import 'package:quran/pages/tabligh.dart';
import 'package:quran/pages/itikaf.dart';
import 'package:quran/pages/janazah_ziyarat.dart';
import 'package:quran/pages/daily_duas.dart';
import 'package:quran/pages/khatam_planner.dart';
import 'package:quran/pages/zakat.dart';
import 'package:quran/pages/qibla.dart';
import 'package:quran/pages/statistics.dart';
import 'package:quran/pages/tasbih.dart';
import 'package:quran/pages/asmaul_husna_screen.dart';
import 'package:quran/pages/inheritance_screen.dart';
import 'package:quran/pages/topic_quran_screen.dart';
import 'package:quran/pages/prophets_screen.dart';
import 'package:quran/pages/qaida_screen.dart';
import 'package:quran/pages/quiz_screen.dart';
import 'package:quran/pages/sunnah_screen.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class UtilitiesScreen extends StatelessWidget {
  const UtilitiesScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("অন্যান্য সুবিধা"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ইসলামিক টুলস",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 14),

            // Grid of Utilities
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _UtilityTile(
                  icon: Icons.access_time_rounded,
                  label: "নামাজের সময়",
                  subtitle: "আজকের সূচি",
                  gradient: const [Color(0xFF00695C), Color(0xFF00897B)],
                  onTap: () => _navigate(context, const PrayerTimesScreen()),
                ),
                _UtilityTile(
                  icon: Icons.explore_rounded,
                  label: "কিবলা কম্পাস",
                  subtitle: "দিকনির্দেশনা",
                  gradient: const [Color(0xFFD84315), Color(0xFFF4511E)],
                  onTap: () => _navigate(context, const QiblaCompassScreen()),
                ),
                _UtilityTile(
                  icon: Icons.fingerprint_rounded,
                  label: "ডিজিটাল তাসবিহ",
                  subtitle: "জিকির কাউন্টার",
                  gradient: const [Color(0xFF0277BD), Color(0xFF0288D1)],
                  onTap: () => _navigate(context, const TasbihScreen()),
                ),
                _UtilityTile(
                  icon: Icons.bar_chart_rounded,
                  label: "আমার অগ্রগতি",
                  subtitle: "পাঠের পরিসংখ্যান",
                  gradient: const [Color(0xFF5E35B1), Color(0xFF673AB7)],
                  onTap: () => _navigate(context, const StatisticsScreen()),
                ),
                _UtilityTile(
                  icon: Icons.format_list_numbered_rounded,
                  label: "আসমাউল হুসনা",
                  subtitle: "আল্লাহর ৯৯ নাম",
                  gradient: const [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  onTap: () => _navigate(context, const AsmaulHusnaScreen()),
                ),
                _UtilityTile(
                  icon: Icons.description_outlined,
                  label: "ওসীয়তনামা ও বণ্টন",
                  subtitle: "উত্তরাধিকার হিসাব",
                  gradient: const [Color(0xFF4527A0), Color(0xFF673AB7)],
                  onTap: () => _navigate(context, const InheritanceScreen()),
                ),
                _UtilityTile(
                  icon: Icons.menu_book_rounded,
                  label: "বিষয়ভিত্তিক কুরআন",
                  subtitle: "আয়াত ইনডেক্স",
                  gradient: const [Color(0xFF00796B), Color(0xFF009688)],
                  onTap: () => _navigate(context, const TopicQuranScreen()),
                ),
                _UtilityTile(
                  icon: Icons.auto_stories_rounded,
                  label: "নবীদের কাহিনী",
                  subtitle: "সীরাত ও জীবনী",
                  gradient: const [Color(0xFFE65100), Color(0xFFEF6C00)],
                  onTap: () => _navigate(context, const ProphetsScreen()),
                ),
                _UtilityTile(
                  icon: Icons.school_rounded,
                  label: "সহজ কুরআন শিক্ষা",
                  subtitle: "কায়দা ও মাখরাজ",
                  gradient: const [Color(0xFF006064), Color(0xFF00838F)],
                  onTap: () => _navigate(context, const QaidaScreen()),
                ),
                _UtilityTile(
                  icon: Icons.quiz_rounded,
                  label: "শব্দার্থ কুইজ",
                  subtitle: "কুরআন শব্দ শিখুন",
                  gradient: const [Color(0xFF0277BD), Color(0xFF01579B)],
                  onTap: () => _navigate(context, const QuizScreen()),
                ),
                _UtilityTile(
                  icon: Icons.today_rounded,
                  label: "সুন্নাহ ট্র্যাকার",
                  subtitle: "আমল ও অভ্যাস",
                  gradient: const [Color(0xFFD84315), Color(0xFFBF360C)],
                  onTap: () => _navigate(context, const SunnahScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "বিশেষ নির্দেশিকা",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 14),
            _HajjUmrahBanner(
              onTap: () => _navigate(context, const HajjUmrahScreen()),
            ),
            const SizedBox(height: 14),
            _RamadanBanner(
              onTap: () => _navigate(context, const RamadanScreen()),
            ),
            const SizedBox(height: 14),
            _TablighBanner(
              onTap: () => _navigate(context, const TablighScreen()),
            ),
            const SizedBox(height: 14),
            _ItikafBanner(
              onTap: () => _navigate(context, const ItikafScreen()),
            ),
            const SizedBox(height: 14),
            _JanazahZiyaratBanner(
              onTap: () => _navigate(context, const JanazahZiyaratScreen()),
            ),
            const SizedBox(height: 14),
            _DailyDuasBanner(
              onTap: () => _navigate(context, const DailyDuasScreen()),
            ),
            const SizedBox(height: 14),
            _KhatamPlannerBanner(
              onTap: () => _navigate(context, const KhatamPlannerScreen()),
            ),
            const SizedBox(height: 14),
            _ZakatBanner(
              onTap: () => _navigate(context, const ZakatScreen()),
            ),
            const SizedBox(height: 14),
            _AsmaulHusnaBanner(
              onTap: () => _navigate(context, const AsmaulHusnaScreen()),
            ),
            const SizedBox(height: 14),
            _InheritanceBanner(
              onTap: () => _navigate(context, const InheritanceScreen()),
            ),
            const SizedBox(height: 14),
            _TopicQuranBanner(
              onTap: () => _navigate(context, const TopicQuranScreen()),
            ),
            const SizedBox(height: 14),
            _ProphetsBanner(
              onTap: () => _navigate(context, const ProphetsScreen()),
            ),
            const SizedBox(height: 14),
            _QaidaBanner(
              onTap: () => _navigate(context, const QaidaScreen()),
            ),
            const SizedBox(height: 14),
            _QuizBanner(
              onTap: () => _navigate(context, const QuizScreen()),
            ),
            const SizedBox(height: 14),
            _SunnahBanner(
              onTap: () => _navigate(context, const SunnahScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZakatBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ZakatBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB78628), Color(0xFFC6933A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB78628).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.calculate_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "জাকাত",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "সহজে আপনার জাকাত হিসাব করুন ও সঠিক নিয়ম জানুন",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _KhatamPlannerBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _KhatamPlannerBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A148C).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "কুরআন খতম প্ল্যানার",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "রমজান ও সারা বছরের কুরআন খতমের পরিকল্পনা",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyDuasBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyDuasBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006064), Color(0xFF0097A7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006064).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "দৈনন্দিন দোয়া ও আমল",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "প্রতিদিনের প্রয়োজনীয় দোয়া ও ফজিলতপূর্ণ আমল",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _JanazahZiyaratBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _JanazahZiyaratBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF37474F), Color(0xFF455A64)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37474F).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "জানাযা ও কবর জিয়ারত",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "জানাযার নামাজ ও কবর জিয়ারতের নিয়ম ও দোয়া",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItikafBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ItikafBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.roofing_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ইতিকাফ সাথী",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "১০ দিনের ইতিকাফ গাইড ও আমল ট্র্যাকার",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _TablighBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _TablighBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00796B)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004D40).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "তাবলিগ সাথী",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ছয় উসুল ও চিল্লা সফর ট্র্যাকার",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _RamadanBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _RamadanBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF1A237E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "রমজান ও রোজা গাইড",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "সেহরি-ইফতারের সময়, কাউন্টডাউন, দোয়া ও আমল ট্র্যাকার",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _HajjUmrahBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _HajjUmrahBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E342E).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "হজ ও ওমরাহ নির্দেশিকা",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ধাপ অনুসারে সহজ হজ ও ওমরাহ গাইড এবং প্রয়োজনীয় দোয়া সমূহ",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _UtilityTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AsmaulHusnaBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AsmaulHusnaBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1A4A1A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Arabic calligraphy
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اللَّهُ',
                  style: TextStyle(
                    fontFamily: 'Lateef',
                    fontSize: 44,
                    color: AppColors.goldLight,
                    height: 1.0,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'আসমাউল হুসনা',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'আল্লাহর ৯৯টি সুন্দর নাম — অর্থ, ফজিলত ও ধিকর কাউন্টার সহ',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '৯৯টি নাম দেখুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InheritanceBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _InheritanceBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4527A0), Color(0xFF673AB7), Color(0xFF311B92)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4527A0).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: icon
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'উত্তরাধিকার ও ওসীয়তনামা',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'শরিয়ত সম্মত সম্পত্তি বণ্টন হিসাব করুন এবং একটি আইনসম্মত ওসীয়তনামা (ইসলামিক উইল) PDF তৈরি ও প্রিন্ট করুন',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'হিসাব করুন ও উইল তৈরি করুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicQuranBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _TopicQuranBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00796B), Color(0xFF009688), Color(0xFF004D40)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00796B).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'বিষয়ভিত্তিক কুরআন',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ঈমান, ইবাদত, নৈতিকতা ও পারিবারিক জীবনের মতো গুরুত্বপূর্ণ বিষয়ে কুরআনের প্রাসঙ্গিক আয়াতসমূহ এক নজরে দেখুন',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'আয়াতসমূহ দেখুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProphetsBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ProphetsBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE65100), Color(0xFFEF6C00), Color(0xFFE65100)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'নবীদের কাহিনী ও সীরাত',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'হযরত মুহাম্মদ (সা.)-এর পবিত্র সীরাত ও জীবনচরিত সহ অন্যান্য গুরুত্বপূর্ণ নবীদের কাহিনী বিস্তারিত পড়ুন',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'কাহিনী ও সীরাত পড়ুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QaidaBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _QaidaBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF004D40)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006064).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'সহজ কুরআন শিক্ষা (কায়দা)',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'উচ্চারণের সঠিক মাখরাজ ও হরকতের ব্যবহারসহ সম্পূর্ণ নূরানী কায়দা পদ্ধতি শিখুন শূন্য থেকে শুরু করে',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'কুরআন শিক্ষা শুরু করুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _QuizBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0277BD), Color(0xFF0288D1), Color(0xFF01579B)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0277BD).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.quiz_rounded,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'কুরআনিক শব্দার্থ কুইজ',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'কুরআনে বহুল ব্যবহৃত গুরুত্বপূর্ণ শব্দাবলীর অর্থ শিখুন এবং মজাদার কুইজ গেমের মাধ্যমে নিজেকে যাচাই করুন',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'কুইজ খেলা শুরু করুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunnahBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SunnahBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD84315), Color(0xFFF4511E), Color(0xFFBF360C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD84315).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.today_rounded,
                  size: 40,
                  color: AppColors.goldLight,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'সুন্নাহ ট্র্যাকার',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'দৈনন্দিন গুরুত্বপূর্ণ সুন্নাহ অভ্যাসসমূহ ট্র্যাক করুন এবং প্রতিটির ফজিলত ও আমলের নিয়ম জানুন',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'সুন্নাহ ট্র্যাকার দেখুন →',
                      style: GoogleFonts.poppins(
                        color: AppColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




