import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quran/services/bangla_pdf_helper.dart' as bp;
import 'package:quran/services/inheritance_calculator.dart';

// Pre-shaped Unicode Arabic constants to ensure correct letter connections in PDF
const String _arabicBismillah = "\uFE91\uFEB4\uFEE2\u0020\uFDF2\u0020\uFE8D\uFEDF\uFEAE\uFEA3\uFEE4\uFB51\uFEE5\u0020\uFE8D\uFEDF\uFEAE\uFEA3\uFEF4\uFEE2";
const String _arabicShahadah = "\uFE83\uFEB7\uFEEC\uFEAA\u0020\uFE83\uFEE5\u0020\uFEFB\u0020\uFE87\uFEDF\uFEEA\u0020\uFE87\uFEFB\u0020\uFDF2\u0020\uFEED\uFE83\uFEB7\uFEEC\uFEAA\u0020\uFE83\uFEE5\u0020\uFEE3\uFEA4\uFEE4\uFEAA\uFE8D\u0020\uFECB\uFE92\uFEAA\uFEE9\u0020\uFEED\uFEAD\uFEB3\uFEEE\uFEDF\uFEEA";

class WillPdfGenerator {
  static Future<Uint8List> generateWillPdf({
    required String name,
    required String fatherName,
    required String address,
    required String nid,
    required String specificLegacy,
    required String generalInstructions,
    required InheritanceResult result,
  }) async {
    final pdf = pw.Document();

    // Load local font for Arabic to support offline rendering
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final arabicFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context context) {
          return [
            // ── Header ──────────────────────────────────────────────────────
            pw.Center(
              child: pw.Text(
                _arabicBismillah,
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 22,
                  color: PdfColors.black,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: bp.Text(
                "শেষ ওসীয়তনামা (ইসলামিক উইল)",
                fontSize: 15,
                color: PdfColors.green900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            // ── Declaration of Faith (Shahadah) ─────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    _arabicShahadah,
                    style: pw.TextStyle(font: arabicFont, fontSize: 14),
                    textAlign: pw.TextAlign.center,
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 3),
                  bp.Text(
                    "আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ব্যতীত কোনো উপাস্য নেই এবং মুহাম্মদ (সা.) আল্লাহর বান্দা ও রাসূল।",
                    fontSize: 9,
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // ── 1. Testator Info ─────────────────────────────────────────────
            bp.Text(
              "১. ওসীয়তকারীর ঘোষণা:",
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 4),
            bp.Text(
              "আমি, $name, পিতা/স্বামী: $fatherName, ঠিকানা: $address, এনআইডি নম্বর: $nid, সুস্থ মস্তিষ্কে ও সজ্ঞানে এই ওসীয়তনামা সম্পাদন করছি। আমার মৃত্যুর পর নিম্নলিখিত নির্দেশনাবলী অনুযায়ী আমার সম্পত্তি ও অন্যান্য বিষয়াদি পরিচালিত হবে।",
              fontSize: 9,
            ),
            pw.SizedBox(height: 8),

            // ── 2. General Instructions ──────────────────────────────────────
            bp.Text(
              "২. দাফন-কাফন ও ঋণ পরিশোধ সংক্রান্ত সাধারণ নির্দেশনা:",
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 4),
            bp.Text(
              "ক) আমার মৃত্যুর পর সর্বপ্রথম আমার ত্যাজ্য সম্পত্তি হতে আমার দাফন-কাফনের যাবতীয় খরচ নির্বাহ করা হবে।\n"
              "খ) অতঃপর আমার বকেয়া দেনমোহর, পাওনাদারদের ঋণ এবং কোনো বান্দার হক থাকলে তা দ্রুততম সময়ের মধ্যে পরিশোধ করা হবে।\n"
              "গ) সাধারণ নির্দেশাবলী: ${generalInstructions.isEmpty ? 'পারিবারিক শান্তি ও ইসলামের নিয়ম অনুযায়ী জীবনযাপন করার অনুরোধ রইলো।' : generalInstructions}",
              fontSize: 9,
            ),
            pw.SizedBox(height: 8),

            // ── 3. Legacy (Wasiyyah) ─────────────────────────────────────────
            bp.Text(
              "৩. অ-উত্তরাধিকারীদের অনুকূলে ওসীয়ত (অনধিক ১/৩ অংশ):",
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 4),
            bp.Text(
              specificLegacy.isEmpty
                  ? "আমার মোট সম্পত্তির ১/৩ (এক-তৃতীয়াংশ) বা এর কম কোনো অংশ অ-উত্তরাধিকারী কোনো ব্যক্তি বা জনকল্যাণমূলক কাজে ওসীয়ত করার জন্য অবশিষ্ট রাখা হয়নি।"
                  : "আমার মোট সম্পত্তির ১/৩ (এক-তৃতীয়াংশ) অংশ হতে নিম্নলিখিত ব্যক্তি/প্রতিষ্ঠানের অনুকূলে ওসীয়ত করছি:\n$specificLegacy",
              fontSize: 9,
            ),
            pw.SizedBox(height: 8),

            // ── 4. Shariah Shares Table ──────────────────────────────────────
            bp.Text(
              "৪. উত্তরাধিকারীদের মধ্যে শরিয়ত সম্মত বণ্টন:",
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 4),
            bp.Text(
              "ঋণ পরিশোধ ও ওসীয়ত সম্পাদনের পর অবশিষ্ট সম্পত্তির শরিয়াহ নির্দেশিত হিস্যা নিম্নরূপ নির্ধারিত হলো:",
              fontSize: 9,
            ),
            pw.SizedBox(height: 6),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: bp.Text("উত্তরাধিকারী সম্পর্ক", fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: bp.Text("প্রাপ্ত অংশ (শতকরা হার)", fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                ...result.shares.entries.map((entry) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: bp.Text(entry.key, fontSize: 9),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: bp.Text(
                          "${(entry.value * 100).toStringAsFixed(2)}%",
                          fontSize: 9,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 8),

            // ── Calculation Explanation ──────────────────────────────────────
            bp.Text(
              "বণ্টনের ব্যাখ্যা:",
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 3),
            bp.Text(
              result.explanation,
              fontSize: 8,
              color: PdfColors.grey700,
            ),
            pw.SizedBox(height: 20),

            // ── Signatures Row ───────────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    bp.Text("ওসীয়তকারীর স্বাক্ষর ও তারিখ", fontSize: 9),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    bp.Text("১ম সাক্ষীর স্বাক্ষর ও নাম", fontSize: 9),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    bp.Text("২য় সাক্ষীর স্বাক্ষর ও নাম", fontSize: 9),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
