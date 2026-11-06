import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/splash_controller.dart';

/// Premium animated splash screen for INERTIA SPORTS ACADEMY
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>(); // Ensure controller is active

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dark Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF090B10),
                    Color(0xFF10141F),
                    Color(0xFF161C2C),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Subtle Golden Ambient Glow at the Center
          Positioned.fill(
            child: Center(
              child: Container(
                width: 240.h,
                height: 240.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x1AF59E0B),
                    width: 40,
                  ),
                ),
              ),
            ),
          ),

          // Subtle Athletic Grid Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashGridPainter(),
            ),
          ),

          // Center Logo and INERTIA SPORTS ACADEMY Title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Logo Emblem with Glow & EST. 2024 Badge
                    _buildLogoEmblem(),
                    SizedBox(height: 28.h),

                    // INERTIA (Top) & SPORTS ACADEMY (Bottom) in CAPS
                    Column(
                      children: [
                        Text(
                          'INERTIA',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3.0,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'SPORTS ACADEMY',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFF59E0B),
                            letterSpacing: 4.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Tagline in CAPS
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0x0DFFFFFF),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0x40F59E0B),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'GATEWAY TO SPORTS EXCELLENCE',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Loading / Subtitle
          Positioned(
            bottom: 36.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'MULTI-SPORT TRAINING & ARENA BOOKINGS',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0x66FFFFFF),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoEmblem() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer Glowing Orbit Ring (Shader safe)
        Container(
          width: 168.h,
          height: 168.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0x44F59E0B),
              width: 1.5,
            ),
          ),
        ),

        // Main Circular Emblem Box (140.h)
        Container(
          width: 140.h,
          height: 140.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF181C26),
            border: Border.all(
              color: const Color(0xFFF59E0B),
              width: 3.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo/logo.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 68.sp,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ),

        // EST. 2024 Pill
        Positioned(
          bottom: -8.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EST.',
                  style: GoogleFonts.inter(
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '2024',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom grid lines painter for splash screen
class _SplashGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x09F59E0B)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const double step = 34.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
