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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // 3 Tabs: প্রাত্যহিক, বিষয়ভিত্তিক, বুকমার্ক
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  // Filter list of duas by search query
  List<_DuaItemData> _filterDuas(List<_DuaItemData> duas) {
    if (_searchQuery.isEmpty) return duas;
    return duas.where((d) {
      return d.title.toLowerCase().contains(_searchQuery) ||
          d.arabic.toLowerCase().contains(_searchQuery) ||
          d.pronunciation.toLowerCase().contains(_searchQuery) ||
          d.translation.toLowerCase().contains(_searchQuery) ||
          d.virtue.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("দৈনন্দিন দোয়া ও আমল"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "প্রাত্যহিক দোয়া"),
            Tab(text: "বিষয়ভিত্তিক"),
            Tab(text: "বুকমার্ক"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search input field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "দু'আ ও জিকির খুঁজুন...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.emerald),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Basic Daily Duas
                _buildBasicTab(context, settings, isDark),
                // Tab 2: Categorized Duas list
                _buildCategoriesTab(context, settings, isDark),
                // Tab 3: Bookmark Tab
                _buildBookmarkTab(context, settings, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Basic daily list tab
  Widget _buildBasicTab(BuildContext context, SettingsService settings, bool isDark) {
    final rawDuas = _getAllDuas().where((d) => d.category == 'basic').toList();
    final filtered = _filterDuas(rawDuas);

    if (filtered.isEmpty) {
      return _buildEmptyState("কোন দোয়া খুঁজে পাওয়া যায়নি 🔍", isDark);
    }

    return _buildDuaList(context, filtered, settings, isDark);
  }

  // 2. Categories selector tab
  Widget _buildCategoriesTab(BuildContext context, SettingsService settings, bool isDark) {
    final categories = _getCategories();
    final allDuas = _getAllDuas();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final count = allDuas.where((d) => d.category == cat.id).length;
        final cardBg = isDark ? AppColors.cardDark : Colors.white;
        final borderClr = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderClr),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuaCategoryDetailPage(
                      category: cat,
                      duas: allDuas.where((d) => d.category == cat.id).toList(),
                    ),
                  ),
                );
              },
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              title: Text(
                cat.name,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$count টি",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 3. Bookmarks Tab
  Widget _buildBookmarkTab(BuildContext context, SettingsService settings, bool isDark) {
    final bookmarkedIds = settings.bookmarkedDuas;
    final allDuas = _getAllDuas();
    final bookmarked = allDuas.where((d) => bookmarkedIds.contains(d.id)).toList();
    final filtered = _filterDuas(bookmarked);

    if (filtered.isEmpty) {
      return _buildEmptyState(
        _searchQuery.isEmpty ? "কোন বুকমার্ক করা দোয়া নেই 🌟" : "কোন বুকমার্ক দোয়া খুঁজে পাওয়া যায়নি 🔍",
        isDark,
      );
    }

    return _buildDuaList(context, filtered, settings, isDark);
  }

  // Render a scrollable list of duas
  Widget _buildDuaList(BuildContext context, List<_DuaItemData> duas, SettingsService settings, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final d = duas[index];
        final isBookmarked = settings.bookmarkedDuas.contains(d.id);
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
                        fontSize: 13.5,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isBookmarked ? AppColors.gold : (isDark ? Colors.white38 : Colors.black38),
                          size: 20,
                        ),
                        onPressed: () => settings.toggleDuaBookmark(d.id),
                        tooltip: "বুকমার্ক করুন",
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 18,
                        ),
                        onPressed: () => _copyToClipboard(textToCopy, d.title),
                        tooltip: "দোয়া কপি করুন",
                      ),
                    ],
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

  Widget _buildEmptyState(String msg, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  List<_DuaCategoryData> _getCategories() {
    return [
      _DuaCategoryData(id: 'iman', name: 'ঈমান অধ্যায়', icon: Icons.security_rounded, color: AppColors.emerald),
      _DuaCategoryData(id: 'taharat', name: 'তাহারাত (পাক-পবিত্রতা) অধ্যায়', icon: Icons.clean_hands_rounded, color: AppColors.gold),
      _DuaCategoryData(id: 'wudu', name: 'ওযূ অধ্যায়', icon: Icons.water_drop_rounded, color: Colors.blueAccent),
      _DuaCategoryData(id: 'adhan', name: 'আযান-ইকামত অধ্যায়', icon: Icons.notifications_active_rounded, color: Colors.deepOrangeAccent),
      _DuaCategoryData(id: 'masjid', name: 'মসজিদ অধ্যায়', icon: Icons.mosque_rounded, color: AppColors.emerald),
      _DuaCategoryData(id: 'namaz', name: 'নামাযের মধ্যে দু\'আ অধ্যায়', icon: Icons.accessibility_new_rounded, color: AppColors.gold),
      _DuaCategoryData(id: 'sleep_food', name: 'ঘুম ও আহার অধ্যায়', icon: Icons.bedtime_rounded, color: Colors.teal),
      _DuaCategoryData(id: 'protection', name: 'বিপদ ও আশ্রয় অধ্যায়', icon: Icons.warning_amber_rounded, color: Colors.redAccent),
    ];
  }

  List<_DuaItemData> _getAllDuas() {
    return [
      // 1. Basic (original 11 duas)
      const _DuaItemData(
        id: "basic_1",
        category: "basic",
        title: "ঘুম থেকে ওঠার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আহইয়ানা বা’দা মা আমাদেরতানা ওয়া ইলাইহিন নুশুর।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের মৃত্যুর (ঘুমের) পর পুনর্জীবিত করলেন এবং তাঁর দিকেই আমাদের ফিরে যেতে হবে।",
        virtue: "ঘুম থেকে উঠে এই দোয়াটি পড়া রাসূলুল্লাহ (সা.) এর অন্যতম একটি সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "basic_2",
        category: "basic",
        title: "ঘুমানোর পূর্বে দোয়া",
        arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
        pronunciation: "বিসমিকা আল্লাহুম্মা আমুতু ওয়া আহয়া।",
        translation: "হে আল্লাহ! আপনারই নামে আমি মৃত্যুবরণ করছি (ঘুমাচ্ছি) এবং জীবিত হব (জাগ্রত হব)।",
        virtue: "ঘুমানোর পূর্বে ডান কাতে শুয়ে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "basic_3",
        category: "basic",
        title: "খাবারের শুরুতে দোয়া",
        arabic: "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
        pronunciation: "বিসমিল্লাহি ওয়া আলা বারাকাতিল্লাহ।",
        translation: "আল্লাহর নামে এবং আল্লাহর বরকতের ওপর ভরসা করে খাওয়া শুরু করলাম।",
        virtue: "খাবারের শুরুতে বিসমিল্লাহ বলতে ভুলে গেলে বলুন: 'বিসমিল্লাহি আউওয়ালাহু ওয়া আখিরাহু'।"
      ),
      const _DuaItemData(
        id: "basic_4",
        category: "basic",
        title: "খাবার শেষ করার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আতআমানা ওয়া সাকানা ওয়া জাআলানা মুসলিমীন।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের আহার করিয়েছেন, পান করিয়েছেন এবং মুসলমান বানিয়েছেন।",
        virtue: "আহার শেষে আল্লাহর শুকরিয়া আদায় করা অত্যন্ত ফজিলতপূর্ণ আমল।"
      ),
      const _DuaItemData(
        id: "basic_5",
        category: "basic",
        title: "পিতা-মাতার জন্য দোয়া",
        arabic: "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
        pronunciation: "রাব্বির হামহুমা কামা রাব্বাইয়ানি সাগিরা।",
        translation: "হে আমার প্রতিপালক! তাঁদের (পিতা-মাতার) উভয়ের প্রতি দয়া করুন, যেমন তাঁরা শৈশবে আমাকে স্নেহ-মমতার সাথে লালন-পালন করেছেন।",
        virtue: "সুরা বনি ইসরাইল (আয়াত ২৪) এর এই দোয়াটি যেকোনো সময় পিতা-মাতার কল্যাণে পাঠ করা যায়।"
      ),
      const _DuaItemData(
        id: "basic_6",
        category: "basic",
        title: "ঘর থেকে বের হওয়ার দোয়া",
        arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
        pronunciation: "বিসমিল্লাহি তাওয়াককালতু আলাল্লাহি ওয়া লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহ।",
        translation: "আল্লাহর নামে বের হচ্ছি, আল্লাহর ওপর ভরসা করলাম। আর আল্লাহর সাহায্য ব্যতীত গুনাহ থেকে বাঁচার এবং নেক কাজ করার কোনো শক্তি নেই।",
        virtue: "এই দোয়া পড়ে বের হলে আল্লাহ তার জন্য যথেষ্ট হন, তাকে শয়তানের অনিষ্ট থেকে রক্ষা করা হয়।"
      ),
      const _DuaItemData(
        id: "basic_7",
        category: "basic",
        title: "ঘরে প্রবেশ করার দোয়া",
        arabic: "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
        pronunciation: "বিসমিল্লাহি ওয়ালাজনা, ওয়া বিসমিল্লাহি খারাজনা, ওয়া আলাল্লাহি রাব্বিনা তাওয়াককালনা।",
        translation: "আল্লাহর নামে আমরা প্রবেশ করলাম, আল্লাহর নামেই বের হলাম এবং আমাদের রব আল্লাহর ওপরই ভরসা করলাম।",
        virtue: "ঘরে প্রবেশের সময় সালাম দিয়ে এই দোয়া পাঠ করলে শয়তান সেই ঘরে রাত কাটানোর সুযোগ পায় না।"
      ),
      const _DuaItemData(
        id: "basic_8",
        category: "basic",
        title: "জ্ঞান বৃদ্ধির দোয়া",
        arabic: "رَّبِّ زِدْنِي عِلْمًا",
        pronunciation: "রাব্বি জিদনি ইলমা।",
        translation: "হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করে দিন।",
        virtue: "সুরা ত্বহা (আয়াত ১১৪)। দ্বীনি ও দুনিয়াবি কল্যাণকর জ্ঞান অর্জনে এটি অত্যন্ত ফলপ্রসূ।"
      ),
      const _DuaItemData(
        id: "basic_9",
        category: "basic",
        title: "বিপদ-আপদ ও দুশ্চিন্তা মুক্তির দোয়া (ইউনুস নবীর দোয়া)",
        arabic: "لَّا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
        pronunciation: "লা ইলাহা ইল্লা আন্তা সুবহানাকা ইন্নী কুনতু মিনাজ জোয়ালিমীন।",
        translation: "আপনি ব্যতীত কোনো ইলাহ নেই, আপনি অতি পবিত্র। নিশ্চয়ই আমি অপরাধীদের অন্তর্ভুক্ত।",
        virtue: "সুরা আম্বিয়া (আয়াত ৮৭)। রাসুলুল্লাহ (সা.) বলেছেন, কোনো মুসলমান বিপদে পড়ে এই দোয়া করলে আল্লাহ তা কবুল করেন।"
      ),
      const _DuaItemData(
        id: "basic_10",
        category: "basic",
        title: "শয়তান ও সব ধরনের ক্ষতি থেকে বাঁচার দোয়া",
        arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
        pronunciation: "বিসমিল্লাহিল্লাজি লা ইয়াদুররু মায়াসমিহি শাইউন ফিল আরদি ওয়া লা ফিস সামায়ি ওয়া হুয়াস সামিউল আলীম।",
        translation: "আল্লাহর নামে, যাঁর নামের বরকতে আসমান ও জমিনের কোনো কিছুই কোনো ক্ষতি করতে পারে না। আর তিনি সর্বশ্রোতা ও সর্বজ্ঞ।",
        virtue: "রাসুলুল্লাহ (সা.) বলেছেন, যে ব্যক্তি সকাল-সন্ধ্যা ৩ বার এই দোয়া পড়বে, কোনো জিনিসই তার ক্ষতি করতে পারবে না।"
      ),
      const _DuaItemData(
        id: "basic_11",
        category: "basic",
        title: "আয়াতুল কুরসি (সবচেয়ে ফজিলতপূর্ণ আয়াত)",
        arabic: "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        pronunciation: "আল্লাহু লা ইলাহা ইল্লা হুয়াল হাইয়্যুল কাইয়্যুম। লা তা'খুযুহু সিনাতুও ওয়ালা নাওম। লাহু মা ফিস সামাওয়াতি ওয়ামা ফিল আরদ্। মান যাল্লাযী ইয়াশফাউ 'ইন্দাহু ইল্লা বিইযনিহ্। ইয়া'লামু মা বাইনা আইদীহিম ওয়اما খালফাহুম। ওয়ালা ইয়ুহীতূনা বিশাইয়িম মিন 'ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি'আ কুরসিইয়্যুহুস সামাওয়াতি ওয়াল আরদ্; ওয়ালা ইয়াউদুহু হিফযুহুমা ওয়া হুয়াল 'আলিইয়্যুল 'আযীম।",
        translation: "আল্লাহ, তিনি ব্যতীত কোনো ইলাহ নেই। তিনি চিরঞ্জীব, সবকিছুর ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সবকিছু তাঁরই। কে সে, যে তাঁর অনুমতি ছাড়া তাঁর নিকট সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে তা তিনি জানেন। আর তাঁর জ্ঞানের কোনো কিছু তারা আয়ত্ত করতে পারে না, কেবল তিনি যতটুকু চান তা ছাড়া। তাঁর কুরসি আসমান ও জমিন পরিব্যাপ্ত এবং এ দুটির সংরক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি অতি উচ্চ, অতি মহান।",
        virtue: "সুরা বাকারা (আয়াত ২৫৫)। শোয়ার সময় পাঠ করলে সারারাত আল্লাহর পক্ষ থেকে একজন রক্ষক নিযুক্ত থাকে এবং শয়তান কাছে আসতে পারে না। প্রতি ফরজ নামাজের পর পাঠ করলে জান্নাতে প্রবেশের মাঝে শুধু মৃত্যুই বাধা থাকে।"
      ),

      // 2. Iman Section (8 duas)
      const _DuaItemData(
        id: "iman_1",
        category: "iman",
        title: "কালিমা তাইয়্যেবা",
        arabic: "لَا إِلَهَ إِلَّا اللَّهُ مُحَمَّدٌ رَسُولُ اللَّهِ",
        pronunciation: "লা ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসূলুল্লাহ।",
        translation: "আল্লাহ ছাড়া কোনো উপাস্য নেই, মুহাম্মাদ (সা.) আল্লাহর রাসূল।",
        virtue: "এটি ইসলামের মূল ভিত্তি এবং সবচেয়ে বড় যিকির।"
      ),
      const _DuaItemData(
        id: "iman_2",
        category: "iman",
        title: "কালিমা শাহাদাত (ঈমানের সাক্ষ্য)",
        arabic: "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
        pronunciation: "আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু।",
        translation: "আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো ইলাহ নেই, তিনি একক, তাঁর কোনো শরিক নেই এবং আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মাদ (সা.) তাঁর বান্দা ও রাসূল।",
        virtue: "এটি পাঠ করলে জান্নাতের আটটি দরজাই উন্মুক্ত করা হয়।"
      ),
      const _DuaItemData(
        id: "iman_3",
        category: "iman",
        title: "শিরক থেকে আশ্রয়ের দু'আ",
        arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ، وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ",
        pronunciation: "আল্লাহুম্মা ইন্নি আউযুবিকা আন উশরিকা বিকা ওয়া আনা আ’লামু, ওয়া আস্তাগফিরুকা লিমা লা আ’লামু।",
        translation: "হে আল্লাহ! জেনে-শুনে আপনার সাথে শিরক করা থেকে আমি আপনার নিকট আশ্রয় চাই এবং না জেনে যে শিরক করে ফেলি তার জন্য ক্ষমা প্রার্থনা করছি।",
        virtue: "শিরক থেকে মুক্ত থাকতে রাসূলুল্লাহ (সা.) এই দু'আ পড়তে নির্দেশ দিয়েছেন।"
      ),
      const _DuaItemData(
        id: "iman_4",
        category: "iman",
        title: "ঈমানের ওপর অবিচল থাকার দু'আ",
        arabic: "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
        pronunciation: "ইয়া মুক্বাল্লিবাল কুলূবি সাব্বিত ক্বালবী আলা দ্বীনিকা।",
        translation: "হে মনের পরিবর্তনকারী! আমার মনকে আপনার দ্বীনের ওপর অবিচল ও দৃঢ় রাখুন।",
        virtue: "হাদিসে এসেছে, রাসূলুল্লাহ (সা.) সবচেয়ে বেশি এই দু'আটি পাঠ করতেন।"
      ),
      const _DuaItemData(
        id: "iman_5",
        category: "iman",
        title: "আল্লাহকে রব হিসেবে সন্তুষ্টির দোয়া",
        arabic: "رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
        pronunciation: "রাদীতু বিল্লাহি রাব্বাও ওয়া বিল ইসলামী দ্বীনাও ওয়া বি মুহাম্মাদিন সাল্লাল্লাহু আলাইহি ওয়া সাল্লামা নাবিয়্যা।",
        translation: "আমি আল্লাহকে রব হিসেবে, ইসলামকে দ্বীন হিসেবে এবং মুহাম্মাদ (সা.)-কে নবী হিসেবে পেয়ে সন্তুষ্ট হয়েছি।",
        virtue: "সকাল ও সন্ধ্যায় ৩ বার পাঠ করলে কিয়ামতের দিন আল্লাহ তাআলা তাকে সন্তুষ্ট করতে দায়িত্ব গ্রহণ করেন।"
      ),
      const _DuaItemData(
        id: "iman_6",
        category: "iman",
        title: "শয়তানের কুপ্ররোচনা থেকে আশ্রয়",
        arabic: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
        pronunciation: "আউযু বিল্লাহি মিনাশ শায়ত্বানির রাজীম।",
        translation: "বিতাড়িত শয়তান থেকে আল্লাহর নিকট আশ্রয় প্রার্থনা করছি।",
        virtue: "যেকোনো কুচিন্তা বা কুপ্ররোচনা মনে জাগলে তৎক্ষণাৎ এটি পাঠ করতে হবে।"
      ),
      const _DuaItemData(
        id: "iman_7",
        category: "iman",
        title: "ঈমান নবায়নের দু'আ",
        arabic: "آمَنْتُ بِاللَّهِ وَرُسُلِهِ",
        pronunciation: "আমানতু বিল্লাহি ওয়া রুসুলিহ।",
        translation: "আমি আল্লাহ এবং তাঁর রাসূলগণের ওপর ঈমান আনলাম।",
        virtue: "মনের মাঝে কোনো অস্থিরতা বা কুসংস্কারের উদ্রেক হলে এটি পড়া উপকারী।"
      ),
      const _DuaItemData(
        id: "iman_8",
        category: "iman",
        title: "কালিমা তাওহীদ",
        arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
        pronunciation: "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইয়িন ক্বাদীর।",
        translation: "এক আল্লাহ ছাড়া কোনো উপাস্য নেই, তাঁর কোনো শরিক নেই। সার্বভৌমত্ব ও প্রশংসা তাঁরই। আর তিনি সব কিছুর ওপর ক্ষমতাবান।",
        virtue: "প্রতিদিন ১০০ বার পড়লে ১০টি গোলাম আযাদ করার সওয়াব ও ১০০টি হাসানাহ অর্জন হয়।"
      ),

      // 3. Taharat Section (2 duas)
      const _DuaItemData(
        id: "taharat_1",
        category: "taharat",
        title: "শৌচাগারে প্রবেশের দোয়া",
        arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ",
        pronunciation: "আল্লাহুম্মা ইন্নি আউযুবিকা মিনাল খুবুসি ওয়াল খাবায়িস।",
        translation: "হে আল্লাহ! আমি অপবিত্র নর ও নারী জিন (শয়তান) থেকে আপনার নিকট আশ্রয় চাচ্ছি।",
        virtue: "শৌচাগারে প্রবেশের পূর্বে বাম পা বাড়িয়ে এটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "taharat_2",
        category: "taharat",
        title: "শৌচাগার থেকে বের হওয়ার দোয়া",
        arabic: "غُفْرَانَكَ",
        pronunciation: "গুফরানাকা।",
        translation: "আমি আপনার নিকট ক্ষমা প্রার্থনা করছি।",
        virtue: "শৌচাগার থেকে ডান পা দিয়ে বের হয়ে এই দু'আটি পাঠ করা সুন্নাহ।"
      ),

      // 4. Wudu Section (5 duas)
      const _DuaItemData(
        id: "wudu_1",
        category: "wudu",
        title: "ওযূ শুরুর দোয়া",
        arabic: "بِسْمِ اللَّهِ",
        pronunciation: "বিসমিল্লাহ।",
        translation: "আল্লাহর নামে শুরু করছি।",
        virtue: "ওযূর শুরুতে বিসমিল্লাহ বলা ওযূর অন্যতম সুন্নাহ আমল।"
      ),
      const _DuaItemData(
        id: "wudu_2",
        category: "wudu",
        title: "ওযূ শেষের দোয়া",
        arabic: "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ، اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ",
        pronunciation: "আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু ওয়া ashহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু, আল্লাহুম্মাজ আলনী মিনাত তাউওয়াবীনা ওয়াজ আলনী মিনাল মুতাত্বহহিরীন।",
        translation: "আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো ইলাহ নেই, তিনি একক, তাঁর কোনো শরিক নেই এবং আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মাদ (সা.) তাঁর বান্দা ও রাসূল। হে আল্লাহ! আমাকে তওবাকারী ও পবিত্রতা অর্জনকারীদের অন্তর্ভুক্ত করুন।",
        virtue: "ওযূ শেষ করে এই দোয়াটি পড়লে জান্নাতের ৮টি দরজাই খুলে দেওয়া হয়।"
      ),
      const _DuaItemData(
        id: "wudu_3",
        category: "wudu",
        title: "ওযূর মাঝের দোয়া",
        arabic: "اللَّهُمَّ اغْفِرْ لِي ذَنْبِي، وَوَسِّعْ لِي فِي دَارِي، وَبَارِكْ لِي فِي رِزْقِي",
        pronunciation: "আল্লাহুম্মাগফিরলী যাম্বী, ওয়া ওয়াসসি’লী ফী দারী, ওয়া বারিকলী ফী রিযক্বী।",
        translation: "হে আল্লাহ! আমার গুনাহসমূহ ক্ষমা করে দিন, আমার ঘর প্রশস্ত করে দিন এবং আমার রিযিকে বরকত দান করুন।",
        virtue: "ওযূর করার সময় বা নামাজে পড়ার জন্য অত্যন্ত ফলপ্রসূ।"
      ),
      const _DuaItemData(
        id: "wudu_4",
        category: "wudu",
        title: "মেসওয়াক করার গুরুত্ব",
        arabic: "بِسْمِ اللَّهِ",
        pronunciation: "বিসমিল্লাহ।",
        translation: "আল্লাহর নামে শুরু করছি।",
        virtue: "রাসূলুল্লাহ (সা.) বলেছেন, মেসওয়াক মুখের পবিত্রতার মাধ্যম এবং প্রতিপালকের সন্তুষ্টির উৎস।"
      ),
      const _DuaItemData(
        id: "wudu_5",
        category: "wudu",
        title: "অজু করার পর দোয়া (২)",
        arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ",
        pronunciation: "সুবহানাকাল্লাহুম্মা ওয়া বিহামদিকা, আশহাদু আল্লা ইলাহা ইল্লা আনতা, আস্তাগফিরুকা ওয়া আতূবু ইলাইকা।",
        translation: "হে আল্লাহ! আপনার প্রশংসা সহ পবিত্রতা ঘোষণা করছি। আমি সাক্ষ্য দিচ্ছি যে, আপনি ছাড়া কোনো ইলাহ নেই। আমি আপনার কাছে ক্ষমা চাচ্ছি এবং তওবা করছি।",
        virtue: "এটি পাঠ করলে একটি বিশেষ সিলমোহরে তা সংরক্ষিত করে আরশের নিচে রেখে দেওয়া হয়, যা কিয়ামত পর্যন্ত অক্ষত থাকবে।"
      ),

      // 5. Adhan Section (3 duas)
      const _DuaItemData(
        id: "adhan_1",
        category: "adhan",
        title: "আযানের জবাব দেওয়া",
        arabic: "مِثْلَ مَا يَقُولُ الْمُؤَذِّنُ",
        pronunciation: "মুয়াযযিন যা বলে তা বলা।",
        translation: "মুয়াযযিনের প্রতিটি বাক্যের পর হুবহু তাই বলা, কেবল হাইয়্যা আলাস সালাহ ও হাইয়্যা আলাল ফালাহ এর বদলে 'লা হাওলা ওয়া লা কুওয়াতা ইল্লা বিল্লাহ' বলা।",
        virtue: "যে ব্যক্তি বিশ্বাসের সাথে মুয়াযযিনের জবাব দেয়, সে জান্নাতে প্রবেশ করবে।"
      ),
      const _DuaItemData(
        id: "adhan_2",
        category: "adhan",
        title: "আযানের পরের দোয়া",
        arabic: "اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ",
        pronunciation: "আল্লাহুম্মা রাব্বা হাযিহিদ দাওয়াতিত তাম্মাহ, ওয়াস সালাতিল কায়িমাহ, আতি মুহাম্মাদানিল ওয়াসীলাতা ওয়াল ফাদীলাহ, ওয়াবআছহু মাক্বামাম মাহমূدانিল্লাযী ওয়াআদতাহ।",
        translation: "হে আল্লাহ! এই পরিপূর্ণ আহ্বান এবং প্রতিষ্ঠিত সালাতের মালিক। আমাদের প্রিয় নবী মুহাম্মাদ (সা.)-কে অসীলা (জান্নাতের সর্বোচ্চ সম্মান) ও ফজিলত দান করুন এবং তাঁকে প্রশংসিত স্থানে অধিষ্ঠিত করুন, যার প্রতিশ্রুতি আপনি তাঁকে দিয়েছেন।",
        virtue: "যে ব্যক্তি আযান শুনে এই দোয়া পড়বে, কিয়ামতের দিন তার জন্য রাসূলুল্লাহ (সা.)-এর শাফায়াত ওয়াজিব হয়ে যাবে।"
      ),
      const _DuaItemData(
        id: "adhan_3",
        category: "adhan",
        title: "ইকামতের জবাব",
        arabic: "أَقَامَهَا اللَّهُ وَأَدَامَهَا",
        pronunciation: "আক্বামাহাল্লাহু ওয়া আদামাহা।",
        translation: "আল্লাহ এটিকে চিরস্থায়ী ও প্রতিষ্ঠিত রাখুন।",
        virtue: "ইকামতের সময় মুয়াযযিনের বাক্যসমূহের জবাব দেওয়া এবং নামাজে মনোযোগ বৃদ্ধির আমল।"
      ),

      // 6. Masjid Section (4 duas)
      const _DuaItemData(
        id: "masjid_1",
        category: "masjid",
        title: "মসজিদে প্রবেশের দোয়া",
        arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
        pronunciation: "আল্লাহুম্মাফ তাহলী আবওয়াবা রাহমাতিক।",
        translation: "হে আল্লাহ! আমার জন্য আপনার রহমতের দুয়ারসমূহ খুলে দিন।",
        virtue: "মসজিদে প্রবেশের সময় দুরুদ শরিফ সহ এই দোয়াটি পড়া অত্যন্ত ফজিলতপূর্ণ সুন্নাহ আমল।"
      ),
      const _DuaItemData(
        id: "masjid_2",
        category: "masjid",
        title: "মসজিদ থেকে বের হওয়ার দোয়া",
        arabic: "اللَّهُمَّ إِني أَسْأَلُكَ مِنْ فَضْلِكَ",
        pronunciation: "আল্লাহুম্মা ইন্নি আসআলুকা মিন ফাদলিক।",
        translation: "হে আল্লাহ! আমি আপনার অনুগ্রহ প্রার্থনা করছি।",
        virtue: "মসজিদ থেকে বাম পা দিয়ে বের হওয়ার সময় এটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "masjid_3",
        category: "masjid",
        title: "মসজিদের দিকে যাওয়ার দোয়া",
        arabic: "اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي لِسَانِي نُورًا، وَفِي سَمْعِي نُورًا، وَفِي بَصَرِي نُورًا",
        pronunciation: "আল্লাহুম্মাজ আল ফী ক্বালবী নূরান, ওয়া ফী লিসানী নূরান, ওয়া ফী সাম’ঈ নূরান, ওয়া ফী বাছারী নূরান।",
        translation: "হে আল্লাহ! আমার অন্তরে আলো দিন, আমার জবান বা জিহ্বায় আলো দিন, আমার কানে আলো দিন এবং আমার চোখে আলো দিন।",
        virtue: "মসজিদের দিকে যাওয়ার সময় এ দোয়াটি রাসূলুল্লাহ (সা.) পাঠ করতেন।"
      ),
      const _DuaItemData(
        id: "masjid_4",
        category: "masjid",
        title: "তাহিয়্যাতুল মসজিদ (সালাত)",
        arabic: "صَلَاةُ رَكْعَتَيْنِ قَبْلَ الْجُلُوسِ",
        pronunciation: "বসার পূর্বে দুই রাকাত নামাজ।",
        translation: "মসজিদে প্রবেশের পর বসার আগে আল্লাহর সম্মানে ২ রাকাত সালাত আদায় করা।",
        virtue: "রাসূলুল্লাহ (সা.) বলেছেন, তোমাদের কেউ মসজিদে প্রবেশ করলে সে যেন ২ রাকাত সালাত আদায়ের পূর্বে না বসে।"
      ),

      // 7. Namaz Section (12 duas)
      const _DuaItemData(
        id: "namaz_1",
        category: "namaz",
        title: "ছানা (তাকবীরে তাহরীমার পর)",
        arabic: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ",
        pronunciation: "সুবহানাকাল্লাহুম্মা ওয়া বিহামদিকা ওয়া তাবারাকাসমুকা ওয়া তাআলা জাদ্দুকা ওয়া লা ইলাহা গাইরুকা।",
        translation: "হে আল্লাহ! আমি আপনার প্রশংসা সহ পবিত্রতা ঘোষণা করছি। আপনার নাম বরকতময়, আপনার মহিমা অতি উচ্চ এবং আপনি ছাড়া কোনো ইলাহ নেই।",
        virtue: "সালাত শুরুর পর তাকবীরে তাহরীমার শেষে এটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_2",
        category: "namaz",
        title: "রুকুর তাসবিহ",
        arabic: "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
        pronunciation: "সুবহানা রাব্বিয়াল আজীম।",
        translation: "আমার মহান প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
        virtue: "রুকু অবস্থায় ৩ বার বা তার বেশি বিজোড় সংখ্যায় এটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_3",
        category: "namaz",
        title: "রুকু থেকে ওঠার দোয়া",
        arabic: "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ",
        pronunciation: "সামিয়াল্লাহু লিমান হামিদাহ। রাব্বানা লাকাল হামদ।",
        translation: "আল্লাহ শুনলেন যে ব্যক্তি তাঁর প্রশংসা করল। হে আমাদের রব! সমস্ত প্রশংসা কেবল আপনারই।",
        virtue: "রুকু থেকে সোজা হয়ে দাঁড়িয়ে এটি পাঠ করতে হয়।"
      ),
      const _DuaItemData(
        id: "namaz_4",
        category: "namaz",
        title: "সিজদার তাসবিহ",
        arabic: "سُبْحَانَ رَبِّيَ الْأَعْلَى",
        pronunciation: "সুবহানা রাব্বিয়াল আ'লা।",
        translation: "আমার সর্বউচ্চ প্রতিপালকের পবিত্রতা ঘোষণা করছি।",
        virtue: "সিজদা অবস্থায় ৩ বার এটি পাঠ করা সুন্নাহ। বান্দা সিজদা অবস্থায় আল্লাহর সবচেয়ে নিকটবর্তী হয়।"
      ),
      const _DuaItemData(
        id: "namaz_5",
        category: "namaz",
        title: "দুই সিজদার মাঝের দোয়া",
        arabic: "اللَّهُمَّ اغْفِرْ لِي، وَارْحَمْنِي، وَاهْدِنِي، وَعَافِنِي، وَارْزُقْنِي",
        pronunciation: "আল্লাহুম্মাগ ফিরলী ওয়ারহামনী ওয়াহদীনি ওয়া আফিনী ওয়ারযুক্বনী।",
        translation: "হে আল্লাহ! আমাকে ক্ষমা করুন, আমার প্রতি দয়া করুন, আমাকে হেদায়েত দিন, আমাকে নিরাপত্তা দিন এবং আমাকে জীবিকা দান করুন।",
        virtue: "দুই সিজদার মাঝখানে সোজা হয়ে বসে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_6",
        category: "namaz",
        title: "তাশাহহুদ (আত্তাহিয়্যাতু)",
        arabic: "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
        pronunciation: "আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত ত্বাইয়্যিবাতু, আসসালামু আলাইকা আইয়্যুহান নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু, আসসালামু আলাইনা ওয়া আলা ইবাদিল্লাহিস সালিহীন, আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়া ashহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসূলুহু।",
        translation: "যাবতীয় সম্মান, উপাসনা ও পবিত্রতা একমাত্র আল্লাহর জন্য। হে নবী! আপনার প্রতি শান্তি, আল্লাহর রহমত ও বরকত বর্ষিত হোক। আমাদের প্রতি এবং আল্লাহর নেক বান্দাদের প্রতি শান্তি বর্ষিত হোক। আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই এবং মুহাম্মাদ (সা.) তাঁর বান্দা ও রাসূল।",
        virtue: "সালাতের ২য় ও শেষ রাকাতে বসে তাশাহহুদ পাঠ করা ওয়াজিব।"
      ),
      const _DuaItemData(
        id: "namaz_7",
        category: "namaz",
        title: "দুরুদ শরীফ (সালাতে পড়ার)",
        arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
        pronunciation: "আল্লাহুম্মা সাল্লি আলা মুহাম্মাদিও ওয়া আলা আলি মুহাম্মাদিন কামা সাল্লাইতা আলা ইব্রাহীমা ওয়া আলা আলি ইব্রাহীমা ইন্নাকা হামীদুম মাজীদ। আল্লাহুম্মা বারিক আলা মুহাম্মাদিও ওয়া আলা আলি মুহাম্মাদিন কামা বারাকতা আলা ইব্রাহীমা ওয়া আলা আলি ইব্রাহীমা ইন্নাকা হামীদুম মাজীদ।",
        translation: "হে আল্লাহ! আপনি মুহাম্মাদ (সা.) ও তাঁর বংশধরদের ওপর রহমত বর্ষণ করুন, যেমন আপনি ইব্রাহীম (আ.) ও তাঁর বংশধরদের ওপর রহমত বর্ষণ করেছিলেন। নিশ্চয়ই আপনি প্রশংসিত ও মহিমান্বিত। হে আল্লাহ! আপনি মুহাম্মাদ (সা.) ও তাঁর বংশধরদের ওপর বরকত বর্ষণ করুন, যেমন আপনি ইব্রাহীম (আ.) ও তাঁর বংশধরদের ওপর বরকত বর্ষণ করেছিলেন। নিশ্চয়ই আপনি প্রশংসিত ও মহিমান্বিত।",
        virtue: "তাশাহহুদের পর দুরুদ পাঠ করা সালাতের অন্যতম প্রধান আমল ও রোকন।"
      ),
      const _DuaItemData(
        id: "namaz_8",
        category: "namaz",
        title: "দোয়ায় মাসূরা",
        arabic: "اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ، وَارْحَمْنِي، إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ",
        pronunciation: "আল্লাহুম্মা ইন্নী যলামতু নাফসী যুলমান কাছীরাও ওয়া লা ইয়াগফিরুয যুনূবা ইল্লা আনতা, ফাগফিরলী মাগফিরাতাম মিন ইনদিকা ওয়ারহামনী, ইন্নাকা আনতাল গাফুরুর রাহীম।",
        translation: "হে আল্লাহ! আমি আমার নিজের ওপর অনেক জুলুম করেছি। আর আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই। অতএব আপনি আপনার পক্ষ থেকে আমাকে ক্ষমা করুন এবং আমার প্রতি দয়া করুন। নিশ্চয়ই আপনি পরম ক্ষমাশীল ও দয়াময়।",
        virtue: "সালাতে দুরুদের পর এবং সালাম ফেরানোর আগে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_9",
        category: "namaz",
        title: "বিতর সালাতে দোয়া কুনুত",
        arabic: "اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنُؤْمِنُ بِكَ وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ وَنَشْكُرُكَ وَلَا نَكْفُرُكَ وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ. اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ وَإِكَ نَسْعَى وَنَحْفِدُ وَنَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحِقٌ",
        pronunciation: "আল্লাহুম্মা ইন্না নাসতাঈনুকা ওয়া নাসতাগফিরুকা ওয়া নুমিনু বিকা ওয়া নাতাওয়াককালু আলাইকা ওয়া নুছনী আলাইকাল খাইরা ওয়া নাশকুরুকা ওয়া লা নাকফুরুকা ওয়া নাখলাউ ওয়া নাতরুকু মাইঁ ইয়াফজুরুকা। আল্লাহুম্মা ইয়্যাকা নাবুদু ওয়া লাকা নুছাল্লী ওয়া নাসজুদু ওয়া ইলাইকা নাস’আ ওয়া নাহফিদু ওয়া নারজু রাহমাতাকা ওয়া নাখশা আযাবাকা ইন্না আযাবাকা বিল কুফফারি মুলহিক্ব।",
        translation: "হে আল্লাহ! আমরা আপনার সাহায্য চাই, আপনার কাছে ক্ষমা চাই, আপনার ওপর ঈমান রাখি, আপনার ওপর ভরসা করি, আপনার উত্তম প্রশংসা করি, আপনার কৃতজ্ঞতা প্রকাশ করি, অকৃতজ্ঞ হই না এবং যে আপনার অবাধ্যতা করে তাকে আমরা বর্জন করি ও ত্যাগ করি। হে আল্লাহ! আমরা আপনারই ইবাদত করি, আপনার জন্যই সালাত আদায় করি ও সিজদা করি, আপনার দিকেই আমরা ধাবিত হই এবং আপনার রহমতের আশা করি ও আযাবকে ভয় করি। নিশ্চয়ই আপনার আযাব কাফেরদের গ্রাস করবে।",
        virtue: "বিতর সালাতের শেষ রাকাতে রুকুর পূর্বে বা পরে এই কুনুত পাঠ করা ওয়াজিব/সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_10",
        category: "namaz",
        title: "সালাম ফেরানোর পর দোয়া",
        arabic: "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ ذَا الْجَلَالِ وَالْإِكْرَامِ",
        pronunciation: "আল্লাহুম্মা আনতাস সালামু ওয়া মিনকাস সালামু, তাবারাকতা যাল জালালি ওয়াল ইকরাম।",
        translation: "হে আল্লাহ! আপনিই শান্তি এবং আপনার পক্ষ থেকেই শান্তি বর্ষিত হয়। হে প্রতাপ ও সম্মানের অধিকারী! আপনি বরকতময়।",
        virtue: "ফরজ সালাত শেষে সালাম ফেরানোর পর ১ বার 'আল্লাহু আকবার' ও ৩ বার 'আস্তাগফিরুল্লাহ' বলে এই দোয়াটি পড়া সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "namaz_11",
        category: "namaz",
        title: "নামাজ শেষে ইবাদত কবুলের দোয়া",
        arabic: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
        pronunciation: "আল্লাহুম্মা আইন্নী আলা যিকরিকা ওয়া শুকরিকা ওয়া হুসনি ইবাদাতিকা।",
        translation: "হে আল্লাহ! আমাকে আপনার যিকির করতে, আপনার কৃতজ্ঞতা প্রকাশ করতে এবং আপনার সুন্দর ইবাদত করতে সাহায্য করুন।",
        virtue: "প্রতি নামাজের পর এটি পাঠ করতে রাসূলুল্লাহ (সা.) বিশেষভাবে নির্দেশ দিয়েছেন।"
      ),
      const _DuaItemData(
        id: "namaz_12",
        category: "namaz",
        title: "নামাজের শেষ বৈঠকে ৪টি বড় ফিতনা থেকে আশ্রয়",
        arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ",
        pronunciation: "আল্লাহুম্মা ইন্নি আউযুবিকা মিন আযাবি জাহান্নামা, ওয়া মিন আযাবিল ক্বাবরি, ওয়া মিন ফিতনাতিল মাহইয়া ওয়াল মামাতি, ওয়া মিন শাররি ফিতনাতিল মাসীহিদ দাজ্জাল।",
        translation: "হে আল্লাহ! আমি আপনার নিকট আশ্রয় চাই জাহান্নামের আযাব থেকে, কবরের আযাব থেকে, জীবন ও মৃত্যুর ফিতনা থেকে এবং দাজ্জালের ফিতনার অনিষ্ট থেকে।",
        virtue: "তাশাহহুদ ও দুরুদের পর এই দোয়াটি পাঠ করা সুন্নাতে মুয়াক্কাদাহ।"
      ),

      // 8. Sleep & Food Category details (7 duas)
      const _DuaItemData(
        id: "sleep_food_1",
        category: "sleep_food",
        title: "ঘুম থেকে ওঠার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আহইয়ানা বা’দা মা আমাদেরতানা ওয়া ইলাইহিন নুশুর।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের মৃত্যুর (ঘুমের) পর পুনর্জীবিত করলেন এবং তাঁর দিকেই আমাদের ফিরে যেতে হবে।",
        virtue: "ঘুম থেকে উঠে এই দোয়াটি পড়া রাসূলুল্লাহ (সা.) এর অন্যতম একটি সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "sleep_food_2",
        category: "sleep_food",
        title: "ঘুমানোর পূর্বে দোয়া",
        arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
        pronunciation: "বিসমিকা আল্লাহুম্মা আমুতু ওয়া আহয়া।",
        translation: "হে আল্লাহ! আপনারই নামে আমি মৃত্যুবরণ করছি (ঘুমাচ্ছি) এবং জীবিত হব (জাগ্রত হব)।",
        virtue: "ঘুমানোর পূর্বে ডান কাতে শুয়ে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "sleep_food_3",
        category: "sleep_food",
        title: "খাবারের শুরুতে দোয়া",
        arabic: "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ",
        pronunciation: "বিসমিল্লাহি ওয়া আলা বারাকাতিল্লাহ।",
        translation: "আল্লাহর নামে এবং আল্লাহর বরকতের ওপর ভরসা করে খাওয়া শুরু করলাম।",
        virtue: "খাবারের শুরুতে বিসমিল্লাহ বলতে ভুলে গেলে বলুন: 'বিসমিল্লাহি আউওয়ালাহু ওয়া আখিরাহু'।"
      ),
      const _DuaItemData(
        id: "sleep_food_4",
        category: "sleep_food",
        title: "খাবার শেষ করার দোয়া",
        arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
        pronunciation: "আলহামদু লিল্লাহিল্লাজি আতআমানা ওয়া সাকানা ওয়া জাআলানা মুসলিমীন।",
        translation: "সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের আহার করিয়েছেন, পান করিয়েছেন এবং মুসলমান বানিয়েছেন।",
        virtue: "আহার শেষে আল্লাহর শুকরিয়া আদায় করা অত্যন্ত ফজিলতপূর্ণ আমল।"
      ),
      const _DuaItemData(
        id: "sleep_food_5",
        category: "sleep_food",
        title: "নতুন ফল খাওয়ার দোয়া",
        arabic: "اللَّهُمَّ بَارِكْ لَنَا فِي ثَمَرِنَا، وَبَارِك... ",
        pronunciation: "আল্লাহুম্মা বারিক লানা ফী ছামারিনা, ওয়া বারিক লানা ফী মাদীনাতিনা।",
        translation: "হে আল্লাহ! আমাদের ফলে বরকত দিন, আমাদের শহরে বরকত দিন এবং আমাদের খাদ্যশস্যের পরিমাপে বরকত দিন।",
        virtue: "নতুন কোনো ফল খেতে শুরু করলে এই দোয়াটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "sleep_food_6",
        category: "sleep_food",
        title: "মেহমানদারির কৃতজ্ঞতার দোয়া",
        arabic: "اللَّهُمَّ أَطْعَمْ مَنْ أَطْعَمَنِي، وَاسْقِ مَنْ سَقَانِي",
        pronunciation: "আল্লাহুম্মা আতইম মান আতইমানী, ওয়াসক্বি মান সাক্বানী।",
        translation: "হে আল্লাহ! যে আমাকে আহার করিয়েছে তাকে আহার করান, যে আমাকে পান করিয়েছে তাকে পান করান।",
        virtue: "কারো বাড়িতে মেহমান হিসেবে আহার করার পর মেজবানের কল্যাণে এ দোয়াটি রাসূলুল্লাহ (সা.) পড়তেন।"
      ),
      const _DuaItemData(
        id: "sleep_food_7",
        category: "sleep_food",
        title: "দুধ পান করার পর দোয়া",
        arabic: "اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَزِدْنَا مِنْهُ",
        pronunciation: "আল্লাহুম্মা বারিক লানা ফীহি ওয়া যিদনা মিনহু।",
        translation: "হে আল্লাহ! আমাদের জন্য এতে বরকত দান করুন এবং তা আমাদের জন্য বৃদ্ধি করে দিন।",
        virtue: "দুধ বা পুষ্টিকর পানীয় পানের পর আল্লাহর শুকরিয়া সহ এই দোয়া পাঠ করা সুন্নাহ।"
      ),

      // 9. Protection & Refuge Category details (7 duas)
      const _DuaItemData(
        id: "protection_1",
        category: "protection",
        title: "বিপদ-আপদ ও দুশ্চিন্তা মুক্তির দোয়া (ইউনুস নবীর দোয়া)",
        arabic: "لَّا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
        pronunciation: "লা ইলাহা ইল্লা আন্তা সুবহানাকা ইন্নী কুনতু মিনাজ জোয়ালিমীন।",
        translation: "আপনি ব্যতীত কোনো ইলাহ নেই, আপনি অতি পবিত্র। নিশ্চয়ই আমি অপরাধীদের অন্তর্ভুক্ত।",
        virtue: "সুরা আম্বিয়া (আয়াত ৮৭)। রাসুলুল্লাহ (সা.) বলেছেন, কোনো মুসলমান বিপদে পড়ে এই দোয়া করলে আল্লাহ তা কবুল করেন।"
      ),
      const _DuaItemData(
        id: "protection_2",
        category: "protection",
        title: "শয়তান ও সব ধরনের ক্ষতি থেকে বাঁচার দোয়া",
        arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
        pronunciation: "বিসমিল্লাহিল্লাজি লা ইয়াদুররু মায়াসমিহি শাইউন ফিল আরদি ওয়া লা ফিস সামায়ি ওয়া হুয়াস সামিউল আলীম।",
        translation: "আল্লাহর নামে, যাঁর নামের বরকতে আসমান ও জমিনের কোনো কিছুই কোনো ক্ষতি করতে পারে না। আর তিনি সর্বশ্রোতা ও সর্বজ্ঞ।",
        virtue: "রাসুলুল্লাহ (সা.) বলেছেন, যে ব্যক্তি সকাল-সন্ধ্যা ৩ বার এই দোয়া পড়বে, কোনো জিনিসই তার ক্ষতি করতে পারবে না।"
      ),
      const _DuaItemData(
        id: "protection_3",
        category: "protection",
        title: "আয়াতুল কুরসি (সবচেয়ে ফজিলতপূর্ণ আয়াত)",
        arabic: "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ",
        pronunciation: "আল্লাহু লা ইলাহা ইল্লা হুয়াল হাইয়্যুল কাইয়্যুম। লা তা'খুযুহু সিনাতুও ওয়ালা নাওম। লাহু মা ফিস সামাওয়াতি ওয়ামা ফিল আরদ্। মান যাল্লাযী ইয়াশফাউ 'ইন্দাহু ইল্লা বিইযনিহ্। ইয়া'লামু মা বাইনা আইদীহিম ওয়ামা খালফাহুম। ওয়ালা ইয়ুহীতূনা বিশাইয়িম মিন 'ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি'আ কুরসিইয়্যুহুস সামাওয়াতি ওয়াল আরদ্; ওয়ালা ইয়াউদুহু হিফযুহুমা ওয়া হুয়াল 'আলিইয়্যুল 'আযীম।",
        translation: "আল্লাহ, তিনি ব্যতীত কোনো ইলাহ নেই। তিনি চিরঞ্জীব, সবকিছুর ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সবকিছু তাঁরই। কে সে, যে তাঁর অনুমতি ছাড়া তাঁর নিকট সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে তা তিনি জানেন। আর তাঁর জ্ঞানের কোনো কিছু তারা আয়ত্ত করতে পারে না, কেবল তিনি যতটুকু চান তা ছাড়া। তাঁর কুরসি আসমান ও জমিন পরিব্যাপ্ত এবং এ দুটির সংরক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি অতি উচ্চ, অতি মহান।",
        virtue: "সুরা বাকারা (আয়াত ২৫৫)। শোয়ার সময় পাঠ করলে সারারাত আল্লাহর পক্ষ থেকে একজন রক্ষক নিযুক্ত থাকে এবং শয়তান কাছে আসতে পারে না। প্রতি ফরজ নামাজের পর পাঠ করলে জান্নাতে প্রবেশের মাঝে শুধু মৃত্যুই বাধা থাকে।"
      ),
      const _DuaItemData(
        id: "protection_4",
        category: "protection",
        title: "অসুস্থতা ও নজর লাগা থেকে বাঁচার দোয়া",
        arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ",
        pronunciation: "আউযু বিকালিমাাতিল্লাহিত তাাম্মাহ মিন কুল্লি শায়ত্বানিও ওয়া হাম্মাহ, ওয়া মিন কুল্লি আই’নিল লাম্মাহ।",
        translation: "আমি আল্লাহর পরিপূর্ণ কলেমসমূহের অসীলায় আশ্রয় চাচ্ছি সকল শয়তান, বিষাক্ত পোকা-মাকড় এবং সকল কুদৃষ্টি (নজর লাগা) থেকে।",
        virtue: "বাচ্চাদের ও নিজেকে কুদৃষ্টি ও শয়তানের মন্দ প্রভাব থেকে নিরাপদে রাখতে রাসূলুল্লাহ (সা.) এই দোয়া পড়তে বলতেন।"
      ),
      const _DuaItemData(
        id: "protection_5",
        category: "protection",
        title: "বিষাদ ও ঋণ মুক্তির দোয়া",
        arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ",
        pronunciation: "আল্লাহুম্মা ইন্নি আউযুবিকা মিনাল হামমি ওয়াল হাযানি, ওয়া আউযুবিকা মিনাল আজযি ওয়াল কাসালি, ওয়া আউযুবিকা মিনাল জুবনি ওয়াল বুখলি, ওয়া আউযুবিকা মিন গালাবাতিদ দাইনি ওয়া কাহরির রিজাল।",
        translation: "হে আল্লাহ! আমি আপনার নিকট আশ্রয় চাই উদ্বেগ ও উৎকণ্ঠা থেকে, অক্ষমতা ও অলসতা থেকে, ভীরুতা ও কৃপণতা থেকে এবং ঋণের বোঝা ও মানুষের দমন-পীড়ন থেকে।",
        virtue: "দুশ্চিন্তা ও ঋণের চরম বোঝায় জর্জরিত মানুষের জন্য এটি অত্যন্ত শক্তিশালী ও প্রশান্তিদায়ক দোয়া।"
      ),
      const _DuaItemData(
        id: "protection_6",
        category: "protection",
        title: "প্রাকৃতিক দুর্যোগ বা ভয়ের সময়ের দোয়া",
        arabic: "اللَّهُمَّ لَا تَقْتُلْنَا بِغَضَبِكَ، وَلَا تُهْلِكْنَا بِعَذَابِكَ، وَعَافِنَا قَبْلَ ذَلِكَ",
        pronunciation: "আল্লাহুম্মা লা তাক্বতুলনা বিগাদাবিকা, ওয়া লা তুহলিকনা বিআযাবিকা, ওয়া আফিনা ক্বাবলা যালিকা।",
        translation: "হে আল্লাহ! আপনার গজব দিয়ে আমাদের হত্যা করবেন না এবং আপনার আযাব দিয়ে ধ্বংস করবেন না; বরং এর পূর্বেই আমাদের ক্ষমা ও নিরাপত্তা দান করুন।",
        virtue: "ঝড়-তুফান, বজ্রপাত বা ভূমিকম্পের ন্যায় প্রাকৃতিক দুর্যোগের সময় এটি পাঠ করা সুন্নাহ।"
      ),
      const _DuaItemData(
        id: "protection_7",
        category: "protection",
        title: "ক্ষমা ও তওবার শ্রেষ্ঠ দোয়া (সায়্যিদুল ইস্তিগফার)",
        arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
        pronunciation: "আল্লাহুম্মা আনতা রাব্বি লা ইলাহা ইল্লা আনতা, খালাক্বতানি ওয়া আনা আবদুকা, ওয়া আনা আলা আহদিকা ওয়া ওয়া’দিকা মাস্তাত্বা’তু। আউযু বিকা মিন শাররি মা ছানা’তু, আবূউ লাকা বিনি’মাতিকা আলাইয়া, ওয়া আবূউ লাকা বিযাম্বি ফাগফিরলী ফাইন্নাহু লা ইয়াগফিরুয যুনূবা ইল্লা আনতা।",
        translation: "হে আল্লাহ! আপনিই আমার প্রতিপালক, আপনি ছাড়া কোনো সত্য উপাস্য নেই। আপনিই আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা। আমি আমার সাধ্যমতো আপনার সাথে কৃত অঙ্গীকার ও প্রতিশ্রুতির ওপর অবিচল আছি। আমি যা করেছি তার মন্দ ফলাফল থেকে আপনার নিকট আশ্রয় চাই। আমার ওপর আপনার যে নেয়ামত রয়েছে তা স্বীকার করছি এবং আমার গুনাহও স্বীকার করছি। অতএব আমাকে ক্ষমা করুন, কেননা আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই।",
        virtue: "রাসূলুল্লাহ (সা.) বলেছেন, যে ব্যক্তি দিনের বেলায় বিশ্বাসের সাথে এটি পড়বে এবং সন্ধ্যা হওয়ার পূর্বে মারা যাবে সে জান্নাতী হবে। একইভাবে রাতে পড়ে সকালের পূর্বে মারা গেলে জান্নাতী হবে।"
      ),
    ];
  }
}

// Model classes helper
class _DuaCategoryData {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const _DuaCategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _DuaItemData {
  final String id;
  final String category;
  final String title;
  final String arabic;
  final String pronunciation;
  final String translation;
  final String virtue;

  const _DuaItemData({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.pronunciation,
    required this.translation,
    required this.virtue,
  });
}

// Detail page for sub-categories
class DuaCategoryDetailPage extends StatefulWidget {
  final _DuaCategoryData category;
  final List<_DuaItemData> duas;

  const DuaCategoryDetailPage({
    super.key,
    required this.category,
    required this.duas,
  });

  @override
  State<DuaCategoryDetailPage> createState() => _DuaCategoryDetailPageState();
}

class _DuaCategoryDetailPageState extends State<DuaCategoryDetailPage> {
  final TextEditingController _subSearchController = TextEditingController();
  String _subQuery = "";

  @override
  void initState() {
    super.initState();
    _subSearchController.addListener(() {
      setState(() {
        _subQuery = _subSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _subSearchController.dispose();
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

  List<_DuaItemData> _getFilteredSubDuas() {
    if (_subQuery.isEmpty) return widget.duas;
    return widget.duas.where((d) {
      return d.title.toLowerCase().contains(_subQuery) ||
          d.arabic.toLowerCase().contains(_subQuery) ||
          d.pronunciation.toLowerCase().contains(_subQuery) ||
          d.translation.toLowerCase().contains(_subQuery) ||
          d.virtue.toLowerCase().contains(_subQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;
    final filtered = _getFilteredSubDuas();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sub-search bar inside details page
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _subSearchController,
              decoration: InputDecoration(
                hintText: "এই ক্যাটাগরিতে খুঁজুন...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: widget.category.color),
                suffixIcon: _subQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _subSearchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: widget.category.color, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      "কোন দোয়া খুঁজে পাওয়া যায়নি 🔍",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final d = filtered[index];
                      final isBookmarked = settings.bookmarkedDuas.contains(d.id);
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
                                      fontSize: 13.5,
                                      color: widget.category.color,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: isBookmarked ? AppColors.gold : (isDark ? Colors.white38 : Colors.black38),
                                        size: 20,
                                      ),
                                      onPressed: () => settings.toggleDuaBookmark(d.id),
                                      tooltip: "বুকমার্ক করুন",
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy_rounded,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        size: 18,
                                      ),
                                      onPressed: () => _copyToClipboard(textToCopy, d.title),
                                      tooltip: "দোয়া কপি করুন",
                                    ),
                                  ],
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
                                  Icon(Icons.info_outline_rounded, color: widget.category.color, size: 16),
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
                  ),
          ),
        ],
      ),
    );
  }
}
