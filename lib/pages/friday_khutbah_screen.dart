import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/audio_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class FridayKhutbahScreen extends StatefulWidget {
  const FridayKhutbahScreen({super.key});

  @override
  State<FridayKhutbahScreen> createState() => _FridayKhutbahScreenState();
}

class _FridayKhutbahScreenState extends State<FridayKhutbahScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Player state subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Local state variables
  int? _playingIndex;
  bool _isPlaying = false;
  ProcessingState _processingState = ProcessingState.idle;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String _searchQuery = "";
  String _selectedCategory = "সব";

  final List<Map<String, dynamic>> _allKhutbahs = [
    {
      'title': 'জুমার দিনের ফজিলত ও জুমার আদব',
      'khatib': 'শাইখ মিজানুর রহমান আজহারী',
      'category': 'ঈমান ও আমল',
      'duration': '২২:১৪',
      'url': 'https://archive.org/download/CharacteristicsOfTheMunafiqbanglaTranslation/CharacteristicsOfTheMunafiqbanglaTranslation.mp3',
      'description': 'জুমার দিনের বিশেষ ফজিলত, গুরুত্ব, দোয়া কবুলের বিশেষ সময় এবং জুমার খুতবা শোনার আদবসমূহ সম্পর্কে আলোচনা।'
    },
    {
      'title': 'তাকওয়া ও মুমিনের প্রকৃত বৈশিষ্ট্য',
      'khatib': 'মুফতি তারেক জামিল (অনূদিত)',
      'category': 'ঈমান ও আমল',
      'duration': '১৫:৪৫',
      'url': 'https://archive.org/download/Quran-Translation-In-Bengali/001.mp3',
      'description': 'তাকওয়া বা খোদাভীতি অর্জনের উপায় এবং একজন প্রকৃত মুমিনের দৈনন্দিন জীবনের গুণাবলী সম্পর্কে গুরুত্বপূর্ণ দিকনির্দেশনা।'
    },
    {
      'title': 'পিতা-মাতার প্রতি সন্তানের দায়িত্ব ও অধিকার',
      'khatib': 'শাইখ আহমাদুল্লাহ',
      'category': 'পরিবার ও সমাজ',
      'duration': '১৮:৩০',
      'url': 'https://archive.org/download/Quran-Translation-In-Bengali/103.mp3',
      'description': 'ইসলামে পিতা-মাতার অপরিসীম মর্যাদা, তাদের অধিকার এবং তাদের অবাধ্যতার মারাত্মক পরিণতি নিয়ে আলোচনা।'
    },
    {
      'title': 'হালাল রুজি ও ইবাদত কবুলের পূর্বশর্ত',
      'khatib': 'মুফতি মোস্তফা কামাল',
      'category': 'পরিবার ও সমাজ',
      'duration': '১৪:২০',
      'url': 'https://archive.org/download/Quran-Translation-In-Bengali/107.mp3',
      'description': 'জীবন ও উপার্জনে বারাকাহ অর্জনে হালাল রুজির গুরুত্ব এবং বর্তমান সমাজে হারাম রুজির বিস্তার ও কুফল।'
    },
    {
      'title': 'বিপদ-আপদে ধৈর্য ও আল্লাহর ওপর তাওয়াক্কুল',
      'khatib': 'মাওলানা নোমান আলী খান (অনূদিত)',
      'category': 'আখলাক ও উপদেশ',
      'duration': '১২:১০',
      'url': 'https://archive.org/download/Quran-Translation-In-Bengali/110.mp3',
      'description': 'জীবনের কঠিনতম সময়ে কীভাবে নিজেকে নিয়ন্ত্রণ করতে হয় এবং আল্লাহর ওপর অবিচল আস্থা ও ভরসা রাখা যায়।'
    },
    {
      'title': 'মিথ্যা ও গীবতের ভয়াবহতা ও মুখের হেফাজত',
      'khatib': 'শাইখ আব্দুল কাইয়ুম',
      'category': 'আখলাক ও উপদেশ',
      'duration': '১৬:০৫',
      'url': 'https://archive.org/download/Quran-Translation-In-Bengali/112.mp3',
      'description': 'মুখের হেফাজত করা, গীবত ও পরনিন্দা থেকে দূরে থাকা এবং সত্যবাদিতার মাধ্যমে চরিত্র গঠনের উপায়।'
    }
  ];

  final List<String> _categories = ["সব", "ঈমান ও আমল", "পরিবার ও সমাজ", "আখলাক ও উপদেশ"];

  @override
  void initState() {
    super.initState();
    
    // Subscribe to player state changes
    _positionSubscription = _audioPlayer.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _durationSubscription = _audioPlayer.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _processingState = state.processingState;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playKhutbah(int index, String url) async {
    // 1. Stop Quran audio playback to avoid overlapping sounds
    Provider.of<AudioService>(context, listen: false).stop();

    if (_playingIndex == index) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } else {
      setState(() {
        _playingIndex = index;
        _position = Duration.zero;
        _duration = Duration.zero;
      });

      try {
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('অডিও লোড করতে সমস্যা হয়েছে। দয়া করে আপনার ইন্টারনেট কানেকশন চেক করুন।')),
          );
        }
      }
    }
  }

  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _skip10Seconds(bool forward) async {
    final newPosition = forward 
        ? _position + const Duration(seconds: 10) 
        : _position - const Duration(seconds: 10);
    
    if (newPosition < Duration.zero) {
      await _seek(Duration.zero);
    } else if (newPosition > _duration) {
      await _seek(_duration);
    } else {
      await _seek(newPosition);
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _playingIndex = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;
    final isTodayFriday = DateTime.now().weekday == DateTime.friday;

    // Filter khutbahs based on search query and selected category
    final filteredKhutbahs = _allKhutbahs.asMap().entries.where((entry) {
      final khutbah = entry.value;
      final matchesSearch = khutbah['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          khutbah['khatib']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          khutbah['description']!.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == "সব" || khutbah['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("জুমার খুতবা ও আলোচনা"),
        actions: [
          if (_playingIndex != null)
            IconButton(
              icon: const Icon(Icons.stop_rounded, color: Colors.white),
              tooltip: 'বন্ধ করুন',
              onPressed: _stopPlayback,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Friday special status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [const Color(0xFF0F2C15), const Color(0xFF081C0E)]
                        : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded, 
                      color: isDark ? AppColors.goldLight : AppColors.emerald,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTodayFriday 
                            ? "আজ পবিত্র জুমাবার! জুমার খুতবা ও আমল মনোযোগ দিয়ে শুনুন।"
                            : "জুমার প্রস্তুতি এবং অন্যান্য গুরুত্বপূর্ণ দিনের খুতবা এখান থেকে শুনুন।",
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.emeraldDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "খুতবা বা বক্তার নাম খুঁজুন...",
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.emerald),
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Category filters
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        selectedColor: AppColors.emerald,
                        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected 
                                ? AppColors.emerald 
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Khutbah list
              Expanded(
                child: filteredKhutbahs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              "কোনো খুতবা পাওয়া যায়নি।",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        itemCount: filteredKhutbahs.length,
                        itemBuilder: (ctx, i) {
                          final idx = filteredKhutbahs[i].key;
                          final khutbah = filteredKhutbahs[i].value;
                          final isCurrent = _playingIndex == idx;
                          final isLoading = isCurrent && _processingState == ProcessingState.loading;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCurrent 
                                    ? AppColors.emerald.withValues(alpha: 0.5) 
                                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                width: isCurrent ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Play / Loading button
                                GestureDetector(
                                  onTap: () => _playKhutbah(idx, khutbah['url']!),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isCurrent 
                                          ? AppColors.emerald.withValues(alpha: 0.12)
                                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                                            ),
                                          )
                                        : Icon(
                                            isCurrent && _isPlaying 
                                                ? Icons.pause_rounded 
                                                : Icons.play_arrow_rounded,
                                            color: isCurrent 
                                                ? AppColors.emerald 
                                                : (isDark ? Colors.white70 : Colors.black87),
                                            size: 26,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.emerald.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              khutbah['category']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.emerald,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded, 
                                                size: 11, 
                                                color: isDark ? Colors.white38 : Colors.black38,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                khutbah['duration']!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: isDark ? Colors.white38 : Colors.black38,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        khutbah['title']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        khutbah['khatib']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.emerald,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        khutbah['description']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          height: 1.4,
                                        ),
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
            ],
          ),

          // Mini Player Controller at bottom
          if (_playingIndex != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linear buffer / progress slider bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  activeTrackColor: AppColors.emerald,
                                  inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  thumbColor: AppColors.emerald,
                                  overlayColor: AppColors.emerald.withValues(alpha: 0.15),
                                ),
                                child: Slider(
                                  value: _position.inMilliseconds.toDouble(),
                                  max: _duration.inMilliseconds > 0 
                                      ? _duration.inMilliseconds.toDouble() 
                                      : 1.0,
                                  onChanged: (value) {
                                    _seek(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Player main control bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            // Metadata details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _allKhutbahs[_playingIndex!]['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _allKhutbahs[_playingIndex!]['khatib']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: AppColors.emerald,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Controls (Prev10, Play/Pause, Next10, Stop)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10_rounded),
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  iconSize: 22,
                                  tooltip: '১০ সেকেন্ড পেছনে',
                                  onPressed: () => _skip10Seconds(false),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.emerald,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isPlaying 
                                          ? Icons.pause_rounded 
                                          : Icons.play_arrow_rounded,
                                    ),
                                    color: Colors.white,
                                    iconSize: 22,
                                    onPressed: () => _playKhutbah(_playingIndex!, _allKhutbahs[_playingIndex!]['url']!),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10_rounded),
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  iconSize: 22,
                                  tooltip: '১০ সেকেন্ড সামনে',
                                  onPressed: () => _skip10Seconds(true),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  color: Colors.redAccent,
                                  iconSize: 22,
                                  tooltip: 'বন্ধ করুন',
                                  onPressed: _stopPlayback,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
