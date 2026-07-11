import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/data/prophets_data.dart';
import 'package:quran/theme/app_theme.dart';

class ProphetsScreen extends StatelessWidget {
  const ProphetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("নবীদের কাহিনী ও সীরাত"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prophetsStories.length,
        itemBuilder: (ctx, i) {
          final story = prophetsStories[i];
          final isMuhammad = story.name.contains("মুহাম্মদ");

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: isMuhammad
                  ? Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 2)
                  : Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: (isMuhammad ? AppColors.gold : Colors.black)
                      .withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ProphetDetailScreen(story: story, isDark: isDark),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMuhammad) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.gold, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  "সর্বশ্রেষ্ঠ রাসূল ও সীরাতুন্নবী",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isMuhammad
                                          ? (isDark ? AppColors.goldLight : Colors.brown.shade800)
                                          : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    story.period,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              story.arabicName,
                              style: const TextStyle(
                                fontFamily: 'Lateef',
                                fontSize: 24,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          story.summary,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "কাহিনী পড়ুন →",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Detail Story Screen ──
class _ProphetDetailScreen extends StatelessWidget {
  final ProphetStory story;
  final bool isDark;
  const _ProphetDetailScreen({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMuhammad = story.name.contains("মুহাম্মদ");

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Beautiful Custom Header ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            title: Text(
              story.name,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: isMuhammad ? const Color(0xFF1B5E20) : AppColors.emeraldDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isMuhammad
                        ? [const Color(0xFF0F3D13), const Color(0xFF1B5E20)]
                        : [const Color(0xFF004D40), AppColors.emeraldDark],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      story.arabicName,
                      style: const TextStyle(
                        fontFamily: 'Lateef',
                        fontSize: 32,
                        color: AppColors.goldLight,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        story.period,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Story Chapters (Sections) ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final section = story.sections[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                            const Icon(Icons.menu_book_rounded, color: AppColors.emerald, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                section.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          section.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            height: 1.8,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: story.sections.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
