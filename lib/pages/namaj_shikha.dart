import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class NamajShikhaScreen extends StatefulWidget {
  const NamajShikhaScreen({super.key});

  @override
  State<NamajShikhaScreen> createState() => _NamajShikhaScreenState();
}

class _NamajShikhaScreenState extends State<NamajShikhaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final steps = [
      _WuduStep("১. নিয়ত ও তাকবীরে তাহরীমা", "কিবলামুখী হয়ে দাঁড়িয়ে মনে মনে নামাজের নিয়ত করে 'আল্লাহু আকবার' বলে দুই হাত কান/কাঁধ পর্যন্ত উঠিয়ে নাভির নিচে (পুরুষ) বা বুকের ওপর (নারী) বাঁধতে হবে।"),
      _WuduStep("২. সানা ও কিরাআত", "হাত বাঁধার পর সানা পড়তে হবে। তারপর সূরা ফাতিহা পড়ে অন্য যেকোনো একটি সূরা বা আয়াত মিলিয়ে পড়তে হবে।"),
      _WuduStep("৩. রুকু (নত হওয়া)", "'আল্লাহু আকবার' বলে রুকুতে যেতে হবে এবং পিঠ সোজা রেখে অন্তত ৩ বার 'সুবহানা রাব্বিয়াল আজিম' বলতে হবে।"),
      _WuduStep("৪. কাওমা (দাঁড়ানো)", "রুকু থেকে ওঠার সময় 'সামিয়াল্লাহু লিমান হামিদাহ' বলে সোজা হয়ে দাঁড়িয়ে 'রাব্বানা লাকাল হামদ' পড়তে হবে।"),
      _WuduStep("৫. সাজদাহ (অবনত হওয়া)", "'আল্লাহু আকবার' বলে মাটিতে কপাল ও নাক রেখে সাজদাহ করতে হবে এবং ৩ বার 'সুবহানা রাব্বিয়াল আলা' বলতে হবে।"),
      _WuduStep("৬. জলসা (বসা)", "প্রথম সাজদাহ থেকে উঠে সোজা হয়ে বসতে হবে এবং একটি সংক্ষিপ্ত দোয়া পাঠ করে পুনরায় দ্বিতীয় সাজদাহ করতে হবে।"),
      _WuduStep("৭. তাশাহহুদ ও বসা", "দ্বিতীয় বা চতুর্থ রাকাতে তাশাহহুদ (আত্তাহিয়্যাতু), দরূদ শরীফ ও দোয়া মাসূরা পড়ে ডান ও বাম দিকে সালাম ফিরিয়ে নামাজ শেষ করতে হবে।"),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("নামাজের ফরজসমূহ (১৩ টি)", isDark),
        const SizedBox(height: 8),
        _buildFarzCard("**আহকাম (নামাজের বাইরে ৭ ফরজ):**\n১. শরীর পবিত্র হওয়া। ২. কাপড় পবিত্র হওয়া। ৩. নামাজের জায়গা পবিত্র হওয়া। ৪. সতর ঢাকা। ৫. কিবলামুখী হওয়া। ৬. ওয়াক্ত চেনা। ৭. নামাজের নিয়ত করা।\n\n**আরকান (নামাজের ভেতরে ৬ ফরজ):**\n১. তাকবীরে তাহরীমা বলা। ২. দাঁড়িয়ে নামাজ পড়া। ৩. কিরাআত (কুরআন পাঠ) করা। ৪. রুকু করা। ৫. সিজদাহ করা। ৬. শেষ বৈঠকে তাশাহহুদ পরিমাণ বসা।", isDark),
        const SizedBox(height: 20),
        _buildSectionHeader("১ রাকাত নামাজের ধারাবাহিক বিবরণ", isDark),
        const SizedBox(height: 10),
        ...steps.map((s) => _buildStepCard(s.title, s.desc, isDark)),
      ],
    );
  }

  // ── সূরা ও দোয়া ট্যাব ──
  Widget _buildDuasTab(bool isDark) {
    final prayers = [
      _DuaData("১. ছানা (নামাজের শুরু)", "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلاَ إِلَهَ غَيْرُكَ", "সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা, ওয়া তাবারাকাসমুকা ওয়া তা'আলা জাদ্দুকা, ওয়া লা ইলাহা গাইরুকা।", "হে আল্লাহ! আমি আপনার সপ্রশংস পবিত্রতা ঘোষণা করছি। আপনার নাম বরকতময়, আপনার মহিমা সর্বোচ্চ এবং আপনি ব্যতীত কোনো উপাস্য নেই।"),
      _DuaData("২. তাশাহহুদ (আত্তাহিয়্যাতু)", "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ", "আত্তাহিয়্যাতু লিল্লাহি ওয়াস-সালাওয়াতু ওয়াত-তাইয়্যিবাতু, আসসালামু আলাইকা আইয়্যুহান-নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু, আসসালামু আলাইনা ওয়া আলা ইবাদিল্লাহিস-সালিহীন, আশহাদু আল-লা ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।", "যাবতীয় সম্মান, প্রার্থনা ও পবিত্রতা একমাত্র আল্লাহর জন্য। হে নবী, আপনার ওপর শান্তি, আল্লাহর রহমত ও বরকত বর্ষিত হোক। আমাদের ওপর এবং আল্লাহর নেক বান্দাদের ওপর শান্তি বর্ষিত হোক। আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই এবং মুহাম্মদ (সা.) তাঁর বান্দা ও রাসূল।"),
      _DuaData("৩. দরূদ শরীফ", "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ", "আল্লাহুম্মা সাল্লি আলা মুহাম্মাদিওঁ ওয়া আলা আলি মুহাম্মাদিন, কামা সাল্লাইতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ। আল্লাহুম্মা বারিক আলা মুহাম্মাদিওঁ ওয়া আলা আলি মুহাম্মাদিন, কামা বারাকতা আলা ইব্রাহিমা ওয়া আলা আলি ইব্রাহিমা ইন্নাকা হামিদুম মাজিদ।", "হে আল্লাহ! মুহাম্মদ (সা.) ও তাঁর পরিবারের ওপর রহমত বর্ষণ করুন, যেমন করেছিলেন ইব্রাহিম (আ.) ও তাঁর পরিবারের ওপর। নিশ্চয়ই আপনি প্রশংসিত ও মহিমান্বিত। হে আল্লাহ! মুহাম্মদ (সা.) ও তাঁর পরিবারের ওপর বরকত দান করুন, যেমন করেছিলেন ইব্রাহিম (আ.) ও তাঁর পরিবারের ওপর।"),
      _DuaData("৪. দোয়া মাসূরা", "اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ", "আল্লাহুম্মা ইন্নি জলামতু নাফসি জুলমান কাসিরাওঁ ওয়ালা ইয়াগফিরুজ-জুনুবা ইল্লা আনতা, ফাগফিরলি মাগফিরাতাম-মিন ইন্দিকা ওয়ারহামনি, ইন্নাকা আনতাল গাফুরুর রাহিম।", "হে আল্লাহ! আমি নিজের ওপর অনেক জুলুম করেছি, আর আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই। অতএব আপনার পক্ষ থেকে আমাকে ক্ষমা করুন এবং আমার ওপর দয়া করুন। নিশ্চয়ই আপনি ক্ষমাশীল ও দয়াময়।"),
      _DuaData("৫. দোয়া কুনূত (বিতর নামাজ)", "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ وَنَشْكُرُكَ وَلاَ نَكْفُرُكَ وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِلَيْكَ نَسْعَى وَنَحْفِدُ وَنَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحِقٌ", "আল্লাহুম্মা ইন্না নাসতা'ইনূকা ওয়া নাসতাগফিরূকা ওয়া নু'মিনূ বিকা ওয়া নাতাওয়াক্কালু আলাইকা ওয়া নুছনী আলাইকাল খায়রা ওয়া নাশকুরুকা ওয়া লা নাকফুরুকা ওয়া নাখলা'উ ওয়া নাতরুকু মাই-ইয়াফজুরুক। আল্লাহুম্মা ইয়্যাকা না'বুদু ওয়া লাকা নুসল্লী ওয়া নাসজুদু ওয়া ইলাইকা নাস'আ ওয়া নাহফিদু ওয়া নারজু রাহমাতাকা ওয়া নাখশা আজাবাকা ইন্না আজাবাকা বিল কুফফারি মুলহিক।", "হে আল্লাহ! আমরা আপনার সাহায্য চাই, আপনার কাছে ক্ষমা চাই, আপনার ওপর ঈমান আনি, আপনার ওপর ভরসা করি। আমরা আপনার প্রশংসা করি, আপনার কৃতজ্ঞতা প্রকাশ করি এবং অকৃতজ্ঞ হই না। যারা আপনার অবাধ্য হয়, তাদের আমরা ত্যাগ করি। হে আল্লাহ! আমরা আপনারই ইবাদত করি, আপনার জন্যই নামাজ পড়ি ও সেজদা করি। আমরা আপনার দিকেই দৌড়াই ও সেবা করি। আমরা আপনার রহমতের আশা করি ও আজাবকে ভয় পাই। নিশ্চয়ই আপনার আজাব কাফেরদের গ্রাস করবে।"),
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
