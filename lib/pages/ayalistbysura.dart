import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/services/audio_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/theme/app_theme.dart';

class AyaListBySura extends StatefulWidget {
  final dynamic suraInfo;
  final int initialAyah;

  const AyaListBySura(this.suraInfo, {super.key, this.initialAyah = 1});

  @override
  AyaListByState createState() => AyaListByState();
}

class AyaListByState extends State<AyaListBySura> {
  List<dynamic> _verseData = [];
  int _ayahCount = 0;
  bool _showArabic = true;
  bool _showBangla = true;
  bool _showEnglish = true;
  late ScrollController _scrollController;
  int _lastReadAyah = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lastReadAyah = widget.initialAyah;
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _saveLastRead(_lastReadAyah);
    super.dispose();
  }

  Future<void> _loadData() async {
    final jsonStr = await rootBundle
        .loadString("assets/quran/${widget.suraInfo['id']}.json");
    setState(() {
      _verseData = json.decode(jsonStr) as List;
      var count = (widget.suraInfo['total_verses'] as int?) ?? 0;
      if (count == 0 && _verseData.isNotEmpty) {
        try {
          final versesMap = _verseData[0]['verse'] as Map<String, dynamic>;
          count = versesMap.length;
        } catch (_) {}
      }
      _ayahCount = count;
    });
    // Scroll to initial ayah after data loads
    if (widget.initialAyah > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final offset = (widget.initialAyah - 1) * 280.0;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _saveLastRead(int ayahIndex) {
    final settings = context.read<SettingsService>();
    if (settings.lastReadSurahId != widget.suraInfo['id'] || settings.lastReadAyahIndex != ayahIndex) {
      settings.saveLastRead(
        surahId: widget.suraInfo['id'] as int,
        ayahIndex: ayahIndex,
        surahName: widget.suraInfo['name'] as String? ?? '',
        surahBangla: widget.suraInfo['bangla_name'] as String? ?? '',
      );
      settings.incrementAyahsRead(surahId: widget.suraInfo['id'] as int);
    }
  }

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

  String _getArabic(int ayah) {
    if (_verseData.isEmpty) return '';
    return (_verseData[0]['verse']['verse_$ayah'] as String?) ?? '';
  }

  String _getBangla(int ayah) {
    if (_verseData.isEmpty) return '';
    return (_verseData[0]['verse_bn']['verse_$ayah'] as String?) ?? '';
  }

  String _getEnglish(int ayah) {
    if (_verseData.isEmpty) return '';
    return (_verseData[0]['verse_en']['verse_$ayah'] as String?) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsService>();
    final isDark = context.select<SettingsService, bool>((s) => s.isDarkMode);
    final arabicFontSize = context.select<SettingsService, double>((s) => s.arabicFontSize);
    final translationFontSize = context.select<SettingsService, double>((s) => s.translationFontSize);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveLastRead(_lastReadAyah);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "সূরা ${widget.suraInfo['bangla_name']}",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            // Font size
            IconButton(
              icon: const Icon(Icons.text_fields_rounded),
              onPressed: _showFontSizeSheet,
              tooltip: "ফন্ট সাইজ",
            ),
            // Dark mode
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: settings.toggleDarkMode,
            ),
            // Translation toggle menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.translate_rounded),
              color: isDark ? AppColors.surfaceDark : AppColors.emerald,
              offset: const Offset(0, 40),
              onSelected: (v) {
                setState(() {
                  switch (v) {
                    case 'all':
                      _showArabic = _showBangla = _showEnglish = true;
                      break;
                    case 'ar':
                      _showArabic = true;
                      _showBangla = _showEnglish = false;
                      break;
                    case 'arbn':
                      _showArabic = _showBangla = true;
                      _showEnglish = false;
                      break;
                    case 'aren':
                      _showArabic = _showEnglish = true;
                      _showBangla = false;
                      break;
                    case 'bn':
                      _showBangla = true;
                      _showArabic = _showEnglish = false;
                      break;
                    case 'en':
                      _showEnglish = true;
                      _showArabic = _showBangla = false;
                      break;
                  }
                });
              },
              itemBuilder: (_) => [
                _tMenuItem('all', 'সকল'),
                _tMenuItem('ar', 'শুধু আরবি'),
                _tMenuItem('arbn', 'আরবি + বাংলা'),
                _tMenuItem('aren', 'আরবি + ইংরেজি'),
                _tMenuItem('bn', 'শুধু বাংলা'),
                _tMenuItem('en', 'Only English'),
              ],
            ),
          ],
        ),
        body: _verseData.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollUpdateNotification) {
                    // Estimate current ayah from scroll position
                    final ayah = (_scrollController.offset / 280).floor() + 1;
                    if (ayah > 0 && ayah <= _ayahCount) {
                      _lastReadAyah = ayah;
                    }
                  }
                  return false;
                },
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,
                  thickness: 8,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                    itemCount: _ayahCount,
                    itemBuilder: (ctx, i) {
                      final ayah = i + 1;
                      return _VerseCard(
                        ayah: ayah,
                        surahId: widget.suraInfo['id'] as int,
                        totalAyahs: _ayahCount,
                        surahName: widget.suraInfo['name'] as String? ?? '',
                        surahBangla: widget.suraInfo['bangla_name'] as String? ?? '',
                        arabicText: _getArabic(ayah),
                        banglaText: _getBangla(ayah),
                        englishText: _getEnglish(ayah),
                        showArabic: _showArabic,
                        showBangla: _showBangla,
                        showEnglish: _showEnglish,
                        arabicFontSize: arabicFontSize,
                        translationFontSize: translationFontSize,
                        isDark: isDark,
                        onToast: _showToast,
                      );
                    },
                  ),
                ),
              ),
        bottomNavigationBar: Consumer<AudioService>(
          builder: (ctx, audio, _) {
            if (!audio.isActive) return const SizedBox.shrink();
            return _MiniAudioPlayer(
              audio: audio,
              surahBangla: widget.suraInfo['bangla_name'] as String? ?? '',
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _tMenuItem(String value, String label) =>
      PopupMenuItem<String>(
        value: value,
        child: Text(label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      );
}

// ─── Verse Card ───────────────────────────────────────────────────────────────

class _VerseCard extends StatelessWidget {
  final int ayah;
  final int surahId;
  final int totalAyahs;
  final String surahName;
  final String surahBangla;
  final String arabicText;
  final String banglaText;
  final String englishText;
  final bool showArabic;
  final bool showBangla;
  final bool showEnglish;
  final double arabicFontSize;
  final double translationFontSize;
  final bool isDark;
  final void Function(String) onToast;

  const _VerseCard({
    required this.ayah,
    required this.surahId,
    required this.totalAyahs,
    required this.surahName,
    required this.surahBangla,
    required this.arabicText,
    required this.banglaText,
    required this.englishText,
    required this.showArabic,
    required this.showBangla,
    required this.showEnglish,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.isDark,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkService>();
    final isBookmarked = bookmarks.isBookmarked(surahId, ayah);
    final audio = context.watch<AudioService>();
    final isCurrentPlaying = audio.isCurrentAyah(surahId, ayah);

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
        border: isCurrentPlaying
            ? Border.all(color: AppColors.emerald.withValues(alpha: 0.8), width: 2.0)
            : (isBookmarked
                ? Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.5)
                : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: Ayah number ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      colors: [AppColors.emerald, AppColors.emeraldLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$ayah',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "সূরা $surahBangla : $ayah",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.emerald,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Arabic ──
                if (showArabic && arabicText.isNotEmpty) ...[
                  Text(
                    arabicText,
                    style: TextStyle(
                      fontFamily: 'Lateef',
                      fontSize: arabicFontSize,
                      color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
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

                // ── English ──
                if (showEnglish && englishText.isNotEmpty) ...[
                  Text(
                    englishText,
                    style: GoogleFonts.poppins(
                      fontSize: translationFontSize - 2,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Bangla ──
                if (showBangla && banglaText.isNotEmpty)
                  Text(
                    banglaText,
                    style: GoogleFonts.poppins(
                      fontSize: translationFontSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.7,
                    ),
                  ),
              ],
            ),
          ),

          // ── Action row ──
          Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Play / Pause Audio
                Consumer<AudioService>(
                  builder: (ctx, audio, _) {
                    final isPlaying = audio.isPlayingAyah(surahId, ayah);
                    final isCurrent = audio.isCurrentAyah(surahId, ayah);
                    final isLoading = audio.isLoading && isCurrent;

                    return _ActionBtn(
                      icon: isLoading
                          ? Icons.hourglass_bottom_rounded
                          : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      tooltip: isPlaying ? "থামান" : "শুনুন",
                      isDark: isDark,
                      onTap: () {
                        if (isPlaying) {
                          audio.togglePlayPause();
                        } else {
                          audio.playAyah(
                            surahId: surahId,
                            ayahIndex: ayah,
                            maxAyah: totalAyahs,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 4),
                // Share
                _ActionBtn(
                  icon: Icons.share_rounded,
                  tooltip: "শেয়ার",
                  isDark: isDark,
                  onTap: () {
                    final text =
                        "সূরা $surahBangla ($surahId:$ayah)\n$arabicText\n$banglaText";
                    Share.share(text);
                  },
                ),
                const SizedBox(width: 4),
                // Copy Bangla
                _ActionBtn(
                  icon: Icons.content_copy_rounded,
                  tooltip: "কপি",
                  isDark: isDark,
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: "সূরা $surahBangla ($surahId:$ayah)\n$banglaText"));
                    onToast("আয়াত $ayah কপি হয়েছে");
                  },
                ),
                const SizedBox(width: 4),
                // Bookmark
                _ActionBtn(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip: isBookmarked ? "বুকমার্ক সরান" : "বুকমার্ক করুন",
                  color: isBookmarked ? AppColors.gold : null,
                  isDark: isDark,
                  onTap: () {
                    context.read<BookmarkService>().toggleBookmark(
                          Bookmark(
                            surahId: surahId,
                            surahName: surahName,
                            surahBangla: surahBangla,
                            ayahIndex: ayah,
                            arabicText: arabicText,
                            bnText: banglaText,
                          ),
                        );
                    onToast(isBookmarked
                        ? "বুকমার্ক সরানো হয়েছে"
                        : "বুকমার্ক করা হয়েছে ⭐");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.isDark,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
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
            color: color ?? (isDark ? AppColors.goldLight : AppColors.emerald),
          ),
        ),
      ),
    );
  }
}

// ─── Mini Audio Player ────────────────────────────────────────────────────────

class _MiniAudioPlayer extends StatelessWidget {
  final AudioService audio;
  final String surahBangla;
  final bool isDark;

  const _MiniAudioPlayer({
    required this.audio,
    required this.surahBangla,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            audio.isPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
            color: AppColors.emerald,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "সূরা $surahBangla",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  "আয়াত ${audio.currentAyahIndex}",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            color: isDark ? Colors.white70 : Colors.black87,
            onPressed: audio.currentAyahIndex > 1 ? audio.playPrevious : null,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
              ),
              child: Icon(
                audio.isLoading
                    ? Icons.hourglass_bottom_rounded
                    : (audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: audio.togglePlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            color: isDark ? Colors.white70 : Colors.black87,
            onPressed: audio.playNext,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: Colors.redAccent,
            onPressed: audio.stop,
          ),
        ],
      ),
    );
  }
}
