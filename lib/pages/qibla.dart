import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import 'package:quran/services/settings_service.dart';
import 'package:quran/services/prayer_service.dart';
import 'package:quran/theme/app_theme.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  QiblaCompassScreenState createState() => QiblaCompassScreenState();
}

class QiblaCompassScreenState extends State<QiblaCompassScreen> {
  double _latitude = 23.8103; // Default Dhaka
  double _longitude = 90.4125;
  double _qiblaDirection = 0;
  bool _loadingLocation = true;
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final settings = context.read<SettingsService>();
    if (settings.isAutomaticLocation) {
      final pos = await PrayerService.getPosition();
      if (pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationName = 'আমার অবস্থান (GPS)';
      } else {
        // Fallback to selected district
        final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
        _latitude = dist.latitude;
        _longitude = dist.longitude;
        _locationName = '${dist.nameBn} (${dist.nameEn})';
      }
    } else {
      final dist = PrayerService.getDistrictByName(settings.selectedDistrict);
      _latitude = dist.latitude;
      _longitude = dist.longitude;
      _locationName = '${dist.nameBn} (${dist.nameEn})';
    }

    // Calculate Qibla direction using adhan package
    final coordinates = Coordinates(_latitude, _longitude);
    _qiblaDirection = Qibla(coordinates).direction;

    if (mounted) {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsService>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("কিবলা কম্পাস"),
      ),
      body: _loadingLocation
          ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState("কম্পাস সেন্সর পড়তে সমস্যা হচ্ছে।", isDark);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
                }

                double? heading = snapshot.data?.heading;
                if (heading == null) {
                  return _buildErrorState("আপনার ডিভাইসে কম্পাস সেন্সর পাওয়া যায়নি।", isDark);
                }

                // Calculate rotations in radians
                double deviceHeadingRad = heading * (math.pi / 180.0);
                double qiblaHeadingRad = _qiblaDirection * (math.pi / 180.0);

                // Compass rotates in opposite direction of device heading
                double compassRotation = -deviceHeadingRad;
                // Needle rotates relative to device heading to point to Qibla
                double needleRotation = qiblaHeadingRad - deviceHeadingRad;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _locationName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "কিবলার কোণ: ${_qiblaDirection.round()}° উত্তর থেকে পূর্ব",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Compass Stack
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Dial base
                            Transform.rotate(
                              angle: compassRotation,
                              child: _buildCompassDial(isDark),
                            ),
                            // 2. Qibla Needle (points to Kaaba)
                            Transform.rotate(
                              angle: needleRotation,
                              child: _buildQiblaNeedle(),
                            ),
                            // 3. Center pin
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Instruction text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        "মোবাইলটি সোজা সমান্তরালভাবে (flat) ধরে রাখুন। লাল কিবলা সূচকটি কা’বার দিক নির্দেশ করে।",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCompassDial(bool isDark) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.2),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cardinal Directions
          Positioned(
            top: 14,
            child: Text("N", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
          ),
          Positioned(
            bottom: 14,
            child: Text("S", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white70 : Colors.black87)),
          ),
          Positioned(
            left: 14,
            child: Text("W", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white70 : Colors.black87)),
          ),
          Positioned(
            right: 14,
            child: Text("E", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white70 : Colors.black87)),
          ),

          // Tick marks (circles inside)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Long needle pointing to top (Kaaba direction)
        Positioned(
          top: 30,
          child: Column(
            children: [
              const Icon(
                Icons.mosque_rounded,
                color: AppColors.goldDark,
                size: 26,
              ),
              const SizedBox(height: 4),
              CustomPaint(
                size: const Size(12, 100),
                painter: _NeedlePainter(color: AppColors.gold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String msg, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "সেন্সর পাওয়া যায়নি",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "$msg কিবলা দিকনির্দেশনার জন্য GPS এবং কম্পাস সেন্সর থাকা আবশ্যক।",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  final Color color;
  _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
