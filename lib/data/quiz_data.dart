class QuizQuestion {
  final String word; // Arabic word
  final String correctTranslation; // Bengali meaning
  final List<String> options; // 4 multiple-choice options

  const QuizQuestion({
    required this.word,
    required this.correctTranslation,
    required this.options,
  });
}

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    word: 'رَبّ',
    correctTranslation: 'প্রতিপালক / প্রভূ',
    options: ['সৃষ্টিকর্তা', 'প্রতিপালক / প্রভূ', 'মালিক', 'বিচারক'],
  ),
  QuizQuestion(
    word: 'قَلْب',
    correctTranslation: 'অন্তর',
    options: ['মস্তিষ্ক', 'চোখ', 'অন্তর', 'জিহ্বা'],
  ),
  QuizQuestion(
    word: 'يَوْم',
    correctTranslation: 'দিন',
    options: ['মাস', 'বছর', 'দিন', 'সপ্তাহ'],
  ),
  QuizQuestion(
    word: 'الْآخِرَة',
    correctTranslation: 'পরকাল',
    options: ['পৃথিবী', 'আকাশ', 'পরকাল', 'জান্নাত'],
  ),
  QuizQuestion(
    word: 'عَذَاب',
    correctTranslation: 'শাস্তি',
    options: ['পুরস্কার', 'দয়া', 'শাস্তি', 'ক্ষমা'],
  ),
  QuizQuestion(
    word: 'أَرْض',
    correctTranslation: 'পৃথিবী',
    options: ['আকাশ', 'পৃথিবী', 'পাহাড়', 'সমুদ্র'],
  ),
  QuizQuestion(
    word: 'سَمَاء',
    correctTranslation: 'আকাশ',
    options: ['আকাশ', 'পৃথিবী', 'চন্দ্র', 'সূর্য'],
  ),
  QuizQuestion(
    word: 'كِتَاب',
    correctTranslation: 'বই / গ্রন্থ',
    options: ['কলম', 'বই / গ্রন্থ', 'খাতা', 'চিঠি'],
  ),
  QuizQuestion(
    word: 'رَحْمَة',
    correctTranslation: 'রহমত / দয়া',
    options: ['শাস্তি', 'ক্রোধ', 'রহমত / দয়া', 'জ্ঞান'],
  ),
  QuizQuestion(
    word: 'عِلْم',
    correctTranslation: 'জ্ঞান',
    options: ['অজ্ঞানতা', 'বলপ্রয়োগ', 'সম্পদ', 'জ্ঞান'],
  ),
  QuizQuestion(
    word: 'نُور',
    correctTranslation: 'আলো',
    options: ['অন্ধকার', 'আলো', 'আগুন', 'পানি'],
  ),
  QuizQuestion(
    word: 'جَنَّة',
    correctTranslation: 'জান্নাত / বাগান',
    options: ['জাহান্নাম', 'জান্নাত / বাগান', 'মরুভূমি', 'নদী'],
  ),
  QuizQuestion(
    word: 'نَاس',
    correctTranslation: 'মানুষ',
    options: ['ফেরেশতা', 'জীন', 'মানুষ', 'পশু'],
  ),
  QuizQuestion(
    word: 'خَوْف',
    correctTranslation: 'ভয়',
    options: ['সাহস', 'ভয়', 'আনন্দ', 'আশা'],
  ),
  QuizQuestion(
    word: 'صِدْق',
    correctTranslation: 'সত্য',
    options: ['মিথ্যা', 'সত্য', 'ধোঁকা', 'অহংকার'],
  ),
  QuizQuestion(
    word: 'حَقّ',
    correctTranslation: 'সত্য / অধিকার',
    options: ['বাতিল / মিথ্যা', 'সত্য / অধিকার', 'পরাজয়', 'সন্দেহ'],
  ),
  QuizQuestion(
    word: 'مَوْت',
    correctTranslation: 'মৃত্যু',
    options: ['জীবন', 'ঘুম', 'বার্ধক্য', 'মৃত্যু'],
  ),
  QuizQuestion(
    word: 'صَبْر',
    correctTranslation: 'ধৈর্য',
    options: ['রাগ', 'ধৈর্য', 'তাড়াহুড়ো', 'ভীতি'],
  ),
  QuizQuestion(
    word: 'شُكْر',
    correctTranslation: 'কৃতজ্ঞতা',
    options: ['অকৃতজ্ঞতা', 'নিন্দা', 'কৃতজ্ঞতা', 'অহংকার'],
  ),
  QuizQuestion(
    word: 'ذِكْر',
    correctTranslation: 'স্মরণ / জিকির',
    options: ['ভুলে যাওয়া', 'স্মরণ / জিকির', 'চিন্তা', 'প্রশ্ন'],
  ),
];
