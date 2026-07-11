import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class HajjUmrahScreen extends StatefulWidget {
  const HajjUmrahScreen({super.key});

  @override
  State<HajjUmrahScreen> createState() => _HajjUmrahScreenState();
}

class _HajjUmrahScreenState extends State<HajjUmrahScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String arabic, String pronunciation, String translation, String title) {
    final text = "$title:\n\nআরবি: $arabic\n\nউচ্চারণ: $pronunciation\n\nঅনুবাদ: $translation";
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "দোয়াটি ক্লিপবোর্ডে কপি করা হয়েছে! 📋",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.emerald,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("হজ ও ওমরাহ গাইড"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: "ওমরাহ নির্দেশিকা"),
            Tab(text: "হজ নির্দেশিকা"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUmrahTab(context, settings, isDark),
          _buildHajjTab(context, settings, isDark),
        ],
      ),
    );
  }

  Widget _buildUmrahTab(BuildContext context, SettingsService settings, bool isDark) {
    final steps = _getUmrahSteps();
    return _buildTimelineList(context, steps, settings.completedUmrahSteps, (stepId) {
      settings.toggleUmrahStep(stepId);
    }, isDark);
  }

  Widget _buildHajjTab(BuildContext context, SettingsService settings, bool isDark) {
    final steps = _getHajjSteps();
    return _buildTimelineList(context, steps, settings.completedHajjSteps, (stepId) {
      settings.toggleHajjStep(stepId);
    }, isDark);
  }

  Widget _buildTimelineList(
    BuildContext context,
    List<_PilgrimageStep> steps,
    Set<String> completedSteps,
    Function(String) onToggle,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isCompleted = completedSteps.contains(step.id);
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline vertical line & node
              Column(
                children: [
                  GestureDetector(
                    onTap: () => onToggle(step.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.emerald : (isDark ? AppColors.cardDark : Colors.white),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? AppColors.emerald : AppColors.gold,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted ? AppColors.emerald : AppColors.gold).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : Center(
                              child: Text(
                                "${index + 1}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted ? AppColors.emerald : AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Card Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isCompleted
                            ? AppColors.emerald.withValues(alpha: 0.35)
                            : (isDark ? Colors.white10 : Colors.black12),
                        width: 1,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: isCompleted
                            ? AppColors.emerald.withValues(alpha: isDark ? 0.05 : 0.02)
                            : null,
                        title: Text(
                          step.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isCompleted
                                ? AppColors.emeraldLight
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        subtitle: Text(
                          step.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            color: isCompleted ? AppColors.emerald : AppColors.textSecondaryLight,
                          ),
                          onPressed: () => onToggle(step.id),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Text(
                                  step.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                if (step.actions.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    "করণীয় কার্যাবলী:",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...step.actions.map((act) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            Expanded(
                                              child: Text(
                                                act,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                                if (step.duas.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    "প্রয়োজনীয় দোয়া সমূহ:",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.emeraldLight,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...step.duas.map((dua) => Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark ? Colors.white10 : Colors.black12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    dua.title,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                      color: AppColors.gold,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                                  onPressed: () => _copyToClipboard(
                                                    context,
                                                    dua.arabic,
                                                    dua.pronunciation,
                                                    dua.translation,
                                                    dua.title,
                                                  ),
                                                  tooltip: "কপি করুন",
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                dua.arabic,
                                                style: TextStyle(
                                                  fontFamily: 'Lateef',
                                                  fontSize: 24,
                                                  height: 1.8,
                                                  color: isDark ? AppColors.arabicDark : AppColors.arabicLight,
                                                ),
                                                textAlign: TextAlign.right,
                                                textDirection: TextDirection.rtl,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "উচ্চারণ: ${dua.pronunciation}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "অনুবাদ: ${dua.translation}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_PilgrimageStep> _getUmrahSteps() {
    return [
      _PilgrimageStep(
        id: "umrah_step_1",
        title: "ইহরাম পরিধান ও নিয়ত",
        subtitle: "ওমরাহর ১ম ফরজ ও আবশ্যক ধাপ",
        description: "মীকাত বা নির্দিষ্ট সীমা অতিক্রম করার পূর্বে ওমরাহর উদ্দেশ্যে পরিষ্কার-পরিচ্ছন্ন হয়ে ইহরামের কাপড় পরিধান করা, নফল সালাত আদায় করা ও নিয়ত করা।",
        actions: [
          "নখ ও অতিরিক্ত চুল কেটে পরিচ্ছন্ন হওয়া",
          "গোসল বা অযু সম্পন্ন করা",
          "সেলাইবিহীন দুই টুকরো সাদা চাদর পরিধান করা (পুরুষদের জন্য)",
          "দুই রাকাত ইহরামের নফল সালাত আদায় করা",
          "ওমরাহর নিয়ত করে উচ্চস্বরে তালবিয়াহ পাঠ শুরু করা"
        ],
        duas: [
          _PilgrimageDua(
            title: "ওমরাহর নিয়ত",
            arabic: "اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي",
            pronunciation: "আল্লাহুম্মা ইন্নি উরিদুল উমরাতা ফায়াসসিরহা লি ওয়া তাকাব্বালহা মিন্নি।",
            translation: "হে আল্লাহ! আমি ওমরাহ আদায়ের ইচ্ছা করছি; আপনি আমার জন্য তা সহজ করে দিন এবং আমার পক্ষ থেকে তা কবুল করুন।"
          ),
          _PilgrimageDua(
            title: "তালবিয়াহ",
            arabic: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
            pronunciation: "লাব্বাইকা আল্লাহুম্মা লাব্বাইক, লাব্বাইকা লা শারীকা লাকা লাব্বাইক, ইন্নাল হামদা ওয়ান নিয় মাতা লাকা ওয়াল মুলক, লা শারীকা লাক।",
            translation: "আমি হাজির হে আল্লাহ, আমি হাজির। আপনার কোন শরিক নেই, আমি হাজির। নিশ্চয়ই সকল প্রশংসা, নেয়ামত এবং সাম্রাজ্য একমাত্র আপনারই, আপনার কোন শরিক নেই।"
          ),
        ],
      ),
      _PilgrimageStep(
        id: "umrah_step_2",
        title: "পবিত্র কাবা ঘর তাওয়াফ",
        subtitle: "ওমরাহর ২য় ফরজ ও অত্যন্ত গুরুত্বপূর্ণ কাজ",
        description: "পবিত্র কাবা শরীফকে হাজরে আসওয়াদ কোণ থেকে শুরু করে ঘড়ির কাটার বিপরীত দিকে মোট ৭ বার প্রদক্ষিণ করা।",
        actions: [
          "অযুসহ পবিত্র অবস্থায় মসজিদে হারামে প্রবেশ করা",
          "ইযতিবা করা (ডান কাঁধ খোলা রাখা - পুরুষদের জন্য)",
          "হাজরে আসওয়াদকে চুম্বন বা দূর থেকে হাতের ইশারায় ইশতিলাম করে তাওয়াফ শুরু করা",
          "প্রথম ৩ চক্করে রমল (বীরদর্পে দ্রুত চলা - পুরুষদের জন্য)",
          "প্রতি চক্করের শেষে রুকনে ইয়ামানি ও হাজরে আসওয়াদের মাঝের দোয়া পাঠ করা",
          "তাওয়াফ শেষে ডান কাঁধ ঢেকে নেওয়া ও মাকামে ইব্রাহীমের পেছনে বা সুবিধাজনক স্থানে ২ রাকাত সালাত আদায় করা",
          "মন ভরে জমজমের পানি পান করা"
        ],
        duas: [
          _PilgrimageDua(
            title: "তাওয়াফ শুরুর ইশতিলাম ইশারা",
            arabic: "بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ",
            pronunciation: "বিসমিল্লাহি ওয়াল্লাহু আকবার।",
            translation: "আল্লাহর নামে শুরু করছি, আল্লাহ মহান।"
          ),
          _PilgrimageDua(
            title: "রুকনে ইয়ামানি ও হাজরে আসওয়াদের মাঝের দোয়া",
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْইَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
            pronunciation: "রাব্বানা আতিনা ফিদ দুনয়া হাসানাতাও ওয়া ফিল আখিরাতি হাসানাতাও ওয়া কিনা আজাবান নার।",
            translation: "হে আমাদের রব! আপনি আমাদের দুনিয়াতে কল্যাণ দান করুন এবং আখিরাতেও কল্যাণ দান করুন এবং জাহান্নামের আগুন থেকে রক্ষা করুন। (সূরা বাকারা: ২০১)"
          ),
        ],
      ),
      _PilgrimageStep(
        id: "umrah_step_3",
        title: "সাফা ও মারওয়া পাহাড়ে সাঈ",
        subtitle: "ওমরাহর ওয়াজিব কাজ",
        description: "সাফা পাহাড় থেকে শুরু করে মারওয়া পাহাড় পর্যন্ত মোট ৭ বার হেঁটে যাতায়াত করা। সাফা থেকে মারওয়া ১ বার এবং মারওয়া থেকে সাফা ২য় বার এভাবে হিসাব করা হয়।",
        actions: [
          "সাফা পাহাড়ে উঠে কিবলামুখী হয়ে দাঁড়ানো ও দোয়া করা",
          "মারওয়া পাহাড়ের উদ্দেশ্যে স্বাভাবিক গতিতে হাঁটা",
          "সবুজ বাতি চিহ্নিত দুই পিলারের মধ্যবর্তী স্থান দৌড়ে বা দ্রুত পার হওয়া (পুরুষদের জন্য)",
          "মারওয়া পাহাড়ে পৌঁছে সাফার মতই কিবলামুখী হয়ে দোয়া করা",
          "মারওয়া পাহাড়ে গিয়ে ৭ম বার সাঈ শেষ করা"
        ],
        duas: [
          _PilgrimageDua(
            title: "সাফা পাহাড়ে আরোহণের দোয়া",
            arabic: "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَن يَطَّوَّفَ بِهِمَا",
            pronunciation: "ইন্নাস সাফা ওয়াল মারওয়াতা মিন শাআইরিল্লাহ, ফামান হাজ্জাল বাইতা আউই’তামারা ফালা জুনাহা আলাইহি আইঁ ইয়াত্তাওয়াফা বিহিমা।",
            translation: "নিশ্চয়ই সাফা ও মারওয়া আল্লাহর নিদর্শনসমূহের অন্তর্ভুক্ত। অতএব যে ব্যক্তি কাবা গৃহের হজ বা ওমরাহ সম্পন্ন করে, তার জন্য এ পাহাড় দুটিতে সাঈ করায় কোনো গুনাহ নেই।"
          ),
        ],
      ),
      _PilgrimageStep(
        id: "umrah_step_4",
        title: "হালক বা কসর (মাথা মুণ্ডন বা চুল কাটা)",
        subtitle: "ওমরাহর শেষ ওয়াজিব কাজ",
        description: "সাঈ শেষ করার পর পুরুষদের সম্পূর্ণ মাথা মুণ্ডন করা (হালক) অথবা সমানভাবে পুরো মাথার চুল ছোট করা (কসর) এবং নারীদের আঙুলের এক কর পরিমাণ চুল কাটা।",
        actions: [
          "হাজামতখানায় বা নিরাপদ স্থানে গিয়ে চুল কাটা",
          "চুল কাটার পর ওমরাহ সম্পন্ন হয় এবং এহরামের সমস্ত নিষেধাজ্ঞা উঠে যায়"
        ],
        duas: [],
      ),
    ];
  }

  List<_PilgrimageStep> _getHajjSteps() {
    return [
      _PilgrimageStep(
        id: "hajj_step_1",
        title: "ইহরাম ও মিনার উদ্দেশ্যে যাত্রা (৮ই জিলহজ)",
        subtitle: "হজের প্রথম দিন",
        description: "৮ই জিলহজ সকালে মক্কা থেকে হজের ইহরাম বেঁধে তালবিয়াহ পাঠ করতে করতে মিনার উদ্দেশ্যে রওয়ানা হওয়া এবং সেখানে অবস্থান করা।",
        actions: [
          "৮ই জিলহজ সকালে মক্কার বাসস্থান থেকে পুনরায় হজের নিয়ত করে ইহরাম বাঁধা",
          "মিনায় পৌঁছানো এবং ৮ই জিলহজ জোহর, আসর, মাগরিব, এশা এবং ৯ই জিলহজ ফজর সালাত সেখানে আদায় করা",
          "মিনায় অবস্থান করা সুন্নাত"
        ],
        duas: [
          _PilgrimageDua(
            title: "হজের নিয়ত",
            arabic: "اللَّهُمَّ إِنِّي أُرِيدُ الْحَجَّ فَيَسِّرْهُ لِي وَتَقَبَّلْهُ مِنِّي",
            pronunciation: "আল্লাহুম্মা ইন্নি উরিদুল হাজ্জা ফায়াসসিরহু লি ওয়া তাকাব্বালহু মিন্নি।",
            translation: "হে আল্লাহ! আমি হজের নিয়ত করছি, আপনি তা আমার জন্য সহজ করে দিন এবং তা কবুল করে নিন।"
          ),
          _PilgrimageDua(
            title: "তালবিয়াহ",
            arabic: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
            pronunciation: "লাব্বাইকা আল্লাহুম্মা লাব্বাইক, লাব্বাইকা লা শারীকা লাকা লাব্বাইক, ইন্নাল হামদা ওয়ান নিয় মাতা লাকা ওয়াল মুলক, লা শারীকা লাক।",
            translation: "আমি হাজির হে আল্লাহ, আমি হাজির। আপনার কোন শরিক নেই, আমি হাজির. নিশ্চয়ই সকল প্রশংসা, নেয়ামত এবং সাম্রাজ্য একমাত্র আপনারই, আপনার কোন শরিক নেই।"
          ),
        ],
      ),
      _PilgrimageStep(
        id: "hajj_step_2",
        title: "আরাফাত ময়দানে অবস্থান (৯ই জিলহজ)",
        subtitle: "হজের প্রধান ফরজ রোকন",
        description: "৯ই জিলহজ সকালে মিনা থেকে আরাফাতের উদ্দেশ্যে রওনা হওয়া এবং দুপুরের পর থেকে সূর্যাস্ত পর্যন্ত আরাফাতের ময়দানে অবস্থান করা।",
        actions: [
          "৯ই জিলহজ জোহর ও আসর সালাত একত্রে আরাফাতে জোহরের ওয়াক্তে কসর করে আদায় করা",
          "সূর্যাস্ত পর্যন্ত কিবলামুখী হয়ে দাঁড়িয়ে আল্লাহর দরবারে রোনাজারি, ক্ষমা ও কল্যাণ প্রার্থনা করা",
          "আরাফাতে অবস্থান করা হজের প্রধান স্তম্ভ; এটি ছাড়া হজ হবে না"
        ],
        duas: [
          _PilgrimageDua(
            title: "আরাফাত দিবসের দোয়া",
            arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            pronunciation: "লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারিকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইয়িন কাদির।",
            translation: "একমাত্র আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই, তাঁর কোনো শরিক নেই। রাজত্ব এবং প্রশংসা একমাত্র তাঁরই, এবং তিনি সব বিষয়ের ওপর ক্ষমতাবান।"
          ),
        ],
      ),
      _PilgrimageStep(
        id: "hajj_step_3",
        title: "মুজদালিফায় রাত্রিযাপন (৯ই জিলহজ দিবাগত রাত)",
        subtitle: "হজের ওয়াজিব কাজ",
        description: "৯ই জিলহজ সূর্যাস্তের পর আরাফাত থেকে মুজদালিফার উদ্দেশ্যে রওয়ানা হওয়া এবং সেখানে খোলা আকাশের নিচে রাত কাটানো।",
        actions: [
          "সূর্যাস্তের পর আরাফাতে মাগরিব না পড়ে মুজদালিফায় গিয়ে মাগরিব ও এশা সালাত একত্রে আদায় করা",
          "খোলা আকাশের নিচে রাত্রিযাপন করা এবং হজের বাকি কাজগুলোর জন্য শক্তি সঞ্চয় করা",
          "শয়তানকে মারার জন্য ছোট ছোট নুড়িপথর (৭০টি বা তার কম) সংগ্রহ করা",
          "১০ই জিলহজ ফজরের পর কিছুক্ষণ দোয়ায় মশগুল থাকা"
        ],
        duas: [],
      ),
      _PilgrimageStep(
        id: "hajj_step_4",
        title: "কঙ্কর নিক্ষেপ, কোরবানি ও মাথা কামানো (১০ই জিলহজ)",
        subtitle: "হজের ১০ই জিলহজের কার্যাবলী",
        description: "১০ই জিলহজ সকালে মুজদালিফা থেকে মিনায় ফিরে জামারাতুল আকাবায় (বড় শয়তানকে) পাথর মারা, কোরবানি করা ও চুল কাটা।",
        actions: [
          "১০ই জিলহজ সকালে মিনায় ফিরে জামারাতুল আকাবায় (বড় শয়তান) ৭টি নুড়ি পাথর নিক্ষেপ করা",
          "কোরবানি সম্পন্ন করা",
          "মাথা মুণ্ডন করা (পুরুষদের জন্য) বা চুল ছোট করা এবং নারীদের এক কর পরিমাণ চুল কাটা",
          "এর মাধ্যমে প্রথম তাহাল্লুল সম্পন্ন হয় এবং ইহরামের সমস্ত নিষেধাজ্ঞা (স্ত্রী সহবাস বাদে) শেষ হয়"
        ],
        duas: [],
      ),
      _PilgrimageStep(
        id: "hajj_step_5",
        title: "তাওয়াফে জিয়ারত ও সাঈ (১০-১২ই জিলহজ)",
        subtitle: "হজের দ্বিতীয় ফরজ কাজ",
        description: "মক্কায় কাবা শরীফ গিয়ে তাওয়াফে জিয়ারত (ফরজ তাওয়াফ) সম্পন্ন করা এবং সাফা-মারওয়া পাহাড়ে হজের সাঈ করা।",
        actions: [
          "মক্কায় গিয়ে তাওয়াফে জিয়ারত করা ও মাকামে ইব্রাহীমে ২ রাকাত সালাত আদায় করা",
          "সাফা ও মারওয়া পাহাড়ে হজের সাঈ করা",
          "এর মাধ্যমে দ্বিতীয় তাহাল্লুল সম্পন্ন হয় এবং বৈবাহিক সম্পর্কসহ ইহরামের সকল নিষেধাজ্ঞা উঠে যায়"
        ],
        duas: [],
      ),
      _PilgrimageStep(
        id: "hajj_step_6",
        title: "মিনায় অবস্থান ও পুনরায় কঙ্কর নিক্ষেপ (১১-১২ই জিলহজ)",
        subtitle: "মিনায় শেষ দিনগুলো",
        description: "১১ ও ১২ই জিলহজ মিনায় অবস্থান করা এবং প্রতিদিন জোহর সালাতের পর থেকে ৩টি শয়তানকে ৭টি করে মোট ২১টি কঙ্কর নিক্ষেপ করা।",
        actions: [
          "১১ই জিলহজ দুপুরের পর ছোট, মধ্যম ও বড় শয়তানকে ৭টি করে পাথর মারা",
          "১২ই জিলহজ একইভাবে তিন শয়তানকে পাথর মারা",
          "১২ই জিলহজ সূর্যাস্তের পূর্বে মিনা ত্যাগ করা অথবা ১৩ই জিলহজ পাথর মেরে বিদায় নেওয়া"
        ],
        duas: [],
      ),
      _PilgrimageStep(
        id: "hajj_step_7",
        title: "বিদায়ী তাওয়াফ",
        subtitle: "মক্কা থেকে বিদায়ের পূর্ব মুহূর্তে",
        description: "মক্কার বাইরে থেকে আগত হাজীদের জন্য নিজ দেশে ফেরার পূর্বে মক্কা শরিফ ত্যাগের পূর্বে বিদায়ী তাওয়াফ আদায় করা ওয়াজিব।",
        actions: [
          "মক্কা ত্যাগ করার পূর্ব মুহূর্তে ৭ বার কাবা শরিফ তাওয়াফ করা",
          "তাওয়াফ শেষে বিদায়ী মোনাজাত করা"
        ],
        duas: [],
      ),
    ];
  }
}

class _PilgrimageStep {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> actions;
  final List<_PilgrimageDua> duas;

  const _PilgrimageStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.actions,
    required this.duas,
  });
}

class _PilgrimageDua {
  final String title;
  final String arabic;
  final String pronunciation;
  final String translation;

  const _PilgrimageDua({
    required this.title,
    required this.arabic,
    required this.pronunciation,
    required this.translation,
  });
}
