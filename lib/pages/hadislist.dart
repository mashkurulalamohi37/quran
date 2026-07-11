import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class HadisList extends StatefulWidget {
  const HadisList({super.key});
  @override
  HadisListState createState() => HadisListState();
}

class HadisListState extends State<HadisList> {
  List<dynamic> _hadisData = [];
  static const int _totalHadis = 42;
  bool _showArabic = true;
  bool _showBangla = true;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final raw = await rootBundle.loadString("assets/40hadis/40.json");
    setState(() {
      _hadisData = json.decode(raw) as List;
    });
  }

  String _getArabic(int i) {
    if (_hadisData.isEmpty) return '';
    return (_hadisData[0]['verse']['verse_$i'] as String?) ?? '';
  }

  String _getBangla(int i) {
    if (_hadisData.isEmpty) return '';
    return (_hadisData[0]['verse_bn']['verse_$i'] as String?) ?? '';
  }

  bool _isSahih(int i) => i != 30;

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.emerald,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Consumer<SettingsService>(
        builder: (ctx, settings, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ফন্ট সাইজ",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 20),
              Text("আরবি টেক্সট: ${settings.arabicFontSize.round()}",
                  style: GoogleFonts.poppins(fontSize: 13)),
              Slider(
                value: settings.arabicFontSize,
                min: 24,
                max: 60,
                divisions: 18,
                activeColor: AppColors.emerald,
                label: settings.arabicFontSize.round().toString(),
                onChanged: settings.setArabicFontSize,
              ),
              Text("অনুবাদ টেক্সট: ${settings.translationFontSize.round()}",
                  style: GoogleFonts.poppins(fontSize: 13)),
              Slider(
                value: settings.translationFontSize,
                min: 12,
                max: 28,
                divisions: 16,
                activeColor: AppColors.emeraldLight,
                label: settings.translationFontSize.round().toString(),
                onChanged: settings.setTranslationFontSize,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("৪০ হাদিস"),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: _showFontSizeSheet,
            tooltip: "ফন্ট সাইজ",
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: settings.toggleDarkMode,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate_rounded),
            color: isDark ? AppColors.surfaceDark : AppColors.emerald,
            onSelected: (v) {
              setState(() {
                switch (v) {
                  case 'all':
                    _showArabic = _showBangla = true;
                    break;
                  case 'ar':
                    _showArabic = true;
                    _showBangla = false;
                    break;
                  case 'bn':
                    _showBangla = true;
                    _showArabic = false;
                    break;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'all',
                  child: Text("আরবি + বাংলা",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
              PopupMenuItem(
                  value: 'ar',
                  child: Text("শুধু আরবি",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
              PopupMenuItem(
                  value: 'bn',
                  child: Text("শুধু বাংলা",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13))),
            ],
          ),
        ],
      ),
      body: _hadisData.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
          : Builder(
              builder: (context) {
                final matchingIndices = <int>[];
                for (int i = 1; i <= _totalHadis; i++) {
                  final arabic = _getArabic(i);
                  final bangla = _getBangla(i);
                  final numStr = i.toString();
                  if (_searchQuery.isEmpty ||
                      arabic.toLowerCase().contains(_searchQuery) ||
                      bangla.toLowerCase().contains(_searchQuery) ||
                      numStr.contains(_searchQuery)) {
                    matchingIndices.add(i);
                  }
                }

                return Column(
                  children: [
                    Container(
                      color: isDark ? AppColors.emeraldDark : AppColors.emerald,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _searchCtrl,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "হাদিস খুঁজুন...",
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
                    Expanded(
                      child: matchingIndices.isEmpty
                          ? Center(
                              child: Text(
                                "কোনো হাদিস পাওয়া যায়নি",
                                style: GoogleFonts.poppins(color: Colors.grey),
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
                                padding: const EdgeInsets.all(12),
                                itemCount: matchingIndices.length,
                                itemBuilder: (ctx, i) {
                                  final hadisNum = matchingIndices[i];
                final arabic = _getArabic(hadisNum);
                final bangla = _getBangla(hadisNum);
                final isSahih = _isSahih(hadisNum);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.emeraldDark.withValues(alpha: 0.6)
                              : AppColors.emerald.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1A237E),
                                    Color(0xFF283593)
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$hadisNum',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "হাদিস নং $hadisNum",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.emerald,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSahih
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSahih
                                      ? Colors.green.withValues(alpha: 0.4)
                                      : Colors.orange.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                isSahih ? "সহিহ" : "নির্নিত নয়",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSahih ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Content ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_showArabic && arabic.isNotEmpty) ...[
                              Text(
                                arabic,
                                style: TextStyle(
                                  fontFamily: 'Lateef',
                                  fontSize: settings.arabicFontSize,
                                  color: isDark
                                      ? AppColors.arabicDark
                                      : AppColors.arabicLight,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.white12
                                    : AppColors.emerald.withValues(alpha: 0.12),
                                height: 20,
                              ),
                            ],
                            if (_showBangla && bangla.isNotEmpty)
                              Text(
                                bangla,
                                style: GoogleFonts.poppins(
                                  fontSize: settings.translationFontSize,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  height: 1.7,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Actions ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionBtn(
                              icon: Icons.share_rounded,
                              isDark: isDark,
                              onTap: () => Share.share(
                                  "হাদিস $hadisNum\n$arabic\n$bangla"),
                            ),
                            const SizedBox(width: 4),
                            _actionBtn(
                              icon: Icons.content_copy_rounded,
                              isDark: isDark,
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: "$arabic\n$bangla"));
                                _showToast("হাদিস $hadisNum কপি হয়েছে");
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
),
    );
  }

  Widget _actionBtn(
      {required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.emerald.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.goldLight : AppColors.emerald,
        ),
      ),
    );
  }
}
