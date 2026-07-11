import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/pages/ayalistbysura.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;
    final bookmarks = context.watch<BookmarkService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("বুকমার্কসমূহ"),
        actions: [
          if (bookmarks.count > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: "সকল মুছুন",
              onPressed: () => _confirmClearAll(context, bookmarks),
            ),
        ],
      ),
      body: bookmarks.count == 0
          ? _EmptyState(isDark: isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarks.count,
              itemBuilder: (ctx, i) {
                final bm = bookmarks.bookmarks[i];
                return Dismissible(
                  key: ValueKey('${bm.surahId}_${bm.ayahIndex}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) => bookmarks.removeAt(i),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => AyaListBySura(
                            {
                              'id': bm.surahId,
                              'number': bm.surahId.toString(),
                              'bangla_name': bm.surahBangla,
                              'name': bm.surahName,
                              'transliteration_en': '',
                              'total_verses': 286,
                              'total_verses_b': '',
                              'revelation_type': 'Meccan',
                            },
                            initialAyah: bm.ayahIndex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Gold bookmark icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.bookmark_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            // Surah + Ayah info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "সূরা ${bm.surahBangla}",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.emerald.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "আয়াত ${bm.ayahIndex}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppColors.emerald,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bm.arabicText.isNotEmpty
                                        ? bm.arabicText
                                        : bm.bnText,
                                    style: bm.arabicText.isNotEmpty
                                        ? TextStyle(
                                            fontFamily: 'Lateef',
                                            fontSize: 18,
                                            color: isDark
                                                ? AppColors.arabicDark
                                                : AppColors.arabicLight,
                                          )
                                        : GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: bm.arabicText.isNotEmpty
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                  if (bm.arabicText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      bm.bnText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmClearAll(BuildContext context, BookmarkService bookmarks) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("সব মুছবেন?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("সকল বুকমার্ক মুছে যাবে।",
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              for (int i = bookmarks.count - 1; i >= 0; i--) {
                bookmarks.removeAt(i);
              }
              Navigator.pop(ctx);
            },
            child: const Text("মুছুন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                size: 52, color: AppColors.gold),
          ),
          const SizedBox(height: 20),
          Text(
            "কোনো বুকমার্ক নেই",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "আয়াত পড়তে পড়তে ⭐ আইকন ট্যাপ করে\nবুকমার্ক সংরক্ষণ করুন",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
