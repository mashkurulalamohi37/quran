import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:quran/pages/ayalistbysura.dart';
import 'package:quran/pages/prayer_times.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/services/sound_service.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/theme/app_theme.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:quran/pages/hijri_calendar_screen.dart';
import 'package:quran/services/widget_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  HomeDashboardState createState() => HomeDashboardState();
}

class HomeDashboardState extends State<HomeDashboard> {
  final formKey = GlobalKey<FormState>();
  final usrName = TextEditingController();
  final usrEmail = TextEditingController();
  final usrComments = TextEditingController();
  String? name, email, comments;

  final InAppReview _inAppReview = InAppReview.instance;

  int _ringerMode = 2; // 0 = Silent, 1 = Vibrate, 2 = Normal

  @override
  void initState() {
    super.initState();
    _initRingerMode();
    WidgetService.updateWidget();
  }

  Future<void> _initRingerMode() async {
    final mode = await SoundService.getRingerMode();
    if (mounted) {
      setState(() {
        _ringerMode = mode;
      });
    }
  }

  Future<void> _toggleManualMute() async {
    final hasDnd = await SoundService.checkDndPermission();
    if (!hasDnd) {
      _showDndPrompt();
      return;
    }
    if (_ringerMode == 2) {
      await SoundService.setRingerMode(0); // silent
    } else {
      await SoundService.setRingerMode(2); // normal
    }
    _initRingerMode();
  }

  void _showDndPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("অনুমতি প্রয়োজন 📳", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("সাইলেন্ট মোড পরিবর্তন করতে ‘Do Not Disturb’ (DND) এক্সেস প্রয়োজন। সেটিংস থেকে অনুমতি দিন।", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () {
              Navigator.pop(ctx);
              SoundService.openDndSettings();
            },
            child: const Text("অনুমতি দিন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usrName.dispose();
    usrEmail.dispose();
    usrComments.dispose();
    super.dispose();
  }

  Future<void> _review() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        final url = Uri.parse("https://play.google.com/store/apps/details?id=com.banglaquran.quran");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      final url = Uri.parse("https://play.google.com/store/apps/details?id=com.banglaquran.quran");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: AppColors.emerald,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    const pattern = r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleReset();
      _showToast("Thank you for your valuable feedback! 🌟");
    }
  }

  void _handleReset() {
    Navigator.of(context).pop();
    usrName.clear();
    usrEmail.clear();
    usrComments.clear();
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Feedback', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usrName,
                  decoration: _inputDecoration("Your name", Icons.person),
                  validator: (v) => (v == null || v.isEmpty) ? "Name is required" : null,
                  onSaved: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usrEmail,
                  decoration: _inputDecoration("Email address", Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  onSaved: (v) => email = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usrComments,
                  decoration: _inputDecoration("Your comments", Icons.comment),
                  minLines: 2,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  onChanged: (v) => comments = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _handleReset,
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: _handleSubmit,
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.emerald),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald, width: 2),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined, color: AppColors.emerald),
              const SizedBox(width: 8),
              Text(
                "প্রাইভেসি পলিসি",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _policySection("১. কোনো ব্যক্তিগত তথ্য সংগ্রহ করা হয় না", "আমাদের অ্যাপটি ব্যবহারকারীদের কোনো ব্যক্তিগত নাম, ইমেল, ফোন নম্বর বা তথ্য সার্ভারে সংগ্রহ বা সংরক্ষণ করে না।"),
                const SizedBox(height: 10),
                _policySection("২. লোকেশন পারমিশন", "নামাজের সঠিক সময় ও কিবলার দিক নির্ধারণের জন্য জিপিএস লোকেশন পারমিশন ব্যবহার করা হয়। এই লোকেশন ডেটা সম্পূর্ণ অফলাইনে প্রসেস হয় এবং কোনো সার্ভারে পাঠানো হয় না।"),
                const SizedBox(height: 10),
                _policySection("৩. কোনো বিজ্ঞাপন বা ট্র্যাকার নেই", "অ্যাপটি সম্পূর্ণ বিজ্ঞাপন-মুক্ত। এতে কোনো থার্ড-পার্টি ট্র্যাকিং বা অ্যানালিটিক্স কোড নেই।"),
                const SizedBox(height: 10),
                _policySection("৪. ডাটা স্টোরেজ", "আপনার বুকমার্ক, পড়ার পরিসংখ্যান এবং সেটিংস আপনার নিজের ডিভাইসের লোকাল স্টোরেজে সংরক্ষিত থাকে।"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "ঠিক আছে",
                style: GoogleFonts.poppins(color: AppColors.emerald, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _policySection(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.emerald),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: GoogleFonts.poppins(fontSize: 11.5, height: 1.5),
        ),
      ],
    );
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final bookmarks = context.watch<BookmarkService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D2B12), const Color(0xFF0D1117), const Color(0xFF1A1A0A)]
                : [const Color(0xFF1B5E20), const Color(0xFF2E7D32), const Color(0xFF1A4A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.wb_sunny_outlined, color: Colors.transparent), // spacer
                    Text(
                      "বাংলা কুরআন",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      color: isDark ? AppColors.cardDark : AppColors.emeraldDark,
                      onSelected: (v) {
                        if (v == 'feedback') _showFeedbackDialog();
                        if (v == 'privacy') _showPrivacyPolicy();
                        if (v == 'rate') _review();
                      },
                      itemBuilder: (_) => [
                        _menuItem('privacy', Icons.privacy_tip_outlined, 'Privacy Policy'),
                        _menuItem('feedback', Icons.feedback_outlined, 'Feedback'),
                        _menuItem('rate', Icons.star_outline, 'Rate App'),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Bismillah header ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                  style: const TextStyle(
                    fontFamily: 'Lateef',
                    fontSize: 26,
                    color: AppColors.goldLight,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Subtitle ──
              Text(
                "পড়ুন, শিখুন, আমল করুন",
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),

              // ── Main content card ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDark : AppColors.bgLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Continue Reading card
                        if (settings.hasLastRead) ...[
                          _ContinueReadingCard(
                            settings: settings,
                            onTap: () {
                              final suraInfo = {
                                'id': settings.lastReadSurahId,
                                'number': settings.lastReadSurahId.toString(),
                                'bangla_name': settings.lastReadSurahBangla,
                                'name': settings.lastReadSurahName,
                                'transliteration_en': '',
                                'total_verses': 0,
                                'total_verses_b': '',
                                'revelation_type': 'Meccan',
                              };
                              _navigate(AyaListBySura(
                                suraInfo,
                                initialAyah: settings.lastReadAyahIndex,
                              ));
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Quick statistics summary card
                        _QuickStatsCard(settings: settings, isDark: isDark),
                        const SizedBox(height: 16),

                        // Hijri / Islamic Calendar Card
                        _HijriDateCard(isDark: isDark),
                        const SizedBox(height: 16),

                        // Home Prayer Times Card
                        _HomePrayerTimesCard(settings: settings, isDark: isDark),
                        const SizedBox(height: 16),

                        // Silent Mode Card
                        _SoundControlCard(
                          settings: settings,
                          isDark: isDark,
                          ringerMode: _ringerMode,
                          onTapToggle: _toggleManualMute,
                        ),
                        const SizedBox(height: 20),

                        // Daily Ayah card
                        _DailyAyahCard(isDark: isDark),
                        const SizedBox(height: 20),

                        // Recent Bookmarks horizontal slider (if any)
                        if (bookmarks.count > 0) ...[
                          Text(
                            "সাম্প্রতিক বুকমার্ক",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bookmarks.count,
                              itemBuilder: (ctx, i) {
                                final bm = bookmarks.bookmarks[i];
                                return GestureDetector(
                                  onTap: () {
                                    _navigate(AyaListBySura(
                                      {
                                        'id': bm.surahId,
                                        'number': bm.surahId.toString(),
                                        'bangla_name': bm.surahBangla,
                                        'name': bm.surahName,
                                        'transliteration_en': '',
                                        'total_verses': 0,
                                        'total_verses_b': '',
                                        'revelation_type': 'Meccan',
                                      },
                                      initialAyah: bm.ayahIndex,
                                    ));
                                  },
                                  child: Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "সূরা ${bm.surahBangla}",
                                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "আয়াত ${bm.ayahIndex}",
                                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          bm.bnText,
                                          style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Version info
                        Center(
                          child: Text(
                            "বাংলা কুরআন • v1.0.7",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final SettingsService settings;
  final VoidCallback onTap;
  const _ContinueReadingCard({required this.settings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF9A825).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "শেষ পড়া",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "সূরা ${settings.lastReadSurahBangla}",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "আয়াত ${settings.lastReadAyahIndex}",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  final SettingsService settings;
  final bool isDark;
  const _QuickStatsCard({required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatIndicator(
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
            value: "${settings.streak} দিন",
            label: "ধারাবাহিকতা",
          ),
          Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
          _StatIndicator(
            icon: Icons.menu_book_rounded,
            color: AppColors.emerald,
            value: "${settings.surahsStartedCount} টি",
            label: "শুরু করা সূরা",
          ),
          Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
          _StatIndicator(
            icon: Icons.check_circle_outline_rounded,
            color: Colors.blue,
            value: "${settings.totalAyahsRead} টি",
            label: "পঠিত আয়াত",
          ),
        ],
      ),
    );
  }
}

class _StatIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatIndicator({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


class _DailyAyahCard extends StatelessWidget {
  final bool isDark;
  const _DailyAyahCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emeraldLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "আজকের আয়াত",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
            style: TextStyle(
              fontFamily: 'Lateef',
              fontSize: 28,
              color: Color(0xFF1B5E20),
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "নিশ্চয়ই কষ্টের সাথে স্বস্তি আছে। � সূরা আশ-শারহ: ৬",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// -- Hijri Date Card --

class _HijriDateCard extends StatelessWidget {
  final bool isDark;
  const _HijriDateCard({required this.isDark});



  static const List<String> _hijriMonthsBengali = [
    'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
    'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শাবান',
    'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ',
  ];

  static const List<String> _daysBengali = [
    'রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার',
    'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার',
  ];

  static const List<String> _gregMonthsBengali = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট',
    'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);

    final hDay   = hijri.hDay;
    final hMonth = hijri.hMonth;
    final hYear  = hijri.hYear;
    final monthBn = _hijriMonthsBengali[hMonth - 1];

    final dayBn  = _daysBengali[now.weekday % 7];
    final gregMon = _gregMonthsBengali[now.month - 1];

    final isSpecial = hMonth == 9;   // Ramadan

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF16321B), const Color(0xFF0C1D0F)]
                : [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left rounded icon box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSpecial ? AppColors.gold.withValues(alpha: 0.25) : Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mosque_rounded,
                  color: isSpecial ? AppColors.goldLight : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Middle date details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${_toBengaliNum(hDay)} $monthBn ${_toBengaliNum(hYear)} হিজরি",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSpecial) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 0.5),
                            ),
                            child: Text(
                              "রমজান",
                              style: GoogleFonts.poppins(
                                color: AppColors.goldLight,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$dayBn, ${_toBengaliNum(now.day)} $gregMon ${_toBengaliNum(now.year)} খ্রি.",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Right arrow icon
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Sound Control Card --

class _SoundControlCard extends StatelessWidget {
  final SettingsService settings;
  final bool isDark;
  final int ringerMode;
  final VoidCallback onTapToggle;

  const _SoundControlCard({
    required this.settings,
    required this.isDark,
    required this.ringerMode,
    required this.onTapToggle,
  });

  @override
  Widget build(BuildContext context) {
    String titleText = "স্বয়ংক্রিয় সাইলেন্ট";
    String subtitleText = "সেটিংস থেকে চালু করুন";
    IconData leadingIcon = Icons.notifications_active_rounded;
    Color iconColor = AppColors.emerald;

    if (settings.silentModeType == 'manual') {
      titleText = "ম্যানুয়াল সাইলেন্ট";
      subtitleText = ringerMode == 0
          ? "ফোন সাইলেন্ট আছে (রিংগার অন করতে চাপুন)"
          : "রিংগার চালু আছে (সাইলেন্ট করতে চাপুন)";
      leadingIcon = ringerMode == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded;
      iconColor = ringerMode == 0 ? Colors.redAccent : AppColors.emerald;
    } else if (settings.silentModeType == 'time') {
      titleText = "নামাজের সময় সাইলেন্ট";
      subtitleText = "নামাজের ওয়াক্তে স্বয়ংক্রিয় সাইলেন্ট হবে";
      leadingIcon = Icons.timer_rounded;
      iconColor = AppColors.gold;
    } else if (settings.silentModeType == 'gps') {
      titleText = "মসজিদে স্বয়ংক্রিয় সাইলেন্ট";
      subtitleText = "মসজিদ সীমানায় ঢুকলে সাইলেন্ট হবে";
      leadingIcon = Icons.gps_fixed_rounded;
      iconColor = Colors.blueAccent;
    }

    final isClickable = settings.silentModeType == 'manual';

    return GestureDetector(
      onTap: isClickable ? onTapToggle : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: isClickable
              ? Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(leadingIcon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(
                Icons.swap_horiz_rounded,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// -- Home Prayer Times Card --

class _WaqtPhase {
  final String activeLabel;
  final String activeTimeStr;
  final String nextLabel;
  final String nextTimeStr;
  final DateTime startTime;
  final DateTime endTime;

  _WaqtPhase({
    required this.activeLabel,
    required this.activeTimeStr,
    required this.nextLabel,
    required this.nextTimeStr,
    required this.startTime,
    required this.endTime,
  });
}

class _HomePrayerTimesCard extends StatelessWidget {
  final SettingsService settings;
  final bool isDark;

  const _HomePrayerTimesCard({required this.settings, required this.isDark});

  DailyPrayers _calculateTodayPrayers() {
    double lat = 23.8103;
    double lng = 90.4125;
    if (settings.isAutomaticLocation) {
      if (settings.cachedLatitude != null && settings.cachedLongitude != null) {
        lat = settings.cachedLatitude!;
        lng = settings.cachedLongitude!;
      } else {
        final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
        lat = dist.latitude;
        lng = dist.longitude;
      }
    } else {
      final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
      lat = dist.latitude;
      lng = dist.longitude;
    }
    return PrayerService.calculate(
      lat: lat,
      lng: lng,
      method: settings.calculationMethod,
      madhab: settings.madhab,
    );
  }

  String _toBn(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(english[i], bengali[i]);
    }
    return input;
  }

  String _fmtTimeBn(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return _toBn("$h:$m");
  }

  String _getActivePrayerId(DailyPrayers p, DateTime now) {
    if (now.isBefore(p.fajr.time)) return "isha";
    if (now.isBefore(p.dhuhr.time)) return "fajr";
    if (now.isBefore(p.asr.time)) return "dhuhr";
    if (now.isBefore(p.maghrib.time)) return "asr";
    if (now.isBefore(p.isha.time)) return "maghrib";
    return "isha";
  }

  Widget _buildPrayerTimeColumn(String label, String timeStr, bool isActive, bool isDark) {
    final activeColor = AppColors.emerald;
    final inactiveTxt = isDark ? Colors.white70 : Colors.black87;
    final inactiveSub = isDark ? Colors.white38 : Colors.black38;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.emerald.withValues(alpha: isDark ? 0.15 : 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 1) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? activeColor : inactiveTxt,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            timeStr,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.bold,
              color: isActive ? activeColor : inactiveSub,
            ),
          ),
        ],
      ),
    );
  }

  _WaqtPhase _getWaqtPhase(DailyPrayers p, DateTime now) {
    final todayMidnight = DateTime(now.year, now.month, now.day, 0, 0);
    final tomorrowMidnight = todayMidnight.add(const Duration(days: 1));

    // Tahajjud end is 15 minutes before Fajr start
    final tahajjudEnd = p.fajr.time.subtract(const Duration(minutes: 15));

    // 1. Tahajjud (Midnight to Tahajjud End)
    if (now.isAfter(todayMidnight) && now.isBefore(tahajjudEnd)) {
      return _WaqtPhase(
        activeLabel: "তাহাজ্জুদ শেষ",
        activeTimeStr: _fmtTimeBn(tahajjudEnd),
        nextLabel: "ফজর",
        nextTimeStr: _fmtTimeBn(p.fajr.time),
        startTime: todayMidnight,
        endTime: tahajjudEnd,
      );
    }
    // 2. Fajr (Tahajjud End to Sunrise)
    if (now.isAfter(tahajjudEnd) && now.isBefore(p.sunrise.time)) {
      return _WaqtPhase(
        activeLabel: "ফজর শেষ",
        activeTimeStr: _fmtTimeBn(p.sunrise.time),
        nextLabel: "যোহর",
        nextTimeStr: _fmtTimeBn(p.dhuhr.time),
        startTime: p.fajr.time,
        endTime: p.sunrise.time,
      );
    }
    // 3. Ishraq (Sunrise to Dhuhr)
    if (now.isAfter(p.sunrise.time) && now.isBefore(p.dhuhr.time)) {
      return _WaqtPhase(
        activeLabel: "ইশরাক শেষ",
        activeTimeStr: _fmtTimeBn(p.dhuhr.time),
        nextLabel: "যোহর",
        nextTimeStr: _fmtTimeBn(p.dhuhr.time),
        startTime: p.sunrise.time,
        endTime: p.dhuhr.time,
      );
    }
    // 4. Dhuhr (Dhuhr to Asr)
    if (now.isAfter(p.dhuhr.time) && now.isBefore(p.asr.time)) {
      return _WaqtPhase(
        activeLabel: "যোহর শেষ",
        activeTimeStr: _fmtTimeBn(p.asr.time),
        nextLabel: "আসর",
        nextTimeStr: _fmtTimeBn(p.asr.time),
        startTime: p.dhuhr.time,
        endTime: p.asr.time,
      );
    }
    // 5. Asr (Asr to Maghrib)
    if (now.isAfter(p.asr.time) && now.isBefore(p.maghrib.time)) {
      return _WaqtPhase(
        activeLabel: "আসর শেষ",
        activeTimeStr: _fmtTimeBn(p.maghrib.time),
        nextLabel: "মাগরিব",
        nextTimeStr: _fmtTimeBn(p.maghrib.time),
        startTime: p.asr.time,
        endTime: p.maghrib.time,
      );
    }
    // 6. Maghrib (Maghrib to Isha)
    if (now.isAfter(p.maghrib.time) && now.isBefore(p.isha.time)) {
      return _WaqtPhase(
        activeLabel: "মাগরিব শেষ",
        activeTimeStr: _fmtTimeBn(p.isha.time),
        nextLabel: "এশা",
        nextTimeStr: _fmtTimeBn(p.isha.time),
        startTime: p.maghrib.time,
        endTime: p.isha.time,
      );
    }
    // 7. Isha (Isha to Midnight)
    return _WaqtPhase(
      activeLabel: "এশা শেষ",
      activeTimeStr: _fmtTimeBn(tomorrowMidnight),
      nextLabel: "তাহাজ্জুদ",
      nextTimeStr: _fmtTimeBn(tomorrowMidnight),
      startTime: p.isha.time,
      endTime: tomorrowMidnight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayers = _calculateTodayPrayers();
    final now = DateTime.now();
    final phase = _getWaqtPhase(prayers, now);

    // Calculate progress
    final totalSecs = phase.endTime.difference(phase.startTime).inSeconds;
    final elapsedSecs = now.difference(phase.startTime).inSeconds;
    double progress = totalSecs > 0 ? (elapsedSecs / totalSecs).clamp(0.0, 1.0) : 0.0;

    // Remaining duration
    final remaining = phase.endTime.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    String remainingStr = "";
    if (hours > 0) {
      remainingStr += _toBn("$hours") + " ঘণ্টা ";
    }
    remainingStr += _toBn("$minutes") + " মিনিট বাকি";

    // Check if it's day or night for icon
    final isDayTime = now.isAfter(prayers.sunrise.time) && now.isBefore(prayers.maghrib.time);
    final statusIcon = isDayTime ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    final statusIconColor = isDayTime ? Colors.orangeAccent : Colors.amber;

    final txtColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Top-right subtle glow decoration
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emerald.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Location & Live Clock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.emerald),
                            const SizedBox(width: 4),
                            Text(
                              _toBn(settings.selectedDistrict),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusIconColor),
                              const SizedBox(width: 4),
                              Text(
                                _fmtTimeBn(now),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: txtColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Row 2: Next Prayer grand layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "পরবর্তী ওয়াক্ত",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phase.nextLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.emerald,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "শুরু হবে",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${phase.nextTimeStr} মিনিটে",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: txtColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row 4: Status (Ongoing Waqt & Countdown)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "চলমান: ${phase.activeLabel.split(' ')[0]}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: txtColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            remainingStr,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),

                    // Row 4.5: Other Daily Prayer Times
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPrayerTimeColumn("ফজর", _fmtTimeBn(prayers.fajr.time), _getActivePrayerId(prayers, now) == "fajr", isDark),
                        _buildPrayerTimeColumn("যোহর", _fmtTimeBn(prayers.dhuhr.time), _getActivePrayerId(prayers, now) == "dhuhr", isDark),
                        _buildPrayerTimeColumn("আসর", _fmtTimeBn(prayers.asr.time), _getActivePrayerId(prayers, now) == "asr", isDark),
                        _buildPrayerTimeColumn("মাগরিব", _fmtTimeBn(prayers.maghrib.time), _getActivePrayerId(prayers, now) == "maghrib", isDark),
                        _buildPrayerTimeColumn("এশা", _fmtTimeBn(prayers.isha.time), _getActivePrayerId(prayers, now) == "isha", isDark),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),

                    // Row 5: Sunrise & Sunset times in footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_twilight_rounded, size: 14, color: Colors.orangeAccent),
                            const SizedBox(width: 4),
                            Text(
                              "সূর্যোদয়: ${_fmtTimeBn(prayers.sunrise.time)}",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              "সূর্যাস্ত: ${_fmtTimeBn(prayers.maghrib.time)}",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
