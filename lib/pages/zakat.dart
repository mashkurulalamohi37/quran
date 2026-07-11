import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/theme/app_theme.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Assets
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _investmentController = TextEditingController();
  final _merchandiseController = TextEditingController();
  final _receivableController = TextEditingController();

  // Controllers for Liabilities
  final _debtController = TextEditingController();
  final _businessLiabilityController = TextEditingController();

  // Nisab configuration
  final _nisabController = TextEditingController(text: "100000"); // Default 100k BDT

  // Calculations Results State
  double _totalAssets = 0.0;
  double _totalLiabilities = 0.0;
  double _netWealth = 0.0;
  double _zakatPayable = 0.0;
  bool _isNisabMet = false;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _goldController.dispose();
    _investmentController.dispose();
    _merchandiseController.dispose();
    _receivableController.dispose();
    _debtController.dispose();
    _businessLiabilityController.dispose();
    _nisabController.dispose();
    super.dispose();
  }

  void _calculateZakat() {
    FocusScope.of(context).unfocus();

    // Parse double fields, fallback to 0.0
    final cash = double.tryParse(_cashController.text.trim()) ?? 0.0;
    final gold = double.tryParse(_goldController.text.trim()) ?? 0.0;
    final investments = double.tryParse(_investmentController.text.trim()) ?? 0.0;
    final merchandise = double.tryParse(_merchandiseController.text.trim()) ?? 0.0;
    final receivables = double.tryParse(_receivableController.text.trim()) ?? 0.0;

    final debts = double.tryParse(_debtController.text.trim()) ?? 0.0;
    final businessLiabilities = double.tryParse(_businessLiabilityController.text.trim()) ?? 0.0;

    final nisab = double.tryParse(_nisabController.text.trim()) ?? 100000.0;

    setState(() {
      _totalAssets = cash + gold + investments + merchandise + receivables;
      _totalLiabilities = debts + businessLiabilities;
      _netWealth = _totalAssets - _totalLiabilities;

      if (_netWealth >= nisab) {
        _isNisabMet = true;
        _zakatPayable = _netWealth * 0.025; // 2.5%
      } else {
        _isNisabMet = false;
        _zakatPayable = 0.0;
      }
      _hasCalculated = true;
    });
  }

  void _resetFields() {
    setState(() {
      _cashController.clear();
      _goldController.clear();
      _investmentController.clear();
      _merchandiseController.clear();
      _receivableController.clear();
      _debtController.clear();
      _businessLiabilityController.clear();
      _nisabController.text = "100000";

      _totalAssets = 0.0;
      _totalLiabilities = 0.0;
      _netWealth = 0.0;
      _zakatPayable = 0.0;
      _isNisabMet = false;
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("জাকাত"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "হিসাব করুন"),
            Tab(text: "নিয়ম ও মাসয়ালা"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalculatorTab(isDark),
          _buildRulesTab(isDark),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "আপনার সম্পদ ও ঋণের বিবরণী লিখুন:",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
          ),
          const SizedBox(height: 16),

          // Assets Section Card
          _buildFormCard(
            title: "১. জাকাতযোগ্য সম্পদ (Assets)",
            icon: Icons.account_balance_wallet_rounded,
            isDark: isDark,
            fields: [
              _buildInputField("নগদ ও ব্যাংকে থাকা অর্থ", _cashController, "টাকা (BDT)", isDark),
              _buildInputField("স্বর্ণ ও রৌপ্যের নগদ বাজারমূল্য", _goldController, "টাকা (BDT)", isDark),
              _buildInputField("শেয়ার, বন্ড ও অন্যান্য বিনিয়োগ", _investmentController, "টাকা (BDT)", isDark),
              _buildInputField("ব্যবসায়িক পণ্যের নগদ মূল্য", _merchandiseController, "টাকা (BDT)", isDark),
              _buildInputField("অন্যের কাছে পাওনা (যা ফেরতযোগ্য)", _receivableController, "টাকা (BDT)", isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Liabilities Section Card
          _buildFormCard(
            title: "২. ঋণ ও প্রদেয় বিলসমূহ (Liabilities)",
            icon: Icons.remove_circle_outline_rounded,
            isDark: isDark,
            fields: [
              _buildInputField("ব্যক্তিগত ঋণ ও অন্যান্য দেনা", _debtController, "টাকা (BDT)", isDark),
              _buildInputField("ব্যবসায়িক বকেয়া ও প্রদেয় বিল", _businessLiabilityController, "টাকা (BDT)", isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Nisab Settings Card
          _buildFormCard(
            title: "৩. নেসাব নির্ধারণ",
            icon: Icons.verified_rounded,
            isDark: isDark,
            fields: [
              _buildInputField("৫২.৫ তোলা রূপার সমমূল্য (নেসাব)", _nisabController, "টাকা (BDT)", isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _resetFields,
                  child: const Text("রিসেট করুন", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _calculateZakat,
                  child: const Text("হিসাব করুন", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          if (_hasCalculated) ...[
            const SizedBox(height: 24),
            _buildResultCard(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> fields,
    required bool isDark,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.emerald, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String suffix, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white30 : Colors.black38),
          suffixText: suffix,
          suffixStyle: GoogleFonts.poppins(fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    final netText = _netWealth < 0 ? "০ BDT (ঋণগ্রস্ত)" : "${_netWealth.toStringAsFixed(0)} BDT";
    final zakatText = _zakatPayable > 0 ? "${_zakatPayable.toStringAsFixed(0)} BDT" : "০ BDT";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isNisabMet 
            ? AppColors.emerald.withValues(alpha: 0.12)
            : (isDark ? Colors.white10 : Colors.black12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isNisabMet ? AppColors.emerald : Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isNisabMet ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: _isNisabMet ? AppColors.emerald : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                _isNisabMet ? "জাকাত ফরজ হয়েছে" : "জাকাত ফরজ হয়নি",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _isNisabMet ? AppColors.emeraldLight : Colors.orange,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildResultRow("মোট সম্পদ (Total Assets):", "${_totalAssets.toStringAsFixed(0)} BDT", isDark),
          const SizedBox(height: 8),
          _buildResultRow("মোট ঋণ (Total Liabilities):", "- ${_totalLiabilities.toStringAsFixed(0)} BDT", isDark),
          const SizedBox(height: 8),
          _buildResultRow("নিট সম্পদ (Net Wealth):", netText, isDark),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "প্রদেয় জাকাত (২.৫%):",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                zakatText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _isNisabMet ? AppColors.emeraldLight : Colors.red,
                ),
              ),
            ],
          ),
          if (!_isNisabMet) ...[
            const SizedBox(height: 12),
            Text(
              "* নিট সম্পদ নেসাবের (১,০০,০০০ BDT) কম হওয়ায় আপনার ওপর জাকাত আদায় করা ফরজ নয়।",
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRulesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "জাকাতের মৌলিক নিয়মাবলী ও মাসয়ালা",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
        ),
        const SizedBox(height: 16),
        _buildRuleTile(
          "১. জাকাত কার ওপর ফরজ?",
          "জাকাত ফরজ হওয়ার ৫টি শর্ত রয়েছে:\n১. মুসলিম হওয়া।\n২. স্বাধীন হওয়া।\n৩. নেসাব পরিমাণ মালের মালিক হওয়া।\n৪. সম্পদের ওপর পূর্ণ মালিকানা থাকা।\n৫. সম্পদ এক বছর অতিবাহিত হওয়া।",
          isDark,
        ),
        _buildRuleTile(
          "২. নেসাবের পরিমাণ কত?",
          "স্বর্ণের ক্ষেত্রে: ৭.৫ তোলা (৮৭.৪৮ গ্রাম) স্বর্ণের সমমূল্য।\nরৌপ্যের ক্ষেত্রে: ৫২.৫ তোলা (৬১২.৩৬ গ্রাম) রৌপ্যের সমমূল্য।\nনগদ টাকা বা ব্যবসার মালের ক্ষেত্রে: ৫২.৫ তোলা রৌপ্যের বর্তমান বাজারমূল্যই হচ্ছে নগদ অর্থের নেসাব। নিট সম্পদ এই পরিমাণ অতিক্রম করলে ২.৫% হারে জাকাত দিতে হবে।",
          isDark,
        ),
        _buildRuleTile(
          "৩. জাকাত কাদের দেওয়া যাবে (খাতসমূহ)?",
          "পবিত্র কুরআনে (সুরা তওবা, আয়াত ৬০) জাকাতের ৮টি খাত উল্লেখ করা হয়েছে:\n১. ফকির (দরিদ্র)\n২. মিসকিন (রিক্তহস্ত)\n৩. জাকাত আদায়কারী কর্মচারী\n৪. ইসলামের প্রতি আকৃষ্ট করার উদ্দেশ্যে\n৫. দাসমুক্তির জন্য\n৬. ঋণগ্রস্ত ব্যক্তি\n৭. আল্লাহর রাস্তায় সংগ্রামকারী মুজাহিদ\n৮. মুসাফির (যিনি সফরে অর্থকষ্টে পড়েছেন)",
          isDark,
        ),
        _buildRuleTile(
          "৪. কোন কোন সম্পদের জাকাত হয় না?",
          "ব্যক্তিগত ব্যবহারের জিনিসপত্রের ওপর জাকাত ফরজ নয়। যেমন:\n- বসবাসের বাড়ি বা ফ্ল্যাট\n- ব্যক্তিগত ব্যবহারের গাড়ি ও পোশাক-আশাক\n- ঘরের আসবাবপত্র\n- চাষাবাদের বা কাজের পশুপাখি\n- কারখানার ব্যবহারের যন্ত্রপাতি বা যন্ত্রপাতি সরঞ্জাম",
          isDark,
        ),
      ],
    );
  }

  Widget _buildRuleTile(String title, String desc, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        iconColor: AppColors.emerald,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
