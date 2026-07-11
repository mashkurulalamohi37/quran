import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/pages/ayalistbysura.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class _SearchResult {
  final int surahId;
  final String surahBangla;
  final String surahName;
  final String transliteration;
  final int ayahIndex;
  final String arabicText;
  final String banglaText;
  final String englishText;

  const _SearchResult({
    required this.surahId,
    required this.surahBangla,
    required this.surahName,
    required this.transliteration,
    required this.ayahIndex,
    required this.arabicText,
    required this.banglaText,
    required this.englishText,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<dynamic> _suraList = [];
  // Cache: surahId → verse data
  final Map<int, dynamic> _verseCache = {};
  List<_SearchResult> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _loadSuraList();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSuraList() async {
    final raw = await rootBundle.loadString('assets/sura_list.json');
    _suraList = json.decode(raw) as List;
  }

  Future<dynamic> _loadSurahVerses(int surahId) async {
    if (_verseCache.containsKey(surahId)) return _verseCache[surahId];
    final raw = await rootBundle.loadString('assets/quran/$surahId.json');
    final data = json.decode(raw) as List;
    _verseCache[surahId] = data;
    return data;
  }

  Future<void> _search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    setState(() {
      _loading = true;
      _results = [];
      _searched = true;
    });

    final found = <_SearchResult>[];

    for (final sura in _suraList) {
      final id = sura['id'] as int;
      final totalVerses = sura['total_verses'] as int;
      try {
        final data = await _loadSurahVerses(id);
        if (data.isEmpty) continue;
        final verseObj = data[0];

        for (int i = 1; i <= totalVerses; i++) {
          final bn = (verseObj['verse_bn']['verse_$i'] as String?) ?? '';
          final en = (verseObj['verse_en']['verse_$i'] as String?) ?? '';
          final ar = (verseObj['verse']['verse_$i'] as String?) ?? '';

          if (bn.toLowerCase().contains(q) || en.toLowerCase().contains(q)) {
            found.add(_SearchResult(
              surahId: id,
              surahBangla: sura['bangla_name'] as String,
              surahName: sura['name'] as String,
              transliteration: sura['transliteration_en'] as String,
              ayahIndex: i,
              arabicText: ar,
              banglaText: bn,
              englishText: en,
            ));
            if (found.length >= 100) break;
          }
        }
        if (found.length >= 100) break;
      } catch (_) {
        continue;
      }
    }

    if (mounted) {
      setState(() {
        _results = found;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: "বাংলা বা ইংরেজিতে আয়াত খুঁজুন...",
            hintStyle:
                GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {
                        _results = [];
                        _searched = false;
                      });
                    },
                  )
                : null,
          ),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _search(_ctrl.text),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.emerald),
            const SizedBox(height: 16),
            Text(
              "অনুসন্ধান করা হচ্ছে...",
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (!_searched) {
      return _InitialHint(isDark: isDark);
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              "'${_ctrl.text}' এর জন্য কোনো ফলাফল নেই",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: isDark ? AppColors.cardDark : const Color(0xFFF0F7F0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppColors.emerald),
              const SizedBox(width: 6),
              Text(
                "${_results.length} টি ফলাফল পাওয়া গেছে${_results.length >= 100 ? " (প্রথম ১০০)" : ""}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.emerald,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _results.length,
            itemBuilder: (ctx, i) =>
                _ResultCard(result: _results[i], query: _ctrl.text, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

// ─── Initial hint ─────────────────────────────────────────────────────────────

class _InitialHint extends StatelessWidget {
  final bool isDark;
  const _InitialHint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.manage_search_rounded,
                  size: 48, color: AppColors.emerald),
            ),
            const SizedBox(height: 20),
            Text(
              "আয়াত অনুসন্ধান",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "বাংলা অনুবাদ বা ইংরেজি অনুবাদ দিয়ে\nসব ১১৪ সূরার মধ্যে আয়াত খুঁজুন।",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _chip("সবর", isDark),
                _chip("prayer", isDark),
                _chip("রহমত", isDark),
                _chip("জান্নাত", isDark),
                _chip("mercy", isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool isDark) {
    return Builder(
      builder: (ctx) => GestureDetector(
        onTap: () {
          final state = ctx.findAncestorStateOfType<SearchScreenState>();
          state?._ctrl.text = label;
          state?._search(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.emerald,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Result Card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final _SearchResult result;
  final String query;
  final bool isDark;

  const _ResultCard({
    required this.result,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AyaListBySura(
            {
              'id': result.surahId,
              'number': result.surahId.toString(),
              'bangla_name': result.surahBangla,
              'name': result.surahName,
              'transliteration_en': result.transliteration,
              'total_verses': 286,
              'total_verses_b': '',
              'revelation_type': 'Meccan',
            },
            initialAyah: result.ayahIndex,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "সূরা ${result.surahBangla} : ${result.ayahIndex}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            // Arabic
            if (result.arabicText.isNotEmpty)
              Text(
                result.arabicText,
                style: TextStyle(
                  fontFamily: 'Lateef',
                  fontSize: 22,
                  color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
              ),
            const SizedBox(height: 6),
            // Highlighted Bangla
            _HighlightedText(
              text: result.banglaText,
              query: query,
              isDark: isDark,
              fontSize: 13,
            ),
            if (result.englishText.isNotEmpty) ...[
              const SizedBox(height: 4),
              _HighlightedText(
                text: result.englishText,
                query: query,
                isDark: isDark,
                fontSize: 12,
                secondary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final bool isDark;
  final double fontSize;
  final bool secondary;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.isDark,
    required this.fontSize,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final idx = lower.indexOf(q);

    if (idx == -1 || q.isEmpty) {
      return Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: secondary
              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      );
    }

    final before = text.substring(0, idx);
    final match = text.substring(idx, idx + query.length);
    final after = text.substring(idx + query.length);

    return Text.rich(
      TextSpan(
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: secondary
              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: const TextStyle(
              backgroundColor: Color(0x33F9A825),
              color: AppColors.goldDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
