import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class ItikafScreen extends StatefulWidget {
  const ItikafScreen({super.key});

  @override
  State<ItikafScreen> createState() => _ItikafScreenState();
}

class _ItikafScreenState extends State<ItikafScreen> with SingleTickerProviderStateMixin {
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
        title: const Text("ইতিকাফ সাথী"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "ইতিকাফের বিধান"),
            Tab(text: "আমল ট্র্যাকার"),
            Tab(text: "দোয়া ও ইস্তিগফার"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRulesTab(context, settings, isDark),
          _buildTrackerTab(context, settings, isDark),
          _buildDuasTab(context, settings, isDark),
        ],
      ),
    );
  }

  Widget _buildRulesTab(BuildContext context, SettingsService settings, bool isDark) {
    final sections = _getItikafRules();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final sec = sections[index];
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
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(sec.icon, color: AppColors.gold, size: 20),
              ),
              title: Text(
                sec.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                      ...sec.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
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

  Widget _buildTrackerTab(BuildContext context, SettingsService settings, bool isDark) {
    if (!settings.isItikafActive) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.roofing_rounded, color: AppColors.gold, size: 64),
              const SizedBox(height: 16),
              Text(
                "১০ দিনের ইতিকাফ শুরু করুন",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "রমজানের শেষ দশ দিন মসজিদে অবস্থান করে ইতিকাফ করা সুন্নাতে মুয়াক্কাদাহ কেফায়াহ। আপনার ইতিকাফের আমল রেকর্ড ও নজরদারি করতে নিচে ক্লিক করুন।",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text("ইতিকাফ শুরু করুন", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => settings.startItikaf(),
              ),
            ],
          ),
        ),
      );
    }

    final completedDays = settings.itikafDaysCompleted;
    final progress = completedDays / 10.0;
    final activeDay = completedDays < 10 ? completedDays + 1 : 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Itikaf Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF283593)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.3),
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
                          "১০ দিনের ইতিকাফ ট্র্যাকার",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "শুরু: ${settings.itikafStartDate}",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white70),
                      onPressed: () => _confirmStopItikaf(context, settings),
                      tooltip: "ইতিকাফ শেষ করুন",
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
                            "অগ্রগতি: $completedDays / ১০ দিন সম্পন্ন",
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
                                onPressed: completedDays > 0 ? () => settings.decrementItikafDay() : null,
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
                                onPressed: completedDays < 10 ? () => settings.incrementItikafDay() : null,
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

          // Daily Checklist for Itikaf
          if (completedDays < 10) ...[
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
                    _buildItikafDeedTile(settings, activeDay, "prayers", "৫ ওয়াক্ত নামাজ জামাতে আদায়", Icons.check_circle_outline_rounded, AppColors.emerald),
                    const Divider(height: 1),
                    _buildItikafDeedTile(settings, activeDay, "tahajjud", "তাহাজ্জুদ ও অন্যান্য নফল সালাত", Icons.stars_rounded, Colors.purple),
                    const Divider(height: 1),
                    _buildItikafDeedTile(settings, activeDay, "quran", "কুরআন তিলাওয়াত ও তাদাব্বুর", Icons.auto_stories_rounded, Colors.orange),
                    const Divider(height: 1),
                    _buildItikafDeedTile(settings, activeDay, "dhikr", "সকাল ও বিকেলের মাসনুন জিকির", Icons.fingerprint_rounded, Colors.blue),
                    const Divider(height: 1),
                    _buildItikafDeedTile(settings, activeDay, "repentance", "তওবা, ইস্তিগফার ও কান্নাকাটি", Icons.favorite_rounded, Colors.redAccent),
                    const Divider(height: 1),
                    _buildItikafDeedTile(settings, activeDay, "learning", "দ্বীনি কিতাব পাঠ ও দ্বীনি আলোচনা", Icons.menu_book_rounded, Colors.teal),
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
                      "সম্পূর্ণ হয়েছে! 🎉",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "আপনার ১০ দিনের পবিত্র ইতিকাফ সফর শেষ হয়েছে।\nআল্লাহ আপনার ইবাদত ও ইতিকাফ কবুল করুন।",
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

  Widget _buildItikafDeedTile(
    SettingsService settings,
    int dayIndex,
    String deedId,
    String title,
    IconData icon,
    Color color,
  ) {
    final completedDeeds = settings.getItikafDeeds(dayIndex);
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
        settings.toggleItikafDeed(dayIndex, deedId);
      },
    );
  }

  void _confirmStopItikaf(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("ইতিকাফ শেষ করবেন?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("ইতিকাফ বন্ধ করলে সমস্ত রেকর্ড মুছে যাবে। আপনি কি নিশ্চিত?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.stopItikaf();
              Navigator.pop(ctx);
            },
            child: const Text("শেষ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDuasTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDuaItem(
          isDark: isDark,
          title: "লাইলাতুল কদরের দোয়া (ক্ষমা চাওয়ার বিশেষ দোয়া)",
          arabic: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
          pronunciation: "আল্লাহুম্মা ইন্নাকা আফুউউন তুহিব্বুল আফওয়া ফাফু আন্নি।",
          translation: "হে আল্লাহ! নিশ্চয়ই আপনি ক্ষমাশীল, আপনি ক্ষমা করতে ভালোবাসেন। অতএব আমাকে ক্ষমা করুন।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "ক্ষমা প্রার্থনা ও তওবার দোয়া (সাইয়্যিদুল ইস্তিগফার)",
          arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
          pronunciation: "আল্লাহুম্মা আন্তা রাব্বি লা ইলাহা ইল্লা আন্তা। খালাকতানি ওয়া আনা আবদুকা, ওয়া আনা আলা আহদিকা ওয়া ওয়া’দিকা মাস্তাতাতু। আউজুবিকা মিন শাররি মা সানাতু, আবূউ লাকা বিনি’মাতিকা আলাইয়্যা, ওয়া আবূউ লাকা বিজাম্বি ফাগফিরলী, ফাইন্নাহু লা ইয়াগফিরুজ জুনূবা ইল্লা আন্তা।",
          translation: "হে আল্লাহ! আপনিই আমার রব। আপনি ছাড়া কোনো ইলাহ নেই। আপনিই আমাকে সৃষ্টি করেছেন এবং আমি আপনার গোলাম। আর আমি আমার সাধ্যমতো আপনার অঙ্গীকার ও প্রতিশ্রুতির ওপর কায়েম আছি। আমি আমার কৃতকর্মের মন্দ পরিণতি থেকে আপনার আশ্রয় চাচ্ছি। আমার ওপর আপনার যে নেয়ামত রয়েছে তা আমি স্বীকার করছি এবং আমার গুনাহও স্বীকার করছি। অতএব আমাকে ক্ষমা করে দিন। কেননা আপনি ছাড়া আর কেউ গুনাহ ক্ষমা করতে পারে না।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "মসজিদে প্রবেশের দোয়া",
          arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
          pronunciation: "আল্লাহুম্মাফ তাহলী আবওয়াবা রাহমাতিক।",
          translation: "হে আল্লাহ! আমার জন্য আপনার রহমতের দরজাসমূহ খুলে দিন।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "মসজিদ থেকে বের হওয়ার দোয়া",
          arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
          pronunciation: "আল্লাহুম্মা ইন্নী নাসআলুকা মিন ফাদলিক।",
          translation: "হে আল্লাহ! আমি আপনার অনুগ্রহ প্রার্থনা করছি।"
        ),
      ],
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

  List<_ItikafRuleSection> _getItikafRules() {
    return [
      _ItikafRuleSection(
        icon: Icons.gavel_rounded,
        title: "ইতিকাফের মৌলিক শর্তাবলী",
        items: [
          "১. নিয়ত করা: আল্লাহর ইবাদত করার জন্য মসজিদে অবস্থানের নিয়ত করা বাধ্যতামূলক।",
          "২. মুসলমান হওয়া: অমুসলিমের ইতিকাফ গ্রহণযোগ্য নয়।",
          "৩. বুদ্ধিমান ও প্রাপ্তবয়স্ক হওয়া: নাবালক বুদ্ধিমান শিশুর ইতিকাফ হতে পারে, তবে পাগল বা অবুঝের হবে না।",
          "৪. পবিত্র থাকা: জানাবাত (অপবিত্রতা), হায়েজ (ঋতুস্রাব) এবং নেফাস (সন্তান প্রসব পরবর্তী রক্তস্রাব) থেকে মুক্ত থাকা আবশ্যক।",
          "৫. উপযুক্ত স্থান: জামে মসজিদ বা পাঞ্জেগানা মসজিদ যেখানে নিয়মিত ৫ ওয়াক্ত নামাজ জামাতে আদায় করা হয়।"
        ],
      ),
      _ItikafRuleSection(
        icon: Icons.dangerous_rounded,
        title: "ইতিকাফ ভঙ্গকারী বিষয়সমূহ",
        items: [
          "১. বিনা প্রয়োজনে মসজিদ থেকে বের হওয়া: শরীয়তসম্মত প্রয়োজন (যেমন- প্রস্রাব-পায়খানা, ওযু বা খাবার আনার লোক না থাকলে আনা) ছাড়া মসজিদ সীমানার বাইরে গেলে ইতিকাফ ভেঙে যাবে।",
          "২. সহবাস বা যৌন মিলন করা: ইতিকাফ অবস্থায় স্বামী-স্ত্রীর দৈহিক সম্পর্ক বা জড়িয়ে পড়া সম্পূর্ণ হারাম এবং এর ফলে ইতিকাফ বাতিল হয়ে যায় (সুরা বাকারা: ১৮৭)।",
          "৩. অজ্ঞান বা পাগল হওয়া: কেউ যদি ইতিকাফের মাঝে পাগল হয়ে যায় বা টানা কয়েক দিন বেহুঁশ হয়ে থাকে তবে ইতিকাফ নষ্ট হয়ে যায়।",
          "৪. হায়েজ বা নেফাস হওয়া: নারীদের ইতিকাফ চলাকালে হায়েজ শুরু হলে ইতিকাফ ভেঙে যাবে এবং মসজিদ ত্যাগ করতে হবে (পরবর্তীতে ১ দিন কাজা করতে হবে)।",
          "৫. ধর্মত্যাগ করা (মুরতাদ হওয়া): আল্লাহ না করুন, কেউ ইসলাম ত্যাগ করলে ইতিকাফ বাতিল হবে।"
        ],
      ),
      _ItikafRuleSection(
        icon: Icons.check_circle_outline_rounded,
        title: "ইতিকাফ অবস্থায় জায়েজ বিষয়সমূহ",
        items: [
          "১. ওযু ও গোসলের জন্য বের হওয়া (যদি মসজিদে ব্যবস্থা না থাকে)।",
          "২. প্রাকৃতিক প্রয়োজনে (প্রস্রাব-পায়খানা) বাইরে যাওয়া।",
          "৩. জামাত না থাকলে জুমার নামাজের জন্য পার্শ্ববর্তী জামে মসজিদে যাওয়া এবং ওয়াজিব নামাজ শেষে ফিরে আসা।",
          "৪. মসজিদে পানাহার করা, ঘুমানো বা জরুরি কেনাবেচা করা (ব্যবসায়িক পণ্য মসজিদে না এনে)।",
          "৫. চুল আঁচড়ানো, সুগন্ধি মাখা বা সাধারণ স্বাস্থ্য পরীক্ষা করা।"
        ],
      ),
      _ItikafRuleSection(
        icon: Icons.star_rounded,
        title: "ইতিকাফের কতিপয় আদব",
        items: [
          "১. বেশি বেশি কুরআন তিলাওয়াত, নফল নামাজ, জিকির ও দোয়ায় মশগুল থাকা।",
          "২. ফালতু বা অনর্থক কথাবার্তা এড়িয়ে চলা। তবে প্রয়োজনীয় দুনিয়াবী বা দ্বীনি কথা বলা জায়েজ।",
          "৩. শেষ ১০ রাতে শবে কদর পাওয়ার আশায় বিনিদ্র ইবাদত করা।",
          "৪. সম্পূর্ণ নীরব থাকাকে ইবাদত মনে না করা (ইসলামে মৌনব্রত রাখার ইতিকাফ অপছন্দনীয়)।"
        ],
      ),
    ];
  }
}

class _ItikafRuleSection {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ItikafRuleSection({
    required this.icon,
    required this.title,
    required this.items,
  });
}
