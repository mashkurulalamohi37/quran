import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class KhatamPlannerScreen extends StatefulWidget {
  const KhatamPlannerScreen({super.key});

  @override
  State<KhatamPlannerScreen> createState() => _KhatamPlannerScreenState();
}

class _KhatamPlannerScreenState extends State<KhatamPlannerScreen> {
  final _customDaysController = TextEditingController();
  final _scrollController = ScrollController();
  int _selectedTargetOption = 30; // Default to 30 days (Ramadan)
  bool _isCustomMode = false;

  @override
  void dispose() {
    _customDaysController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getDailyReadingTarget(int day, int targetDays) {
    if (targetDays == 30) {
      return "পারা (Juz) $day";
    }

    final dailyJuz = 30.0 / targetDays;

    if (targetDays == 60) {
      final juzNum = ((day + 1) / 2).floor();
      final part = day % 2 == 1 ? "প্রথম অর্ধাংশ" : "শেষ অর্ধাংশ";
      return "পারা $juzNum ($part)";
    }

    if (targetDays == 15) {
      return "পারা ${day * 2 - 1} এবং ${day * 2}";
    }

    if (dailyJuz >= 1.0) {
      final startJuz = ((day - 1) * dailyJuz + 1).round();
      final endJuz = (day * dailyJuz).round().clamp(1, 30);
      if (startJuz == endJuz) {
        return "পারা $startJuz";
      }
      return "পারা $startJuz থেকে $endJuz";
    } else {
      final dailyPages = 604.0 / targetDays;
      final startPage = ((day - 1) * dailyPages + 1).round();
      final endPage = (day * dailyPages).round().clamp(1, 604);
      if (startPage == endPage) {
        return "পৃষ্ঠা $startPage";
      }
      return "পৃষ্ঠা $startPage থেকে $endPage";
    }
  }

  void _confirmStopPlan(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("পরিকল্পনা বন্ধ করবেন?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("আপনার বর্তমান কুরআন খতমের অগ্রগতি ও রুটিন মুছে যাবে। আপনি কি নিশ্চিত?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              settings.stopKhatamPlan();
              Navigator.pop(ctx);
            },
            child: const Text("বন্ধ করুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;
    final active = settings.isKhatamActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text("কুরআন খতম প্ল্যানার"),
      ),
      body: active
          ? _buildActiveTracker(context, settings, isDark)
          : _buildSetupView(context, settings, isDark),
    );
  }

  Widget _buildSetupView(BuildContext context, SettingsService settings, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "কুরআন খতম পরিকল্পনা শুরু করুন",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "একটি খতমের লক্ষ্য নির্ধারণ করুন। লক্ষ্য অনুযায়ী প্রতিদিন আপনাকে নির্দিষ্ট অংশ পড়তে হবে, যা কুরআন খতম সহজ ও নিয়মতান্ত্রিক করবে।",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Preset Options Grid
          Row(
            children: [
              Expanded(child: _buildPresetCard("রমজান খতম", "৩০ দিন", 30, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildPresetCard("২ মাসের পরিকল্পনা", "৬০ দিন", 60, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPresetCard("বার্ষিক খতম", "৩৬৫ দিন", 365, isDark)),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCustomMode = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCustomMode 
                          ? AppColors.emerald.withValues(alpha: 0.12)
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isCustomMode ? AppColors.emerald : Colors.grey.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "কাস্টম লক্ষ্য",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _isCustomMode ? AppColors.emerald : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ইচ্ছামতো দিন লিখুন",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isCustomMode) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _customDaysController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                labelText: "কাস্টম টার্গেট (দিন)",
                labelStyle: GoogleFonts.poppins(fontSize: 12),
                hintText: "উদাহরণ: ৪৫, ১০০, ইত্যাদি",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.emerald, width: 2),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Start Plan Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                int days = _selectedTargetOption;
                if (_isCustomMode) {
                  final customText = _customDaysController.text.trim();
                  final parsed = int.tryParse(customText) ?? 0;
                  if (parsed <= 0 || parsed > 1000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("অনুগ্রহ করে ১ থেকে ১০০০ এর মধ্যে সঠিক দিন লিখুন।")),
                    );
                    return;
                  }
                  days = parsed;
                }
                settings.startKhatamPlan(days);
              },
              child: Text(
                "পরিকল্পনা শুরু করুন",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(String title, String subtitle, int value, bool isDark) {
    final isSelected = !_isCustomMode && _selectedTargetOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTargetOption = value;
          _isCustomMode = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.emerald.withValues(alpha: 0.12)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.emerald : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? AppColors.emerald : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTracker(BuildContext context, SettingsService settings, bool isDark) {
    final targetDays = settings.khatamTargetDays;
    final completedDays = settings.khatamCompletedDays;
    final totalFinished = completedDays.length;
    final percentage = (totalFinished / targetDays * 100).toStringAsFixed(1);
    final remainingDays = targetDays - totalFinished;

    final dailyJuz = (30.0 / targetDays).toStringAsFixed(2);
    final dailyPages = (604.0 / targetDays).toStringAsFixed(1);
    final dailyVerses = (6236.0 / targetDays).round();

    return Column(
      children: [
        // Top Dashboard Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
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
                        "$targetDays দিনের খতম পরিকল্পনা",
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "শুরু: ${settings.khatamStartDate}",
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                    label: const Text("বন্ধ করুন", style: TextStyle(color: Colors.red, fontSize: 12)),
                    onPressed: () => _confirmStopPlan(context, settings),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: totalFinished / targetDays,
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      color: AppColors.emerald,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "$percentage%",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.emerald),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stat Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildTrackerMiniCard(
                      "সম্পন্ন",
                      "$totalFinished / $targetDays দিন",
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTrackerMiniCard(
                      "অবশিষ্ট",
                      "$remainingDays দিন",
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTrackerMiniCard(
                      "দৈনিক পারা টার্গেট",
                      "$dailyJuz পারা",
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTrackerMiniCard(
                      "দৈনিক পৃষ্ঠা টার্গেট",
                      "$dailyPages পৃষ্ঠা",
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTrackerMiniCard(
                      "দৈনিক আয়াত টার্গেট",
                      "$dailyVerses আয়াত",
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Daily Reading List
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 8,
            radius: const Radius.circular(8),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: targetDays,
              itemBuilder: (ctx, index) {
                final day = index + 1;
                final isDone = completedDays.contains(day);
                final assignment = _getDailyReadingTarget(day, targetDays);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDone 
                          ? AppColors.emerald.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () => settings.toggleKhatamDay(day),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.emerald : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? AppColors.emerald : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Day Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "দিন $day",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDone ? Colors.grey : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "আজকের পাঠ্য: $assignment",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDone ? Colors.grey : AppColors.emeraldLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isDone)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "সম্পন্ন",
                            style: TextStyle(color: AppColors.emeraldLight, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerMiniCard(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
