import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  PrayerTimesScreenState createState() => PrayerTimesScreenState();
}

class PrayerTimesScreenState extends State<PrayerTimesScreen> {
  DailyPrayers? _prayers;
  bool _loading = true;
  String _locationName = '';
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _loadPrayers() async {
    if (!mounted) return;
    final settings = context.read<SettingsService>();

    double lat = 23.8103;
    double lng = 90.4125;
    _locationName = 'Dhaka (ঢাকা)';

    if (settings.isAutomaticLocation) {
      if (settings.cachedLatitude != null && settings.cachedLongitude != null) {
        lat = settings.cachedLatitude!;
        lng = settings.cachedLongitude!;
        _locationName = 'আমার অবস্থান (GPS - ক্যাশ)';
        
        final prayers = PrayerService.calculate(
          lat: lat,
          lng: lng,
          method: settings.calculationMethod,
          madhab: settings.madhab,
        );
        setState(() {
          _prayers = prayers;
          _loading = false;
        });
        _fetchFreshLocation(settings);
      } else {
        setState(() { _loading = true; });
        final pos = await PrayerService.getPosition();
        if (pos == null) {
          final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
          lat = dist.latitude;
          lng = dist.longitude;
          _locationName = '${dist.nameBn} (${dist.nameEn}) - GPS বন্ধ';
        } else {
          lat = pos.latitude;
          lng = pos.longitude;
          _locationName = 'আমার অবস্থান (GPS)';
          settings.updateCachedLocation(lat, lng);
        }
        final prayers = PrayerService.calculate(
          lat: lat,
          lng: lng,
          method: settings.calculationMethod,
          madhab: settings.madhab,
        );
        setState(() {
          _prayers = prayers;
          _loading = false;
        });
      }
    } else {
      setState(() { _loading = true; });
      final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
      lat = dist.latitude;
      lng = dist.longitude;
      _locationName = '${dist.nameBn} (${dist.nameEn})';
      
      final prayers = PrayerService.calculate(
        lat: lat,
        lng: lng,
        method: settings.calculationMethod,
        madhab: settings.madhab,
      );
      setState(() {
        _prayers = prayers;
        _loading = false;
      });
    }
  }

  Future<void> _fetchFreshLocation(SettingsService settings) async {
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
            _prayers = prayers;
            _locationName = 'আমার অবস্থান (GPS)';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _locationName = 'আমার অবস্থান (GPS)';
          });
        }
      }
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<SettingsService>(
          builder: (ctx, settings, _) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "নামাজের সময় নির্ধারণ সেটিংস",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.emerald),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text("স্বয়ংক্রিয় অবস্থান (GPS)", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text("সরাসরি GPS থেকে নামাজের সময় নির্ণয়", style: GoogleFonts.poppins(fontSize: 11)),
                      value: settings.isAutomaticLocation,
                      activeColor: AppColors.emerald,
                      onChanged: (val) {
                        settings.setAutomaticLocation(val);
                        _loadPrayers();
                      },
                    ),

                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text("মুসাফির মোড (কসর)", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text("সফরকালে যোহর, আসর ও এশা কসর (২ রাকাত) করার নির্দেশনা দেখতে", style: GoogleFonts.poppins(fontSize: 11)),
                      value: settings.isMusafir,
                      activeColor: AppColors.gold,
                      onChanged: (val) {
                        settings.setMusafir(val);
                      },
                    ),

                    if (!settings.isAutomaticLocation) ...[
                      const SizedBox(height: 12),
                      Text("জেলা নির্বাচন করুন:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: settings.selectedDistrict,
                            isExpanded: true,
                            dropdownColor: settings.isDarkMode ? AppColors.cardDark : Colors.white,
                            onChanged: (val) {
                              if (val != null) {
                                settings.setSelectedDistrict(val);
                                _loadPrayers();
                              }
                            },
                            items: PrayerService.bdDistricts.map((d) {
                              return DropdownMenuItem<String>(
                                value: d.nameEn,
                                child: Text("${d.nameBn} (${d.nameEn})"),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Text("হিসাব পদ্ধতি:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: settings.calculationMethod,
                          isExpanded: true,
                          dropdownColor: settings.isDarkMode ? AppColors.cardDark : Colors.white,
                          onChanged: (val) {
                            if (val != null) {
                              settings.setCalculationMethod(val);
                              _loadPrayers();
                            }
                          },
                          items: PrayerService.calculationMethods.map((m) {
                            return DropdownMenuItem<String>(
                              value: m.key,
                              child: Text(m.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text("মাযহাব:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text("হানাফি (আসর দেরি)", style: GoogleFonts.poppins(fontSize: 12))),
                            selected: settings.madhab == 'hanafi',
                            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                            onSelected: (val) {
                              if (val) {
                                settings.setMadhab('hanafi');
                                _loadPrayers();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(child: Text("শাফেয়ী / অন্যান্য", style: GoogleFonts.poppins(fontSize: 12))),
                            selected: settings.madhab == 'shafi',
                            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                            onSelected: (val) {
                              if (val) {
                                settings.setMadhab('shafi');
                                _loadPrayers();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;
    final now = DateTime.now();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D2B12), const Color(0xFF0D1117)]
                : [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "নামাজের সময়",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded,
                          color: Colors.white70),
                      onPressed: _showSettingsSheet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white70),
                      onPressed: _loadPrayers,
                    ),
                  ],
                ),
              ),

              // ── Date + Clock header ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      _formatDate(now),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                    if (_prayers != null) ...[
                      const SizedBox(height: 4),
                      _NextPrayerBadge(prayers: _prayers!),
                    ],
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDark : AppColors.bgLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildBody(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.emerald),
            SizedBox(height: 16),
            Text("নামাজের সময় নির্ণয় করা হচ্ছে..."),
          ],
        ),
      );
    }

    if (_prayers == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "আজকের নামাজের সময়সূচি",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            // Location Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.emerald),
                  const SizedBox(width: 4),
                  Text(
                    _locationName,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (context.watch<SettingsService>().isMusafir) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.goldDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "মুসাফির মোড সক্রিয় রয়েছে। যোহর, আসর এবং এশা সালাত কসর (২ রাকাত) করার নির্দেশনা প্রদর্শন করা হচ্ছে।",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.amber.shade200 : AppColors.goldDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ..._prayers!.all.map((p) => _PrayerCard(
              prayer: p,
              isNext: p == _prayers!.nextPrayer(),
              isDark: isDark,
            )),
        const SizedBox(height: 16),
        _ForbiddenTimesCard(prayers: _prayers!, isDark: isDark),
        const SizedBox(height: 16),
        _InfoCard(isDark: isDark),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
      'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    const days = ['রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার',
        'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার'];
    return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _NextPrayerBadge extends StatelessWidget {
  final DailyPrayers prayers;
  const _NextPrayerBadge({required this.prayers});

  @override
  Widget build(BuildContext context) {
    final next = prayers.nextPrayer();
    if (next == null) return const SizedBox();
    final remaining = prayers.timeUntilNext();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'পরবর্তী: ${next.banglaName} — ${remaining != null ? PrayerService.formatCountdown(remaining) : ""}',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerInfo prayer;
  final bool isNext;
  final bool isDark;

  const _PrayerCard({
    required this.prayer,
    required this.isNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isQasrApplicable = settings.isMusafir &&
        (prayer.name.toLowerCase() == 'dhuhr' ||
         prayer.name.toLowerCase() == 'asr' ||
         prayer.name.toLowerCase() == 'isha');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isNext
            ? const LinearGradient(
                colors: [AppColors.emerald, AppColors.emeraldLight],
              )
            : null,
        color: isNext ? null : (isDark ? AppColors.cardDark : AppColors.cardLight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? AppColors.emerald.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: isNext ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(prayer.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayer.banglaName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isNext ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    if (isQasrApplicable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isNext ? Colors.white24 : AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isNext ? Colors.white30 : AppColors.gold,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "কসর ২ রাকাত",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isNext ? Colors.white : AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  prayer.name,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isNext ? Colors.white70 : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PrayerService.formatTime(prayer.time),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isNext ? Colors.white : AppColors.emerald,
                ),
              ),
              if (isNext)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "পরবর্তী",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  const _InfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final methodInfo = PrayerService.calculationMethods.firstWhere(
      (m) => m.key == settings.calculationMethod,
      orElse: () => PrayerService.calculationMethods.first,
    );
    final madhabName = settings.madhab == 'shafi' ? 'শাফেয়ী / অন্যান্য' : 'হানাফি';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.emerald, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "পদ্ধতি: ${methodInfo.name} | মাযহাব: $madhabName",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForbiddenTimesCard extends StatelessWidget {
  final DailyPrayers prayers;
  final bool isDark;

  const _ForbiddenTimesCard({required this.prayers, required this.isDark});

  String _formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final sunriseStart = prayers.sunrise.time;
    final sunriseEnd = sunriseStart.add(const Duration(minutes: 15));

    final middayStart = prayers.dhuhr.time.subtract(const Duration(minutes: 10));
    final middayEnd = prayers.dhuhr.time;

    final sunsetStart = prayers.maghrib.time.subtract(const Duration(minutes: 15));
    final sunsetEnd = prayers.maghrib.time;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  "নামাজ নিষিদ্ধ সময়সূচি (আজ)",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildForbiddenRow(
              "সূর্যোদয় কালীন সময়",
              "${_formatTimeOnly(sunriseStart)} - ${_formatTimeOnly(sunriseEnd)}",
              isDark,
            ),
            const Divider(height: 12),
            _buildForbiddenRow(
              "দ্বিপ্রহর (মাথার উপর সূর্য)",
              "${_formatTimeOnly(middayStart)} - ${_formatTimeOnly(middayEnd)}",
              isDark,
            ),
            const Divider(height: 12),
            _buildForbiddenRow(
              "সূর্যাস্ত কালীন সময়*",
              "${_formatTimeOnly(sunsetStart)} - ${_formatTimeOnly(sunsetEnd)}",
              isDark,
            ),
            const SizedBox(height: 10),
            Text(
              "* বি.দ্র: সূর্যাস্তের সময় সেই দিনের আসর নামাজ ব্যতীত অন্য সকল প্রকার সালাত আদায় করা নিষিদ্ধ। এছাড়া উপরোক্ত ৩টি সময়ে যেকোনো সালাত (ফরজ ও নফল) আদায় করা নিষিদ্ধ।",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForbiddenRow(String title, String timeRange, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          timeRange,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
