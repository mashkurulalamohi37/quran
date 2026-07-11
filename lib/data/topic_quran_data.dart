class TopicVerseRef {
  final int surahId;
  final int ayahNumber;
  final String note; // Brief contextual note in Bengali

  const TopicVerseRef({
    required this.surahId,
    required this.ayahNumber,
    required this.note,
  });
}

class QuranTopic {
  final String title;
  final String icon;
  final String category;
  final List<TopicVerseRef> verses;

  const QuranTopic({
    required this.title,
    required this.icon,
    required this.category,
    required this.verses,
  });
}

const List<QuranTopic> quranTopics = [
  QuranTopic(
    title: 'আল্লাহর একত্ববাদ (তাওহীদ)',
    icon: '☝️',
    category: 'ঈমান ও আকীদা',
    verses: [
      TopicVerseRef(surahId: 112, ayahNumber: 1, note: 'বলুন, তিনিই আল্লাহ, এক-অদ্বিতীয়।'),
      TopicVerseRef(surahId: 112, ayahNumber: 2, note: 'আল্লাহ কারো মুখাপেক্ষী নন, সকলেই তাঁর মুখাপেক্ষী।'),
      TopicVerseRef(surahId: 112, ayahNumber: 3, note: 'তিনি কাউকে জন্ম দেননি এবং জন্ম নেননি।'),
      TopicVerseRef(surahId: 112, ayahNumber: 4, note: 'এবং তাঁর সমকক্ষ কেউ নেই।'),
      TopicVerseRef(surahId: 2, ayahNumber: 255, note: 'আয়াতুল কুরসি: আল্লাহর সার্বভৌমত্ব ও ক্ষমতার বর্ণনা।'),
    ],
  ),
  QuranTopic(
    title: 'পিতা-মাতার প্রতি আচরণ',
    icon: '🤲',
    category: 'পারিবারিক জীবন',
    verses: [
      TopicVerseRef(surahId: 17, ayahNumber: 23, note: 'পিতা-মাতার সাথে ভালো ব্যবহার করুন, তাঁদের প্রতি উফ শব্দটিও বলবেন না।'),
      TopicVerseRef(surahId: 17, ayahNumber: 24, note: 'তাঁদের জন্য দয়া ও রহমতের দুআ করুন।'),
      TopicVerseRef(surahId: 31, ayahNumber: 14, note: 'পিতা-মাতার প্রতি কৃতজ্ঞতা প্রকাশের নির্দেশ।'),
    ],
  ),
  QuranTopic(
    title: 'ধৈর্য ও পরীক্ষা',
    icon: '⏳',
    category: 'চরিত্র ও নৈতিকতা',
    verses: [
      TopicVerseRef(surahId: 2, ayahNumber: 153, note: 'ধৈর্য ও নামাজের মাধ্যমে সাহায্য প্রার্থনা করুন। নিশ্চয়ই আল্লাহ ধৈর্যশীলদের সাথে আছেন।'),
      TopicVerseRef(surahId: 2, ayahNumber: 155, note: 'ভয়, ক্ষুধা ও জান-মালের ক্ষতির মাধ্যমে আল্লাহ মুমিনদের পরীক্ষা করেন।'),
      TopicVerseRef(surahId: 2, ayahNumber: 156, note: 'বিপদে বলুন: নিশ্চয়ই আমরা আল্লাহর জন্য এবং তাঁর কাছেই ফিরে যাব।'),
      TopicVerseRef(surahId: 94, ayahNumber: 5, note: 'নিশ্চয় কষ্টের সাথে স্বস্তি রয়েছে।'),
      TopicVerseRef(surahId: 94, ayahNumber: 6, note: 'নিশ্চয়ই কষ্টের সাথেই স্বস্তি রয়েছে।'),
    ],
  ),
  QuranTopic(
    title: 'নামাজ ও ইবাদত',
    icon: '🕌',
    category: 'ইবাদত ও আমল',
    verses: [
      TopicVerseRef(surahId: 2, ayahNumber: 43, note: 'নামাজ কায়েম করো, যাকাত দাও এবং রুকুকারীদের সাথে রুকু করো।'),
      TopicVerseRef(surahId: 29, ayahNumber: 45, note: 'নিশ্চয়ই নামাজ অশ্লীল ও মন্দ কাজ থেকে বিরত রাখে।'),
      TopicVerseRef(surahId: 20, ayahNumber: 14, note: 'আমাকে স্মরণের উদ্দেশ্যে নামাজ কায়েম করুন।'),
    ],
  ),
  QuranTopic(
    title: 'বিবাহ ও দাম্পত্য শান্তি',
    icon: '💍',
    category: 'পারিবারিক জীবন',
    verses: [
      TopicVerseRef(surahId: 30, ayahNumber: 21, note: 'তিনি তোমাদের মধ্য থেকে তোমাদের সঙ্গী সৃষ্টি করেছেন যাতে তোমরা শান্তি পাও এবং ভালোবাসা সৃষ্টি করেছেন।'),
      TopicVerseRef(surahId: 4, ayahNumber: 19, note: 'স্ত্রীদের সাথে সদ্ভাবে জীবনযাপন করুন।'),
    ],
  ),
  QuranTopic(
    title: 'পরকাল ও বিচার দিবস',
    icon: '⚖️',
    category: 'ঈমান ও আকীদা',
    verses: [
      TopicVerseRef(surahId: 99, ayahNumber: 7, note: 'কেউ অণু পরিমাণ ভালো কাজ করলে তা দেখতে পাবে।'),
      TopicVerseRef(surahId: 99, ayahNumber: 8, note: 'কেউ অণু পরিমাণ মন্দ কাজ করলে তাও দেখতে পাবে।'),
      TopicVerseRef(surahId: 101, ayahNumber: 6, note: 'যার পাল্লা ভারী হবে সে সন্তোষজনক জীবনে থাকবে।'),
      TopicVerseRef(surahId: 101, ayahNumber: 7, note: 'এবং যার পাল্লা হালকা হবে, তার স্থান হবে হাবিয়া।'),
    ],
  ),
  QuranTopic(
    title: 'রাগ নিয়ন্ত্রণ ও ক্ষমা',
    icon: '🤝',
    category: 'চরিত্র ও নৈতিকতা',
    verses: [
      TopicVerseRef(surahId: 3, ayahNumber: 134, note: 'যারা রাগ সংবরণ করে ও মানুষকে ক্ষমা করে। আল্লাহ সৎকর্মশীলদের ভালোবাসেন।'),
      TopicVerseRef(surahId: 42, ayahNumber: 37, note: 'যখন তারা রাগান্বিত হয়, তখন তারা ক্ষমা করে দেয়।'),
    ],
  ),
  QuranTopic(
    title: 'রোজা ও রমজান',
    icon: '🌙',
    category: 'ইবাদত ও আমল',
    verses: [
      TopicVerseRef(surahId: 2, ayahNumber: 183, note: 'হে মুমিনগণ, তোমাদের ওপর রোজা ফরজ করা হয়েছে, যেমন তোমাদের পূর্ববর্তীদের ওপর করা হয়েছিল, যাতে তোমরা তাকওয়া অর্জন করতে পারো।'),
      TopicVerseRef(surahId: 2, ayahNumber: 185, note: 'রমজান মাস, যাতে কুরআন অবতীর্ণ হয়েছে মানুষের পথপ্রদর্শক হিসেবে।'),
    ],
  ),
];
