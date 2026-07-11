import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/pages/ayalistbysura.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class SuraList extends StatefulWidget {
  const SuraList({super.key});
  @override
  SuraListState createState() => SuraListState();
}

class SuraListState extends State<SuraList> {
  List<dynamic> _allSurahs = [];
  List<dynamic> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final jsonString = await rootBundle.loadString('assets/sura_list.json');
    final list = json.decode(jsonString) as List;
    setState(() {
      _allSurahs = list;
      _filtered = list;
    });
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _allSurahs;
      } else {
        _filtered = _allSurahs.where((s) {
          return s['bangla_name'].toString().toLowerCase().contains(q) ||
              s['transliteration_en'].toString().toLowerCase().contains(q) ||
              s['translation_en'].toString().toLowerCase().contains(q) ||
              s['number'].toString().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text("সূরাসমূহ"),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white70,
            ),
            onPressed: context.read<SettingsService>().toggleDarkMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Container(
            color: isDark ? AppColors.emeraldDark : AppColors.emerald,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: "সূরা খুঁজুন...",
                hintStyle: GoogleFonts.poppins(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Count strip ──
          Container(
            color: isDark ? AppColors.cardDark : const Color(0xFFF0F7F0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.library_books_rounded, size: 16, color: AppColors.emerald),
                const SizedBox(width: 6),
                Text(
                  _searchCtrl.text.isEmpty
                      ? "মোট ${_allSurahs.length} টি সূরা"
                      : "${_filtered.length} টি ফলাফল",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.emerald,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Surah List ──
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text("কোনো ফলাফল পাওয়া যায়নি",
                            style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 8,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _SurahCard(
                        surah: _filtered[i],
                        isDark: isDark,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Surah Card ───────────────────────────────────────────────────────────────

class _SurahCard extends StatelessWidget {
  final dynamic surah;
  final bool isDark;
  const _SurahCard({required this.surah, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMeccan = surah['revelation_type'] == 'Meccan';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AyaListBySura(surah)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // ── Number badge ──
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    surah['number'] ?? '${surah['id']}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Bangla name + verse count ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "সূরা ${surah['bangla_name']}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          surah['transliteration_en'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("•",
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)),
                        const SizedBox(width: 6),
                        Text(
                          "${surah['total_verses_b']} আয়াত",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Right side: Arabic + chip ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surah['name'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Lateef',
                      fontSize: 22,
                      color: AppColors.emeraldLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMeccan
                          ? AppColors.makkiColor.withValues(alpha: 0.15)
                          : AppColors.madinaBg.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMeccan
                            ? AppColors.makkiColor.withValues(alpha: 0.4)
                            : AppColors.madinaBg.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isMeccan ? "মক্কী" : "মাদানী",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isMeccan ? AppColors.makkiColor : AppColors.madinaBg,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
