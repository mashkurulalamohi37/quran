class QaidaItem {
  final String arabic;
  final String banglaPron;
  final String description;

  const QaidaItem({
    required this.arabic,
    required this.banglaPron,
    required this.description,
  });
}

class QaidaLesson {
  final int id;
  final String title;
  final String subtitle;
  final String introduction;
  final List<QaidaItem> items;

  const QaidaLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.introduction,
    required this.items,
  });
}

const List<QaidaLesson> qaidaLessons = [
  QaidaLesson(
    id: 1,
    title: 'পাঠ ১: ২৯টি আরবি হরফ',
    subtitle: 'আরবি বর্ণমালা ও উচ্চারণ',
    introduction: 'আরবি ভাষায় মোট ২৯টি অক্ষর বা হরফ রয়েছে। এগুলো ডান দিক থেকে বাম দিকে পড়তে হয়। নিচে প্রতিটি হরফের বাংলা উচ্চারণ ও উচ্চারণের সঠিক স্থান (মাখরাজ) দেওয়া হলো:',
    items: [
      QaidaItem(arabic: 'ا', banglaPron: 'আলিফ', description: 'মুখের খালি জায়গা থেকে স্বাভাবিকভাবে উচ্চারিত হয়।'),
      QaidaItem(arabic: 'ب', banglaPron: 'বা', description: 'দুই ঠোঁটের ভেজা অংশ থেকে উচ্চারিত হয়।'),
      QaidaItem(arabic: 'ت', banglaPron: 'তা', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের গোড়ার সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'ث', banglaPron: 'ছা', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের আগার সাথে লাগিয়ে (নরম করে)।'),
      QaidaItem(arabic: 'ج', banglaPron: 'জীম', description: 'জিহ্বার মধ্যখান তার বরাবর উপরের তালুর সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'ح', banglaPron: 'হা', description: 'হলকের (কণ্ঠনালীর) মধ্যভাগ হতে চাপ দিয়ে হালকাভাবে।'),
      QaidaItem(arabic: 'خ', banglaPron: 'খা', description: 'হলকের শেষ ভাগ (মুখের দিকে) হতে খসখসে আওয়াজে মোটা করে।'),
      QaidaItem(arabic: 'د', banglaPron: 'দাল', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের গোড়ার সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'ذ', banglaPron: 'যাল', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের আগার সাথে লাগিয়ে (নরম করে)।'),
      QaidaItem(arabic: 'ر', banglaPron: 'রা', description: 'জিহ্বার আগার পিঠ তার বরাবর উপরের তালুর সাথে লাগিয়ে (মোটা করে)।'),
      QaidaItem(arabic: 'ز', banglaPron: 'যা', description: 'জিহ্বার আগা সামনের নিচের দুই দাঁতের পেটের সাথে মিলিয়ে (শীশ দিয়ে)।'),
      QaidaItem(arabic: 'س', banglaPron: 'সীন', description: 'জিহ্বার আগা সামনের নিচের দুই দাঁতের আগার সাথে মিলিয়ে (শীশ দিয়ে)।'),
      QaidaItem(arabic: 'ش', banglaPron: 'শীন', description: 'জিহ্বার মধ্যখান তার বরাবর উপরের তালুর সাথে লাগিয়ে বাতাসে ছড়িয়ে।'),
      QaidaItem(arabic: 'ص', banglaPron: 'সোয়াদ', description: 'জিহ্বার আগা সামনের নিচের দুই দাঁতের সাথে লাগিয়ে মোটা আওয়াজে।'),
      QaidaItem(arabic: 'ض', banglaPron: 'যোয়াদ', description: 'জিহ্বার গোড়ার ডান বা বাম পাশ উপরের মাড়ির দাঁতের গোড়ার সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'ط', banglaPron: 'তয়া', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের গোড়ার সাথে লাগিয়ে মোটা আওয়াজে।'),
      QaidaItem(arabic: 'ظ', banglaPron: 'যোয়া', description: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের আগার সাথে লাগিয়ে মোটা আওয়াজে।'),
      QaidaItem(arabic: 'ع', banglaPron: 'আইন', description: 'হলকের মধ্যভাগ হতে চিপে বা ঘর্ষণ দিয়ে পরিষ্কারভাবে।'),
      QaidaItem(arabic: 'غ', banglaPron: 'গাইন', description: 'হলকের শেষ ভাগ হতে মোটা আওয়াজে গরগর করে।'),
      QaidaItem(arabic: 'ف', banglaPron: 'ফা', description: 'সামনের উপরের দুই দাঁতের আগা নিচের ঠোঁটের ভেতরের পেটে লাগিয়ে।'),
      QaidaItem(arabic: 'ق', banglaPron: 'ক্বফ', description: 'জিহ্বার গোড়া তার বরাবর উপরের তালুর সাথে লাগিয়ে মোটা ও শক্তভাবে।'),
      QaidaItem(arabic: 'ك', banglaPron: 'কাফ', description: 'জিহ্বার গোড়া থেকে একটু আগে বাড়িয়ে নরমভাবে।'),
      QaidaItem(arabic: 'ل', banglaPron: 'লাম', description: 'জিহ্বার আগার পাশ তার বরাবর উপরের তালুর সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'م', banglaPron: 'মীম', description: 'দুই ঠোঁটের শুকনা অংশ মিলিয়ে উচ্চারিত হয়।'),
      QaidaItem(arabic: 'ن', banglaPron: 'নূন', description: 'জিহ্বার আগা তার বরাবর উপরের তালুর সাথে লাগিয়ে।'),
      QaidaItem(arabic: 'و', banglaPron: 'ওয়াও', description: 'দুই ঠোঁট গোল করে মধ্যখানে ফাঁক রেখে উচ্চারিত হয়।'),
      QaidaItem(arabic: 'ه', banglaPron: 'হা (বড়)', description: 'হলকের শুরু (বুকের দিকে) হতে স্বাভাবিকভাবে।'),
      QaidaItem(arabic: 'ي', banglaPron: 'ইয়া', description: 'জিহ্বার মধ্যখান উপরের তালুর সাথে লাগিয়ে স্বাভাবিকভাবে।'),
    ],
  ),
  QaidaLesson(
    id: 2,
    title: 'পাঠ ২: হরকত (Short Vowels)',
    subtitle: 'যবর, জের ও পেশ এর ব্যবহার',
    introduction: 'আরবিতে স্বরচিহ্নকে "হরকত" বলা হয়। হরকত ৩টি: যবর ( َ ), জের ( ِ ), পেশ ( ُ )। হরকতের উচ্চারণ তাড়াতাড়ি করতে হয়, টেনে পড়া যাবে না।',
    items: [
      QaidaItem(arabic: 'بَ', banglaPron: 'বা-যবর "বা"', description: 'আ-কার এর মতো উচ্চারণ হবে।'),
      QaidaItem(arabic: 'بِ', banglaPron: 'বা-জের "বি"', description: 'ই-কার এর মতো উচ্চারণ হবে।'),
      QaidaItem(arabic: 'بُ', banglaPron: 'বা-পেশ "বু"', description: 'উ-কার এর মতো উচ্চারণ হবে।'),
      QaidaItem(arabic: 'تَ - تِ - تُ', banglaPron: 'তা - তি - তু', description: 'তাড়াতাড়ি উচ্চারণ করুন।'),
      QaidaItem(arabic: 'جَ - جِ - جُ', banglaPron: 'জা - জি - জু', description: 'টান ছাড়া উচ্চারণ করুন।'),
    ],
  ),
  QaidaLesson(
    id: 3,
    title: 'পাঠ ৩: তানভীন (Double Vowels)',
    subtitle: 'দুই যবর, দুই জের ও দুই পেশ',
    introduction: 'দুই যবর ( ً ), দুই জের ( ٍ ) এবং দুই পেশ ( ٌ ) কে "তানভীন" বলে। তানভীনের উচ্চারণের শেষে একটি নূন-সাকিন (ন্) এর উচ্চারণ যুক্ত হয়।',
    items: [
      QaidaItem(arabic: 'بً', banglaPron: 'বান', description: 'বা + ন্ = বান (দুই যবর)'),
      QaidaItem(arabic: 'بٍ', banglaPron: 'বিন', description: 'বা + ন্ = বিন (দুই জের)'),
      QaidaItem(arabic: 'بٌ', banglaPron: 'বুন', description: 'বা + ন্ = বুন (দুই পেশ)'),
      QaidaItem(arabic: 'أً - إٍ - أٌ', banglaPron: 'আন - ইন - উন', description: 'আলিফের ওপর তানভীন।'),
      QaidaItem(arabic: 'مً - مٍ - مٌ', banglaPron: 'মান - মিন - মুন', description: 'মীমের ওপর তানভীন।'),
    ],
  ),
  QaidaLesson(
    id: 4,
    title: 'পাঠ ৪: জযম বা সুকুন',
    subtitle: 'হরফ যুক্ত করার নিয়ম',
    introduction: 'অর্ধচন্দ্র বা গোল চিহ্নেকে ( ْ ) জযম বা সুকুন বলে। জযমযুক্ত হরফ নিজে উচ্চারিত হতে পারে না, তা পূর্বের হরকতের সাথে যুক্ত হয়ে উচ্চারিত হয়।',
    items: [
      QaidaItem(arabic: 'أَبْ', banglaPron: 'আবছ্ / আব্', description: 'আলিফ-যবর বা-সাকিন = আব্।'),
      QaidaItem(arabic: 'أَمْ', banglaPron: 'আম্', description: 'আলিফ-যবর মীম-সাকিন = আম্।'),
      QaidaItem(arabic: 'هُمْ', banglaPron: 'হুম্', description: 'হা-পেশ মীম-সাকিন = হুম্।'),
      QaidaItem(arabic: 'مِنْ', banglaPron: 'মিন্', description: 'মীম-জের নূন-সাকিন = মিন্।'),
    ],
  ),
  QaidaLesson(
    id: 5,
    title: 'পাঠ ৫: তাশদীদ (Tashdeed)',
    subtitle: 'দ্বিত্ব উচ্চারণ এর নিয়ম',
    introduction: 'তিন দাঁতওয়ালা চিহ্নকে ( ّ ) তাশদীদ বলে। তাশদীদযুক্ত হরফ দুইবার উচ্চারিত হয় — প্রথমবার তার পূর্বের হরকতের সাথে যুক্ত হয়ে, দ্বিতীয়বার নিজের হরকতের সাথে।',
    items: [
      QaidaItem(arabic: 'أَبَّ', banglaPron: 'আব্বা', description: 'আলিফ-যবর বা-সাকিন (আব্) + বা-যবর (বা) = আব্বা।'),
      QaidaItem(arabic: 'إِنَّ', banglaPron: 'ইন্না', description: 'আলিফ-জের নূন-সাকিন (ইন্) + নূন-যবর (না) = ইন্না (সাথে গুন্নাহ করতে হবে)।'),
      QaidaItem(arabic: 'رَبِّ', banglaPron: 'রব্বি', description: 'রা-যবর বা-সাকিন (রব্) + বা-জের (বি) = রব্বি।'),
      QaidaItem(arabic: 'ثُمَّ', banglaPron: 'ছুম্মা', description: 'ছা-পেশ মীম-সাকিন (ছুম্) + মীম-যবর (মা) = ছুম্মা।'),
    ],
  ),
  QaidaLesson(
    id: 6,
    title: 'পাঠ ৬: কলকলাহ (Echoing)',
    subtitle: 'প্রতিধ্বনি করে পড়ার নিয়ম',
    introduction: 'কলকলাহ এর হরফ ৫টি: ক্বফ (ق), তয়া (ط), বা (ب), জীম (ج), দাল (د)। সংক্ষেপে (কুতুবু জাদ)। এই ৫টি হরফে জযম হলে প্রতিধ্বনি বা ধাক্কা দিয়ে পড়তে হয়।',
    items: [
      QaidaItem(arabic: 'أَقْ', banglaPron: 'আক্ব্ (প্রতিধ্বনি)', description: 'আলিফ-যবর ক্বফ-সাকিন = আক্ব্ (ধাক্কা দিয়ে)।'),
      QaidaItem(arabic: 'أَبْ', banglaPron: 'আব্ (প্রতিধ্বনি)', description: 'আলিফ-যবর বা-সাকিন = আব্ (ধাক্কা দিয়ে)।'),
      QaidaItem(arabic: 'يَدْ', banglaPron: 'ইয়াদ্ (প্রতিধ্বনি)', description: 'ইয়া-যবর দাল-সাকিন = ইয়াদ্ (ধাক্কা দিয়ে)।'),
      QaidaItem(arabic: 'أَجْ', banglaPron: 'আজ্ (প্রতিধ্বনি)', description: 'আলিফ-যবর জীম-সাকিন = আজ্ (ধাক্কা দিয়ে)।'),
    ],
  ),
  QaidaLesson(
    id: 7,
    title: 'পাঠ ৭: মদ্দের নিয়ম (Stretching)',
    subtitle: 'টেনে পড়ার নিয়ম',
    introduction: 'মদ্দের হরফ ৩টি: আলিফ (খালি আলিফের পূর্বে যবর), ওয়াও (জযমওয়ালা ওয়াও-এর পূর্বে পেশ), ইয়া (জযমওয়ালা ইয়া-এর পূর্বে জের)। মদ্দের হরফ হলে ১ আলিফ পরিমাণ টেনে পড়তে হয়।',
    items: [
      QaidaItem(arabic: 'بَا', banglaPron: 'বা-আলিফ-যবর "বাআ"', description: '১ আলিফ (১ সেকেন্ড) টেনে পড়ুন।'),
      QaidaItem(arabic: 'بُو', banglaPron: 'বা-ওয়াও-পেশ "বূূ"', description: '১ আলিফ টেনে পড়তে হবে।'),
      QaidaItem(arabic: 'بِي', banglaPron: 'বা-ইয়া-জের "বী"', description: '১ আলিফ টেনে পড়ুন।'),
      QaidaItem(arabic: 'مَا - مُو - مِي', banglaPron: 'মা - মূ - মী', description: 'টেনে উচ্চারণ করুন।'),
    ],
  ),
  QaidaLesson(
    id: 8,
    title: 'পাঠ ৮: নূন সাকিন ও তানভীন',
    subtitle: 'ইযহার ও ইখফা এর নিয়ম',
    introduction: 'জযমযুক্ত নূন (নূনে সাকিন) এবং তানভীনের ৪টি নিয়ম আছে। তার মধ্যে প্রধান ২টি হলো: ১. ইযহার (পরিষ্কার করে পড়া), ২. ইখফা (নাক দিয়ে গুন্নাহ করে লুকিয়ে পড়া)।',
    items: [
      QaidaItem(arabic: 'مِنْ خَوْفٍ', banglaPron: 'মিন্ খওফিন্ (ইযহার)', description: 'নূন সাকিনের পর গলা থেকে উচ্চারিত হরফ (খ) থাকায় গুন্নাহ ছাড়া পরিষ্কার করে পড়তে হবে।'),
      QaidaItem(arabic: 'أَنْعَمْتَ', banglaPron: 'আন্\'আম্তা (ইযহার)', description: 'নূন সাকিনের পর (আইন) থাকায় পরিষ্কার করে পড়া।'),
      QaidaItem(arabic: 'مِنْ قَبْلِ', banglaPron: 'মিং ক্বব্লি (ইখফা)', description: 'নূন সাকিনের পর গুন্নাহর হরফ (ক্বফ) থাকায় নাকে গুন্নাহ করে পড়তে হবে।'),
      QaidaItem(arabic: 'مَنْ دَخَلَ', banglaPron: 'মাং দাখালা (ইখফা)', description: 'নাক দিয়ে লুকিয়ে গুন্নাহ করুন।'),
    ],
  ),
  QaidaLesson(
    id: 9,
    title: 'পাঠ ৯: ওয়াজিব গুন্নাহ ও মীম সাকিন',
    subtitle: 'গুন্নাহ ও মীম সাকিন এর নিয়ম',
    introduction: '১. ওয়াজিব গুন্নাহ: নূন (ন) বা মীম (ম) এর ওপর তাশদীদ থাকলে নাকে গুন্নাহ করে পড়া ওয়াজিব। ২. মীম সাকিন: জযমযুক্ত মীমের পর মীম বা বা আসলে গুন্নাহ করে পড়তে হয়।',
    items: [
      QaidaItem(arabic: 'إِنَّ', banglaPron: 'ইন্না (ওয়াজিব গুন্নাহ)', description: 'তাশদীদযুক্ত নূন থাকায় ১ আলিফ সময় নাকে ধরে রেখে গুন্নাহ করতে হবে।'),
      QaidaItem(arabic: 'ثُمَّ', banglaPron: 'ছুম্মা (ওয়াজিব গুন্নাহ)', description: 'তাশদীদযুক্ত মীম থাকায় গুন্নাহ করা আবশ্যক।'),
      QaidaItem(arabic: 'لَهُمْ مَثَلًا', banglaPron: 'লাহুম্-মাছালান (গুন্নাহ)', description: 'মীম সাকিনের পর মীম আসায় মিলিয়ে গুন্নাহ করতে হবে।'),
      QaidaItem(arabic: 'تَرْمِيهِمْ بِحِجَارَةٍ', banglaPron: 'তারমীহিম্-বিহিজারাহ (ইখফা)', description: 'মীম সাকিনের পর বা আসায় গুন্নাহ হবে।'),
    ],
  ),
  QaidaLesson(
    id: 10,
    title: 'পাঠ ১০: ওয়াকফ বা থামার নিয়ম',
    subtitle: 'কুরআন তিলাওয়াতে থামার নিয়ম',
    introduction: 'আয়াতের শেষে বা বিভিন্ন ওয়াকফ চিহ্নে (যেমন: মীম ۥ, তয়া ۥ, জীম ۥ) শ্বাস ছাড়ার জন্য থামতে হয়। থামার সময় শেষ হরফের হরকত জযম বা সুকুনে রূপান্তরিত হয়।',
    items: [
      QaidaItem(arabic: 'الْعَالَمِينَ ۥ', banglaPron: 'আল-আলামীন (থামার সময়)', description: 'থামলে শেষ হরফের যবর জযম হয়ে যাবে এবং ন্ উচ্চারণ হবে।'),
      QaidaItem(arabic: 'أَحَدٌ ۥ', banglaPron: 'আহাদ্ (থামার সময়)', description: 'তানভীন থাকলে থামার পর তা জযম হয়ে যাবে (কলকলাহ হবে)।'),
      QaidaItem(arabic: 'نَارٌ حَامِيَةٌ ۥ', banglaPron: 'নারুন হামিয়াহ্ (থামার সময়)', description: 'গোল তা (ة) থাকলে থামার সময় তা হা (হ্) হয়ে যায়।'),
      QaidaItem(arabic: 'رَحْمَةً ۥ', banglaPron: 'রাহ্মাহ্ (থামার সময়)', description: 'গোল তা থাকলে হ-এর মতো উচ্চারণ হবে।'),
    ],
  ),
];

