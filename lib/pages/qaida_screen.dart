import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/data/qaida_data.dart';
import 'package:quran/theme/app_theme.dart';

class QaidaScreen extends StatefulWidget {
  const QaidaScreen({super.key});

  @override
  State<QaidaScreen> createState() => _QaidaScreenState();
}

class _QaidaScreenState extends State<QaidaScreen> {
  Set<int> _completedLessons = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int>{};
    for (final lesson in qaidaLessons) {
      if (prefs.getBool('qaida_completed_lesson_${lesson.id}') ?? false) {
        completed.add(lesson.id);
      }
    }
    setState(() {
      _completedLessons = completed;
    });
  }

  Future<void> _toggleLessonCompletion(int lessonId, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('qaida_completed_lesson_$lessonId', isCompleted);
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = qaidaLessons.length;
    final done = _completedLessons.length;
    final progress = total > 0 ? done / total : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("সহজ কুরআন শিক্ষা (কায়দা)"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Progress Header Card ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF004D40), Color(0xFF00796B)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004D40).withValues(alpha: 0.3),
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
                      "আপনার অগ্রগতি",
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
                        "$done / $total সম্পন্ন",
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
                      ? "মাশাআল্লাহ! আপনি সব কয়টি পাঠ শেষ করেছেন! 🎉"
                      : "সহজ ধাপে কুরআন পাঠ ও উচ্চারণ শিখুন।",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Lessons list ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: qaidaLessons.length,
              itemBuilder: (ctx, i) {
                final lesson = qaidaLessons[i];
                final isDone = _completedLessons.contains(lesson.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.emerald.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isDone
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.emerald)
                          : Text(
                              "${lesson.id}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                    ),
                    title: Text(
                      lesson.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lesson.subtitle,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.emerald),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _QaidaLessonDetails(
                            lesson: lesson,
                            isDone: isDone,
                            onToggleCompletion: (val) => _toggleLessonCompletion(lesson.id, val),
                            isDark: isDark,
                          ),
                        ),
                      );
                      _loadProgress();
                    },
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

// ── Lesson Details ──
class _QaidaLessonDetails extends StatelessWidget {
  final QaidaLesson lesson;
  final bool isDone;
  final ValueChanged<bool> onToggleCompletion;
  final bool isDark;

  const _QaidaLessonDetails({
    required this.lesson,
    required this.isDone,
    required this.onToggleCompletion,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      lesson.introduction,
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid of Qaida items
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lesson.items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (ctx, idx) {
                      final item = lesson.items[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Arabic character
                            Text(
                              item.arabic,
                              style: const TextStyle(
                                fontFamily: 'Lateef',
                                fontSize: 44,
                                color: AppColors.emerald,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            // Bangla Pronunciation
                            Text(
                              item.banglaPron,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Description
                            Text(
                              item.description,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: Colors.grey,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Completion mark action bottom bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDone ? "পাঠটি সম্পন্ন হয়েছে ✅" : "অধ্যয়ন শুরু করুন",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDone ? AppColors.emerald : Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? Colors.grey : AppColors.emerald,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    onToggleCompletion(!isDone);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    isDone ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isDone ? "রিসেট করুন" : "পাঠ সম্পন্ন",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
