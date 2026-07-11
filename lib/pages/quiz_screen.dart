import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/data/quiz_data.dart';
import 'package:quran/theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<QuizQuestion> _sessionQuestions = [];
  int _currentIdx = 0;
  int _score = 0;
  int _highScore = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startNewQuiz();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
    });
  }

  Future<void> _updateHighScore(int score) async {
    if (score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_high_score', score);
      setState(() {
        _highScore = score;
      });
    }
  }

  void _startNewQuiz() {
    final random = Random();
    final allQuestions = List<QuizQuestion>.from(quizQuestions);
    allQuestions.shuffle(random);
    setState(() {
      _sessionQuestions.clear();
      // Take up to 10 questions for this session
      _sessionQuestions.addAll(allQuestions.take(10));
      _currentIdx = 0;
      _score = 0;
      _selectedOption = null;
      _answered = false;
      _finished = false;
    });
  }

  void _submitAnswer(String option) {
    if (_answered) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedOption = option;
      _answered = true;
      final q = _sessionQuestions[_currentIdx];
      if (option == q.correctTranslation) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIdx < _sessionQuestions.length - 1) {
      setState(() {
        _currentIdx++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() {
        _finished = true;
      });
      _updateHighScore(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_finished) {
      return _buildResultScreen(isDark);
    }

    if (_sessionQuestions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = _sessionQuestions[_currentIdx];
    final total = _sessionQuestions.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("কুরআনিক শব্দার্থ কুইজ"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Score & Progress bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "প্রশ্ন: ${_toBengaliNum(_currentIdx + 1)} / ${_toBengaliNum(total)}",
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  "স্কোর: ${_toBengaliNum(_score)}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentIdx + 1) / total,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 32),

            // ── Question Card (Arabic Word) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "শব্দটির অর্থ কী?",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q.word,
                    style: const TextStyle(
                      fontFamily: 'Lateef',
                      fontSize: 56,
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Options List ──
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (ctx, i) {
                  final opt = q.options[i];
                  final isSelected = _selectedOption == opt;
                  final isCorrect = opt == q.correctTranslation;

                  Color cardBg = isDark ? AppColors.cardDark : Colors.white;
                  Color borderCol = isDark ? Colors.white10 : Colors.black12;
                  Widget? trailingIcon;

                  if (_answered) {
                    if (isCorrect) {
                      cardBg = AppColors.emerald.withValues(alpha: 0.15);
                      borderCol = AppColors.emerald;
                      trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.emerald);
                    } else if (isSelected) {
                      cardBg = Colors.red.withValues(alpha: 0.15);
                      borderCol = Colors.red;
                      trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.red);
                    }
                  } else if (isSelected) {
                    borderCol = AppColors.emerald;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: _answered ? 2.0 : 1.0),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        opt,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: trailingIcon,
                      onTap: () => _submitAnswer(opt),
                    ),
                  );
                },
              ),
            ),

            // ── Action Button ──
            if (_answered)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                label: Text(
                  _currentIdx < total - 1 ? "পরবর্তী প্রশ্ন" : "ফলাফল দেখুন",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final percent = (_score / _sessionQuestions.length) * 100;
    String feedback = "";
    String emoji = "";

    if (percent >= 90) {
      feedback = "মাশাআল্লাহ! অসাধারণ পারফরম্যান্স!";
      emoji = "🏆";
    } else if (percent >= 60) {
      feedback = "খুব ভালো হয়েছে! আর একটু চেষ্টা করলেই পূর্ণ নম্বর পাবেন।";
      emoji = "👍";
    } else {
      feedback = "আবার চেষ্টা করুন এবং কুরআনিক শব্দ শিখুন।";
      emoji = "📚";
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("কুইজ ফলাফল"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              feedback,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Score card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _scoreRow("আপনার স্কোর:", "${_toBengaliNum(_score)} / ${_toBengaliNum(10)}"),
                  const Divider(height: 24),
                  _scoreRow("সর্বোচ্চ স্কোর (High Score):", _toBengaliNum(_highScore)),
                ],
              ),
            ),

            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.emerald),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.emerald),
                    label: Text(
                      "ফিরে যান",
                      style: GoogleFonts.poppins(color: AppColors.emerald, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startNewQuiz,
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    label: Text(
                      "পুনরায় খেলুন",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  String _toBengaliNum(int n) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return n.toString().split('').map((c) => digits[int.parse(c)]).join();
  }
}
