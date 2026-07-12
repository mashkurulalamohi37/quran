import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/audio_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class NamajShikhaScreen extends StatefulWidget {
  const NamajShikhaScreen({super.key});

  @override
  State<NamajShikhaScreen> createState() => _NamajShikhaScreenState();
}

class _NamajShikhaScreenState extends State<NamajShikhaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInteractiveView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("নামাজ শিক্ষা"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: "ওযু ও পবিত্রতা"),
            Tab(text: "নামাজের নিয়ম"),
            Tab(text: "সূরা ও দোয়া"),
            Tab(text: "নামাজের প্রকার"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWuduTab(isDark),
          _buildStepsTab(isDark),
          _buildDuasTab(isDark),
          _buildTypesTab(isDark),
        ],
      ),
    );
  }

  // ── ওযু ও পবিত্রতা ট্যাব ──
  Widget _buildWuduTab(bool isDark) {
    final steps = [
      _WuduStep("১. নিয়ত ও বিসমিল্লাহ", "ওযুর শুরুতে মনে মনে নিয়ত করতে হবে এবং 'বিসমিল্লাহ' বলে শুরু করতে হবে।"),
      _WuduStep("২. কবজি পর্যন্ত হাত ধোয়া", "দুই হাতের কবজি পর্যন্ত ভালো করে ৩ বার ধুতে হবে এবং আঙুল খিলাল করতে হবে।"),
      _WuduStep("৩. কুলি করা", "ডান হাত দিয়ে মুখে পানি নিয়ে ৩ বার ভালো করে কুলি করতে হবে।"),
      _WuduStep("৪. নাকে পানি দেওয়া", "ডান হাত দিয়ে নাকে পানি দিয়ে বাম হাতের কনিষ্ঠা ও বুড়ো আঙুল দিয়ে ৩ বার নাক পরিষ্কার করতে হবে।"),
      _WuduStep("৫. মুখমণ্ডল ধোয়া", "কপাল থেকে থুতনি এবং এক কানের লতি থেকে অন্য কানের লতি পর্যন্ত পুরো মুখমণ্ডল ৩ বার ধুতে হবে।"),
      _WuduStep("৬. কনুইসহ হাত ধোয়া", "প্রথমে ডান হাত পরে বাম হাত কনুইসহ ভালো করে ৩ বার ধুতে হবে।"),
      _WuduStep("৭. মাথা ও কান মাসাহ করা", "ভেজা হাত দিয়ে পুরো মাথা একবার সামনের দিক থেকে পেছনে এবং কান ও ঘাড় মাসাহ করতে হবে।"),
      _WuduStep("৮. পা ধোয়া", "প্রথমে ডান পা ও পরে বাম পা টাখনুসহ ভালো করে ৩ বার ধুতে হবে।"),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("ওযুর ফরজসমূহ (৪ টি)", isDark),
        const SizedBox(height: 8),
        _buildFarzCard("১. মুখমণ্ডল একবার ধোয়া।\n২. দুই হাতের কনুইসহ ধোয়া।\n৩. মাথার চারভাগের একভাগ মাসাহ করা।\n৪. দুই পায়ের টাখনুসহ ধোয়া।", isDark),
        const SizedBox(height: 20),
        _buildSectionHeader("ওযুর ধারাবাহিক পদ্ধতি", isDark),
        const SizedBox(height: 10),
        ...steps.map((s) => _buildStepCard(s.title, s.desc, isDark)),
      ],
    );
  }

  // ── নামাজের নিয়ম ট্যাব ──
  Widget _buildStepsTab(bool isDark) {
    final classicSteps = [
      _WuduStep("১. নিয়ত ও তাকবীরে তাহরীমা", "কিবলামুখী হয়ে দাঁড়িয়ে মনে মনে নামাজের নিয়ত করে 'আল্লাহু আকবার' বলে দুই হাত কান/কাঁধ পর্যন্ত উঠিয়ে নাভির নিচে (পুরুষ) বা বুকের ওপর (নারী) বাঁধতে হবে।"),
      _WuduStep("২. সানা ও কিরাআত", "হাত বাঁধার পর সানা পড়তে হবে। তারপর সূরা ফাতিহা পড়ে অন্য যেকোনো একটি সূরা বা আয়াত মিলিয়ে পড়তে হবে।"),
      _WuduStep("৩. রুকু (নত হওয়া)", "'আল্লাহু আকবার' বলে রুকুতে যেতে হবে এবং পিঠ সোজা রেখে অন্তত ৩ বার 'সুবহানা রাব্বিয়াল আজিম' বলতে হবে।"),
      _WuduStep("৪. কাওমা (দাঁড়ানো)", "রুকু থেকে ওঠার সময় 'সামিয়াল্লাহু লিমান হামিদাহ' বলে সোজা হয়ে দাঁড়িয়ে 'রাব্বানা লাকাল হামদ' পড়তে হবে।"),
      _WuduStep("৫. সাজদাহ (অবনত হওয়া)", "'আল্লাহু আকবার' বলে মাটিতে কপাল ও নাক রেখে সাজদাহ করতে হবে এবং ৩ বার 'সুবহানা রাব্বিয়াল আলা' বলতে হবে।"),
      _WuduStep("৬. জলসা (বসা)", "প্রথম সাজদাহ থেকে উঠে সোজা হয়ে বসতে হবে এবং একটি সংক্ষিপ্ত দোয়া পাঠ করে পুনরায় দ্বিতীয় সাজদাহ করতে হবে।"),
      _WuduStep("৭. তাশাহহুদ ও বসা", "দ্বিতীয় বা চতুর্থ রাকাতে তাশাহহুদ (আত্তাহিয়্যাতু), দরূদ শরীফ ও দোয়া মাসূরা পড়ে ডান ও বাম দিকে সালাম ফিরিয়ে নামাজ শেষ করতে হবে।"),
    ];

    return Column(
      children: [
        // Toggle view buttons at top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isInteractiveView ? AppColors.emerald : Colors.grey.withValues(alpha: 0.1),
                    foregroundColor: _isInteractiveView ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _isInteractiveView = true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videogame_asset_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text("ইন্টারেক্টিভ গাইড", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isInteractiveView ? AppColors.emerald : Colors.grey.withValues(alpha: 0.1),
                    foregroundColor: !_isInteractiveView ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _isInteractiveView = false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.format_list_numbered_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text("ধারাবাহিক তালিকা", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main body content based on toggle
        Expanded(
          child: _isInteractiveView
              ? const _InteractiveSalahGuide()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader("নামাজের ফরজসমূহ (১৩ টি)", isDark),
                    const SizedBox(height: 8),
                    _buildFarzCard("**আহকাম (নামাজের বাইরে ৭ ফরজ):**\n১. শরীর পবিত্র হওয়া। ২. কাপড় পবিত্র হওয়া। ৩. নামাজের জায়গা পবিত্র হওয়া। ৪. সতর ঢাকা। ۵. কিবলামুখী হওয়া। ৬. ওয়াক্ত চেনা। ৭. নামাজের নিয়ত করা।\n\n**আরকান (নামাজের ভেতরে ৬ ফরজ):**\n১. তাকবীরে তাহরীমা বলা। ২. দাঁড়িয়ে নামাজ পড়া। ৩. কিরাআত (কুরআন পাঠ) করা। ৪. রুকু করা। ৫. সিজদাহ করা। ৬. শেষ বৈঠকে তাশাহহুদ পরিমাণ বসা।", isDark),
                    const SizedBox(height: 20),
                    _buildSectionHeader("১ রাকাত নামাজের বিবরণ (তালিকা)", isDark),
                    const SizedBox(height: 10),
                    ...classicSteps.map((s) => _buildStepCard(s.title, s.desc, isDark)),
                  ],
                ),
        ),
      ],
    );
  }

  // ── সূরা ও দোয়া ট্যাব ──
  Widget _buildDuasTab(bool isDark) {
    final prayers = [
      _DuaData("১. ছানা (নামাজের শুরু)", "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلاَ إِلَهَ غَيْرُكَ", "সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা, ওয়া তাবারাকাসমুকা ওয়া তা'আলা জাদ্দুকা, ওয়া লা ইলাহা গাইরুকা।", "হে আল্লাহ! আমি আপনার সপ্রশংস পবিত্রতা ঘোষণা করছি। আপনার নাম বরকতময়, আপনার মহিমা সর্বোচ্চ এবং আপনি ব্যতীত কোনো উপাস্য নেই।"),
      _DuaData("২. তাশাহহুদ (আত্তাহিয়্যাতু)", "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْহَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", "আত্তাহিয়্যাতু লিল্লাহি ওয়াস-সালাওয়াতু ওয়াত-তাইয়্যিবাতু, আসসালামু আলাইকা আইয়্যুহান-নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু, আসসালামু আলাইনা ওয়া আলা ইবাদিল্লাহিস-সালিহীন, আশহাদু আল-লা ইলাহা ইল্লাল্লাহু ওয়া ashহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।", "যাবতীয় সম্মান, প্রার্থনা ও পবিত্রতা একমাত্র আল্লাহর জন্য। হে নবী, আপনার ওপর শান্তি, আল্লাহর রহমত ও বরকত বর্ষিত হোক। আমাদের ওপর এবং আল্লাহর নেক বান্দাদের ওপর শান্তি বর্ষিত হোক। আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই এবং মুহাম্মদ (সা.) তাঁর বান্দা ও রাসূল।"),
      _DuaData("৩. দরূদ শরীফ", "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَজِيدٌ اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَজِيدٌ", "আল্লাহুম্মা সাল্লি আলা মুহাম্মাদিওঁ ওয়া আলা আলি মুহাম্মাদিন, কামা সাল্লাইতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ। আল্লাহুম্মা বারিক আলা মুহাম্মাদিওঁ ওয়া আলা আলি মুহাম্মাদিন, কামা বারাকতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ।", "হে আল্লাহ! মুহাম্মদ (সা.) ও তাঁর পরিবারের ওপর রহমত বর্ষণ করুন, যেমন করেছিলেন ইব্রাহিম (আ.) ও তাঁর পরিবারের ওপর। নিশ্চয়ই আপনি প্রশংসিত ও মহিমান্বিত। হে আল্লাহ! মুহাম্মদ (সা.) ও তাঁর পরিবারের ওপর বরকত দান করুন, যেমন করেছিলেন ইব্রাহিম (আ.) ও তাঁর পরিবারের ওপর।"),
      _DuaData("৪. দোয়া মাসূরা", "اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ", "আল্লাহুম্মা ইন্নি জলামতু নাফসি জুলমান কাসিরাওঁ ওয়ালা ইয়াগফিরুজ-জুনuবা ইল্লা আনতা, ফাগফিরলি মাগফিরাতাম-মিন ইন্দিকা ওয়ারহামনি, ইন্নাকা আনতাল গাফুরুর রাহিম।", "হে আল্লাহ! আমি নিজের ওপর অনেক জুলুম করেছি, আর আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই। অতএব আপনার পক্ষ থেকে আমাকে ক্ষমা করুন এবং আমার ওপর দয়া করুন। নিশ্চয়ই আপনি ক্ষমাশীল ও দয়াময়।"),
      _DuaData("৫. দোয়া কুনূত (বিতর নামাজ)", "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَনَسْتَغْفِرُكَ وَনُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ وَنَشْكُرُكَ وَلاَ نَكْفُرُكَ وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِليكَّ نَسْعَى وَنَحْفِدُ وَنَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحِقٌ", "আল্লাহুম্মা ইন্না নাসতা'ইনূকা ওয়া নাসতাগফিরূকা ওয়া নু'মিনূ বিকা ওয়া নাতাওয়াক্কালু আলাইকা ওয়া নুছনী আলাইকাল খায়রা ওয়া নাশকুরুকা ওয়া লা নাকফুরুকা ওয়া নাখলা'উ ওয়া নাতরুকু মাই-ইয়াফজুরুক। আল্লাহুম্মা ইয়্যাকা না'বুদু ওয়া লাকা নুসল্লী ওয়া নাসজুদু ওয়া ইলাইকা নাস'আ ওয়া নাহফিদু ওয়া নারজু রাহমাতাকা ওয়া নাখশা আজাবাকা ইন্না আজাবাকা বিল কুফফারি মুলহিক।", "হে আল্লাহ! আমরা আপনার সাহায্য চাই, আপনার কাছে ক্ষমা চাই, আপনার ওপর ঈমান আনি, আপনার ওপর ভরসা করি। আমরা আপনার প্রশংসা করি, আপনার কৃতজ্ঞতা প্রকাশ করি এবং অকৃতজ্ঞ হই না। যারা আপনার অবাধ্য হয়, তাদের আমরা ত্যাগ করি। হে আল্লাহ! আমরা আপনারই ইবাদত করি, আপনার জন্যই নামাজ পড়ি ও সেজদা করি। আমরা আপনার দিকেই ও দৌড়াই ও সেবা করি। আমরা আপনার রহমতের আশা করি ও আজাবকে ভয় পাই। নিশ্চয়ই আপনার আজাব কাফেরদের গ্রাস করবে।"),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final p = prayers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  p.arabic,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: isDark ? AppColors.arabicDark : AppColors.arabicLight),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "উচ্চারণ: ${p.pronunciation}",
                style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 6),
              Text(
                "অর্থ: ${p.translation}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── নামাজের প্রকার ট্যাব ──
  Widget _buildTypesTab(bool isDark) {
    final types = [
      _PrayerType("ফজর", "২ রাকাত সুন্নাত, ২ রাকাত ফরজ। মোট ৪ রাকাত।"),
      _PrayerType("যোহর", "৪ রাকাত কাবলাল জোহর সুন্নাত, ৪ রাকাত ফরজ, ২ রাকাত বা'দাল জোহর সুন্নাত, ২ রাকাত নফল (ঐচ্ছিক)। মোট ১২ রাকাত।"),
      _PrayerType("আসর", "৪ রাকাত সুন্নাত (গাইরে মুয়াক্কাদাহ), ৪ রাকাত ফরজ। মোট ৮ রাকাত।"),
      _PrayerType("মাগরিব", "৩ রাকাত ফরজ, ২ রাকাত সুন্নাত, ২ রাকাত নফল (ঐচ্ছিক)। মোট ৭ রাকাত।"),
      _PrayerType("এশা", "৪ রাকাত সুন্নাত (ঐচ্ছিক), ৪ রাকাত ফরজ, ২ রাকাত সুন্নাত, ২ রাকাত নফল, ৩ রাকাত বিতর (ওয়াজিব), ২ রাকাত নফল। মোট ১৭ রাকাত।"),
      _PrayerType("জুমা (শুক্রবার)", "৪ রাকাত কাবলাল জুমা সুন্নাত, ২ রাকাত ফরজ (খুতবার পর), ৪ রাকাত বা'দাল জুমা সুন্নাত, ২ রাকাত সুন্নাত।"),
      _PrayerType("তাহাজ্জুদ নামাজ", "এশার নামাজের পর থেকে সুবহে সাদিকের পূর্ব পর্যন্ত পড়া যায়। সাধারণত ২ থেকে ১২ রাকাত পর্যন্ত পড়া যায় (২ রাকাত করে করে)। এটি একটি অত্যন্ত ফজিলতপূর্ণ নফল/সুন্নাত ইবাদত। দীর্ঘ কিরাআত ও দীর্ঘ রুকু-সিজদাহ করা উত্তম।"),
      _PrayerType("নফল নামাজ", "যেকোনো নিষিদ্ধ সময় (যেমন: সূর্যোদয়, সূর্যাস্ত, দ্বিপ্রহর) ব্যতীত দিন বা রাতের যেকোনো সময়ে পড়া যায়। সাধারণ ২ রাকাত নামাজের মতোই নিয়ত করে পড়তে হয়।"),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("৫ ওয়াক্ত নামাজের রাকাতের হিসাব", isDark),
        const SizedBox(height: 10),
        ...types.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.emerald)),
              const SizedBox(height: 4),
              Text(t.desc, style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        )),
        const SizedBox(height: 20),
        _buildSectionHeader("ঈদের নামাজ পড়ার নিয়ম", isDark),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ঈদের নামাজ ২ রাকাত এবং এতে অতিরিক্ত ৬টি ওয়াজিব তাকবীর রয়েছে। এটি জামাতে আদায় করা ওয়াজিব। কোনো আজান ও ইকামত নেই।",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Divider(height: 20),
              Text(
                "১ম রাকাত:",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald),
              ),
              const SizedBox(height: 4),
              Text(
                "• নিয়ত করে হাত বেঁধে সানা পড়তে হবে।\n• এরপর ইমামের সাথে অতিরিক্ত ৩টি ওয়াজিব তাকবীর বলতে হবে। ১ম ও ২য় তাকবীরে হাত কান পর্যন্ত উঠিয়ে ছেড়ে দিতে হবে এবং ৩য় তাকবীরে হাত উঠিয়ে বেঁধে নিতে হবে।\n• এরপর ইমাম সূরা ফাতিহা ও অন্য সূরা পড়বেন এবং নিয়ম অনুযায়ী রুকু-সিজদাহ করতে হবে।",
                style: GoogleFonts.poppins(fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                "২য় রাকাত:",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald),
              ),
              const SizedBox(height: 4),
              Text(
                "• দাঁড়িয়ে ইমাম প্রথমে সূরা ফাতিহা ও অন্য সূরা পাঠ করবেন।\n• রুকুতে যাওয়ার আগে ইমামের সাথে অতিরিক্ত ৩টি তাকবীর বলতে হবে এবং প্রতিবার হাত উঠিয়ে ছেড়ে দিতে হবে।\n• এরপর ৪র্থ তাকবীর বলে হাত না উঠিয়ে সরাসরি রুকুতে যেতে হবে এবং বাকি নামাজ সাধারণ নিয়মে শেষ করতে হবে।",
                style: GoogleFonts.poppins(fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── সাহায্যকারী উইজেটস ──
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildFarzCard(String content, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        border: Border.all(color: const Color(0xFFFFCCBC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFD84315), height: 1.5),
      ),
    );
  }

  Widget _buildStepCard(String title, String desc, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.emerald)),
          const SizedBox(height: 6),
          Text(desc, style: GoogleFonts.poppins(fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}



// ── ওযু ও দোয়া মডেল সমূহ ──
class _WuduStep {
  final String title;
  final String desc;
  const _WuduStep(this.title, this.desc);
}

class _DuaData {
  final String title;
  final String arabic;
  final String pronunciation;
  final String translation;
  const _DuaData(this.title, this.arabic, this.pronunciation, this.translation);
}

class _PrayerType {
  final String name;
  final String desc;
  const _PrayerType(this.name, this.desc);
}

// ── ইন্টারেক্টিভ নামাজ শিক্ষা গাইড উইজেট ──
class _InteractiveSalahGuide extends StatefulWidget {
  const _InteractiveSalahGuide();

  @override
  State<_InteractiveSalahGuide> createState() => _InteractiveSalahGuideState();
}

class _InteractiveSalahGuideState extends State<_InteractiveSalahGuide> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _currentStep = 0;
  _HotspotData? _activeHotspot;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  bool _isAudioLoading = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // The 7 Steps of Salat
  final List<_SalahStepData> _steps = [
    _SalahStepData(
      title: "১. নিয়ত ও তাকবীরে তাহরীমা",
      englishTitle: "Takbire Tahrima (Standing & Raise Hands)",
      description: "কিবলামুখী হয়ে দাঁড়িয়ে মনে মনে নামাজের নিয়ত করে 'আল্লাহু আকবার' বলে দুই হাত কান/কাঁধ পর্যন্ত উঠাতে হবে।",
      arabicText: "اللهُ أَكْبَرُ",
      pronunciation: "Allahu Akbar",
      translation: "আল্লাহ সবচেয়ে মহান",
      audioUrl: "https://www.islamcan.com/audio/salah/allahuakbar.mp3",
      hotspots: [
        _HotspotData(80, 48, "হাত উঠানো (বাম)", "দুই হাত কাঁধ বা কান পর্যন্ত উঠাবেন, হাতের তালু কিবলামুখী রাখতে হবে।"),
        _HotspotData(120, 48, "হাত উঠানো (ডান)", "দুই হাত কাঁধ বা কান পর্যন্ত উঠাবেন, হাতের তালু কিবলামুখী রাখতে হবে।"),
        _HotspotData(100, 32, "দৃষ্টির সীমানা", "দৃষ্টি সবসময় সাজদাহ করার জায়গার দিকে নিবদ্ধ রাখতে হবে।"),
      ],
    ),
    _SalahStepData(
      title: "২. ক্বিয়াম ও কিরাআত",
      englishTitle: "Qiyam (Standing & Folded Hands)",
      description: "হাত বাঁধার পর সানা পড়তে হবে। তারপর সূরা ফাতিহা ও অন্য একটি সূরা মিলিয়ে পড়তে হবে।",
      arabicText: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ ...",
      pronunciation: "Sana & Quran recitation",
      translation: "সানা, সূরা ফাতিহা ও অন্য সূরা তিলাওয়াত",
      audioUrl: "https://www.islamcan.com/audio/salah/sana.mp3",
      hotspots: [
        _HotspotData(100, 92, "হাত বাঁধা", "ডান হাতকে বাম হাতের কবজির ওপর রেখে নাভির নিচে (পুরুষ) বা বুকের ওপর (নারী) বাঁধতে হবে।"),
        _HotspotData(100, 72, "সোজা দাঁড়িয়ে থাকা", "ক্বিয়াম বা সোজা হয়ে দাঁড়ানো নামাজের একটি অন্যতম ফরজ। শরীর সোজা ও আরামদায়ক রাখুন।"),
      ],
    ),
    _SalahStepData(
      title: "৩. রুকু (নত হওয়া)",
      englishTitle: "Ruku (Bowing)",
      description: "'আল্লাহু আকবার' বলে রুকুতে যেতে হবে এবং পিঠ সোজা রেখে অন্তত ৩ বার রুকুর তাসবিহ পড়তে হবে।",
      arabicText: "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
      pronunciation: "Subhana Rabbiyal Azeem",
      translation: "আমার মহান প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
      audioUrl: "https://www.islamcan.com/audio/salah/ruku.mp3",
      hotspots: [
        _HotspotData(110, 110, "পিঠ সোজা রাখা", "পিঠ সোজা ও মাটির সমান্তরাল রাখুন, যাতে পিঠের ওপর পানি রাখলে তা গড়িয়ে না পড়ে।"),
        _HotspotData(130, 145, "হাঁটু চেপে ধরা", "দুই হাতের আঙ্গুলগুলো ফাঁকা করে হাঁটু শক্তভাবে চেপে ধরুন এবং কনুই সোজা রাখুন।"),
        _HotspotData(65, 110, "মাথা সোজা রাখা", "মাথা পিঠের চেয়ে বেশি নিচু বা উঁচুতে রাখবেন না, পিঠের সাথে সমান্তরালে রাখুন।"),
      ],
    ),
    _SalahStepData(
      title: "৪. কাওমা (দাঁড়ানো)",
      englishTitle: "Qauma (Standing after Ruku)",
      description: "রুকু থেকে ওঠার সময় 'সামিয়াল্লাহু লিমান হামিদাহ' বলে সোজা হয়ে দাঁড়িয়ে 'রাব্বানা লাকাল হামদ' পড়তে হবে।",
      arabicText: "رَبَّنَا وَلَكَ الْحَمْدُ",
      pronunciation: "Rabbana lakal hamd",
      translation: "হে আমাদের প্রতিপালক, সমস্ত প্রশংসা কেবল আপনারই জন্য।",
      audioUrl: "https://everyayah.com/data/Alafasy_128kbps/001001.mp3",
      hotspots: [
        _HotspotData(85, 100, "হাত সোজা রাখা", "হাত না বেঁধে স্বাভাবিকভাবে শরীরের দুপাশে ঝুলিয়ে রাখুন।"),
        _HotspotData(100, 75, "সোজা হয়ে স্থির হওয়া", "রুকু থেকে উঠে পুরোপুরি সোজা হয়ে দাঁড়ান এবং শরীরের জোড়গুলো শান্ত ও স্থির হতে দিন।"),
      ],
    ),
    _SalahStepData(
      title: "৫. সাজদাহ (অবনত হওয়া)",
      englishTitle: "Sajdah (Prostration)",
      description: "'আল্লাহু আকবার' বলে মাটিতে ৭টি অঙ্গ স্পর্শ করে সাজদাহ করতে হবে এবং ৩ বার তাসবিহ পড়তে হবে।",
      arabicText: "سُبْحَانَ رَبِّيَ الْأَعْلَى",
      pronunciation: "Subhana Rabbiyal A'la",
      translation: "আমার সর্বোচ্চ প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
      audioUrl: "https://www.islamcan.com/audio/salah/sajda.mp3",
      hotspots: [
        _HotspotData(52, 172, "কপাল ও নাক", "কপাল ও নাক উভয়ই মাটিতে শক্তভাবে স্পর্শ করান। এটি সেজদার প্রথম ও প্রধান শর্ত।"),
        _HotspotData(72, 180, "হাতের অবস্থান", "হাত দুটি মাটির ওপর রাখুন, আঙুলগুলো কিবলামুখী করে জুড়ে রাখুন। কনুই মাটি থেকে ও শরীর থেকে দূরে রাখুন।"),
        _HotspotData(155, 180, "পায়ের আঙ্গুল", "উভয় পায়ের আঙুল মাটিতে গেঁথে কিবলামুখী করে রাখুন এবং গোড়ালি জোড়া রাখুন।"),
      ],
    ),
    _SalahStepData(
      title: "৬. জলসা (বসা)",
      englishTitle: "Jalsha (Sitting between Sajdahs)",
      description: "প্রথম সাজদাহ থেকে উঠে সোজা হয়ে আরাম করে বসতে হবে এবং ইস্তিগফার পড়তে হবে।",
      arabicText: "رَبِّ اغْفِرْ لِي",
      pronunciation: "Rabbigh-fir li",
      translation: "হে আল্লাহ! আমাকে ক্ষমা করুন।",
      audioUrl: "https://www.islamcan.com/audio/salah/duamasura.mp3",
      hotspots: [
        _HotspotData(90, 170, "হাত উরুর ওপর", "উভয় হাত সোজা করে উরুর ওপর রাখুন, আঙুলগুলো হাঁটুর কাছাকাছি থাকবে।"),
        _HotspotData(125, 178, "পায়ের ওপর বসা", "বাম পা বিছিয়ে তার ওপর বসুন এবং ডান পা সোজা খাড়া করে আঙুলগুলো কিবলামুখী করে রাখুন।"),
      ],
    ),
    _SalahStepData(
      title: "৭. শেষ বৈঠক ও সালাম",
      englishTitle: "Tashahhud & Salam (Final Sitting)",
      description: "তাশাহহুদ, দরূদ শরীফ ও দোয়া মাসূরা পড়ে ডান ও বাম দিকে সালাম ফিরিয়ে নামাজ শেষ করতে হবে।",
      arabicText: "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللهِ",
      pronunciation: "Assalamu Alaikum wa Rahmatullah",
      translation: "আপনাদের ওপর শান্তি ও আল্লাহর রহমত বর্ষিত হোক।",
      audioUrl: "https://www.islamcan.com/audio/salah/tashahhud.mp3",
      hotspots: [
        _HotspotData(90, 170, "আঙ্গুল ইশারা", "তাশাহহুদ পড়ার সময় 'লা-ইলাহা' (কোন উপাস্য নেই) বলার সময়ে শাহাদাত আঙুল উঁচিয়ে ইশারা করুন।"),
        _HotspotData(110, 75, "সালাম ফিরানো", "প্রথমে ডানে ঘাড় ঘুরিয়ে সালাম দিন, তারপর বামে ঘাড় ঘুরিয়ে সালাম দিন। দৃষ্টি কাঁধের ওপর থাকবে।"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Default to the first hotspot of the first step
    _activeHotspot = _steps[0].hotspots[0];

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state.playing;
          _isAudioLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRecitation(String url) async {
    // Stop Quran playback
    Provider.of<AudioService>(context, listen: false).stop();

    if (_isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('অডিও ফাইল লোড করতে সমস্যা হয়েছে।')),
          );
        }
      }
    }
  }

  void _onStepChange(int newStep) {
    _audioPlayer.stop();
    setState(() {
      _currentStep = newStep;
      _activeHotspot = _steps[newStep].hotspots[0]; // Set first hotspot of new step active
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Step Indicator header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ধাপ ${_currentStep + 1} এর ${_steps.length}",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              Text(
                step.englishTitle,
                style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),
          const SizedBox(height: 16),

          // Custom Painting Vector container with Hotspots
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ground line & stick figure
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (ctx, _) {
                      return CustomPaint(
                        painter: SalahPosturePainter(
                          stepIndex: _currentStep,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),

                // Tap targets for Hotspots
                ...step.hotspots.map((hotspot) {
                  final isActive = _activeHotspot == hotspot;
                  return Positioned(
                    left: hotspot.x - 20, // offset half of container size to center
                    top: hotspot.y - 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _activeHotspot = hotspot;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (ctx, _) {
                            final pulseVal = _pulseController.value;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing outer halo
                                Container(
                                  width: 14 + (24 * pulseVal),
                                  height: 14 + (24 * pulseVal),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isActive ? Colors.blue : Colors.green)
                                        .withValues(alpha: 0.45 * (1 - pulseVal)),
                                  ),
                                ),
                                // Inner solid node
                                Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive ? Colors.blue : Colors.green,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
                
                // Overlay label showing click instructions
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: AppColors.goldLight, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "চিহ্নিত গোলকগুলোতে চাপুন",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hotspot Detail Info Card
          if (_activeHotspot != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeHotspot!.label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _activeHotspot!.detail,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Step general description
          Text(
            step.title,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emerald),
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: GoogleFonts.poppins(fontSize: 12, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),

          // Prayer / Tasbih Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "পঠিত দোয়া/তাসবিহ",
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    // Speaker play button
                    GestureDetector(
                      onTap: () => _playRecitation(step.audioUrl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isAudioLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                                    ),
                                  )
                                : Icon(
                                    _isAudioPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                    size: 14,
                                    color: AppColors.emerald,
                                  ),
                            const SizedBox(width: 4),
                            Text(
                              _isAudioPlaying ? "থামুন" : "উচ্চারণ শুনুন",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    step.arabicText,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "উচ্চারণ: ${step.pronunciation}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "অর্থ: ${step.translation}",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Page navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _currentStep > 0 ? () => _onStepChange(_currentStep - 1) : null,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, size: 12),
                    const SizedBox(width: 4),
                    Text("পেছনে", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: _currentStep < _steps.length - 1 ? () => _onStepChange(_currentStep + 1) : null,
                child: Row(
                  children: [
                    Text("সামনে", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── Salah Posture Painter for Interactive Guide ──
class SalahPosturePainter extends CustomPainter {
  final int stepIndex;
  final bool isDark;

  SalahPosturePainter({required this.stepIndex, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Centering context on 200x200 design canvas
    final scaleX = size.width / 200;
    final scaleY = size.height / 200;
    
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Draw Ground / Prayer Mat
    final matPaint = Paint()
      ..color = isDark ? AppColors.emerald.withValues(alpha: 0.18) : AppColors.emerald.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromLTRBR(15, 178, 185, 190, const Radius.circular(6)), matPaint);

    final matLinePaint = Paint()
      ..color = isDark ? AppColors.emerald.withValues(alpha: 0.35) : AppColors.emerald.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromLTRBR(15, 178, 185, 190, const Radius.circular(6)), matLinePaint);

    // Styling configuration for figure lines
    final linePaint = Paint()
      ..color = isDark ? AppColors.emeraldLight : AppColors.emerald
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()
      ..color = isDark ? AppColors.emeraldLight : AppColors.emerald
      ..style = PaintingStyle.fill;

    switch (stepIndex) {
      case 0: // Takbire Tahrima
        // Head
        canvas.drawCircle(const Offset(100, 50), 9, headPaint);
        // Neck to Torso
        canvas.drawLine(const Offset(100, 59), const Offset(100, 115), linePaint);
        // Shoulders
        canvas.drawLine(const Offset(85, 70), const Offset(115, 70), linePaint);
        // Left arm raised
        canvas.drawLine(const Offset(85, 70), const Offset(80, 50), linePaint);
        canvas.drawLine(const Offset(80, 50), const Offset(80, 42), linePaint);
        // Right arm raised
        canvas.drawLine(const Offset(115, 70), const Offset(120, 50), linePaint);
        canvas.drawLine(const Offset(120, 50), const Offset(120, 42), linePaint);
        // Left Leg
        canvas.drawLine(const Offset(92, 115), const Offset(92, 178), linePaint);
        // Right Leg
        canvas.drawLine(const Offset(108, 115), const Offset(108, 178), linePaint);
        break;

      case 1: // Qiyam (Folded hands)
        // Head
        canvas.drawCircle(const Offset(100, 50), 9, headPaint);
        // Neck to Torso
        canvas.drawLine(const Offset(100, 59), const Offset(100, 115), linePaint);
        // Shoulders
        canvas.drawLine(const Offset(85, 70), const Offset(115, 70), linePaint);
        // Left arm folded
        canvas.drawLine(const Offset(85, 70), const Offset(92, 92), linePaint);
        canvas.drawLine(const Offset(92, 92), const Offset(100, 92), linePaint);
        // Right arm folded
        canvas.drawLine(const Offset(115, 70), const Offset(108, 92), linePaint);
        canvas.drawLine(const Offset(108, 92), const Offset(100, 92), linePaint);
        // Left Leg
        canvas.drawLine(const Offset(92, 115), const Offset(92, 178), linePaint);
        // Right Leg
        canvas.drawLine(const Offset(108, 115), const Offset(108, 178), linePaint);
        break;

      case 2: // Ruku (Bowing)
        // Hip
        const hip = Offset(130, 110);
        // Shoulder
        const shoulder = Offset(85, 110);
        // Spine
        canvas.drawLine(hip, shoulder, linePaint);
        // Head
        canvas.drawCircle(const Offset(68, 110), 9, headPaint);
        // Arm holding knee
        canvas.drawLine(shoulder, const Offset(130, 145), linePaint);
        // Legs (Hip to Knee to Foot)
        canvas.drawLine(hip, const Offset(130, 145), linePaint);
        canvas.drawLine(const Offset(130, 145), const Offset(130, 178), linePaint);
        break;

      case 3: // Qauma (Standing)
        // Head
        canvas.drawCircle(const Offset(100, 50), 9, headPaint);
        // Neck to Torso
        canvas.drawLine(const Offset(100, 59), const Offset(100, 115), linePaint);
        // Shoulders
        canvas.drawLine(const Offset(85, 70), const Offset(115, 70), linePaint);
        // Left arm hanging
        canvas.drawLine(const Offset(85, 70), const Offset(85, 115), linePaint);
        // Right arm hanging
        canvas.drawLine(const Offset(115, 70), const Offset(115, 115), linePaint);
        // Left Leg
        canvas.drawLine(const Offset(92, 115), const Offset(92, 178), linePaint);
        // Right Leg
        canvas.drawLine(const Offset(108, 115), const Offset(108, 178), linePaint);
        break;

      case 4: // Sajdah
        // Head/Forehead touching mat
        canvas.drawCircle(const Offset(52, 172), 9, headPaint);
        // Shoulder
        const shoulder = Offset(75, 150);
        // Hip
        const hip = Offset(120, 135);
        // Torso
        canvas.drawLine(shoulder, hip, linePaint);
        // Arms
        canvas.drawLine(shoulder, const Offset(72, 178), linePaint);
        // Thigh
        canvas.drawLine(hip, const Offset(135, 170), linePaint);
        // Shin/Feet
        canvas.drawLine(const Offset(135, 170), const Offset(155, 178), linePaint);
        break;

      case 5: // Jalsha (Sitting)
        // Head
        canvas.drawCircle(const Offset(110, 75), 9, headPaint);
        // Shoulder
        const shoulder = Offset(110, 95);
        // Hip
        const hip = Offset(120, 145);
        // Torso
        canvas.drawLine(shoulder, hip, linePaint);
        // Thigh
        const knee = Offset(90, 170);
        canvas.drawLine(hip, knee, linePaint);
        // Shins / Feet (flat)
        canvas.drawLine(knee, const Offset(125, 178), linePaint);
        // Arm / Hand on knee
        canvas.drawLine(shoulder, knee, linePaint);
        break;

      case 6: // Tashahhud / Salam
        // Head rotated slightly
        canvas.drawCircle(const Offset(110, 75), 9, headPaint);
        // Draw eyes look direction (line for chin/beard angle)
        canvas.drawLine(const Offset(110, 78), const Offset(100, 78), linePaint..strokeWidth = 2.0);
        
        // Restore line width
        linePaint.strokeWidth = 5.0;
        
        // Shoulder
        const shoulder = Offset(110, 95);
        // Hip
        const hip = Offset(120, 145);
        // Torso
        canvas.drawLine(shoulder, hip, linePaint);
        // Thigh
        const knee = Offset(90, 170);
        canvas.drawLine(hip, knee, linePaint);
        // Shins / Feet (flat)
        canvas.drawLine(knee, const Offset(125, 178), linePaint);
        // Arm / Hand on knee
        canvas.drawLine(shoulder, knee, linePaint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SalahPosturePainter oldDelegate) {
    return oldDelegate.stepIndex != stepIndex || oldDelegate.isDark != isDark;
  }
}

// ── Models specifically for the interactive guide ──
class _SalahStepData {
  final String title;
  final String englishTitle;
  final String description;
  final String arabicText;
  final String translation;
  final String pronunciation;
  final String audioUrl;
  final List<_HotspotData> hotspots;

  const _SalahStepData({
    required this.title,
    required this.englishTitle,
    required this.description,
    required this.arabicText,
    required this.translation,
    required this.pronunciation,
    required this.audioUrl,
    required this.hotspots,
  });
}

class _HotspotData {
  final double x;
  final double y;
  final String label;
  final String detail;

  const _HotspotData(this.x, this.y, this.label, this.detail);
}
