import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Clean, luxury Login Screen for INERTIA SPORTS ACADEMY
/// Adopts the exact same design pattern, palette, and typography as UserSelectionScreen.
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // TOP HERO SECTION (VIBRANT LUXURY SPORTS BRAND)
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12.h,
                bottom: 20.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: CustomPaint(
                painter: _InertiaGridPainter(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Navigation Bar: Back & Skip to Booking
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0x60D4AF37),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18D4AF37),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 15.sp,
                              color: darkText,
                            ),
                          ),
                        ),

                        // Skip to Booking Link
                        GestureDetector(
                          onTap: () {
                            controller.startGuestBookingFlow(goToDashboard: true);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0x80D4AF37),
                                width: 1.1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14D4AF37),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Skip to Booking',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF9E7B1A),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFF9E7B1A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Brand Logo with Ambient Gold Halo
                    _buildLogo(),
                    SizedBox(height: 10.h),

                    // Brand Title
                    Text(
                      'INERTIA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 27.sp,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                        letterSpacing: 3.5,
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // Luxury Sports Academy Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 3.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1AD4AF37),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0x80D4AF37),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'SPORTS ACADEMY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF9E7B1A),
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Tagline
                    Text(
                      'Gateway to Sports Excellence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9E7B1A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // LOGIN FORM SECTION (WHITE LUXURY CARD PATTERN)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 36.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtle Profile Selector Pill with Gold Dot
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.h,
                            height: 6.h,
                            decoration: const BoxDecoration(
                              color: goldAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'PORTAL SIGN IN',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Header: Welcome Back
                  Center(
                    child: Text(
                      'Welcome to the Club',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      'Enter your credentials to access your dashboard',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: slateText,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Role Selector Tabs (Student vs Coach vs Member)
                  Obx(() {
                    final role = controller.selectedRole.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildRoleTab(
                            title: 'Student',
                            subtitle: 'Trainees',
                            svgAsset: 'assets/images/students.svg',
                            isSelected: role == 'Student',
                            onTap: () => controller.selectRole('Student'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildRoleTab(
                            title: 'Coach',
                            subtitle: 'Trainers',
                            svgAsset: 'assets/images/coaching.svg',
                            isSelected: role == 'Coach',
                            onTap: () => controller.selectRole('Coach'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildRoleTab(
                            title: 'Member',
                            subtitle: 'VIP Passes',
                            svgAsset: 'assets/images/members.svg',
                            isSelected: role == 'Member',
                            onTap: () => controller.selectRole('Member'),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 20.h),

                  // Dynamic User Id / Email Field
                  Obx(() {
                    final role = controller.selectedRole.value;
                    String label = 'User ID / Reg. No.';
                    String hint = 'Enter your ID, mobile or email';
                    IconData icon = Icons.person_outline_rounded;
                    TextInputType kbType = TextInputType.text;

                    if (role == 'Coach') {
                      label = 'Coach Email / Staff ID';
                      hint = 'Enter your coach email or staff ID';
                      icon = Icons.sports_rounded;
                      kbType = TextInputType.emailAddress;
                    } else if (role == 'Member') {
                      label = 'Member ID / Card No.';
                      hint = 'Enter your member card ID or phone';
                      icon = Icons.badge_outlined;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _buildInputField(
                          controller: controller.identifierController,
                          hintText: hint,
                          prefixIcon: icon,
                          keyboardType: kbType,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 14.h),

                  // Password Field
                  Text(
                    'Password',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Obx(
                    () => _buildInputField(
                      controller: controller.pinController,
                      hintText: 'Enter your account password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !controller.isPasswordVisible.value,
                      suffixWidget: GestureDetector(
                        onTap: controller.togglePasswordVisibility,
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                          size: 20.sp,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.forgotPassword,
                          arguments: {
                            'role': controller.selectedRole.value,
                            'identifier': controller.identifierController.text.trim(),
                          },
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E7B1A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Single Round Action Button
                  Center(
                    child: Obx(
                      () => Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: controller.isLoading.value
                              ? null
                              : controller.submit,
                          child: Container(
                            width: 68.h,
                            height: 68.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: goldAccent,
                                width: 2.4,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x35D4AF37),
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Color(0x10000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: 24.w,
                                      height: 24.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.8,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          goldAccent,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.arrow_forward_rounded,
                                      color: const Color(0xFF9E7B1A),
                                      size: 30.sp,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Bottom Home Bar Indicator
                  Center(
                    child: Container(
                      width: 120.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 112.h,
        height: 112.h,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Color(0x35D4AF37),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 56.sp,
              color: goldAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required String subtitle,
    String? svgAsset,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x20D4AF37),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28.h,
                height: 28.h,
                padding: EdgeInsets.all(svgAsset != null ? 3.h : 6.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0x20D4AF37)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? const Color(0x80D4AF37) : Colors.transparent,
                    width: 0.8,
                  ),
                ),
                child: svgAsset != null
                    ? SvgPicture.asset(
                        svgAsset,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        icon,
                        size: 16.sp,
                        color: isSelected ? const Color(0xFF9E7B1A) : slateText,
                      ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? darkText : slateText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF9E7B1A)
                            : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    Widget? suffixWidget,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0x60D4AF37),
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: darkText,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              prefixIcon,
              color: goldAccent,
              size: 20.sp,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40.w),
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: suffixWidget != null
              ? Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: suffixWidget,
                )
              : null,
          suffixIconConstraints: BoxConstraints(minWidth: 40.w),
        ),
      ),
    );
  }
}

/// Custom grid lines painter for subtle warm hero background matching UserSelectionScreen
class _InertiaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0AD4AF37)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    const double step = 28.0;

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
