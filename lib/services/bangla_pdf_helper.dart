import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bangla_pdf/bangla_pdf.dart' as original_bp;

extension SafeBanglaTextExtension on String {
  bool get isBanglaText =>
      original_bp.BanglaFontManager.isBanglaText(this) ||
      contains('\u0964') ||
      contains('\u0965');
  String get safeFix => isBanglaText ? SafeBanglaUnicodeMapper.encodeANSI(this) : this;
}

class SafeBanglaUnicodeMapper {
  SafeBanglaUnicodeMapper._();

  static String encodeANSI(String unicode) {
    return _fixFont(unicode);
  }

  static String _fixFont(String unicodeStr) {
    final fixedUnicodeStr = unicodeStr
        .replaceAll("য়", "য়")
        .replaceAll("\u09A1\u09BC", "\u09DC")
        .replaceAll("\u09A2\u09BC", "\u09DD")
        .replaceAll("\u200d", "\u200c");

    var lines = fixedUnicodeStr.split('\n');
    var fixedLines = <String>[];

    for (var line in lines) {
      fixedLines.add(_fixFontInner(line));
    }

    return fixedLines.join('\n');
  }

  static String _fixFontInner(String line) {
    var fixedLine = line.replaceAll("ো", "ো");
    fixedLine = fixedLine.replaceAll("ৌ", "ৌ");

    // Apply safe rearrangement logic
    fixedLine = _rearrangeUnicodeStr(fixedLine);

    _conversionMap.forEach((key, value) {
      fixedLine = fixedLine.replaceAll(key, value);
    });
    return fixedLine;
  }

  static String _rearrangeUnicodeStr(String text) {
    var processedText = text;
    int barrier = 0;
    int i = 0;

    while (i < processedText.length) {
      if (_isBanglaCharacter(processedText[i])) {
        if (_isBanglaPreKar(processedText[i])) {
          int j = 1;
          while (i - j >= 0 && _isBanglaBanjonborno(processedText[i - j])) {
            if (i - j <= barrier) break;
            if (i - j - 1 >= 0 && _isBanglaHalant(processedText[i - j - 1])) {
              j += 2;
            } else {
              break;
            }
          }

          String temp = processedText.substring(0, i - j);
          temp += processedText[i];
          temp += processedText.substring(i - j, i);
          temp += processedText.substring(i + 1, processedText.length);
          processedText = temp;
          barrier = i + 1;
        }

        if (i < (processedText.length - 1) &&
            _isBanglaHalant(processedText[i]) &&
            i - 1 >= 0 &&
            processedText[i - 1] == 'র' &&
            (i - 2 < 0 || !_isBanglaHalant(processedText[i - 2]))) {
          int j = 1;
          int foundPreKar = 0;
          while (true) {
            if (i + j + 1 < processedText.length &&
                _isBanglaBanjonborno(processedText[i + j]) &&
                _isBanglaHalant(processedText[i + j + 1])) {
              j += 2;
            } else if (i + j + 1 < processedText.length &&
                _isBanglaBanjonborno(processedText[i + j]) &&
                _isBanglaPreKar(processedText[i + j + 1])) {
              foundPreKar = 1;
              break;
            } else {
              break;
            }
          }

          String temp = processedText.substring(0, i - 1);
          temp += processedText.substring(i + j + 1, i + j + foundPreKar + 1);
          temp += processedText.substring(i + 1, i + j + 1);
          temp += processedText[i - 1];
          temp += processedText[i];
          temp += processedText.substring(
              i + j + foundPreKar + 1, processedText.length);
          processedText = temp;
          i += j + foundPreKar;
          barrier = i + 1;
        }
      }
      i += 1;
    }
    return processedText;
  }

  static bool _isBanglaCharacter(String chUnicode) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(chUnicode);
  }

  static bool _isBanglaPreKar(String chUnicode) {
    return ['ি', 'ৈ', 'ে'].contains(chUnicode);
  }

  static bool _isBanglaBanjonborno(String chUnicode) {
    return [
      'ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ', 'ছ', 'জ', 'ঝ', 'ঞ',
      'ট', 'ঠ', 'ড', 'ঢ', 'ণ', 'ত', 'থ', 'দ', 'ধ', 'ন',
      'প', 'ফ', 'ব', 'ভ', 'ম', 'শ', 'ষ', 'স', 'হ', 'য',
      'র', 'ল', 'য়', 'ং', 'ঃ', 'ঁ', 'ৎ'
    ].contains(chUnicode);
  }

  static bool _isBanglaHalant(String chUnicode) {
    return chUnicode == '্';
  }

  static const _conversionMap = {
    "।": "|",
    "‘": "Ô",
    "’": "Õ",
    "“": "Ò",
    "”": "Ó",
    "্র্য": "ª¨",
    "র‌্য": "i¨",
    "ক্ক": "°",
    "ক্ট": "±",
    "ক্ত": "³",
    "ক্ব": "K¡",
    "স্ক্র": "¯Œ",
    "ক্র": "µ",
    "ক্ল": "K¬",
    "ক্ষ": "¶",
    "ক্স": "·",
    "গু": "¸",
    "গ্ধ": "»",
    "গ্ন": "Mœ",
    "গ্ম": "M¥",
    "গ্ল": "M­",
    "গ্রু": "Mªy",
    "ঙ্ক": "¼",
    "ঙ্ক্ষ": "•¶",
    "ঙ্খ": "•L",
    "ঙ্গ": "½",
    "ঙ্ঘ": "•N",
    "চ্চ": "”P",
    "চ্ছ": "”Q",
    "চ্ছ্ব": "”Q¡",
    "চ্ঞ": "”T",
    "জ্জ্ব": "¾¡",
    "জ্জ": "¾",
    "জ্ঝ": "À",
    "জ্ঞ": "Á",
    "জ্ব": "R¡",
    "ঞ্চ": "Â",
    "ঞ্ছ": "Ã",
    "ঞ্জ": "Ä",
    "ঞ্ঝ": "Å",
    "ট্ট": "Æ",
    "ট্ব": "U¡",
    "ট্ম": "U¥",
    "ড্ড": "Ç",
    "ণ্ট": "È",
    "ণ্ঠ": "É",
    "ন্স": "Ý",
    "ণ্ড": "Ð",
    "ন্তু": "š‘",
    "ণ্ব": "Y^",
    "ত্ত": "Ë",
    "ত্ত্ব": "Ë¡",
    "ত্থ": "Ì",
    "ত্ন": "Zœ",
    "ত্ম": "Z¥",
    "ন্ত্ব": "š—¡",
    "ত্ব": "Z¡",
    "থ্ব": "_¡",
    "দ্গ": "˜M",
    "দ্ঘ": "˜N",
    "দ্দ": "Ï",
    "দ্ধ": "×",
    "দ্ব": "Ø",
    "দ্ভ": "™¢",
    "দ্ম": "Ù",
    "দ্রু": "`ªæ",
    "ধ্ব": "aŸ",
    "ধ্ম": "a¥",
    "ন্ট": "›U",
    "ন্ঠ": "Ú",
    "ন্ড": "Û",
    "ন্ত্র": "š¿",
    "ন্ত": "šÍ",
    "স্ত্র": "¯¿",
    "ত্র": "Î",
    "ন্থ": "š’",
    "ন্দ": "›`",
    "ন্দ্ব": "›Ø",
    "ন্ধ": "Ü",
    "ন্ন": "bœ",
    "ন্ব": "š^",
    "ন্ম": "b¥",
    "প্ট": "Þ",
    "প্ত": "ß",
    "প্ন": "cœ",
    "প্প": "à",
    "প্ল": "cø",
    "প্স": "á",
    "ফ্ল": "d¬",
    "ব্জ": "â",
    "ব্দ": "ã",
    "ব্ধ": "ä",
    "ব্ব": "eŸ",
    "ব্ল": "eø",
    "ভ্র": "å",
    "ম্ন": "gœ",
    "ম্প": "¤ú",
    "ম্ফ": "ç",
    "ম্ব": "¤^",
    "ম্ভ": "¤¢",
    "ম্ভ্র": "¤£",
    "ম্ম": "¤§",
    "ম্ল": "¤­",
    "রু": "iy",
    "রূ": "iƒ",
    "ল্ক": "é",
    "ল্গ": "ê",
    "ল্প": "í",
    "ল্ট": "ë",
    "ল্ড": "ì",
    "ল্ফ": "î",
    "ল্ব": "j¦",
    "ল্ম": "j¥",
    "ল্ল": "jø",
    "শু": "ï",
    "শ্চ": "ð",
    "শ্ন": "kœ",
    "শ্ব": "k¦",
    "শ্ম": "k¥",
    "শ্ল": "kø",
    "ষ্ক": "®‹",
    "ষ্ক্র": "®Œ",
    "ষ্ট": "ó",
    "ষ্ঠ": "ô",
    "ষ্ণ": "ò",
    "ষ্প": "®ú",
    "ষ্ফ": "õ",
    "ষ্ম": "®§",
    "স্ক": "¯‹",
    "স্ট": "÷",
    "স্খ": "ö",
    "স্ত": "¯Z",
    "স্তু": "¯‘",
    "স্থ": "¯’",
    "স্ন": "mœ",
    "স্প": "¯ú",
    "স্ফ": "ù",
    "স্ব": "¯^",
    "স্ম": "¯§",
    "স্ল": "¯­",
    "হু": "û",
    "হ্ণ": "nè",
    "হ্ন": "ý",
    "হ্ম": "þ",
    "হ্ল": "n¬",
    "হৃ": "ü",
    "র্": "©",
    "্র": "ª",
    "্য": "¨",
    "্": "&",
    "আ": "Av",
    "অ": "A",
    "ই": "B",
    "ঈ": "C",
    "উ": "D",
    "ঊ": "E",
    "ঋ": "F",
    "এ": "G",
    "ঐ": "H",
    "ও": "I",
    "ঔ": "J",
    "ক": "K",
    "খ": "L",
    "গ": "M",
    "ঘ": "N",
    "ঙ": "O",
    "চ": "P",
    "ছ": "Q",
    "জ": "R",
    "ঝ": "S",
    "ঞ": "T",
    "ট": "U",
    "ঠ": "V",
    "ড": "W",
    "ঢ": "X",
    "ণ": "Y",
    "ত": "Z",
    "থ": "_",
    "দ": "`",
    "ধ": "a",
    "ন": "b",
    "প": "c",
    "ফ": "d",
    "ব": "e",
    "ভ": "f",
    "ম": "g",
    "য": "h",
    "র": "i",
    "ল": "j",
    "শ": "k",
    "ষ": "l",
    "স": "m",
    "হ": "n",
    "ড়": "o",
    "ঢ়": "p",
    "য়": "q",
    "ৎ": "r",
    "০": "0",
    "১": "1",
    "২": "2",
    "৩": "3",
    "৪": "4",
    "৫": "5",
    "৬": "6",
    "৭": "7",
    "৮": "8",
    "৯": "9",
    "া": "v",
    "ি": "w",
    "ী": "x",
    "ু": "y",
    "ূ": "~",
    "ৃ": "…",
    "ে": "‡",
    "ৈ": "‰",
    "ৗ": "Š",
    "ং": "s",
    "ঃ": "t",
    "ঁ": "u",
    "৳": "\$",
  };
}

class SafeFixingUtils {
  SafeFixingUtils._();

  static List<pw.TextSpan> getAutoLocalizedSpans({
    required String text,
    pw.Font? banglaFont,
    pw.Font? generalFont,
    double fontSize = 16,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    PdfColor color = PdfColors.black,
    pw.TextStyle? style,
    pw.TextStyle? banglaStyle,
  }) {
    final spans = <pw.TextSpan>[];
    final banglaRegex = RegExp(r'[\u0980-\u09FF\u0964\u0965]+ *');

    final effectiveGeneralStyle = style ??
        pw.TextStyle(
          font: generalFont,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );

    var effectiveBanglaStyle = banglaStyle ??
        pw.TextStyle(
          font: banglaFont ?? original_bp.BanglaFontManager().defaultFont,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );

    if (effectiveBanglaStyle.font == null) {
      effectiveBanglaStyle = effectiveBanglaStyle.copyWith(
        font: banglaFont ?? original_bp.BanglaFontManager().defaultFont,
      );
    }

    int lastIndex = 0;

    for (final match in banglaRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        final nonBanglaText = text.substring(lastIndex, match.start);
        spans.add(pw.TextSpan(
          text: nonBanglaText,
          style: effectiveGeneralStyle,
        ));
      }

      final banglaText = match.group(0)!.safeFix;
      spans.add(pw.TextSpan(
        text: banglaText,
        style: effectiveBanglaStyle,
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      spans.add(pw.TextSpan(
        text: remainingText,
        style: effectiveGeneralStyle,
      ));
    }

    return spans;
  }
}

class Text extends pw.StatelessWidget {
  final String text;
  final double fontSize;
  final pw.FontWeight fontWeight;
  final PdfColor color;
  final pw.TextAlign? textAlign;
  final pw.TextDirection? textDirection;
  final bool? softWrap;
  final bool tightBounds;
  final double textScaleFactor;
  final int? maxLines;
  final pw.TextOverflow? overflow;
  final pw.Font? banglaFont;
  final pw.Font? generalFont;
  final pw.TextStyle? style;
  final pw.TextStyle? banglaStyle;

  Text(
    this.text, {
    this.fontSize = 16,
    this.fontWeight = pw.FontWeight.normal,
    this.color = PdfColors.black,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.tightBounds = false,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.overflow,
    this.banglaFont,
    this.generalFont,
    this.style,
    this.banglaStyle,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.RichText(
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      tightBounds: tightBounds,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      overflow: overflow,
      text: pw.TextSpan(
        children: SafeFixingUtils.getAutoLocalizedSpans(
          text: text,
          banglaFont: banglaFont,
          generalFont: generalFont,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          style: style,
          banglaStyle: banglaStyle,
        ),
      ),
    );
  }
}
