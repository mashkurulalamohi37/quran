class SunnahHabit {
  final String id;
  final String title;
  final String description;
  final String category;
  final String rewardHint; // Motivational saying or reward info in Bengali
  final bool fridayOnly; // Habit is only active on Fridays

  const SunnahHabit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rewardHint,
    this.fridayOnly = false,
  });
}

const List<SunnahHabit> sunnahHabits = [
  SunnahHabit(
    id: 'miswak',
    title: 'মিসওয়াক করা',
    description: 'ওযুর পূর্বে বা মুখ পরিষ্কার করতে মিসওয়াক করা।',
    category: 'পবিত্রতা',
    rewardHint: 'রাসূলুল্লাহ (সা.) বলেছেন: "মিসওয়াক মুখের পবিত্রতা এবং রবের সন্তুষ্টি অর্জনের মাধ্যম।"',
  ),
  SunnahHabit(
    id: 'sleep_right',
    title: 'ডান কাতে ঘুমানো',
    description: 'রাতে ঘুমানোর সময় ডান কাতে শোয়া ও ঘুমানোর দুআ পড়া।',
    category: 'দৈনন্দিন অভ্যাস',
    rewardHint: 'রাসূলুল্লাহ (সা.) রাতে ঘুমাতে যাওয়ার সময় ডান কাতে শুতেন এবং দুআ পড়তেন।',
  ),
  SunnahHabit(
    id: 'charity',
    title: 'দান-সদকাহ করা',
    description: 'ছোট বা বড় অঙ্কের নগদ টাকা বা কাউকে সাহায্য করা/হাসিমুখে কথা বলা।',
    category: 'সামাজিক আমল',
    rewardHint: 'সদকা বিপদ দূর করে এবং গুনাহ দূর করে যেমন পানি আগুনকে নেভায়।',
  ),
  SunnahHabit(
    id: 'salah_jamaat',
    title: 'জামাতে সালাত আদায়',
    description: 'পাঁচ ওয়াক্ত ফরজ নামাজ জামাতে (পুরুষদের জন্য মসজিদে) আদায় করার চেষ্টা করা।',
    category: 'ইবাদত',
    rewardHint: 'জামাতে সালাত একা পড়ার চেয়ে ২৭ গুণ বেশি সওয়াব বহন করে।',
  ),
  SunnahHabit(
    id: 'surah_mulk',
    title: 'সূরা মূলক তিলাওয়াত',
    description: 'প্রতি রাতে ঘুমানোর পূর্বে সূরা আল-মূলক তিলাওয়াত করা।',
    category: 'তিলাওয়াত',
    rewardHint: 'এই সূরাটি কবরের আজাব থেকে তিলাওয়াতকারীকে রক্ষা করার জন্য সুপারিশ করবে।',
  ),
  SunnahHabit(
    id: 'waking_sunnah',
    title: 'জেগে ওঠার সুন্নাত',
    description: 'ঘুম থেকে উঠে দুই হাত দিয়ে মুখমণ্ডল মর্দন করা এবং ঘুম থেকে ওঠার দুআ পড়া।',
    category: 'দৈনন্দিন অভ্যাস',
    rewardHint: 'ঘুম থেকে উঠে আল্লাহকে স্মরণ করলে শয়তানের বাঁধন খুলে যায়।',
  ),
  SunnahHabit(
    id: 'surah_kahf',
    title: 'সূরা কাহাফ তিলাওয়াত',
    description: 'পবিত্র জুমার দিনে সূরা আল-কাহাফ তিলাওয়াত করা বা শোনা।',
    category: 'তিলাওয়াত',
    rewardHint: 'রাসূলুল্লাহ (সা.) বলেছেন: "যে ব্যক্তি জুমার দিন সূরা কাহাফ পড়বে, তার জন্য দুই জুমার মধ্যবর্তী সময় আলোকময় হবে।"',
    fridayOnly: true,
  ),
];
