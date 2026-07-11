import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quran/main.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/services/bookmark_service.dart';
import 'package:quran/services/audio_service.dart';

void main() {
  testWidgets('BanglaQuranApp smoke test', (WidgetTester tester) async {
    final settings = SettingsService();
    final bookmarks = BookmarkService();
    final audio = AudioService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: bookmarks),
          ChangeNotifierProvider.value(value: audio),
        ],
        child: const BanglaQuranApp(),
      ),
    );
    expect(find.text('বাংলা কুরআন'), findsOneWidget);
  });
}
