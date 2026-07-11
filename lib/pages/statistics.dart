import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("আমার অগ্রগতি"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: settings.toggleDarkMode,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Reading Streak ──
          _StreakCard(streak: settings.streak, isDark: isDark),
          const SizedBox(height: 16),

          // ── Stats row ──
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppColors.emerald,
                  value: settings.totalAyahsRead.toString(),
                  label: "মোট আয়াত পড়া",
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF1A237E),
                  value: '${settings.surahsStartedCount}/114',
                  label: "সূরা শুরু করা",
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Surah Progress ──
          _SurahProgressCard(
            started: settings.surahsStartedCount,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // ── Last read ──
          if (settings.hasLastRead) ...[
            _LastReadCard(settings: settings, isDark: isDark),
            const SizedBox(height: 16),
          ],

          // ── Reset ──
          _ResetCard(isDark: isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Streak Card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  final bool isDark;
  const _StreakCard({required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE65100), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "পাঠের ধারা 🔥",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                streak == 0 ? "শুরু করুন!" : "$streak দিন",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                streak == 0
                    ? "প্রতিদিন পড়ুন, ধারা শুরু করুন"
                    : "টানা পড়ে যাচ্ছেন — অসাধারণ!",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text("🔥", style: TextStyle(fontSize: 36)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Surah Progress Card ──────────────────────────────────────────────────────

class _SurahProgressCard extends StatelessWidget {
  final int started;
  final bool isDark;
  const _SurahProgressCard({required this.started, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = started / 114.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.emerald, size: 20),
              const SizedBox(width: 8),
              Text(
                "কুরআন সম্পূর্ণতা",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              Text(
                '$started / 114',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            started == 0
                ? "এখনো কোনো সূরা পড়া হয়নি"
                : started == 114
                    ? "মাশাআল্লাহ! সব সূরা পড়া হয়েছে 🎉"
                    : "${(pct * 100).toStringAsFixed(1)}% সম্পন্ন",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Last Read Card ───────────────────────────────────────────────────────────

class _LastReadCard extends StatelessWidget {
  final SettingsService settings;
  final bool isDark;
  const _LastReadCard({required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("শেষ পড়া",
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              Text("সূরা ${settings.lastReadSurahBangla}",
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text("আয়াত ${settings.lastReadAyahIndex}",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.gold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Reset Card ───────────────────────────────────────────────────────────────

class _ResetCard extends StatelessWidget {
  final bool isDark;
  const _ResetCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.restart_alt_rounded, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("পরিসংখ্যান রিসেট",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text("সব অগ্রগতি মুছে দিন",
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _confirmReset(context),
            child: const Text("রিসেট", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("রিসেট করবেন?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("ধারা, মোট আয়াত, এবং সূরার অগ্রগতি মুছে যাবে।",
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SettingsService>().resetStats();
              Navigator.pop(ctx);
            },
            child: const Text("হ্যাঁ, রিসেট",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
