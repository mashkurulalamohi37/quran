import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/data/sunnah_data.dart';
import 'package:quran/theme/app_theme.dart';

class SunnahScreen extends StatefulWidget {
  const SunnahScreen({super.key});

  @override
  State<SunnahScreen> createState() => _SunnahScreenState();
}

class _SunnahScreenState extends State<SunnahScreen> {
  final Set<String> _completedHabits = {};
  late String _todayStr;
  bool _isFriday = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _isFriday = now.weekday == DateTime.friday;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <String>{};
    for (final habit in sunnahHabits) {
      final key = 'sunnah_completed_${_todayStr}_${habit.id}';
      if (prefs.getBool(key) ?? false) {
        completed.add(habit.id);
      }
    }
    setState(() {
      _completedHabits.clear();
      _completedHabits.addAll(completed);
    });
  }

  Future<void> _toggleHabit(String habitId, bool isChecked) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final key = 'sunnah_completed_${_todayStr}_$habitId';
    await prefs.setBool(key, isChecked);
    _loadProgress();
  }

  List<SunnahHabit> get _filteredHabits {
    // Show Friday-specific habits only on Fridays
    return sunnahHabits.where((h) => !h.fridayOnly || _isFriday).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habits = _filteredHabits;
    final total = habits.length;
    final done = _completedHabits.length;
    final progress = total > 0 ? done / total : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("সুন্নাহ অভ্যাস ট্র্যাকার"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Today's Progress Card ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE65100), Color(0xFFEF6C00)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE65100).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "আজকের সুন্নাহ অগ্রগতি",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${_toBengaliNum(done)} / ${_toBengaliNum(total)} সম্পন্ন",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  progress == 1.0
                      ? "আলহামদুলিল্লাহ! আজকের সব সুন্নাহ আমল সম্পন্ন হয়েছে!"
                      : "সুন্নাহকে জিন্দা রাখুন এবং সুন্নাহ সম্মত জীবন গড়ুন।",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Sunnah Checklist ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: habits.length,
              itemBuilder: (ctx, i) {
                final habit = habits[i];
                final isDone = _completedHabits.contains(habit.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    shape: const Border(), // Remove borders
                    leading: Checkbox(
                      activeColor: AppColors.emerald,
                      value: isDone,
                      onChanged: (val) => _toggleHabit(habit.id, val ?? false),
                    ),
                    title: Text(
                      habit.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    subtitle: Text(
                      habit.category,
                      style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.emerald),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              habit.description,
                              style: GoogleFonts.poppins(fontSize: 12.5),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                habit.rewardHint,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark ? AppColors.goldLight : Colors.brown.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }
}
