import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class DailyDuasScreen extends StatefulWidget {
  const DailyDuasScreen({super.key});

  @override
  State<DailyDuasScreen> createState() => _DailyDuasScreenState();
}

class _DailyDuasScreenState extends State<DailyDuasScreen> with SingleTickerProviderStateMixin {
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
        title: const Text("দৈনন্দিন দোয়া ও আমল"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "ঘুম ও খাবার"),
            Tab(text: "দৈনিক প্রয়োজন"),
            Tab(text: "বিপদ ও রক্ষা"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDuaList(context, _getSleepAndFoodDuas(), isDark),
          _buildDuaList(context, _getDailyEssentialsDuas(), isDark),
          _buildDuaList(context, _getProtectionDuas(), isDark),
        ],
      ),
    );
  }

  Widget _buildDuaList(BuildContext context, List<_DuaItemData> duas, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final d = duas[index];
        final textToCopy = "${d.title}:\n\nআরবি: ${d.arabic}\n\nউচ্চারণ: ${d.pronunciation}\n\nঅনুবাদ: ${d.translation}\n\nফজিলত: ${d.virtue}";
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
                      d.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    onPressed: () => _copyToClipboard(textToCopy, d.title),
                    tooltip: "দোয়া কপি করুন",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  d.arabic,
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
                "উচ্চারণ: ${d.pronunciation}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "অনুবাদ: ${d.translation}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              if (d.virtue.isNotEmpty) ...[
                const Divider(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.emerald, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "ফজিলত ও আমল: ${d.virtue}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<_DuaItemData> _getSleepAndFoodDuas() {
    return [
      const _DuaItemData(
        title: "ঘুম থেকে ওঠার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আহইয়ানা বা’দা মা আমারতানা ওয়া ইলাইহিন নুশুর।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের মৃত্যুর (ঘুমের) পর পুনর্জীবিত করলেন এবং তাঁর দিকেই আমাদের ফিরে যেতে হবে।",
        virtue: "ঘুম থেকে উঠে এই দোয়াটি পড়া রাসূলুল্লাহ (সা.) এর অন্যতম একটি সুন্নাহ।"
      ),
      const _DuaItemData(
        title: "ঘুমানোর পূর্বে দোয়া",
        arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
        pronunciation: "বিসমিকা আল্লাহুম্মা আমুতু ওয়া আহয়া।",
        translation: "হে আল্লাহ! আপনারই নামে আমি মৃত্যুবরণ করছি (ঘুমাচ্ছি) এবং জীবিত হব (জাগ্রত হব)।",
        virtue: "ঘুমানোর পূর্বে ডান কাতে শুয়ে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        title: "খাবারের শুরুতে দোয়া",
        arabic: "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
        pronunciation: "বিসমিল্লাহি ওয়া আলা বারাকাতিল্লাহ।",
        translation: "আল্লাহর নামে এবং আল্লাহর বরকতের ওপর ভরসা করে খাওয়া শুরু করলাম।",
        virtue: "খাবারের শুরুতে বিসমিল্লাহ বলতে ভুলে গেলে বলুন: 'বিসমিল্লাহি আউওয়ালাহু ওয়া আখিরাহু'।"
      ),
      const _DuaItemData(
        title: "খাবার শেষ করার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আতআমানা ওয়া সাকানা ওয়া জাআলানা মুসলিমীন।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের আহার করিয়েছেন, পান করিয়েছেন এবং মুসলমান বানিয়েছেন।",
        virtue: "আহার শেষে আল্লাহর শুকরিয়া আদায় করা অত্যন্ত ফজিলতপূর্ণ আমল।"
      ),
    ];
  }

  List<_DuaItemData> _getDailyEssentialsDuas() {
    return [
      const _DuaItemData(
        title: "পিতা-মাতার জন্য দোয়া",
        arabic: "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
        pronunciation: "রাব্বির হামহুমা কামা রাব্বাইয়ানি সাগিরা।",
        translation: "হে আমার প্রতিপালক! তাঁদের (পিতা-মাতার) উভয়ের প্রতি দয়া করুন, যেমন তাঁরা শৈশবে আমাকে স্নেহ-মমতার সাথে লালন-পালন করেছেন।",
        virtue: "সুরা বনি ইসরাইল (আয়াত ২৪) এর এই দোয়াটি যেকোনো সময় পিতা-মাতার কল্যাণে পাঠ করা যায়।"
      ),
      const _DuaItemData(
        title: "ঘর থেকে বের হওয়ার দোয়া",
        arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
        pronunciation: "বিসমিল্লাহি তাওয়াককালতু আলাল্লাহি ওয়া লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহ।",
        translation: "আল্লাহর নামে বের হচ্ছি, আল্লাহর ওপর ভরসা করলাম। আর আল্লাহর সাহায্য ব্যতীত গুনাহ থেকে বাঁচার এবং নেক কাজ করার কোনো শক্তি নেই।",
        virtue: "এই দোয়া পড়ে বের হলে আল্লাহ তার জন্য যথেষ্ট হন, তাকে শয়তানের অনিষ্ট থেকে রক্ষা করা হয়।"
      ),
      const _DuaItemData(
        title: "ঘরে প্রবেশ করার দোয়া",
        arabic: "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
        pronunciation: "বিসমিল্লাহি ওয়ালাজনা, ওয়া বিসমিল্লাহি খারাজনা, ওয়া আলাল্লাহি রাব্বিনা তাওয়াককালনা।",
        translation: "আল্লাহর নামে আমরা প্রবেশ করলাম, আল্লাহর নামেই বের হলাম এবং আমাদের রব আল্লাহর ওপরই ভরসা করলাম।",
        virtue: "ঘরে প্রবেশের সময় সালাম দিয়ে এই দোয়া পাঠ করলে শয়তান সেই ঘরে রাত কাটানোর সুযোগ পায় না।"
      ),
      const _DuaItemData(
        title: "জ্ঞান বৃদ্ধির দোয়া",
        arabic: "رَّبِّ زِدْنِي عِلْمًا",
        pronunciation: "রাব্বি জিদনি ইলমা।",
        translation: "হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করে দিন।",
        virtue: "সুরা ত্বহা (আয়াত ১১৪)। দ্বীনি ও দুনিয়াবি কল্যাণকর জ্ঞান অর্জনে এটি অত্যন্ত ফলপ্রসূ।"
      ),
    ];
  }

  List<_DuaItemData> _getProtectionDuas() {
    return [
      const _DuaItemData(
        title: "বিপদ-আপদ ও দুশ্চিন্তা মুক্তির দোয়া (ইউনুস নবীর দোয়া)",
        arabic: "لَّا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
        pronunciation: "লা ইলাহা ইল্লা আন্তা সুবহানাকা ইন্নী কুনতু মিনাজ জোয়ালিমীন।",
        translation: "আপনি ব্যতীত কোনো ইলাহ নেই, আপনি অতি পবিত্র। নিশ্চয়ই আমি অপরাধীদের অন্তর্ভুক্ত।",
        virtue: "সুরা আম্বিয়া (আয়াত ৮৭)। রাসুলুল্লাহ (সা.) বলেছেন, কোনো মুসলমান বিপদে পড়ে এই দোয়া করলে আল্লাহ তা কবুল করেন।"
      ),
      const _DuaItemData(
        title: "শয়তান ও সব ধরনের ক্ষতি থেকে বাঁচার দোয়া",
        arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
        pronunciation: "বিসমিল্লাহিল্লাজি লা ইয়াদুররু মায়াসমিহি শাইউন ফিল আরদি ওয়া লা ফিস সামায়ি ওয়া হুয়াস সামিউল আলীম।",
        translation: "আল্লাহর নামে, যাঁর নামের বরকতে আসমান ও জমিনের কোনো কিছুই কোনো ক্ষতি করতে পারে না। আর তিনি সর্বশ্রোতা ও সর্বজ্ঞ।",
        virtue: "রাসুলুল্লাহ (সা.) বলেছেন, যে ব্যক্তি সকাল-সন্ধ্যা ৩ বার এই দোয়া পড়বে, কোনো জিনিসই তার ক্ষতি করতে পারবে না।"
      ),
      const _DuaItemData(
        title: "আয়াতুল কুরসি (সবচেয়ে ফজিলতপূর্ণ আয়াত)",
        arabic: "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        pronunciation: "আল্লাহু লা ইলাহা ইল্লা হুয়াল হাইয়্যুল কাইয়্যুম। লা তা'খুযুহু সিনাতুও ওয়ালা নাওম। লাহু মা ফিস সামাওয়াতি ওয়ামা ফিল আরদ্। মান যাল্লাযী ইয়াশফাউ 'ইন্দাহু ইল্লা বিইযনিহ্। ইয়া'লামু মা বাইনা আইদীহিম ওয়ামা খালফাহুম। ওয়ালা ইয়ুহীতূনা বিশাইয়িম মিন 'ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি'আ কুরসিইয়্যুহুস সামাওয়াতি ওয়াল আরদ্; ওয়ালা ইয়াউদুহু হিফযুহুমা ওয়া হুয়াল 'আলিইয়্যুল 'আযীম।",
        translation: "আল্লাহ, তিনি ব্যতীত কোনো ইলাহ নেই। তিনি চিরঞ্জীব, সবকিছুর ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সবকিছু তাঁরই। কে সে, যে তাঁর অনুমতি ছাড়া তাঁর নিকট সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে তা তিনি জানেন। আর তাঁর জ্ঞানের কোনো কিছু তারা আয়ত্ত করতে পারে না, কেবল তিনি যতটুকু চান তা ছাড়া। তাঁর কুরসি আসমান ও জমিন পরিব্যাপ্ত এবং এ দুটির সংরক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি অতি উচ্চ, অতি মহান।",
        virtue: "সুরা বাকারা (আয়াত ২৫৫)। শোয়ার সময় পাঠ করলে সারারাত আল্লাহর পক্ষ থেকে একজন রক্ষক নিযুক্ত থাকে এবং শয়তান কাছে আসতে পারে না। প্রতি ফরজ নামাজের পর পাঠ করলে জান্নাতে প্রবেশের মাঝে শুধু মৃত্যুই বাধা থাকে।"
      ),
    ];
  }
}

class _DuaItemData {
  final String title;
  final String arabic;
  final String pronunciation;
  final String translation;
  final String virtue;

  const _DuaItemData({
    required this.title,
    required this.arabic,
    required this.pronunciation,
    required this.translation,
    required this.virtue,
  });
}
