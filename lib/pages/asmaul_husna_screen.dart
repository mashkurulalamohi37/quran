import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/data/asmaul_husna_data.dart';
import 'package:quran/theme/app_theme.dart';

class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  List<AsmaName> get _filtered {
    if (_search.isEmpty) return asmaulHusna;
    final q = _search.toLowerCase();
    return asmaulHusna.where((n) =>
        n.transliteration.toLowerCase().contains(q) ||
        n.bengali.toLowerCase().contains(q) ||
        n.meaning.toLowerCase().contains(q) ||
        n.arabic.contains(_search)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Beautiful SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.emeraldDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'أَسْمَاءُ اللَّهِ الْحُسْنَى',
                        style: const TextStyle(
                          fontFamily: 'Lateef',
                          fontSize: 34,
                          color: AppColors.goldLight,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'আসমাউল হুসনা — আল্লাহর ৯৯টি নাম',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '"যে ব্যক্তি এই নামগুলো মুখস্থ করবে, সে জান্নাতে প্রবেশ করবে।"',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 44), // Pushes the texts up to prevent overlap with the title
                    ],
                  ),
                ),
              ),
              title: Text('আসমাউল হুসনা',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 12),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'নাম অনুসন্ধান করুন...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.emerald),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Counter badge ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${filtered.length} টি নাম',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),

          // ── Grid of name cards ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _NameCard(name: filtered[i], isDark: isDark),
                childCount: filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Individual Name Card ────────────────────────────────────────────────────
class _NameCard extends StatelessWidget {
  final AsmaName name;
  final bool isDark;
  const _NameCard({required this.name, required this.isDark});

  // Generate unique color per name based on number
  Color get _accentColor {
    const colors = [
      Color(0xFF1B5E20), Color(0xFF0D47A1), Color(0xFF4A148C),
      Color(0xFF880E4F), Color(0xFF1A237E), Color(0xFF004D40),
      Color(0xFF3E2723), Color(0xFF006064), Color(0xFF33691E),
    ];
    return colors[(name.number - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _NameDetailScreen(name: name, isDark: isDark),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _accentColor,
              _accentColor.withValues(alpha: 0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${name.number}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Arabic name
              Text(
                name.arabic,
                style: const TextStyle(
                  fontFamily: 'Lateef',
                  fontSize: 26,
                  color: AppColors.goldLight,
                  height: 1.3,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Bengali meaning
              Text(
                name.meaning,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                name.transliteration,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Screen ───────────────────────────────────────────────────────────
class _NameDetailScreen extends StatefulWidget {
  final AsmaName name;
  final bool isDark;
  const _NameDetailScreen({required this.name, required this.isDark});

  @override
  State<_NameDetailScreen> createState() => _NameDetailScreenState();
}

class _NameDetailScreenState extends State<_NameDetailScreen>
    with SingleTickerProviderStateMixin {
  int _dhikrCount = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  static const int _target = 100;

  @override
  void initState() {
    super.initState();
    _loadCount();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dhikrCount = prefs.getInt('asma_dhikr_${widget.name.number}') ?? 0;
    });
  }

  Future<void> _increment() async {
    HapticFeedback.lightImpact();
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
    final newCount = _dhikrCount + 1;
    setState(() => _dhikrCount = newCount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('asma_dhikr_${widget.name.number}', newCount);
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('গণনা রিসেট করবেন?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('এই নামের ধিকর গণনা শূন্যে ফিরে যাবে।',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('না', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('হ্যাঁ', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _dhikrCount = 0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('asma_dhikr_${widget.name.number}', 0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _accent {
    const colors = [
      Color(0xFF1B5E20), Color(0xFF0D47A1), Color(0xFF4A148C),
      Color(0xFF880E4F), Color(0xFF1A237E), Color(0xFF004D40),
      Color(0xFF3E2723), Color(0xFF006064), Color(0xFF33691E),
    ];
    return colors[(widget.name.number - 1) % colors.length];
  }

  double get _progress => (_dhikrCount % _target) / _target;

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _accent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${name.number}. ${name.transliteration}',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: _reset,
                tooltip: 'রিসেট',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Top card: Arabic name ──────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent, _accent.withValues(alpha: 0.8)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                  child: Column(
                    children: [
                      Text(
                        name.arabic,
                        style: const TextStyle(
                          fontFamily: 'Lateef',
                          fontSize: 64,
                          color: AppColors.goldLight,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 10)],
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.transliteration,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name.meaning,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Benefit text ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _accent.withValues(alpha: 0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.auto_awesome_rounded, color: _accent, size: 18),
                          const SizedBox(width: 8),
                          Text('ফজিলত ও আমল',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: _accent,
                                fontSize: 14,
                              )),
                        ]),
                        const SizedBox(height: 10),
                        Text(
                          name.benefit,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.7,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Dhikr Counter ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('ধিকর গণনা',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            )),
                        const SizedBox(height: 4),
                        Text('লক্ষ্য: $_target বার',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            )),
                        const SizedBox(height: 16),

                        // Progress ring
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 10,
                                  backgroundColor:
                                      _accent.withValues(alpha: 0.15),
                                  color: _accent,
                                ),
                              ),
                              GestureDetector(
                                onTap: _increment,
                                child: ScaleTransition(
                                  scale: _pulseAnim,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _accent,
                                          _accent.withValues(alpha: 0.7)
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _accent.withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$_dhikrCount',
                                          style: GoogleFonts.poppins(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.0,
                                          ),
                                        ),
                                        Text('বার',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'বৃত্তে চাপ দিন',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),

                        if (_dhikrCount > 0 && _dhikrCount % _target == 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '🎉 মাশাআল্লাহ! $_target বার পূর্ণ হয়েছে!',
                              style: GoogleFonts.poppins(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Navigation arrows ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (name.number > 1)
                        _NavBtn(
                          label: 'আগের নাম',
                          icon: Icons.arrow_back_ios_rounded,
                          accent: _accent,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _NameDetailScreen(
                                  name: asmaulHusna[name.number - 2],
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox(width: 100),
                      if (name.number < 99)
                        _NavBtn(
                          label: 'পরের নাম',
                          icon: Icons.arrow_forward_ios_rounded,
                          accent: _accent,
                          iconRight: true,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _NameDetailScreen(
                                  name: asmaulHusna[name.number],
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox(width: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool iconRight;
  const _NavBtn(
      {required this.label,
      required this.icon,
      required this.accent,
      required this.onTap,
      this.iconRight = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconRight
              ? [
                  Text(label,
                      style: GoogleFonts.poppins(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  const SizedBox(width: 4),
                  Icon(icon, color: accent, size: 14),
                ]
              : [
                  Icon(icon, color: accent, size: 14),
                  const SizedBox(width: 4),
                  Text(label,
                      style: GoogleFonts.poppins(
                          color: accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
        ),
      ),
    );
  }
}
