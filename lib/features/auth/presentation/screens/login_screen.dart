import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Dedicated Login Page matching https://fee.kineticsportsacademy.in/#/auth
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

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
      backgroundColor: const Color(0xFFF9D106),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Solid Uniform Brand Yellow Background (#F9D106)
          Positioned.fill(child: Container(color: const Color(0xFFF9D106))),

          // Giant Vertical "LOGIN" Watermark at TOP RIGHT (Behind content)
          Positioned(
            right: 4.w,
            top: 45.h,
            child: IgnorePointer(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 58.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0x30FFFFFF),
                    letterSpacing: 10.0,
                  ),
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar: Back to User Selection & "Skip to Booking" Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back to User Selection
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Get.back();
                          } else {
                            Get.offNamed(AppRoutes.userSelection);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0x66FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // "Skip to Booking" Link
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            controller.startGuestBookingFlow();
                          },
                          child: Text(
                            'Skip to Booking',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 170.h),

                  // Academy Brand Logo Card
                  _buildBrandLogoCard(),
                  SizedBox(height: 12.h),

                  // Tagline: Gateway to Sports Excellence
                  Text(
                    'Gateway to Sports Excellence',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // User Id Field
                  Text(
                    'User Id',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _buildInputField(
                    controller: controller.identifierController,
                    hintText: 'User Id',
                    suffixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: const Color(0xFF64748B),
                      size: 22.sp,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 14.h),

                  // Password Field
                  Text(
                    'Password',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Obx(
                    () => _buildInputField(
                      controller: controller.pinController,
                      hintText: 'Password',
                      obscureText: !controller.isPasswordVisible.value,
                      suffixIcon: GestureDetector(
                        onTap: controller.togglePasswordVisibility,
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded,
                          color: const Color(0xFF64748B),
                          size: 22.sp,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Forgot Password? Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.snackbar(
                          'Password Recovery',
                          'Password reset instructions have been sent to your registered contact.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: const Color(0xFFD97706),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontFamily: 'Nunito', 
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Sports Equipment Doodle Collage & Forward Circular Action Button
                  // Positioned below the upper login watermark text and below the form fields
                  Center(
                    child: SizedBox(
                      width: 260.w,
                      height: 240.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rich Sports Equipment Doodle Line Illustration
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SportsEquipmentDoodlePainter(),
                            ),
                          ),

                          // Outer ambient circular ring
                          Container(
                            width: 96.h,
                            height: 96.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0x66FFFFFF),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // Center Circular Floating CTA Button
                          Obx(
                            () => GestureDetector(
                              onTap: controller.isLoading.value
                                  ? null
                                  : controller.submit,
                              child: Container(
                                width: 62.h,
                                height: 62.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: controller.isLoading.value
                                      ? SizedBox(
                                          width: 22.w,
                                          height: 22.w,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2.8,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFFD97706)),
                                              ),
                                        )
                                      : Icon(
                                          Icons.arrow_forward_rounded,
                                          color: const Color(0xFFD97706),
                                          size: 28.sp,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildBrandLogoCard() {
    return Container(
      width: 120.h,
      height: 120.h,
      decoration: BoxDecoration(
        color: const Color(0x2EFFFFFF),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: Padding(
          padding: EdgeInsets.all(0.h),
          child: Image.asset(
            'assets/logo/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.sports_tennis_rounded,
                size: 100.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Single clean pill-shaped textfield without inner borders or scalloped container conflicts
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF0F172A),
        style: TextStyle(fontFamily: 'Nunito', 
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          fillColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 20.w,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: 'Nunito', 
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: BoxConstraints(minWidth: 40.w),
        ),
      ),
    );
  }
}

/// Custom painter rendering the rich sports equipment line art doodle collage below the login text
class _SportsEquipmentDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final subtleFillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // 1. Concentric ambient sports rings
    canvas.drawCircle(center, 110, strokePaint);
    canvas.drawCircle(center, 80, strokePaint);

    // 2. Football / Soccer ball (Top Center)
    final soccerCenter = Offset(center.dx, center.dy - 75);
    canvas.drawCircle(soccerCenter, 22, strokePaint);
    canvas.drawCircle(soccerCenter, 22, subtleFillPaint);
    // Pentagon in center of ball
    final pentagon = Path()
      ..moveTo(soccerCenter.dx, soccerCenter.dy - 8)
      ..lineTo(soccerCenter.dx + 8, soccerCenter.dy - 2)
      ..lineTo(soccerCenter.dx + 5, soccerCenter.dy + 7)
      ..lineTo(soccerCenter.dx - 5, soccerCenter.dy + 7)
      ..lineTo(soccerCenter.dx - 8, soccerCenter.dy - 2)
      ..close();
    canvas.drawPath(pentagon, strokePaint);

    // 3. Cricket Stumps & Bat (Top Left)
    canvas.drawLine(
      Offset(center.dx - 90, center.dy - 40),
      Offset(center.dx - 90, center.dy + 15),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 82, center.dy - 40),
      Offset(center.dx - 82, center.dy + 15),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 74, center.dy - 40),
      Offset(center.dx - 74, center.dy + 15),
      strokePaint,
    );
    // Bails on top
    canvas.drawLine(
      Offset(center.dx - 94, center.dy - 40),
      Offset(center.dx - 70, center.dy - 40),
      strokePaint,
    );
    // Bat leaning
    canvas.drawLine(
      Offset(center.dx - 66, center.dy - 60),
      Offset(center.dx - 66, center.dy + 10),
      strokePaint,
    );

    // 4. Tennis Racket (Top Right)
    final racketHead = Offset(center.dx + 75, center.dy - 55);
    canvas.drawOval(
      Rect.fromCenter(center: racketHead, width: 34, height: 42),
      strokePaint,
    );
    canvas.drawLine(
      Offset(racketHead.dx, racketHead.dy + 21),
      Offset(racketHead.dx + 15, racketHead.dy + 65),
      strokePaint,
    );

    // 5. Basketball (Right Center)
    final bbCenter = Offset(center.dx + 95, center.dy + 15);
    canvas.drawCircle(bbCenter, 20, strokePaint);
    canvas.drawLine(
      Offset(bbCenter.dx - 20, bbCenter.dy),
      Offset(bbCenter.dx + 20, bbCenter.dy),
      strokePaint,
    );
    canvas.drawLine(
      Offset(bbCenter.dx, bbCenter.dy - 20),
      Offset(bbCenter.dx, bbCenter.dy + 20),
      strokePaint,
    );

    // 6. Skateboard (Bottom Left)
    final deckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - 60, center.dy + 70),
        width: 55,
        height: 12,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(deckRect, strokePaint);
    canvas.drawCircle(Offset(center.dx - 75, center.dy + 82), 5, strokePaint);
    canvas.drawCircle(Offset(center.dx - 45, center.dy + 82), 5, strokePaint);

    // 7. Badminton Shuttlecock (Bottom Center)
    final shuttlecock = Path()
      ..moveTo(center.dx - 12, center.dy + 85)
      ..lineTo(center.dx + 12, center.dy + 85)
      ..lineTo(center.dx + 4, center.dy + 105)
      ..lineTo(center.dx - 4, center.dy + 105)
      ..close();
    canvas.drawPath(shuttlecock, strokePaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 108), 5, strokePaint);

    // 8. Archery Bow & Arrow (Left Center)
    final bowPath = Path()
      ..moveTo(center.dx - 95, center.dy + 10)
      ..quadraticBezierTo(
        center.dx - 120,
        center.dy + 40,
        center.dx - 95,
        center.dy + 70,
      );
    canvas.drawPath(bowPath, strokePaint);
    canvas.drawLine(
      Offset(center.dx - 95, center.dy + 10),
      Offset(center.dx - 95, center.dy + 70),
      strokePaint,
    );
    // Arrow
    canvas.drawLine(
      Offset(center.dx - 110, center.dy + 40),
      Offset(center.dx - 65, center.dy + 40),
      strokePaint,
    );

    // 9. Stars and Motion Accents
    canvas.drawCircle(
      Offset(center.dx - 35, center.dy - 70),
      3,
      subtleFillPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 35, center.dy - 70),
      3,
      subtleFillPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 70, center.dy + 75),
      4,
      subtleFillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
