import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class RuqyahScreen extends StatelessWidget {
  const RuqyahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;
    final txtColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final conditions = [
      _ConditionItem("১. পূর্ণ ঈমান ও তাওয়াক্কুল", "দৃঢ় বিশ্বাস রাখতে হবে যে আরোগ্য দানকারী একমাত্র আল্লাহ তাআলা। রুকিয়া কেবল একটি শরিয়াহ নির্দেশিত উপায় বা মাধ্যম মাত্র।"),
      _ConditionItem("২. শিরকমুক্ত আমল", "কুরআন ও হাদিসে বর্ণিত দোয়া ছাড়া অন্য কোনো কুফরি কালাম, সুতা, তাবীজ বা কোনো প্রতীক ব্যবহার করা সম্পূর্ণ হারাম বা শিরক।"),
      _ConditionItem("৩. পবিত্রতা ও তওবা", "আমল শুরুর আগে অযু করা, শরীর ও পোশাক পবিত্র রাখা এবং মনের একাগ্রতা ও তওবা সহকারে আল্লাহর কাছে সাহায্য চাওয়া উত্তম।"),
    ];

    final verses = [
      _RuqyahVerse("১. সূরা ফাতিহা (৭ বার)", "سُورَةُ الْفَاتِحَةِ", "কুরআনের শ্রেষ্ঠ সূরা যা সব রোগের মহৌষধ বা শিফা হিসেবে পরিচিত। এটি সাতবার পূর্ণ মনোযোগ দিয়ে পাঠ করবেন।"),
      _RuqyahVerse("২. আয়াতুল কুরসি (৩ বার)", "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...", "দুষ্ট জীন, শয়তানের আছর ও যেকোনো প্রকার কালো জাদু থেকে সুরক্ষার জন্য এটি তিনবার পাঠ করুন।"),
      _RuqyahVerse("৩. শেষ ৩ সূরা (৩ বার করে)", "সূরা ইখলাস, ফালাক ও নাস", "জাদুটোনা ও হিংসুকের বদনজর থেকে বাঁচতে সকাল-সন্ধ্যা এবং ঘুমানোর পূর্বে এই সূরাগুলো ৩ বার করে পাঠ করে শরীরে ফুঁ দেওয়া সুন্নাহ।"),
      _RuqyahVerse("৪. হাদিসের বিশেষ আরোগ্যের দোয়া", "أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ وَاشْفِ أَنْتَ الشَّافِي...", "উচ্চারণ: 'আজহিবিল বাসা রাব্বান নাস, ওয়াশফি আনতাস শাফি, লা শিফাআ ইল্লা শিফাউকা, শিফাউল লা ইয়াগাদিরু সাক্বামা।'\n\nঅর্থ: হে মানুষের প্রতিপালক! কষ্ট দূর করে দিন, আর আরোগ্য দান করুন। আপনিই আরোগ্যদানকারী, আপনার আরোগ্য ছাড়া কোনো নিরাময় নেই, এমন নিরাময় যা কোনো রোগ অবশিষ্ট রাখে না।"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("রুকিয়া শরইয়াহ"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : AppColors.emerald.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "রুকিয়া শরইয়াহ কি?",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.gold : AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "রুকিয়া হলো পবিত্র কুরআন ও হাদিসের আয়াত এবং দোয়ার মাধ্যমে ঝাড়ফুঁক ও চিকিৎসা করা। এটি কুফরি, জাদুটোনা, বদনজর, জীনের আছর এবং শারীরিক-মানসিক রোগ থেকে আরোগ্য লাভের একটি সুন্নাহ সম্মত শক্তিশালী মাধ্যম।",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Conditions Section
            Text(
              "রুকিয়া কার্যকর হওয়ার শর্তাবলী",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 12),
            ...conditions.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.desc,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),

            // Method Section
            Text(
              "রুকিয়া করার সহজ পদ্ধতি",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                border: Border.all(color: const Color(0xFFFFE082)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "দুই হাতের তালু একত্রে জোড় করে নিচের আয়াত ও দোয়াগুলো পাঠ করে ফু দিন এবং পুরো শরীরে হাত বুলিয়ে নিন। অথবা একটি বিশুদ্ধ পানির পাত্রে ফু দিয়ে সেই পানি ৩ শ্বাসে পান করুন এবং বাকি পানি দিয়ে গোসল করুন।",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF5D4037),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verses Section
            Text(
              "রুকিয়ার আয়াত ও দুয়াসমূহ",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 12),
            ...verses.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.gold,
                    ),
                  ),
                  if (v.arabic.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      v.arabic,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const Divider(height: 16),
                  Text(
                    v.desc,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ConditionItem {
  final String title;
  final String desc;
  const _ConditionItem(this.title, this.desc);
}

class _RuqyahVerse {
  final String title;
  final String arabic;
  final String desc;
  const _RuqyahVerse(this.title, this.arabic, this.desc);
}
