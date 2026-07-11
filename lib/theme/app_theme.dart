import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color emerald = Color(0xFF1B5E20);
  static const Color emeraldLight = Color(0xFF2E7D32);
  static const Color emeraldDark = Color(0xFF003300);
  static const Color gold = Color(0xFFF9A825);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldDark = Color(0xFFF57F17);

  // Backgrounds
  static const Color bgLight = Color(0xFFF5F5F0);
  static const Color bgDark = Color(0xFF0D1117);

  // Cards
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF161B22);

  // Surface
  static const Color surfaceDark = Color(0xFF1C2128);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF555577);
  static const Color textPrimaryDark = Color(0xFFE6EDF3);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  // Arabic text
  static const Color arabicLight = Color(0xFF1A1A1A);
  static const Color arabicDark = Color(0xFFF0E6D3);

  // Makki / Madani chips
  static const Color makkiColor = Color(0xFF795548);
  static const Color madinaBg = Color(0xFF1565C0);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.light,
          primary: AppColors.emerald,
          secondary: AppColors.gold,
          surface: AppColors.bgLight,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardLight,
          elevation: 3,
          shadowColor: Color(0x22000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
              color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.poppins(
              color: AppColors.textPrimaryLight, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(
              color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimaryLight),
          bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondaryLight),
          labelSmall: GoogleFonts.poppins(color: AppColors.textSecondaryLight),
        ),
        iconTheme: const IconThemeData(color: AppColors.emerald),
        dividerColor: const Color(0xFFE0E0E0),
        popupMenuTheme: const PopupMenuThemeData(
          color: AppColors.emerald,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.dark,
          primary: AppColors.emeraldLight,
          secondary: AppColors.gold,
          surface: AppColors.bgDark,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.emeraldDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.cardDark,
          elevation: 3,
          shadowColor: Color(0x44000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
              color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.poppins(
              color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(
              color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimaryDark),
          bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondaryDark),
          labelSmall: GoogleFonts.poppins(color: AppColors.textSecondaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        dividerColor: const Color(0xFF30363D),
        popupMenuTheme: const PopupMenuThemeData(
          color: AppColors.surfaceDark,
        ),
      );
}
