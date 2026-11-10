import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                    // Brand Logo Emblem in Black Circle with Gold Border & Glow
                    _buildLogoEmblem(),
                    SizedBox(height: 28.h),

                    // INERTIA (Top) & SPORTS ACADEMY (Bottom) in CAPS
                    Column(
                      children: [
                        Text(
                          'INERTIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
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
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFD4AF37),
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
                          color: const Color(0x40D4AF37),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'GATEWAY TO SPORTS EXCELLENCE',
                        style: TextStyle(
                          fontFamily: 'Nunito',
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'MULTI-SPORT TRAINING & ARENA BOOKINGS',
                    style: TextStyle(
                      fontFamily: 'Nunito',
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
    return Container(
      width: 140.w,
      height: 140.w,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(22.w),
      child: Center(
        child: Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 56.sp,
              color: const Color(0xFFD4AF37),
            ),
          ),
        ),
      ),
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
