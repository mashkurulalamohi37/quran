import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/pages/home_dashboard.dart';
import 'package:quran/pages/suralist.dart';
import 'package:quran/pages/hadislist.dart';
import 'package:quran/pages/utilities.dart';
import 'package:quran/pages/settings_screen.dart';
import 'package:quran/services/audio_service.dart';
import 'package:quran/services/notification_service.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/services/sound_service.dart';
import 'package:quran/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsService();
  final bookmarks = BookmarkService();
  await settings.load();
  await bookmarks.load();
  await NotificationService.initialize();
  await settings.updatePrayerNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: bookmarks),
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: const BanglaQuranApp(),
    ),
  );
}

class DismissKeyboardNavigationObserver extends NavigatorObserver {
  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FocusManager.instance.primaryFocus?.unfocus();
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FocusManager.instance.primaryFocus?.unfocus();
    super.didPop(route, previousRoute);
  }
}

class BanglaQuranApp extends StatelessWidget {
  const BanglaQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Afnan Quran — أفنان القرآن',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const HomeScreen(),
          navigatorObservers: [DismissKeyboardNavigationObserver()],
        );
      },
    );
  }
}

// ─── Home Navigation Shell ───────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late SoundService _soundService;

  @override
  void initState() {
    super.initState();
    _soundService = SoundService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _soundService.startMonitoring(context.read<SettingsService>());
      _requestPermissionsOnFirstLaunch();
    });
  }

  Future<void> _requestPermissionsOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAskedPermissions = prefs.getBool('_hasAskedPermissions') ?? false;
    if (hasAskedPermissions) return;
    await prefs.setBool('_hasAskedPermissions', true);

    // Request notification permission
    await Permission.notification.request();
    // Request location permission
    await Permission.locationWhenInUse.request();
  }

  @override
  void dispose() {
    _soundService.stopMonitoring();
    super.dispose();
  }

  final List<Widget> _tabs = [
    const HomeDashboard(),
    const SuraList(),
    const HadisList(),
    const UtilitiesScreen(),
    const SettingsScreen(),
  ];


  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("অ্যাপ বন্ধ করুন? 🚪", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text("আপনি কি অ্যাপ থেকে বের হতে চান?", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("না", style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("হ্যাঁ, বের হই", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog();
        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.emerald.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emerald,
                );
              }
              return GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: isDark ? Colors.white70 : Colors.black87),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.emerald),
                label: "হোম",
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined, color: isDark ? Colors.white70 : Colors.black87),
                selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.emerald),
                label: "কুরআন",
              ),
              NavigationDestination(
                icon: Icon(Icons.format_quote_outlined, color: isDark ? Colors.white70 : Colors.black87),
                selectedIcon: const Icon(Icons.format_quote_rounded, color: AppColors.emerald),
                label: "হাদিস",
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: isDark ? Colors.white70 : Colors.black87),
                selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.emerald),
                label: "অন্যান্য",
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black87),
                selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.emerald),
                label: "সেটিংস",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
