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

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}";
  }

  PrayerInfo? _currentWaqt(DailyPrayers p) {
    final now = DateTime.now();
    if (now.isAfter(p.isha.time) || now.isBefore(p.fajr.time)) return p.isha;
    if (now.isAfter(p.fajr.time) && now.isBefore(p.sunrise.time)) return p.fajr;
    if (now.isAfter(p.dhuhr.time) && now.isBefore(p.asr.time)) return p.dhuhr;
    if (now.isAfter(p.asr.time) && now.isBefore(p.maghrib.time)) return p.asr;
    if (now.isAfter(p.maghrib.time) && now.isBefore(p.isha.time)) return p.maghrib;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final prayers = _calculateTodayPrayers();
    final active = _currentWaqt(prayers);
    final loc = settings.isAutomaticLocation
        ? (settings.cachedLatitude != null
            ? 'আমার অবস্থান (GPS)'
            : '${settings.selectedDistrict} (GPS খুঁজছে...)')
        : settings.selectedDistrict;
    final txtColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.access_time_filled_rounded,
                        color: AppColors.emerald, size: 20),
                    const SizedBox(width: 8),
                    Text("আজকের সালাত সময়সূচি",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: txtColor)),
                  ]),
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.emerald),
                    const SizedBox(width: 2),
                    Text(loc,
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              _pRow("ফজর (Fajr)", prayers.fajr.time, prayers.sunrise.time, active == prayers.fajr),
              const Divider(height: 10),
              _pRow("যোহর (Dhuhr)", prayers.dhuhr.time, prayers.asr.time, active == prayers.dhuhr),
              const Divider(height: 10),
              _pRow("আসর (Asr)", prayers.asr.time, prayers.maghrib.time, active == prayers.asr),
              const Divider(height: 10),
              _pRow("মাগরিব (Maghrib)", prayers.maghrib.time, prayers.isha.time, active == prayers.maghrib),
              const Divider(height: 10),
              _pRow("এশা (Isha)", prayers.isha.time,
                  prayers.fajr.time.add(const Duration(days: 1)), active == prayers.isha),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pRow(String name, DateTime start, DateTime end, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.emerald.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppColors.emerald.withValues(alpha: 0.25), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.circle_rounded, color: AppColors.emerald, size: 8),
                  ),
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppColors.emerald
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "শুরু: ${_fmt(start)}  •  শেষ: ${_fmt(end)}",
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? AppColors.emerald
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
