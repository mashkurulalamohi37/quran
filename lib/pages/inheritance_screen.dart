import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:quran/services/inheritance_calculator.dart';
import 'package:quran/services/will_pdf_generator.dart';
import 'package:quran/theme/app_theme.dart';

class InheritanceScreen extends StatefulWidget {
  const InheritanceScreen({super.key});

  @override
  State<InheritanceScreen> createState() => _InheritanceScreenState();
}

class _InheritanceScreenState extends State<InheritanceScreen> {
  int _activeStep = 0;

  // Step 1: Relatives State
  bool _hasHusband = false;
  bool _hasWife = false;
  int _numWives = 1;
  int _numSons = 0;
  int _numDaughters = 0;
  bool _hasFather = false;
  bool _hasMother = false;

  // Step 2: Will Document Details
  final _nameCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _legacyCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  InheritanceResult? _calcResult;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _addressCtrl.dispose();
    _nidCtrl.dispose();
    _legacyCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _calcResult = InheritanceCalculator.calculate(
        hasHusband: _hasHusband,
        hasWife: _hasWife,
        numWives: _hasWife ? _numWives : 0,
        numSons: _numSons,
        numDaughters: _numDaughters,
        hasFather: _hasFather,
        hasMother: _hasMother,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text("উত্তরাধিকার ও ওসীয়ত"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Stepper Header ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: isDark ? AppColors.cardDark : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stepHeaderItem(0, "জীবিত আত্মীয়", Icons.people_outline_rounded),
                _stepDivider(),
                _stepHeaderItem(1, "ওসীয়তনামা", Icons.assignment_outlined),
                _stepDivider(),
                _stepHeaderItem(2, "ফলাফল ও প্রিন্ট", Icons.print_outlined),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildActiveStepContent(isDark),
            ),
          ),

          // ── Footer Navigation Bar ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white10 : Colors.black12),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeStep > 0)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: const BorderSide(color: AppColors.emerald),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _activeStep--),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.emerald),
                    label: Text("আগের ধাপ", style: GoogleFonts.poppins(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                  )
                else
                  const SizedBox(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_activeStep == 0) {
                      if (_hasHusband && _hasWife) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("একই সাথে স্বামী ও স্ত্রী উভয়ে জীবিত থাকতে পারে না!")),
                        );
                        return;
                      }
                      _calculate();
                      setState(() => _activeStep = 1);
                    } else if (_activeStep == 1) {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _activeStep = 2);
                      }
                    } else {
                      // Reset
                      setState(() {
                        _activeStep = 0;
                        _calcResult = null;
                      });
                    }
                  },
                  icon: Icon(
                    _activeStep < 2 ? Icons.arrow_forward_rounded : Icons.replay_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _activeStep < 2 ? "পরের ধাপ" : "রিসেট করুন",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepHeaderItem(int index, String label, IconData icon) {
    final isActive = _activeStep == index;
    final isDone = _activeStep > index;
    final color = isActive
        ? AppColors.emerald
        : (isDone ? AppColors.gold : Colors.grey);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildActiveStepContent(bool isDark) {
    switch (_activeStep) {
      case 0:
        return _buildStepRelatives(isDark);
      case 1:
        return _buildStepWillDetails(isDark);
      case 2:
      default:
        return _buildStepResults(isDark);
    }
  }

  // ── Step 1: Living Relatives Selection ──
  Widget _buildStepRelatives(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "জীবিত আত্মীয়দের তালিকা সিলেক্ট করুন:",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Spouses
        _cardSection(
          title: "স্বামী / স্ত্রী",
          isDark: isDark,
          child: Column(
            children: [
              CheckboxListTile(
                activeColor: AppColors.emerald,
                title: const Text("স্বামী জীবিত"),
                value: _hasHusband,
                onChanged: (val) => setState(() {
                  _hasHusband = val ?? false;
                  if (_hasHusband) _hasWife = false;
                }),
              ),
              CheckboxListTile(
                activeColor: AppColors.emerald,
                title: const Text("স্ত্রী জীবিত"),
                value: _hasWife,
                onChanged: (val) => setState(() {
                  _hasWife = val ?? false;
                  if (_hasWife) _hasHusband = false;
                }),
              ),
              if (_hasWife) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("স্ত্রীর সংখ্যা (১-৪):"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _numWives > 1 ? () => setState(() => _numWives--) : null,
                          ),
                          Text("$_numWives", style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _numWives < 4 ? () => setState(() => _numWives++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Descendants (Children)
        _cardSection(
          title: "সন্তানাদি",
          isDark: isDark,
          child: Column(
            children: [
              _counterRow(
                label: "পুত্র সংখ্যা:",
                value: _numSons,
                onChanged: (val) => setState(() => _numSons = val),
              ),
              const Divider(),
              _counterRow(
                label: "কন্যা সংখ্যা:",
                value: _numDaughters,
                onChanged: (val) => setState(() => _numDaughters = val),
              ),
            ],
          ),
        ),

        // Parents
        _cardSection(
          title: "পিতা ও মাতা",
          isDark: isDark,
          child: Column(
            children: [
              CheckboxListTile(
                activeColor: AppColors.emerald,
                title: const Text("পিতা জীবিত"),
                value: _hasFather,
                onChanged: (val) => setState(() => _hasFather = val ?? false),
              ),
              CheckboxListTile(
                activeColor: AppColors.emerald,
                title: const Text("মাতা জীবিত"),
                value: _hasMother,
                onChanged: (val) => setState(() => _hasMother = val ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Will Information ──
  Widget _buildStepWillDetails(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ওসীয়তনামা ওসিয়তকারীর তথ্য:",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _textFormField(
            controller: _nameCtrl,
            label: "ওসীয়তকারীর পূর্ণ নাম (বাংলায়)",
            validator: (v) => v!.isEmpty ? "নাম আবশ্যক" : null,
            isDark: isDark,
          ),
          _textFormField(
            controller: _fatherCtrl,
            label: "পিতা বা স্বামীর নাম",
            validator: (v) => v!.isEmpty ? "পিতা বা স্বামীর নাম আবশ্যক" : null,
            isDark: isDark,
          ),
          _textFormField(
            controller: _addressCtrl,
            label: "স্থায়ী/বর্তমান ঠিকানা",
            validator: (v) => v!.isEmpty ? "ঠিকানা আবশ্যক" : null,
            isDark: isDark,
          ),
          _textFormField(
            controller: _nidCtrl,
            label: "এনআইডি / পাসপোর্ট নম্বর",
            validator: (v) => v!.isEmpty ? "এনআইডি নম্বর আবশ্যক" : null,
            isDark: isDark,
          ),
          _textFormField(
            controller: _legacyCtrl,
            label: "বিশেষ ওসীয়ত (অনধিক ১/৩ অংশ) - ঐচ্ছিক",
            hint: "যেমন: মসজিদের জন্য ১০ শতাংশ জমি, এতিমখানায় নগদ টাকা দান...",
            maxLines: 3,
            isDark: isDark,
          ),
          _textFormField(
            controller: _instructionsCtrl,
            label: "দাফন-কাফন ও পারিবারিক বিশেষ নির্দেশনা - ঐচ্ছিক",
            hint: "যেমন: সুদমুক্ত জীবন গড়ার উপদেশ, ওসীয়তের বাস্তবায়নের তাগিদ...",
            maxLines: 3,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ── Step 3: Calculation & PDF preview ──
  Widget _buildStepResults(bool isDark) {
    if (_calcResult == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "শরিয়ত সম্মত বণ্টন হিস্যা:",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Shares breakdown cards
        ..._calcResult!.shares.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${(entry.value * 100).toStringAsFixed(2)}%",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Explanation text card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "বণ্টনের ব্যাখ্যা:",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.emerald),
              ),
              const SizedBox(height: 8),
              Text(
                _calcResult!.explanation,
                style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          "ওসীয়তনামা প্রিন্ট ও ডাউনলোড করুন:",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // PdfPreview interactive widget
        SizedBox(
          height: 480,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PdfPreview(
              build: (format) => WillPdfGenerator.generateWillPdf(
                name: _nameCtrl.text,
                fatherName: _fatherCtrl.text,
                address: _addressCtrl.text,
                nid: _nidCtrl.text,
                specificLegacy: _legacyCtrl.text,
                generalInstructions: _instructionsCtrl.text,
                result: _calcResult!,
              ),
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.emerald)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardSection({required String title, required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.emerald),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _counterRow({required String label, required int value, required ValueChanged<int> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.emerald, width: 2),
          ),
        ),
      ),
    );
  }
}
