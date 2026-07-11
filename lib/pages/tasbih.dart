import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  TasbihScreenState createState() => TasbihScreenState();
}

class TasbihScreenState extends State<TasbihScreen> {
  int _counter = 0;
  int _target = 33; // 33, 99, -1 (Infinite)
  int _cycleCount = 0;
  int _selectedZikirIndex = 0;

  final List<Map<String, String>> _zikirs = [
    {
      'arabic': 'سُبْحَانَ ٱللَّٰهِ',
      'bangla': 'সুবহানাল্লাহ',
      'meaning': 'আল্লাহ পরম পবিত্র'
    },
    {
      'arabic': 'ٱلْحَمْدُ لِلَّٰهِ',
      'bangla': 'আলহামদুলিল্লাহ',
      'meaning': 'সব প্রশংসা আল্লাহর জন্য'
    },
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'bangla': 'লা ইলাহা ইল্লাল্লাহ',
      'meaning': 'আল্লাহ ছাড়া কোনো উপাস্য নেই'
    },
    {
      'arabic': 'ٱللَّٰهُ أَكْبَرُ',
      'bangla': 'আল্লাহু আকবার',
      'meaning': 'আল্লাহ সবচেয়ে মহান'
    },
    {
      'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ',
      'bangla': 'আস্তাগফিরুল্লাহ',
      'meaning': 'আমি আল্লাহর নিকট ক্ষমা প্রার্থনা করছি'
    },
    {
      'arabic': 'سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ',
      'bangla': 'সুবহানাল্লাহি ওয়া বিহামদিহি',
      'meaning': 'আল্লাহর প্রশংসা সহকারে তাঁর পবিত্রতা ঘোষণা করছি'
    },
  ];

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _counter++;
      if (_target > 0 && _counter >= _target) {
        _counter = 0;
        _cycleCount++;
        // Heavy vibration when target is reached
        HapticFeedback.vibrate();
        _showTargetReachedToast();
      }
    });
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
      _cycleCount = 0;
    });
  }

  void _showTargetReachedToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "লক্ষ্য সম্পন্ন! ${_zikirs[_selectedZikirIndex]['bangla']} পড়া হয়েছে।",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.emerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;
    final activeZikir = _zikirs[_selectedZikirIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ডিজিটাল তাসবিহ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetCounter,
            tooltip: "রিসেট",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Zikir Picker Dropdown
            _buildZikirSelector(isDark),
            const SizedBox(height: 16),

            // Arabic text Display
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
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
                children: [
                  Text(
                    activeZikir['arabic']!,
                    style: TextStyle(
                      fontFamily: 'Lateef',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeZikir['bangla']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emerald,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeZikir['meaning']!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Target selector Row
            _buildTargetSelector(isDark),
            const Spacer(),

            // Large Tap Circle
            GestureDetector(
              onTap: _incrementCounter,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_counter',
                        style: GoogleFonts.poppins(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _target > 0 ? "লক্ষ্য: $_target" : "অসীম",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Cycles Count Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.emerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "সম্পন্ন চক্র (Cycles):",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '$_cycleCount',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildZikirSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedZikirIndex,
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.emerald),
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (int? value) {
            if (value != null) {
              setState(() {
                _selectedZikirIndex = value;
                _counter = 0; // reset on zikir change
              });
            }
          },
          items: List.generate(_zikirs.length, (i) {
            return DropdownMenuItem<int>(
              value: i,
              child: Text(_zikirs[i]['bangla']!),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTargetSelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTargetButton(33, isDark),
        const SizedBox(width: 12),
        _buildTargetButton(99, isDark),
        const SizedBox(width: 12),
        _buildTargetButton(-1, isDark), // -1 represent infinite
      ],
    );
  }

  Widget _buildTargetButton(int targetValue, bool isDark) {
    final isSelected = _target == targetValue;
    final label = targetValue == -1 ? "অসীম" : '$targetValue';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _target = targetValue;
          _counter = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.emerald : AppColors.emerald.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}
