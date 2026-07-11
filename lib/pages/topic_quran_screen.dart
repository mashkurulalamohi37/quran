import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/data/topic_quran_data.dart';
import 'package:quran/theme/app_theme.dart';

class TopicQuranScreen extends StatefulWidget {
  const TopicQuranScreen({super.key});

  @override
  State<TopicQuranScreen> createState() => _TopicQuranScreenState();
}

class _TopicQuranScreenState extends State<TopicQuranScreen> {
  String _selectedCategory = 'সব বিষয়';

  List<String> get _categories => [
        'সব বিষয়',
        'ঈমান ও আকীদা',
        'ইবাদত ও আমল',
        'পারিবারিক জীবন',
        'চরিত্র ও নৈতিকতা',
      ];

  List<QuranTopic> get _filteredTopics {
    if (_selectedCategory == 'সব বিষয়') return quranTopics;
    return quranTopics.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = _filteredTopics;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("বিষয়ভিত্তিক কুরআন"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Categories Horizontal Slider ──
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? AppColors.cardDark : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.emerald
                          : (isDark ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(16),
                      border: isSel
                          ? null
                          : Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Topics List ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              itemBuilder: (ctx, i) {
                final topic = topics[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(topic.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(
                      topic.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${topic.verses.length} টি আয়াত  •  ${topic.category}",
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.emerald),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _TopicDetailsScreen(topic: topic, isDark: isDark),
                      ),
                    ),
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

// ── Detailed Topic Screen ──
class _TopicDetailsScreen extends StatefulWidget {
  final QuranTopic topic;
  final bool isDark;
  const _TopicDetailsScreen({required this.topic, required this.isDark});

  @override
  State<_TopicDetailsScreen> createState() => _TopicDetailsScreenState();
}

class _TopicDetailsScreenState extends State<_TopicDetailsScreen> {
  bool _loading = true;
  final List<Map<String, String>> _loadedVerses = [];

  @override
  void initState() {
    super.initState();
    _loadAllVerses();
  }

  Future<void> _loadAllVerses() async {
    try {
      final List<Map<String, String>> verses = [];
      // Cache loaded surahs to avoid repeated rootBundle requests
      final Map<int, List<dynamic>> cachedSurahs = {};

      for (final ref in widget.topic.verses) {
        if (!cachedSurahs.containsKey(ref.surahId)) {
          final jsonStr = await rootBundle.loadString("assets/quran/${ref.surahId}.json");
          cachedSurahs[ref.surahId] = json.decode(jsonStr) as List;
        }

        final surahData = cachedSurahs[ref.surahId]!;
        final verseMap = surahData[0]['verse'] as Map<String, dynamic>;
        final verseBnMap = surahData[0]['verse_bn'] as Map<String, dynamic>;
        final verseEnMap = surahData[0]['verse_en'] as Map<String, dynamic>;

        final ar = verseMap['verse_${ref.ayahNumber}'] as String? ?? '';
        final bn = verseBnMap['verse_${ref.ayahNumber}'] as String? ?? '';
        final en = verseEnMap['verse_${ref.ayahNumber}'] as String? ?? '';

        verses.add({
          'surahId': ref.surahId.toString(),
          'ayah': ref.ayahNumber.toString(),
          'arabic': ar,
          'bangla': bn,
          'english': en,
          'note': ref.note,
        });
      }

      if (mounted) {
        setState(() {
          _loadedVerses.addAll(verses);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _toBengaliNum(String s) {
    const digits = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    return s.split('').map((c) {
      final idx = int.tryParse(c);
      return idx != null ? digits[idx] : c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(topic.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _loadedVerses.length,
              itemBuilder: (ctx, i) {
                final v = _loadedVerses[i];
                final referenceStr = "সূরা ${_toBengaliNum(v['surahId']!)}: ${_toBengaliNum(v['ayah']!)}";

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                referenceStr,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                              onPressed: () {
                                Share.share(
                                  "${v['arabic']}\n\nঅনুবাদ: ${v['bangla']}\n\n[$referenceStr]",
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Arabic text
                        Text(
                          v['arabic']!,
                          style: const TextStyle(
                            fontFamily: 'Lateef',
                            fontSize: 28,
                            color: AppColors.emeraldDark,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 12),

                        // Bangla translation
                        Text(
                          v['bangla']!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // English translation
                        Text(
                          v['english']!,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        // Note if any
                        if (v['note']!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.gold),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    v['note']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: isDark ? AppColors.goldLight : Colors.brown.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
