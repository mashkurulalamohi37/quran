import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class JanazahZiyaratScreen extends StatefulWidget {
  const JanazahZiyaratScreen({super.key});

  @override
  State<JanazahZiyaratScreen> createState() => _JanazahZiyaratScreenState();
}

class _JanazahZiyaratScreenState extends State<JanazahZiyaratScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text("জানাযা ও কবর জিয়ারত"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "জানাযার নামাজ"),
            Tab(text: "কবর জিয়ারত"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJanazahTab(context, settings, isDark),
          _buildZiyaratTab(context, settings, isDark),
        ],
      ),
    );
  }

  Widget _buildJanazahTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "জানাযার নামাজের ফজিলত ও গুরুত্ব",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "রাসূলুল্লাহ (সা.) বলেছেন: \"যে ব্যক্তি কোনো মৃতের জানাযার নামাজ আদায় করে, সে এক ক্বীরাত নেকি লাভ করে। আর যে ব্যক্তি তার দাফন কাজেও শরিক থাকে, সে দুই ক্বীরাত নেকি পায়।\" সাহাবিগণ জিজ্ঞেস করলেন, দুই ক্বীরাত কী? তিনি বললেন, \"দুটি বিশাল পাহাড়ের সমান নেকি।\" (সহিহ বুখারি)",
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.6,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "জানাযার ৪ তাকবীরের বিবরণ ও নিয়ম",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 8),
        _buildStepCard(
          isDark: isDark,
          stepNum: "১ম তাকবীর",
          title: "তাকবীরে তাহরীমা ও ছানা পাঠ",
          desc: "আল্লাহু আকবার বলে কান পর্যন্ত হাত উঠিয়ে বাম হাতের ওপর ডান হাত নাভির নিচে (অথবা বুকের ওপর) বাঁধুন। এরপর ছানা পাঠ করুন (স্বাভাবিক নামাজের ছানার মতো):",
          arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَجَلَّ ثَنَاؤُكَ، وَلَا إِلَهَ غَيْرُكَ",
          pronunciation: "সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা, ওয়া তাবারাকাসমুকা ওয়া তায়ালা জাদ্দুকা, ওয়া জাল্লা সানাউকা, ওয়া লা ইলাহা গাইরুকা।",
        ),
        _buildStepCard(
          isDark: isDark,
          stepNum: "২য় তাকবীর",
          title: "দুরুদ শরীফ পাঠ",
          desc: "হাত না ছেড়ে দ্বিতীয়বার আল্লাহু আকবার বলুন। অতঃপর দুরুদে ইব্রাহীম পাঠ করুন (যা স্বাভাবিক নামাজে আত্তাহিয়াতু এর পর পড়া হয়):",
          arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
          pronunciation: "আল্লাহুম্মা সাল্লি আলা মুহাম্মাদিও ওয়া আলা আলি মুহাম্মাদ, কামা সাল্লাইতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ। আল্লাহুম্মা বারিক আলা মুহাম্মাদিও ওয়া আলা আলি মুহাম্মাদ, কামা বারাকতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ।",
        ),
        _buildStepCard(
          isDark: isDark,
          stepNum: "৩য় তাকবীর",
          title: "মৃতের জন্য জানাযার দোয়া পাঠ",
          desc: "হাত না ছেড়ে তৃতীয়বার আল্লাহু আকবার বলুন এবং মৃতের জন্য নির্দিষ্ট দোয়া পাঠ করুন:",
          isThirdStep: true,
        ),
        _buildStepCard(
          isDark: isDark,
          stepNum: "৪র্থ তাকবীর",
          title: "সালাম ফিরিয়ে নামাজ শেষ করা",
          desc: "হাত বাঁধা অবস্থায় চতুর্থবার আল্লাহু আকবার বলুন। এরপর প্রথমে ডান দিকে এবং পরে বাম দিকে মুখ ফিরিয়ে সালাম (আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ) ফিরিয়ে নামাজ শেষ করুন এবং হাত ছেড়ে দিন।",
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required bool isDark,
    required String stepNum,
    required String title,
    required String desc,
    String? arabic,
    String? pronunciation,
    bool isThirdStep = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stepNum,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            if (arabic != null && pronunciation != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  arabic,
                  style: TextStyle(
                    fontFamily: 'Lateef',
                    fontSize: 22,
                    height: 1.6,
                    color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "উচ্চারণ: $pronunciation",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text("কপি করুন", style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    final fullText = "$stepNum - $title:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation";
                    _copyToClipboard(fullText, title);
                  },
                ),
              ),
            ],
            if (isThirdStep) ...[
              const SizedBox(height: 12),
              _buildJanazahDuaItem(
                isDark: isDark,
                duaTitle: "প্রাপ্তবয়স্ক পুরুষ ও নারীর জানাযার সাধারণ দোয়া",
                arabic: "اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا وَذَكَرِنَا وَأُنْثَانَا، اللَّهُمَّ مَنْ أَحْيَيْتَهُ مِنَّا فَأَحْيِهِ عَلَى الْإِسْلَامِ، وَمَنْ تَوَفَّيْتَهُ مِنَّا فَتَوَفَّهُ عَلَى الْإِيمَانِ",
                pronunciation: "আল্লাহুম্মাগফির লিহায়্যিনা ওয়া মাইয়্যিতিনা ওয়া শাহিদিনা ওয়া গাইবিনা ওয়া সাগীরিনা ওয়া কাবীরিনা ওয়া জাকারিনা ওয়া উনসানা। আল্লাহুম্মা মান আহইয়াইতাহু মিন্না ফাহয়িহী আলাল ইসলাম, ওয়া মান তাওয়াফফাইতাহু মিন্না ফাতাওয়াফফাহু আলাল ঈমান।",
                translation: "হে আল্লাহ! আমাদের জীবিত ও মৃত, উপস্থিত ও অনুপস্থিত, ছোট ও বড় এবং আমাদের পুরুষ ও নারীদের ক্ষমা করুন। হে আল্লাহ! আমাদের মধ্যে আপনি যাকে জীবিত রাখবেন তাকে ইসলামের ওপর জীবিত রাখুন এবং যাকে মৃত্যু দেবেন তাকে ঈমানের ওপর মৃত্যু দান করুন।",
              ),
              const SizedBox(height: 10),
              _buildJanazahDuaItem(
                isDark: isDark,
                duaTitle: "অপ্রাপ্তবয়স্ক ছেলে শিশুর (নাবালক ছেলে) জানাযার দোয়া",
                arabic: "اللَّهُمَّ اجْعَلْهُ لَنَا فَرَطًا، وَاجْعَلْهُ لَنَا أَجْرًا وَذُخْرًا، وَاجْعَلْهُ لَنَا شَافِعًا وَمُشَفَّعًا",
                pronunciation: "আল্লাহুম্মাজ আলহু লানা ফারাতাওঁ ওয়াজ আলহু লানা আজরাওঁ ওয়া জুখরাওঁ ওয়াজ আলহু লানা শাফিয়াওঁ ওয়া মুসাফফায়া।",
                translation: "হে আল্লাহ! এই শিশুকে আমাদের জন্য অগ্রগামী করুন এবং তাকে আমাদের জন্য প্রতিদান ও সম্পদ বানিয়ে দিন, আর তাকে আমাদের জন্য সুপারিশকারী করুন যার সুপারিশ কবুল করা হবে।"
              ),
              const SizedBox(height: 10),
              _buildJanazahDuaItem(
                isDark: isDark,
                duaTitle: "অপ্রাপ্তবয়স্ক মেয়ে শিশুর (নাবালক মেয়ে) জানাযার দোয়া",
                arabic: "اللَّهُمَّ اجْعَلْهَا لَنَا فَرَطًا، وَاجْعَلْهَا لَنَا أَجْرًا وَذُخْرًا، وَاجْعَلْهَا لَنَا شَافِعَةً وَمُشَفَّعَةً",
                pronunciation: "আল্লাহুম্মাজ আলহা লানা ফারাতাওঁ ওয়াজ আলহা লানা আজরাওঁ ওয়া জুখরাওঁ ওয়াজ আলহা লানা শাফিয়াতাওঁ ওয়া মুসাফফায়াহ।",
                translation: "হে আল্লাহ! এই শিশুকে আমাদের জন্য অগ্রগামী করুন এবং তাকে আমাদের জন্য প্রতিদান ও সম্পদ বানিয়ে দিন, আর তাকে আমাদের জন্য সুপারিশকারী করুন যার সুপারিশ কবুল করা হবে।"
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJanazahDuaItem({
    required bool isDark,
    required String duaTitle,
    required String arabic,
    required String pronunciation,
    required String translation,
  }) {
    final text = "$duaTitle:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation\n\nঅনুবাদ: $translation";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  duaTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.gold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14),
                onPressed: () => _copyToClipboard(text, duaTitle),
                tooltip: "কপি করুন",
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              arabic,
              style: TextStyle(
                fontFamily: 'Lateef',
                fontSize: 20,
                height: 1.6,
                color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "উচ্চারণ: $pronunciation",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "অনুবাদ: $translation",
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZiyaratTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "কবর জিয়ারতের সুন্নাত পদ্ধতি ও আদব সমূহ",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletItem(isDark, "কবর জিয়ারত করতে যাওয়ার উদ্দেশ্য হবে নিজের আখেরাতের স্মরণ এবং মৃতের রুহের মাগফিরাত কামনা।"),
                _buildBulletItem(isDark, "কবরে পৌঁছানোর পর দাঁড়ানো অবস্থায় কবরবাসীদের সালাম দিতে হবে।"),
                _buildBulletItem(isDark, "কবর জিয়ারতের সময় কবরের দিকে মুখ করে দাঁড়াতে হবে এবং নিজের পিঠ কিবলার দিকে থাকবে।"),
                _buildBulletItem(isDark, "জিয়ারতের সময় কবরের উপর বসা বা পা বাড়ানো বা কবরের উপর দিয়ে হাঁটাচলা করা সুন্নাত পরিপন্থী।"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "কবর জিয়ারতের মাসনুন দোয়া",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
        ),
        const SizedBox(height: 8),
        _buildDuaCard(
          isDark: isDark,
          title: "কবর জিয়ারতের দোয়া",
          arabic: "السَّلَامُ عَلَيْكُمْ أَهْلَ الدِّيَارِ مِنَ الْمُؤْمِنِينَ وَالْمُسْلِمِينَ، وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ، أَسْأَلُ اللَّهَ لَنَا وَلَكُمُ الْعَافِيَةَ",
          pronunciation: "আসসালামু আলাইকুম আহলাদ দিয়ারি মিনাল মুমিনীন ওয়াল মুসলিমীন, ওয়া ইন্না ইনশাআল্লাহু বিকুম লাহিকুন, নাসআলুল্লাহা লানা ওয়ালাকুমুল আফিয়াহ।",
          translation: "হে কবরবাসী মুমিন ও মুসলমানগণ! আপনাদের ওপর শান্তি বর্ষিত হোক। নিশ্চয়ই আমরাও ইনশাআল্লাহ আপনাদের সাথে মিলিত হব। আমরা আল্লাহর নিকট আমাদের ও আপনাদের জন্য নিরাপত্তা এবং ক্ষমা প্রার্থনা করছি।"
        ),
        const SizedBox(height: 16),

        Text(
          "কবর জিয়ারতে বর্জনীয় ও নিষিদ্ধ কাজ",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletItem(isDark, "শিরক ও সেজদা বর্জন: কবরে সেজদা করা বা কবরবাসীর নিকট সাহায্য চাওয়া বা কোনো প্রয়োজন মেটানোর আবেদন করা স্পষ্ট শিরক। সাহায্য শুধুমাত্র আল্লাহর নিকট চাইতে হবে।", isForbidden: true),
                _buildBulletItem(isDark, "কবর পাকা করা বা ঘর তৈরি করা: কবরের উপর পাকা দালান বা মাজার তৈরি করা এবং কবরের ওপর আলো জ্বালানো রাসূলুল্লাহ (সা.) কঠোরভাবে নিষেধ করেছেন।", isForbidden: true),
                _buildBulletItem(isDark, "কবরকে কেন্দ্র করে উৎসব: কবরের নিকট ওরশ বা কোনো প্রকার মেলার আয়োজন করা বা কবর ছুঁয়ে চুম্বন বা কপাল ঘষা বিদআত।", isForbidden: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(bool isDark, String text, {bool isForbidden = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isForbidden ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isForbidden ? Colors.redAccent : AppColors.emerald,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard({
    required bool isDark,
    required String title,
    required String arabic,
    required String pronunciation,
    required String translation,
  }) {
    final text = "$title:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation\n\nঅনুবাদ: $translation";
    return Container(
      width: double.infinity,
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
}
