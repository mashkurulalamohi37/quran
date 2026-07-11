import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class TablighScreen extends StatefulWidget {
  const TablighScreen({super.key});

  @override
  State<TablighScreen> createState() => _TablighScreenState();
}

class _TablighScreenState extends State<TablighScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String title) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "$title কপি করা হয়েছে! 📋",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.emerald,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("তাবলিগ সাথী"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "ছয় উসুল"),
            Tab(text: "চিল্লা ট্র্যাকার"),
            Tab(text: "গাশত ও সফর আদব"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsulTab(context, settings, isDark),
          _buildChillaTab(context, settings, isDark),
          _buildMannersTab(context, settings, isDark),
        ],
      ),
    );
  }

  Widget _buildUsulTab(BuildContext context, SettingsService settings, bool isDark) {
    final principles = _getSixUsul();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: principles.length,
      itemBuilder: (context, index) {
        final p = principles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldLight,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                p.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              subtitle: Text(
                p.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        "মূল উদ্দেশ্য:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.objective,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "বিস্তারিত আলোচনা:",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.emeraldLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.details,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          height: 1.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChillaTab(BuildContext context, SettingsService settings, bool isDark) {
    if (!settings.isChillaActive) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "চিল্লা বা সফর শুরু করুন",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "তাবলিগি মেহনতের একটি গুরুত্বপূর্ণ আমল হলো আল্লাহর রাস্তায় সফর। নিচে থেকে আপনার সফরের মেয়াদ সিলেক্ট করে ট্র্যাকার চালু করুন।",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            _buildChillaSetupTile(
              context,
              settings,
              title: "৩ দিন (তিন দিনের জামাত)",
              subtitle: "সে-রোজা বা সংক্ষিপ্ত সফর",
              duration: 3,
              gradient: const [Color(0xFF00695C), Color(0xFF00897B)],
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 14),
            _buildChillaSetupTile(
              context,
              settings,
              title: "৪০ দিন (এক চিল্লা সফর)",
              subtitle: "১ম চিল্লা বা সাধারণ চিল্লা মেহনত",
              duration: 40,
              gradient: const [Color(0xFF004D40), Color(0xFF00796B)],
              icon: Icons.date_range_rounded,
            ),
            const SizedBox(height: 14),
            _buildChillaSetupTile(
              context,
              settings,
              title: "১২০ দিন (তিন চিল্লা সফর)",
              subtitle: "হালকা বা পূর্ণাঙ্গ জামাত মেহনত",
              duration: 120,
              gradient: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              icon: Icons.history_edu_rounded,
            ),
          ],
        ),
      );
    }

    final totalDays = settings.chillaDuration;
    final completedDays = settings.chillaDaysCompleted;
    final progress = totalDays > 0 ? completedDays / totalDays : 0.0;
    final activeDay = completedDays < totalDays ? completedDays + 1 : totalDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Chilla Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004D40).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$totalDays দিনের সক্রিয় চিল্লা",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "শুরু: ${settings.chillaStartDate}",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white70),
                      onPressed: () => _confirmStopChilla(context, settings),
                      tooltip: "সফর শেষ করুন",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            color: AppColors.goldLight,
                          ),
                        ),
                        Text(
                          "${(progress * 100).round()}%",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "অগ্রগতি: $completedDays / $totalDays দিন সম্পন্ন",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: completedDays > 0 ? () => settings.decrementChillaDay() : null,
                                child: const Icon(Icons.remove, size: 16),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: completedDays < totalDays ? () => settings.incrementChillaDay() : null,
                                child: const Row(
                                  children: [
                                    Text("পরবর্তী দিন", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 4),
                                    Icon(Icons.add, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Checklist for Jala/Gasht
          if (completedDays < totalDays) ...[
            Text(
              "আমল তালিকা - দিন $activeDay",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildChillaDeedTile(settings, activeDay, "gasht_general", "উমূমী গাশত (সাধারণ গাশত)", Icons.people_alt_rounded, Colors.teal),
                    const Divider(height: 1),
                    _buildChillaDeedTile(settings, activeDay, "gasht_special", "খুসূসী গাশত (বিশেষ দাওয়াত)", Icons.group_add_rounded, Colors.blue),
                    const Divider(height: 1),
                    _buildChillaDeedTile(settings, activeDay, "taleem", "সকাল ও বিকেলের তালীম", Icons.menu_book_rounded, Colors.purple),
                    const Divider(height: 1),
                    _buildChillaDeedTile(settings, activeDay, "prayers", "৫ ওয়াক্ত নামাজ জামাতে আদায়", Icons.check_circle_outline_rounded, AppColors.emerald),
                    const Divider(height: 1),
                    _buildChillaDeedTile(settings, activeDay, "reading", "ফজিলতের কিতাব তিলাওয়াত", Icons.auto_stories_rounded, Colors.orange),
                    const Divider(height: 1),
                    _buildChillaDeedTile(settings, activeDay, "dhikr", "ব্যক্তিগত জিকির ও তাসবিহ", Icons.fingerprint_rounded, Colors.redAccent),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 64),
                    const SizedBox(height: 14),
                    Text(
                      "অভিনন্দন! 🎉",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "আপনার $totalDays দিনের চিল্লা সফলভাবে সমাপ্ত হয়েছে।\nআল্লাহ আপনার মেহনত কবুল করুন।",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChillaSetupTile(
    BuildContext context,
    SettingsService settings, {
    required String title,
    required String subtitle,
    required int duration,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        onTap: () => settings.startChilla(duration),
      ),
    );
  }

  Widget _buildChillaDeedTile(
    SettingsService settings,
    int dayIndex,
    String deedId,
    String title,
    IconData icon,
    Color color,
  ) {
    final completedDeeds = settings.getChillaDeeds(dayIndex);
    final isDone = completedDeeds.contains(deedId);

    return CheckboxListTile(
      activeColor: AppColors.emerald,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      secondary: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      value: isDone,
      onChanged: (v) {
        settings.toggleChillaDeed(dayIndex, deedId);
      },
    );
  }

  void _confirmStopChilla(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("সফর শেষ করবেন?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("সক্রিয় চিল্লা বন্ধ করলে সমস্ত রেকর্ড মুছে যাবে। আপনি কি নিশ্চিত?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.stopChilla();
              Navigator.pop(ctx);
            },
            child: const Text("শেষ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMannersTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "গাশত ও দাওয়াতের আদব সমূহ",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 10),
        _buildMannersCard(
          isDark: isDark,
          title: "উমূমী গাশত (সাধারণ গাশত)",
          bulletPoints: [
            "গাশত শুরু করার পূর্বে মসজিদে বসে আমীরের বয়ান ও হেদায়েত ভালো করে শুনতে হবে।",
            "গাশতের জামাত চলাকালে সবাইকে জিকিরে মশগুল থাকতে হবে এবং চোখ অবনত রাখতে হবে।",
            "দাওয়াত দেওয়ার সময় নরম ভাষা ও বিনয় ব্যবহার করতে হবে।",
            "রাস্তায় কোনো প্রকার বিশৃঙ্খলা করা যাবে না, কাতারবদ্ধ হয়ে চলতে হবে।"
          ],
        ),
        _buildMannersCard(
          isDark: isDark,
          title: "সফরের প্রয়োজনীয় আমল",
          bulletPoints: [
            "জামাতের আমীরের নির্দেশ ও সিদ্ধান্ত অনুযায়ী চলা ওয়াজিব।",
            "ব্যক্তিগত আমল, রাত জেগে সালাত ও ক্রন্দন করা জামাতের বরকতের কারণ।",
            "খেদমতগার বা সা সাথীদের সেবা করা অত্যন্ত ফজিলতপূর্ণ কাজ।"
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "সফরের প্রয়োজনীয় দোয়া",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 10),
        _buildDuaItem(
          isDark: isDark,
          title: "বাহনে আরোহণের দোয়া",
          arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
          pronunciation: "সুবহানাল্লাজি সাখখারা লানা হাজা ওয়ামা কুন্না লাহু মুকরিনীন, ওয়া ইন্না ইলা রাব্বিনা লামুনকালিবুন।",
          translation: "পবিত্র সেই আল্লাহ, যিনি আমাদের জন্য এই বাহনকে বশীভূত করেছেন অথচ আমরা একে বশীভূত করতে সমর্থ ছিলাম না। আর নিশ্চয়ই আমরা আমাদের রবের দিকে ফিরে যাব।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "সফর শুরু করার দোয়া (যাত্রাপথের দোয়া)",
          arabic: "اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى",
          pronunciation: "আল্লাহুম্মা ইন্না নাসআলুকা ফী সাফারিনা হাজাল বিররা ওয়াত্তাকওয়া, ওয়া মিনাল আমালি মা তারদা।",
          translation: "হে আল্লাহ! আমরা আমাদের এই সফরে আপনার নিকট পুণ্য ও তাকওয়া প্রার্থনা করছি, এবং এমন আমল প্রার্থনা করছি যা আপনি পছন্দ করেন।"
        ),
      ],
    );
  }

  Widget _buildMannersCard({required bool isDark, required String title, required List<String> bulletPoints}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
            ),
            const SizedBox(height: 8),
            ...bulletPoints.map((pt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          pt,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaItem({
    required bool isDark,
    required String title,
    required String arabic,
    required String pronunciation,
    required String translation,
  }) {
    final text = "$title:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation\n\nঅনুবাদ: $translation";
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16),
                onPressed: () => _copyToClipboard(text, title),
                tooltip: "দোয়া কপি করুন",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              arabic,
              style: TextStyle(
                fontFamily: 'Lateef',
                fontSize: 24,
                height: 1.8,
                color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "উচ্চারণ: $pronunciation",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "অনুবাদ: $translation",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  List<_UsulItem> _getSixUsul() {
    return [
      _UsulItem(
        title: "কালেমা (বিস্বাস ও নিয়ত)",
        subtitle: "আল্লাহ ছাড়া কোনো ইলাহ নেই এবং মুহাম্মাদ (সা.) তাঁর রাসূল",
        objective: "১. অন্তরে এই বিশ্বাস আনা যে, সমস্ত মাখলুক কিছু করতে পারে না আল্লাহর হুকুম ছাড়া। আর আল্লাহ তায়ালা সবকিছু করতে পারেন কোনো মাখলুক ছাড়া।\n২. সমস্ত কাজ রাসূলুল্লাহ (সা.) এর পবিত্র তরীকায় করার মানসিকতা অর্জন করা।",
        details: "এটি ঈমানের বুনিয়াদ। কালেমার প্রথম অংশ দ্বারা তাওহীদ (আল্লাহর একত্ববাদ) এবং দ্বিতীয় অংশ দ্বারা রিসালাত (মুহাম্মাদ সা. এর নবুওয়াত) সাব্যস্ত হয়। এই কালেমার নিয়মিত জিকির অন্তরে নূর ও আত্মিক বল সৃষ্টি করে।"
      ),
      _UsulItem(
        title: "নামাজ (Salah)",
        subtitle: "খুশু-খুজুর সাথে সময়মত সালাত আদায়",
        objective: "১. নামাজের বাইরের জীবনেও ২৪ ঘণ্টা আল্লাহর হুকুম ও তরীকা অনুযায়ী চলার যোগ্যতা অর্জন করা।\n২. আল্লাহর মহানতা ও আধিপত্য অন্তরে গেঁথে নেওয়া।",
        details: "নামাজ হলো দ্বীনের খুঁটি। যখন নামাজ সুন্দর হবে, তখন জীবনের সমস্ত আমল সংশোধন হতে শুরু করবে। নামাজের মাধ্যমে মুমিন বান্দা আল্লাহর সবচেয়ে কাছাকাছি পৌঁছাতে পারে।"
      ),
      _UsulItem(
        title: "ইলম ও জিকির (Knowledge & Remembrance)",
        subtitle: "দ্বীন শিক্ষা এবং সার্বক্ষণিক স্মরণ",
        objective: "১. আল্লাহর আদেশ-নিষেধ চেনার জন্য ইলম (সঠিক জ্ঞান) অর্জন করা।\n২. জীবনের প্রতিটি মুহূর্ত জিকির বা স্মরণের মাধ্যমে আল্লাহকে হাজির-নাজির মনে করে অতিবাহিত করা।",
        details: "ইলম দুই প্রকার: মাসায়েল (আদেশ-নিষেধের জ্ঞান) ও ফাযায়েল (আমলের প্রতিদান ও ভালোবাসার জ্ঞান)। ইলম অনুযায়ী আমল করার জন্য সার্বক্ষণিক জিকিরের প্রয়োজন। জিকির হৃদয়কে জীবন্ত রাখে।"
      ),
      _UsulItem(
        title: "একরামুল মুসলিমীন (Honoring Muslims)",
        subtitle: "মুসলমানদের সেবা ও সম্মান প্রদর্শন",
        objective: "১. রাসূলুল্লাহ (সা.) এর খাতিরে সমস্ত উম্মত ও মুসলমানকে সম্মান করা।\n২. নিজের অধিকার ছেড়ে দিয়ে অপরের অধিকার ও সম্মান রক্ষায় সচেষ্ট হওয়া।",
        details: "মুসলমানের সেবাকারীর জন্য আল্লাহ তায়ালার পক্ষ থেকে প্রভূত রহমত রয়েছে। রাসূলুল্লাহ (সা.) বলেছেন, 'যে ব্যক্তি মানুষের ওপর দয়া করে না, আল্লাহও তার ওপর দয়া করেন না।' বড়দের শ্রদ্ধা, ছোটদের স্নেহ এবং সমসাময়িকদের প্রতি সহমর্মিতা একরামুল মুসলিমীন এর অন্তর্ভুক্ত।"
      ),
      _UsulItem(
        title: "ইখলাসে নিয়ত (Sincerity of Intention)",
        subtitle: "একমাত্র আল্লাহর সন্তুষ্টির উদ্দেশ্যে আমল করা",
        objective: "১. সমস্ত ভালো কাজ বা আমল খাঁটি নিয়তে লোকদেখানো মনোভাব (রিয়া) মুক্ত হয়ে একমাত্র আল্লাহর রাজির জন্য করা।\n২. সুনাম বা কোনো পার্থিব সুবিধার প্রত্যাশা বর্জন করা।",
        details: "আমলের গ্রহণযোগ্যতা নিয়তের ওপর নির্ভরশীল। ইখলাসবিহীন পর্বতসম আমলও কিয়ামতের দিন ধূলিকণার মত উড়িয়ে দেওয়া হবে, আর খাঁটি নিয়তে একটি সামান্য আমলও নাজাতের উসিলা হতে পারে।"
      ),
      _UsulItem(
        title: "দাওয়াত ও তাবলিগ (Calling to Islam)",
        subtitle: "জান ও মাল খরচ করে আল্লাহর রাস্তায় মেহনত",
        objective: "১. নিজের ঈমান মজবুত করা এবং বিশ্বজগতের সমস্ত মানুষের মধ্যে আল্লাহর দ্বীন ছড়িয়ে দেওয়ার জন্য মেহনত করা।\n২. সাহাবিদের অনুসরণে জান ও মাল নিয়ে আল্লাহর রাস্তায় বের হওয়া।",
        details: "দাওয়াত ও তাবলিগের কাজ নবীদের উত্তরাধিকার। এই মেহনত মানুষকে দুনিয়াবিমুখ করে এবং আখিরাতমুখী হতে সাহায্য করে। চিল্লা বা আল্লাহর রাস্তায় সময় দেওয়ার মাধ্যমে দাওয়াতের আদব ও দ্বীনের ওপর টিকে থাকার মনোবল তৈরি হয়।"
      ),
    ];
  }
}

class _UsulItem {
  final String title;
  final String subtitle;
  final String objective;
  final String details;

  const _UsulItem({
    required this.title,
    required this.subtitle,
    required this.objective,
    required this.details,
  });
}
