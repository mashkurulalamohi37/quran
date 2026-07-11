import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/services/notification_service.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final bookmarks = context.watch<BookmarkService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("সেটিংস")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──
          _SectionHeader(label: "অ্যাপিয়ারেন্স", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                label: "ডার্ক মোড",
                value: settings.isDarkMode,
                onChanged: (_) => settings.toggleDarkMode(),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Font Size ──
          _SectionHeader(label: "ফন্ট সাইজ", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.text_fields_rounded,
                            color: AppColors.emerald, size: 20),
                        const SizedBox(width: 10),
                        Text("আরবি: ${settings.arabicFontSize.round()}px",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    Slider(
                      value: settings.arabicFontSize,
                      min: 24,
                      max: 60,
                      divisions: 18,
                      activeColor: AppColors.emerald,
                      onChanged: settings.setArabicFontSize,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.translate_rounded,
                            color: AppColors.emeraldLight, size: 20),
                        const SizedBox(width: 10),
                        Text("অনুবাদ: ${settings.translationFontSize.round()}px",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    Slider(
                      value: settings.translationFontSize,
                      min: 12,
                      max: 28,
                      divisions: 16,
                      activeColor: AppColors.emeraldLight,
                      onChanged: settings.setTranslationFontSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Notifications ──
          _SectionHeader(label: "প্রতিদিনের স্মরণ", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SwitchTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFE65100),
                label: "দৈনিক কুরআন স্মরণ",
                value: settings.notificationsEnabled,
                onChanged: (v) async {
                  if (v) {
                    final granted = await NotificationService.requestPermission();
                    if (granted) {
                      await settings.setNotificationsEnabled(true);
                      await NotificationService.scheduleDailyReminder(
                        settings.notificationHour,
                        settings.notificationMinute,
                      );
                    }
                  } else {
                    await settings.setNotificationsEnabled(false);
                    await NotificationService.cancelAll();
                  }
                },
                isDark: isDark,
              ),
              if (settings.notificationsEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time_rounded,
                        color: AppColors.gold, size: 20),
                  ),
                  title: Text("সময়",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 13)),
                  subtitle: Text(
                    _formatTime(settings.notificationHour,
                        settings.notificationMinute),
                    style: GoogleFonts.poppins(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.notificationHour,
                        minute: settings.notificationMinute,
                      ),
                      builder: (ctx, child) => Theme(
                        data: isDark ? ThemeData.dark() : ThemeData.light(),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      await settings.setNotificationTime(
                          picked.hour, picked.minute);
                      await NotificationService.scheduleDailyReminder(
                          picked.hour, picked.minute);
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Prayer Notifications ──
          _SectionHeader(label: "সালাত স্মরণ (কবরের আজাব রিমাইন্ডার)", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SwitchTile(
                icon: Icons.alarm_on_rounded,
                iconColor: AppColors.emerald,
                label: "সালাত রিমাইন্ডার চালু করুন",
                value: settings.prayerNotifEnabled,
                onChanged: (v) async {
                  if (v) {
                    final granted = await NotificationService.requestPermission();
                    if (granted) {
                      await settings.setPrayerNotifEnabled(true);
                    }
                  } else {
                    await settings.setPrayerNotifEnabled(false);
                  }
                },
                isDark: isDark,
              ),
              if (settings.prayerNotifEnabled) ...[
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.redAccent,
                  label: "কবরের আজাব ও সতর্কবাণী প্রদর্শন",
                  value: settings.showKaborWarning,
                  onChanged: (v) => settings.setShowKaborWarning(v),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.wb_twilight_rounded,
                  iconColor: Colors.amber,
                  label: "ফজর",
                  value: settings.notifyFajr,
                  onChanged: (v) => settings.setNotifyFajr(v),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: Colors.orange,
                  label: "যোহর",
                  value: settings.notifyDhuhr,
                  onChanged: (v) => settings.setNotifyDhuhr(v),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.sunny_snowing,
                  iconColor: Colors.deepOrange,
                  label: "আসর",
                  value: settings.notifyAsr,
                  onChanged: (v) => settings.setNotifyAsr(v),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.nights_stay_rounded,
                  iconColor: Colors.indigo,
                  label: "মাগরিব",
                  value: settings.notifyMaghrib,
                  onChanged: (v) => settings.setNotifyMaghrib(v),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: Colors.blueGrey,
                  label: "এশা",
                  value: settings.notifyIsha,
                  onChanged: (v) => settings.setNotifyIsha(v),
                  isDark: isDark,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Silent Mode ──
          _SectionHeader(label: "সাইলেন্ট মোড", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.volume_off_rounded,
                      color: Colors.teal, size: 20),
                ),
                title: Text("সাইলেন্ট মোড টাইপ",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                subtitle: Text(
                  _getSilentModeTypeLabel(settings.silentModeType),
                  style: GoogleFonts.poppins(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey),
                onTap: () => _showSilentModeTypePicker(context, settings),
              ),
              if (settings.silentModeType == 'time') ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_rounded,
                              color: AppColors.gold, size: 20),
                          const SizedBox(width: 10),
                          Text("সাইলেন্ট স্থায়িত্ব: ${settings.silentDuration} মিনিট",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                      Slider(
                        value: settings.silentDuration.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        activeColor: AppColors.gold,
                        onChanged: (v) => settings.setSilentDuration(v.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
              if (settings.silentModeType == 'gps') ...[
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        color: Colors.blueAccent, size: 20),
                  ),
                  title: Text("মসজিদের লোকেশন",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 13)),
                  subtitle: Text(
                    settings.hasMosqueRegistered
                        ? "নিবন্ধিত (ল্যাট: ${settings.mosqueLat.toStringAsFixed(4)}, লং: ${settings.mosqueLng.toStringAsFixed(4)})"
                        : "কোনো লোকেশন সেট করা নেই",
                    style: GoogleFonts.poppins(
                        color: settings.hasMosqueRegistered ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => _registerMosqueLocation(context, settings),
                    child: Text(
                      settings.hasMosqueRegistered ? "পুনরায় সেট" : "সেট করুন",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                if (settings.hasMosqueRegistered) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.radar_rounded,
                                color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 10),
                            Text("মসজিদের ব্যাসার্ধ: ${settings.mosqueRadius.round()} মিটার",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 13)),
                          ],
                        ),
                        Slider(
                          value: settings.mosqueRadius,
                          min: 50,
                          max: 500,
                          divisions: 9,
                          activeColor: Colors.blueAccent,
                          onChanged: (v) => settings.setMosqueRadius(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Data ──
          _SectionHeader(label: "ডেটা", isDark: isDark),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ActionTile(
                icon: Icons.bookmark_remove_rounded,
                iconColor: const Color(0xFF880E4F),
                label: "সব বুকমার্ক মুছুন",
                subtitle: "${bookmarks.count} টি সংরক্ষিত আয়াত",
                isDark: isDark,
                onTap: () => _confirmClearBookmarks(context, bookmarks),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF4A148C),
                label: "শেষ পড়া রিসেট",
                subtitle: settings.hasLastRead
                    ? "সূরা ${settings.lastReadSurahBangla}"
                    : "কোনো ডেটা নেই",
                isDark: isDark,
                onTap: () => settings.clearLastRead(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Footer ──
          Center(
            child: Column(
              children: [
                Text("বাংলা কুরআন",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald,
                        fontSize: 15)),
                Text("Version 1.0.7 · Phase 3",
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTime(int h, int m) {
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final period = h >= 12 ? 'PM' : 'AM';
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  void _confirmClearBookmarks(
      BuildContext context, BookmarkService bookmarks) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("সব বুকমার্ক মুছবেন?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("${bookmarks.count} টি বুকমার্ক মুছে যাবে।",
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("না", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              for (int i = bookmarks.count - 1; i >= 0; i--) {
                bookmarks.removeAt(i);
              }
              Navigator.pop(ctx);
            },
            child: const Text("মুছুন",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getSilentModeTypeLabel(String type) {
    switch (type) {
      case 'none':
        return "বন্ধ";
      case 'manual':
        return "ম্যানুয়াল";
      case 'time':
        return "নামাজের সময়";
      case 'gps':
        return "মসজিদ ভিত্তিক";
      default:
        return "বন্ধ";
    }
  }

  void _showSilentModeTypePicker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("সাইলেন্ট মোড নির্বাচন করুন",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeOption(ctx, settings, 'none', "বন্ধ", "স্বয়ংক্রিয় সائلেন্ট মোড নিষ্ক্রিয় থাকবে", Icons.do_not_disturb_off_rounded),
            _buildTypeOption(ctx, settings, 'manual', "ম্যানুয়াল", "ড্যাশবোর্ড থেকে বোতাম চেপে সাইলেন্ট করতে পারবেন", Icons.volume_off_rounded),
            _buildTypeOption(ctx, settings, 'time', "নামাজের সময়", "নামাজের ওয়াক্ত শুরু হলে স্বয়ংক্রিয় সাইলেন্ট হবে", Icons.timer_rounded),
            _buildTypeOption(ctx, settings, 'gps', "মসজিদ ভিত্তিক", "নিবন্ধিত মসজিদ এলাকায় প্রবেশ করলে সাইলেন্ট হবে", Icons.gps_fixed_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    SettingsService settings,
    String type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = settings.silentModeType == type;
    final isDark = settings.isDarkMode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.emerald : Colors.grey),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
              color: isSelected ? AppColors.emerald : (isDark ? Colors.white : Colors.black))),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 10)),
      onTap: () {
        settings.setSilentModeType(type);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _registerMosqueLocation(BuildContext context, SettingsService settings) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.emerald),
            const SizedBox(width: 20),
            Text("জিপিএস লোকেশন পাওয়া যাচ্ছে...",
                style: GoogleFonts.poppins(fontSize: 13)),
          ],
        ),
      ),
    );

    final pos = await PrayerService.getPosition();
    if (context.mounted) Navigator.pop(context); // Close loading dialog

    if (pos != null) {
      await settings.saveMosqueLocation(pos.latitude, pos.longitude);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("লোকেশন নিবন্ধিত হয়েছে 🎉",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
            content: Text(
                "আপনার মসজিদের অবস্থান সফলভাবে সংরক্ষণ করা হয়েছে।\nল্যাটিটিউড: ${pos.latitude.toStringAsFixed(5)}\nলঙ্গিটিউড: ${pos.longitude.toStringAsFixed(5)}",
                style: GoogleFonts.poppins(fontSize: 13)),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ঠিক আছে", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("লোকেশন পাওয়া যায়নি",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
            content: Text("দয়া করে আপনার জিপিএস চালু করুন এবং লোকেশন পারমিশন দিন।",
                style: GoogleFonts.poppins(fontSize: 13)),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ঠিক আছে", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    }
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.emerald,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 13)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.emerald,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 13)),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}
