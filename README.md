# Bangla Quran & Islamic Utilities App 🕌

A feature-rich, high-performance Flutter mobile application that serves as a complete Quran reading, listening, and comprehensive Islamic utility suite. Built with offline-first capabilities, elegant UI aesthetics, and smooth 60/120 Hz performance.

---

## 🌟 Key Features

### 📖 Quran Reader & Audio Player
- **Interactive Translation:** Read the Quran with Arabic script, Bangla transliteration, and both English/Bangla translations. Fully customizable font sizes (Arabic and translation) in Settings.
- **Scroll Optimization:** High-frequency scroll-monitoring decoupled from widget rebuilding, ensuring fluid, lag-free scrolling.
- **Audio Stream Syncing:** Play and pause suras with fully synced audio player controls using state streams.
- **Bookmark & Search:** Search suras easily by name or number and bookmark favorite verses.

### 📄 Offline Islamic Will Generator (Wasiyyah)
- **Single-Page PDF:** Generates a Shariah-compliant Islamic Will (ওসীয়তনামা) on a single A4 page containing testator details, general commands, inheritance shares in tabular format, calculation logic, and witness signatures.
- **100% Offline Generation:** Includes bundled local Amiri (`Amiri-Regular.ttf`) and Kalpurush fonts so that Arabic and Bengali scripts render correctly without needing an internet connection.

### 🔔 Smart Dual Waqt Reminders & Grave Warnings
- **Double Alert Reminders:** Schedules two local notifications for each prayer:
  1. **Preparation Alert:** Triggers 30 minutes in advance of the Waqt (e.g. `🌅 ৩০ মিনিট পর ফজর ওয়াক্ত শুরু হবে`).
  2. **Exact Waqt Alert:** Triggers at the exact start minute of the Waqt.
- **Koborer Ajab Warning:** Displays a grave warning reminder in the exact-time notification body to warn users of the consequence of missing prayers (configurable in Settings).

### 📅 Sunnah Tracker & Vocab Quiz
- **Daily Sunnah Tracker:** An interactive checklist containing core Sunnah habits (Tahajjud, Miswak, Dhuha, Ayat-al-Kursi) to build consistency with streak tracking.
- **Quranic Vocab Quiz:** A gamified Arabic-to-Bangla matching quiz with score tracking and progress history.

### 🧭 Essential Utilities
- **Qibla Compass:** Device-sensor aligned compass to locate the Kaaba direction dynamically.
- **Hijri Calendar:** Monthly Hijri date view with a compact dashboard widget.
- **Khatam Planner:** Set goals and track daily reading quotas to finish reading the Quran in a target time.
- **Ramadan Calendar:** Calculates local Sehri and Iftar times based on GPS location or selected district.
- **Janazah, Ziyarat, Tasbih & Duas:** step-by-step funeral prayer guides, digital dhikr counter, and classified prayers.

---

## 🛠️ Installation & Setup

### Prerequisites
- **Flutter SDK:** `>=3.3.0 <4.0.0`
- **Android Studio** or **VS Code** with Flutter extensions installed.

### Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/mashkurulalamohi37/quran.git
   cd quran
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on a connected device/emulator:
   ```bash
   flutter run
   ```
4. Build the release APK:
   ```bash
   flutter build apk --release
   ```
   *The built APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 🔑 Permissions

The app automatically prompts for required permissions on the first launch:
- **Notification Permission:** Required for scheduling prayer Waqt reminders and daily reminders.
- **Location Permission:** Required for automatic GPS prayer timings and compass alignment.

---

## 📂 Key Architecture & Services

- **[main.dart](lib/main.dart):** Application entry point, navigation observers, and home tabs structure.
- **[settings_service.dart](lib/services/settings_service.dart):** Central state manager for themes, font sizes, location profiles, and SharedPreferences.
- **[notification_service.dart](lib/services/notification_service.dart):** Custom local notification scheduler for daily Ayahs and dual Waqt alarms.
- **[bangla_pdf_helper.dart](lib/services/bangla_pdf_helper.dart):** Unicode Bengali text shaper, vowel rearranging logic, and ANSI conversion map.
- **[will_pdf_generator.dart](lib/services/will_pdf_generator.dart):** Compile engine for the single-page Islamic Will PDF using offline font assets.
