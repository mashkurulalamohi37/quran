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
import 'package:quran/pages/namaj_shikha.dart';
import 'package:quran/pages/ruqyah_screen.dart';
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
        title: const Text("অন্যান্য সুবিধা ও আমল"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category 1: ইবাদত ও দৈনন্দিন আমল
            _buildCategoryHeader("ইবাদত ও দৈনন্দিন আমল", isDark),
            const SizedBox(height: 10),
            _buildTileGrid([
              _CompactUtilityTile(
                icon: Icons.access_time_rounded,
                label: "নামাজের সময়",
                subtitle: "আজকের সালাত সূচি",
                iconColor: const Color(0xFF00897B),
                bgTint: const Color(0xFF00897B),
                onTap: () => _navigate(context, const PrayerTimesScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.explore_rounded,
                label: "কিবলা কম্পাস",
                subtitle: "দিকনির্দেশনা",
                iconColor: const Color(0xFFF4511E),
                bgTint: const Color(0xFFF4511E),
                onTap: () => _navigate(context, const QiblaCompassScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.fingerprint_rounded,
                label: "ডিজিটাল তাসবিহ",
                subtitle: "জিকির কাউন্টার",
                iconColor: const Color(0xFF0288D1),
                bgTint: const Color(0xFF0288D1),
                onTap: () => _navigate(context, const TasbihScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.auto_stories_rounded,
                label: "দোয়া ও আমল",
                subtitle: "দৈনন্দিন দোয়া সমূহ",
                iconColor: const Color(0xFF0097A7),
                bgTint: const Color(0xFF0097A7),
                onTap: () => _navigate(context, const DailyDuasScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.today_rounded,
                label: "সুন্নাহ ট্র্যাকার",
                subtitle: "আমল ও অভ্যাস",
                iconColor: const Color(0xFFD84315),
                bgTint: const Color(0xFFD84315),
                onTap: () => _navigate(context, const SunnahScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.shield_outlined,
                label: "রুকিয়া শরইয়াহ",
                subtitle: "কুরআনি আরোগ্য",
                iconColor: const Color(0xFF00796B),
                bgTint: const Color(0xFF00796B),
                onTap: () => _navigate(context, const RuqyahScreen()),
              ),
            ]),
            const SizedBox(height: 24),

            // Category 2: বিশেষ গাইড ও ট্র্যাকার
            _buildCategoryHeader("বিশেষ গাইড ও ট্র্যাকার", isDark),
            const SizedBox(height: 10),
            _buildTileGrid([
              _CompactUtilityTile(
                icon: Icons.mosque_rounded,
                label: "হজ ও ওমরাহ",
                subtitle: "ধাপভিত্তিক গাইড",
                iconColor: const Color(0xFF8D6E63),
                bgTint: const Color(0xFF8D6E63),
                onTap: () => _navigate(context, const HajjUmrahScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.nightlight_round,
                label: "রমজান ও রোজা",
                subtitle: "সেহরি ও ইফতার",
                iconColor: const Color(0xFF311B92),
                bgTint: const Color(0xFF311B92),
                onTap: () => _navigate(context, const RamadanScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.roofing_rounded,
                label: "ইতিকাফ সাথী",
                subtitle: "আমল ট্র্যাকার",
                iconColor: const Color(0xFF283593),
                bgTint: const Color(0xFF283593),
                onTap: () => _navigate(context, const ItikafScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.travel_explore_rounded,
                label: "তাবলিগ সাথী",
                subtitle: "চিল্লা সফর ট্র্যাকার",
                iconColor: const Color(0xFF00796B),
                bgTint: const Color(0xFF00796B),
                onTap: () => _navigate(context, const TablighScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.menu_book_rounded,
                label: "খতম প্ল্যানার",
                subtitle: "কুরআন খতম প্ল্যান",
                iconColor: const Color(0xFF7B1FA2),
                bgTint: const Color(0xFF7B1FA2),
                onTap: () => _navigate(context, const KhatamPlannerScreen()),
              ),
            ]),
            const SizedBox(height: 24),

            // Category 3: শিক্ষা ও কুইজ
            _buildCategoryHeader("শিক্ষা ও কুইজ", isDark),
            const SizedBox(height: 10),
            _buildTileGrid([
              _CompactUtilityTile(
                icon: Icons.school_rounded,
                label: "কুরআন শিক্ষা",
                subtitle: "কায়দা ও মাখরাজ",
                iconColor: const Color(0xFF00838F),
                bgTint: const Color(0xFF00838F),
                onTap: () => _navigate(context, const QaidaScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.menu_book_outlined,
                label: "নামাজ শিক্ষা",
                subtitle: "ওযু ও সালাত নিয়ম",
                iconColor: const Color(0xFF2E7D32),
                bgTint: const Color(0xFF2E7D32),
                onTap: () => _navigate(context, const NamajShikhaScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.quiz_rounded,
                label: "শব্দার্থ কুইজ",
                subtitle: "কুরআনি শব্দ শিখুন",
                iconColor: const Color(0xFF0277BD),
                bgTint: const Color(0xFF0277BD),
                onTap: () => _navigate(context, const QuizScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.auto_stories_rounded,
                label: "নবীদের কাহিনী",
                subtitle: "সীরাত ও জীবনী",
                iconColor: const Color(0xFFEF6C00),
                bgTint: const Color(0xFFEF6C00),
                onTap: () => _navigate(context, const ProphetsScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.format_list_numbered_rounded,
                label: "আসমাউল হুসনা",
                subtitle: "আল্লাহর ৯৯ নাম",
                iconColor: const Color(0xFF388E3C),
                bgTint: const Color(0xFF388E3C),
                onTap: () => _navigate(context, const AsmaulHusnaScreen()),
              ),
            ]),
            const SizedBox(height: 24),

            // Category 4: হিসাব ও অন্যান্য
            _buildCategoryHeader("হিসাব ও অন্যান্য", isDark),
            const SizedBox(height: 10),
            _buildTileGrid([
              _CompactUtilityTile(
                icon: Icons.calculate_rounded,
                label: "জাকাত",
                subtitle: "সম্পত্তির জাকাত",
                iconColor: const Color(0xFFC6933A),
                bgTint: const Color(0xFFC6933A),
                onTap: () => _navigate(context, const ZakatScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.description_outlined,
                label: "ওসীয়তনামা",
                subtitle: "উত্তরাধিকার বণ্টন",
                iconColor: const Color(0xFF673AB7),
                bgTint: const Color(0xFF673AB7),
                onTap: () => _navigate(context, const InheritanceScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.volunteer_activism_rounded,
                label: "জানাযা ও কবর",
                subtitle: "নিয়ম ও দোয়া",
                iconColor: const Color(0xFF455A64),
                bgTint: const Color(0xFF455A64),
                onTap: () => _navigate(context, const JanazahZiyaratScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.menu_book_rounded,
                label: "বিষয়ভিত্তিক কুরআন",
                subtitle: "আয়াত ইনডেক্স",
                iconColor: const Color(0xFF009688),
                bgTint: const Color(0xFF009688),
                onTap: () => _navigate(context, const TopicQuranScreen()),
              ),
              _CompactUtilityTile(
                icon: Icons.bar_chart_rounded,
                label: "আমার অগ্রগতি",
                subtitle: "পাঠের পরিসংখ্যান",
                iconColor: const Color(0xFF673AB7),
                bgTint: const Color(0xFF673AB7),
                onTap: () => _navigate(context, const StatisticsScreen()),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.emeraldLight : AppColors.emerald,
        ),
      ),
    );
  }

  Widget _buildTileGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: children,
    );
  }
}

class _CompactUtilityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final Color bgTint;
  final VoidCallback onTap;

  const _CompactUtilityTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.bgTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final txtColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bgTint.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: subColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
