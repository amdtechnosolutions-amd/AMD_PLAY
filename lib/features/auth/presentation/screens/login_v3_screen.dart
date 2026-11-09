import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Login Screen V3 with vertical curved tab sidebar and white & yellow brand styling.
class LoginV3Screen extends GetView<AuthController> {
  const LoginV3Screen({super.key});

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
      backgroundColor: const Color(0xFFC97A00),
      body: Obx(() {
        final isSignUp = controller.isSignUp.value;

        return Stack(
          children: [
            // Outer Background for the Left Vertical Sidebar
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB45309),
                      Color(0xFFC97A00),
                      Color(0xFF9A3412),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Main Layout Row: [Left Sidebar Tab Bar] + [Main Curved Yellow Card]
            Row(
              children: [
                // 1. Left Vertical Tab Bar
                _buildLeftSidebar(isSignUp),

                // 2. Main Radiant Yellow & White Card
                Expanded(
                  child: _buildMainContentCard(context, isSignUp),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // 1. LEFT SIDEBAR WITH VERTICAL TABS
  // ===========================================================================

  Widget _buildLeftSidebar(bool isSignUp) {
    return Container(
      width: 58.w,
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 110.h),

            // "Log In" Vertical Tab
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.toggleIsSignUp(false),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: !isSignUp ? 19.sp : 16.sp,
                      fontWeight:
                          !isSignUp ? FontWeight.w900 : FontWeight.w600,
                      color: !isSignUp
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.8,
                    ),
                    child: const Text('Log In'),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // "Sign Up" Vertical Tab
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.toggleIsSignUp(true),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: isSignUp ? 19.sp : 16.sp,
                      fontWeight:
                          isSignUp ? FontWeight.w900 : FontWeight.w600,
                      color: isSignUp
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.8,
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Small Brand Icon at the bottom of sidebar
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Container(
                width: 32.h,
                height: 32.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 16.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. MAIN FRONT CURVED CARD (RADIANT YELLOW & WHITE)
  // ===========================================================================

  Widget _buildMainContentCard(BuildContext context, bool isSignUp) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD54F),
            Color(0xFFFFC107),
            Color(0xFFFFA000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34.r),
          bottomLeft: Radius.circular(34.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34.r),
          bottomLeft: Radius.circular(34.r),
        ),
        child: SafeArea(
          left: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Bar: Close Button (X)
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offNamed(AppRoutes.userSelection);
                      }
                    },
                    child: Container(
                      width: 34.h,
                      height: 34.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 19.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                // Top Welcome Row with 3D Logo Element
                _buildTopHeroSection(isSignUp),

                SizedBox(height: 24.h),

                // Section Title: "Log in" / "Sign up"
                Text(
                  isSignUp ? 'Sign up' : 'Log in',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 16.h),

                // Form Inputs Container
                if (isSignUp) ...[
                  // Full Name Field
                  _buildWhiteInputCard(
                    controller: controller.nameController,
                    hintText: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 12.h),
                ],

                // Email / User ID Field
                _buildWhiteInputCard(
                  controller: controller.identifierController,
                  hintText: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12.h),

                // Password Field
                Obx(
                  () => _buildWhiteInputCard(
                    controller: controller.pinController,
                    hintText: 'Password',
                    icon: Icons.vpn_key_outlined,
                    obscureText: !controller.isPasswordVisible.value,
                    keyboardType: TextInputType.text,
                    suffixIcon: GestureDetector(
                      onTap: controller.togglePasswordVisibility,
                      child: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9E9E9E),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Remember Me & Forgot Password Row
                _buildOptionsRow(isSignUp),
                SizedBox(height: 26.h),

                // Primary Action Button: "SIGN IN" / "SIGN UP"
                _buildSubmitButton(isSignUp),
                SizedBox(height: 24.h),

                // "— OR —" Divider
                _buildDivider(),
                SizedBox(height: 18.h),

                // Social Login Buttons: Facebook, Google, Instagram
                _buildSocialButtons(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. TOP HERO SECTION: WELCOME TEXT & 3D LOGO EMBLEM
  // ===========================================================================

  Widget _buildTopHeroSection(bool isSignUp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Welcome back...
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: TextStyle(fontFamily: 'Nunito', 
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                isSignUp ? 'to Inertia...' : 'back...',
                style: TextStyle(fontFamily: 'Nunito', 
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                isSignUp
                    ? 'Start your sports journey today'
                    : 'Sports Academy & Arena',
                style: TextStyle(fontFamily: 'Nunito', 
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),

        // Right Column: 3D Faceted Logo Pot Element (matching screenshot plant element)
        _build3DLogoElement(),
      ],
    );
  }

  Widget _build3DLogoElement() {
    return Container(
      width: 96.w,
      height: 106.h,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 3D White Faceted Pot / Base Container with soft shadow
          Container(
            width: 78.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
                bottomLeft: Radius.circular(22.r),
                bottomRight: Radius.circular(22.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFFA000).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'INERTIA',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFB45309),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // 3D Academy Crest Logo emerging from the base
          Positioned(
            top: 0,
            child: Container(
              width: 68.h,
              height: 68.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF131722),
                border: Border.all(
                  color: const Color(0xFFFFD54F),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                      size: 32.sp,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. WHITE INPUT CARD (WITH ICON + VERTICAL DIVIDER)
  // ===========================================================================

  Widget _buildWhiteInputCard({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          // Leading Icon
          Icon(
            icon,
            size: 20.sp,
            color: const Color(0xFF555555),
          ),
          SizedBox(width: 10.w),

          // Vertical Divider
          Container(
            height: 20.h,
            width: 1.2,
            color: const Color(0xFFE0E0E0),
          ),
          SizedBox(width: 10.w),

          // Input Text Field
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(fontFamily: 'Nunito', 
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),

          // Trailing Suffix Icon (e.g. eye toggle)
          ?suffixIcon,
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. OPTIONS ROW: REMEMBER ME & FORGOT PASSWORD
  // ===========================================================================

  Widget _buildOptionsRow(bool isSignUp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Radio / Dot Remember Me
        Obx(
          () => GestureDetector(
            onTap: controller.toggleRememberMe,
            child: Row(
              children: [
                Container(
                  width: 15.h,
                  height: 15.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.8,
                    ),
                  ),
                  child: controller.rememberMe.value
                      ? Center(
                          child: Container(
                            width: 7.h,
                            height: 7.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 7.w),
                Text(
                  'Remember me',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Forgot Password Link (underlined as in the screenshot)
        if (!isSignUp)
          GestureDetector(
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
              'Forgot password',
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
                decorationThickness: 1.6,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // 6. PRIMARY PILL CTA BUTTON ("SIGN IN" / "SIGN UP")
  // ===========================================================================

  Widget _buildSubmitButton(bool isSignUp) {
    return Center(
      child: Obx(
        () => GestureDetector(
          onTap: controller.isLoading.value
              ? null
              : (isSignUp ? controller.submitSignUp : controller.submit),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.8,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                      ),
                    )
                  : Text(
                      isSignUp ? 'SIGN UP' : 'SIGN IN',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. DIVIDER: "— OR —"
  // ===========================================================================

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'OR',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 8. CIRCULAR SOCIAL LOGIN BUTTONS (FACEBOOK, GOOGLE+, INSTAGRAM)
  // ===========================================================================

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook Button
        _buildSocialCircle(
          backgroundColor: const Color(0xFF1877F2),
          child: Text(
            'f',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          onTap: () => controller.loginWithSocial('Facebook'),
        ),
        SizedBox(width: 16.w),

        // Google+ / Google Button
        _buildSocialCircle(
          backgroundColor: Colors.white,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'G',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4285F4),
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEA4335),
                  ),
                ),
              ],
            ),
          ),
          onTap: () => controller.loginWithSocial('Google'),
        ),
        SizedBox(width: 16.w),

        // Instagram / Social Button
        _buildSocialCircle(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.camera_alt_outlined,
            size: 20.sp,
            color: const Color(0xFFE1306C),
          ),
          onTap: () => controller.loginWithSocial('Instagram'),
        ),
      ],
    );
  }

  Widget _buildSocialCircle({
    required Color backgroundColor,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.h,
        height: 44.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
