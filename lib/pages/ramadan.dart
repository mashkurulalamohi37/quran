import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _countdownTimer;
  DateTime? _sehriTime;
  DateTime? _iftarTime;
  String _countdownLabel = "";
  String _countdownValue = "";
  bool _isLoadingTimes = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateFastingTimes();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _calculateFastingTimes() async {
    final settings = context.read<SettingsService>();
    double lat = 23.8103;
    double lng = 90.4125;

    try {
      if (settings.isAutomaticLocation) {
        if (settings.cachedLatitude != null && settings.cachedLongitude != null) {
          lat = settings.cachedLatitude!;
          lng = settings.cachedLongitude!;
          
          final prayers = PrayerService.calculate(
            lat: lat,
            lng: lng,
            method: settings.calculationMethod,
            madhab: settings.madhab,
          );

          if (mounted) {
            setState(() {
              _sehriTime = prayers.fajr.time;
              _iftarTime = prayers.maghrib.time;
              _isLoadingTimes = false;
            });
            _updateCountdown();
          }
          _fetchFreshFastingLocation(settings);
        } else {
          final pos = await PrayerService.getPosition();
          if (pos != null) {
            lat = pos.latitude;
            lng = pos.longitude;
            settings.updateCachedLocation(lat, lng);
          } else {
            final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
            lat = dist.latitude;
            lng = dist.longitude;
          }
          final prayers = PrayerService.calculate(
            lat: lat,
            lng: lng,
            method: settings.calculationMethod,
            madhab: settings.madhab,
          );

          if (mounted) {
            setState(() {
              _sehriTime = prayers.fajr.time;
              _iftarTime = prayers.maghrib.time;
              _isLoadingTimes = false;
            });
            _updateCountdown();
          }
        }
      } else {
        final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
        lat = dist.latitude;
        lng = dist.longitude;
        final prayers = PrayerService.calculate(
          lat: lat,
          lng: lng,
          method: settings.calculationMethod,
          madhab: settings.madhab,
        );

        if (mounted) {
          setState(() {
            _sehriTime = prayers.fajr.time;
            _iftarTime = prayers.maghrib.time;
            _isLoadingTimes = false;
          });
          _updateCountdown();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTimes = false;
        });
      }
    }
  }

  Future<void> _fetchFreshFastingLocation(SettingsService settings) async {
    final pos = await PrayerService.getPosition();
    if (pos != null && mounted) {
      final oldLat = settings.cachedLatitude;
      final oldLng = settings.cachedLongitude;
      if (oldLat == null || oldLng == null || 
          (pos.latitude - oldLat).abs() > 0.001 || 
          (pos.longitude - oldLng).abs() > 0.001) {
        
        await settings.updateCachedLocation(pos.latitude, pos.longitude);
        final prayers = PrayerService.calculate(
          lat: pos.latitude,
          lng: pos.longitude,
          method: settings.calculationMethod,
          madhab: settings.madhab,
        );
        if (mounted) {
          setState(() {
            _sehriTime = prayers.fajr.time;
            _iftarTime = prayers.maghrib.time;
          });
          _updateCountdown();
        }
      }
    }
  }

  void _updateCountdown() {
    if (_sehriTime == null || _iftarTime == null) return;

    final now = DateTime.now();
    Duration diff;

    if (now.isBefore(_sehriTime!)) {
      _countdownLabel = "সেহরির সময় শেষ হতে বাকি";
      diff = _sehriTime!.difference(now);
    } else if (now.isAfter(_sehriTime!) && now.isBefore(_iftarTime!)) {
      _countdownLabel = "ইফতারের সময় হতে বাকি";
      diff = _iftarTime!.difference(now);
    } else {
      _countdownLabel = "আগামীকালের সেহরির সময় বাকি";
      // Approximate tomorrow's Sehri as today's + 24 hours
      final tomorrowSehri = _sehriTime!.add(const Duration(days: 1));
      diff = tomorrowSehri.difference(now);
    }

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (mounted) {
      setState(() {
        _countdownValue = "$hours:$minutes:$seconds";
      });
    }
  }

  void _copyToClipboard(String arabic, String pronunciation, String translation, String title) {
    final text = "$title:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation\n\nঅনুবাদ: $translation";
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "দোয়াটি কপি করা হয়েছে! 📋",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.emerald,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  String _formatTimeString(DateTime? dateTime) {
    if (dateTime == null) return "--:--";
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("রমজান ও রোজা গাইড"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "আজকের রোজা"),
            Tab(text: "রমজান ডায়েরি"),
            Tab(text: "নফল রোজা"),
            Tab(text: "দোয়া ও আমল"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(context, settings, isDark),
          _buildDiaryTab(context, settings, isDark),
          _buildNafalTab(context, settings, isDark),
          _buildDuasTab(context, settings, isDark),
        ],
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context, SettingsService settings, bool isDark) {
    if (_isLoadingTimes) {
      return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Countdown card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF311B92), Color(0xFF512DA8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF311B92).withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.nightlight_round, color: AppColors.goldLight, size: 40),
                const SizedBox(height: 12),
                Text(
                  _countdownLabel,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _countdownValue.isNotEmpty ? _countdownValue : "--:--:--",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sehri & Iftar Timings Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.wb_twilight_rounded, color: Colors.orangeAccent, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          "সেহরির শেষ সময়",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeString(_sehriTime),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emeraldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 50, color: isDark ? Colors.white10 : Colors.black12),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: AppColors.gold, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          "ইফতারের সময়",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeString(_iftarTime),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Basic Fasting Duas
          _buildDuaItem(
            isDark: isDark,
            title: "সেহরির নিয়ত (রোজা রাখার নিয়ত)",
            arabic: "نَوَيْتُ أَنْ أَصُومَ غَدًا مِنْ شَهْرِ رَمَضَانَ الْمُبَارَكِ فَرْضًا لَكَ يَا اللَّهُ فَتَقَبَّلْ مِنِّي إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ",
            pronunciation: "নাওয়াইতু আন আসূমা গাদান মিন শাহরি রামাদ্বানাল মুবারাকি ফারদাল্লাকা ইয়া আল্লাহু ফাতাক্বাব্বাল মিন্নী ইন্নাকা আনতাস সামীউল আলীম।",
            translation: "হে আল্লাহ! আপনার সন্তুষ্টির জন্য আগামীকালের পবিত্র রমজান মাসের ফরজ রোজা রাখার নিয়ত করছি; আপনি আমার পক্ষ থেকে তা কবুল করুন, নিশ্চয়ই আপনি সর্বশ্রোতা ও সর্বজ্ঞ।"
          ),
          _buildDuaItem(
            isDark: isDark,
            title: "ইফতারের দোয়া",
            arabic: "اللَّهُمَّ لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ",
            pronunciation: "আল্লাহুম্মা লাকা সুমতু ওয়া আলা রিজকিকা আফতারতু।",
            translation: "হে আল্লাহ! আমি আপনার উদ্দেশ্যেই রোজা রেখেছি এবং আপনার দেওয়া রিজিক দিয়েই ইফতার করছি।"
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryTab(BuildContext context, SettingsService settings, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "৩০ দিনের রমজান আমল ট্র্যাকার",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.red),
                label: const Text("রিসেট", style: TextStyle(color: Colors.red, fontSize: 12)),
                onPressed: () => _confirmResetTracker(context, settings),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final dayIndex = index + 1;
              final completedDeeds = settings.getRamadanDeeds(dayIndex);
              final progress = completedDeeds.length / 6.0;

              return GestureDetector(
                onTap: () => _showDeedsBottomSheet(context, settings, dayIndex),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: progress == 1.0
                          ? AppColors.emerald.withValues(alpha: 0.5)
                          : (isDark ? Colors.white10 : Colors.black12),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "রমজান $dayIndex",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: progress == 1.0 ? AppColors.emeraldLight : null,
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              color: progress == 1.0 ? AppColors.emerald : AppColors.gold,
                              strokeWidth: 4,
                            ),
                            Text(
                              "${completedDeeds.length}/6",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          progress == 1.0 ? "সম্পূর্ণ" : "${(progress * 100).round()}%",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: progress == 1.0 ? AppColors.emerald : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeedsBottomSheet(BuildContext context, SettingsService settings, int dayIndex) {
    final deeds = [
      _DeedItem(id: "fast", title: "রোজা রাখা", icon: Icons.nightlight_round, color: AppColors.gold),
      _DeedItem(id: "prayers", title: "৫ ওয়াক্ত নামাজ", icon: Icons.check_circle_outline_rounded, color: Colors.blue),
      _DeedItem(id: "taraweeh", title: "তারাবিহ নামাজ", icon: Icons.stars_rounded, color: Colors.purple),
      _DeedItem(id: "quran", title: "কুরআন তিলাওয়াত", icon: Icons.auto_stories_rounded, color: AppColors.emerald),
      _DeedItem(id: "charity", title: "দান বা সাদাকাহ", icon: Icons.favorite_rounded, color: Colors.red),
      _DeedItem(id: "dhikr", title: "জিকির ও দোয়া", icon: Icons.fingerprint_rounded, color: Colors.orange),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final completedDeeds = settings.getRamadanDeeds(dayIndex);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$dayIndex তম রমজানের আমল তালিকা",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...deeds.map((deed) {
                    final isDone = completedDeeds.contains(deed.id);
                    return CheckboxListTile(
                      activeColor: AppColors.emerald,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: deed.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(deed.icon, color: deed.color, size: 20),
                      ),
                      title: Text(
                        deed.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: isDone,
                      onChanged: (v) {
                        settings.toggleRamadanDeed(dayIndex, deed.id);
                        setModalState(() {});
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmResetTracker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("সব রেকর্ড মুছে ফেলবেন?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("রমজান ডায়েরির ৩০ দিনের পঠিত সব রেকর্ড মুছে যাবে। আপনি কি নিশ্চিত?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.resetRamadanTracker();
              Navigator.pop(ctx);
            },
            child: const Text("রিসেট করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDuasTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDuaItem(
          isDark: isDark,
          title: "তারাবিহ নামাজের চার রাকাত পর পর তাসবিহ",
          arabic: "سُبْحَانَ ذِي الْمُلْكِ وَالْمَلَكُوتِ، سُبْحَانَ ذِي الْعِزَّةِ وَالْعَظَمَةِ وَالْهَيْبَةِ وَالْقُدْرَةِ وَالْكِبْرِيَاءِ وَالْجَبَرُوتِ، سُبْحَانَ الْمَلِكِ الْحَيِّ الَّذِي لَا يَنَامُ وَلَا يَمُوتُ، سُبُّوحٌ قُدُّوسٌ رَبُّنَا وَرَبُّ الْمَلَائِكَةِ وَالرُّوحِ",
          pronunciation: "সুবহানা জিল মুলকি ওয়াল মালাকূতি, সুবহানা জিল ইজ্জাতি ওয়াল আজামাতি ওয়াল হাইবাতি ওয়াল কুদরাতি ওয়াল কিবরিয়ায়ি ওয়াল জাবারূতি, সুবহানাল মালিকিল হাইয়্যিল্লাজি লা ইয়ানামু ওয়ালা ইয়ামূতু, সুব্বূহুন কুদ্দূসুন রাব্বুনা ওয়ারাব্বুল মালায়িকাতি ওয়ার রূহ।",
          translation: "পবিত্র সেই আল্লাহ, যিনি জমিন ও আসমানের রাজত্বের মালিক। পবিত্র সেই আল্লাহ, যিনি সম্মান, মর্যাদা, ভয়, ক্ষমতা, গৌরব ও প্রতাপের অধিকারী। পবিত্র সেই আল্লাহ, যিনি চিরঞ্জীব রাজাধিরাজ, যিনি কখনো ঘুমান না এবং মৃত্যুবরণ করবেন না। আমাদের রব অত্যন্ত পবিত্র এবং মহিমান্বিত, যিনি ফেরেশতাকুল ও জিবরাইল (আ.)-এর রব।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "তারাবিহ নামাজ শেষে মোনাজাত",
          arabic: "اللَّهُمَّ إِنَّا نَسْأَلُكَ الْجَنَّةَ وَنَعُوذُ بِكَ مِنَ النَّارِ، يَا خَالِقَ الْجَنَّةِ وَالنَّارِ، بِرَحْمَتِكَ يَا عَزِيزُ يَا غَفَّارُ، يَا كَرِيمُ يَا سَتَّارُ، يَا رَحِيمُ يَا رَحْمَنُ",
          pronunciation: "আল্লাহুম্মা ইন্না নাসআলুকাল জান্নাতা ওয়া নাউযুবিকা মিনান নার, ইয়া খালিকাল জান্নাত ওয়ান নার, বিরাহমাতিকা ইয়া আযীযু ইয়া গাফফার, ইয়া কারীমু ইয়া সাত্তার, ইয়া রাহীমু ইয়া রাহমান।",
          translation: "হে আল্লাহ! আমরা আপনার নিকট জান্নাত প্রার্থনা করছি এবং জাহান্নাম থেকে মুক্তি চাচ্ছি। হে জান্নাত ও জাহান্নামের স্রষ্টা! আপনার রহমতের মাধ্যমে মুক্তি দান করুন, হে পরাক্রমশালী ও ক্ষমাশীল। হে দয়ালু ও গোপনকারী, হে পরম করুণাময় ও দয়াময় আল্লাহ।"
        ),
        _buildDuaItem(
          isDark: isDark,
          title: "লাইলাতুল কদরের দোয়া (ক্ষমা চাওয়ার দোয়া)",
          arabic: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
          pronunciation: "আল্লাহুম্মা ইন্নাকা আফুউউন তুহিব্বুল আফওয়া ফাফু আন্নি।",
          translation: "হে আল্লাহ! নিশ্চয়ই আপনি ক্ষমাশীল, আপনি ক্ষমা করতে ভালোবাসেন। অতএব আমাকে ক্ষমা করুন।"
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
                onPressed: () => _copyToClipboard(arabic, pronunciation, translation, title),
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

  Widget _buildNafalTab(BuildContext context, SettingsService settings, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "নফল রোজা প্ল্যানার ও ট্র্যাকার",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.red),
              label: const Text("রিসেট", style: TextStyle(color: Colors.red, fontSize: 12)),
              onPressed: () => _confirmResetNafal(context, settings),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildShawwalFastsCard(settings, isDark),
        const SizedBox(height: 16),
        _buildArafahAshuraCard(settings, isDark),
        const SizedBox(height: 16),
        _buildWeeklyFastsCard(settings, isDark),
        const SizedBox(height: 16),
        _buildNafalInfoCard(isDark),
      ],
    );
  }

  void _confirmResetNafal(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("নফল রোজা রেকর্ড রিসেট?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("আপনার সমস্ত শাওয়াল, আরাফাহ, আশুরা এবং সাপ্তাহিক নফল রোজার রেকর্ড মুছে যাবে। আপনি কি নিশ্চিত?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.resetNafalFasting();
              Navigator.pop(ctx);
            },
            child: const Text("রিসেট করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShawwalFastsCard(SettingsService settings, bool isDark) {
    final count = settings.shawwalFastsCount;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "শাওয়ালের ৬ রোজা",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              "রাসূলুল্লাহ (সা.) বলেছেন: \"যে ব্যক্তি রমজানের রোজা রাখল, অতঃপর শাওয়াল মাসে ছয়টি রোজা রাখল, সে যেন সারা বছর রোজা রাখল।\" (সহিহ মুসলিম)",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "অগ্রগতি: $count / ৬ টি সম্পন্ন",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: count == 6 ? AppColors.emeraldLight : null),
                ),
                if (count == 6)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "সম্পূর্ণ",
                      style: TextStyle(color: AppColors.emeraldLight, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final step = index + 1;
                final isDone = count >= step;
                return GestureDetector(
                  onTap: () {
                    if (isDone) {
                      settings.setShawwalFastsCount(step - 1);
                    } else {
                      settings.setShawwalFastsCount(step);
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.emerald : (isDark ? Colors.white10 : Colors.black12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone ? AppColors.emerald : Colors.grey.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              "$step",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArafahAshuraCard(SettingsService settings, bool isDark) {
    final arafahDone = settings.arafahFastCompleted;
    final ashuraDone = settings.ashuraFastsCompleted;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "বার্ষিক বিশেষ সুন্নাহ রোজা",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              activeColor: AppColors.emerald,
              contentPadding: EdgeInsets.zero,
              title: Text("আরাফাহর রোজা (৯ জিলহজ)", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text("ফজিলত: পূর্ববর্তী ও পরবর্তী বছরের গুনাহ মাফ হয় (মুসলিম)।", style: GoogleFonts.poppins(fontSize: 11)),
              value: arafahDone,
              onChanged: (val) {
                if (val != null) settings.toggleArafahFast(val);
              },
            ),
            const Divider(height: 16),
            Text(
              "আশুরার রোজা (মহররম)",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
            ),
            const SizedBox(height: 4),
            Text(
              "ফজিলত: পূর্ববর্তী বছরের গুনাহ মাফ হয় (মুসলিম)। ইহুদিদের বিপরীত করতে ১০ই মহররমের সাথে ৯ই অথবা ১১ই মহররম রোজা রাখা সুন্নাহ।",
              style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Center(child: Text("৯ই মহররম", style: GoogleFonts.poppins(fontSize: 11))),
                    selected: ashuraDone.contains('9'),
                    selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.emeraldLight,
                    onSelected: (val) {
                      settings.toggleAshuraFast('9');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilterChip(
                    label: Center(child: Text("১০ই মহররম", style: GoogleFonts.poppins(fontSize: 11))),
                    selected: ashuraDone.contains('10'),
                    selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.emeraldLight,
                    onSelected: (val) {
                      settings.toggleAshuraFast('10');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyFastsCard(SettingsService settings, bool isDark) {
    final count = settings.weeklyNafalFastsCount;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "সাপ্তাহিক রোজা (সোমবার ও বৃহস্পতিবার)",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text(
              "রাসূলুল্লাহ (সা.) বলেছেন: \"সোমবার ও বৃহস্পতিবার মানুষের আমল আল্লাহর কাছে পেশ করা হয়। আমি ভালোবাসি যে আমার আমল পেশ করার সময় আমি রোজা থাকি।\" (তিরমিজি)",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "এই বছরে মোট পঠিত:",
                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    Text(
                      "$count টি রোজা",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: count > 0 ? () => settings.decrementWeeklyNafalFasts() : null,
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(backgroundColor: AppColors.emerald),
                      onPressed: () => settings.incrementWeeklyNafalFasts(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNafalInfoCard(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.emerald, size: 20),
                const SizedBox(width: 8),
                Text(
                  "বার্ষিক অন্যান্য সুন্নাহ রোজা",
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.emeraldLight),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              "আইয়ামে বিজ (চন্দ্র মাসের ১৩, ১৪ ও ১৫ তারিখ)",
              "প্রতি চন্দ্র মাসের এই তিন দিন রোজা রাখা সারা বছর রোজা রাখার সমতুল্য। রাসূলুল্লাহ (সা.) সফরে বা ঘরে থাকা অবস্থায় কখনই এই রোজা ছাড়তেন না।",
              isDark,
            ),
            const Divider(height: 14),
            _buildInfoRow(
              "শাবান মাসের রোজা",
              "রমজানের প্রস্তুতি হিসেবে শাবান মাসে অধিক পরিমাণে রোজা রাখা সুন্নাহ। আয়েশা (রা.) বলেন, রাসূলুল্লাহ (সা.) শাবান মাসের চেয়ে কোনো মাসে অধিক রোজা রাখতেন না।",
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String desc, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DeedItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const _DeedItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}
