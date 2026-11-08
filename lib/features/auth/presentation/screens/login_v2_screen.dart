import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Pixel-perfect Login Screen V2 matching the Golden Stadium Nightscape design.
class LoginV2Screen extends GetView<AuthController> {
  const LoginV2Screen({super.key});

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
      backgroundColor: const Color(0xFF080A0F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Golden Stadium Nightscape Image
          Positioned.fill(
            child: Image.asset(
              'assets/Cinematic Golden Stadium Nightscape.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0D14), Color(0xFF141926), Color(0xFF090B10)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. Dark Vignette Gradient Overlay for High Contrast Legibility
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xD0080A10),
                    Color(0xE00C0F18),
                    Color(0xF5080A10),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  SizedBox(height: 10.h),

                  // Header Crest Emblem (Golden Eagle Logo)
                  _buildHeaderLogo(),
                  SizedBox(height: 14.h),

                  // Brand Title: SPORTS ACADEMY
                  _buildBrandTitle(),
                  SizedBox(height: 6.h),

                  // Subtitle: PLAY | TRAIN | GROW | TOGETHER
                  Text(
                    'PLAY   |   TRAIN   |   GROW   |   TOGETHER',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 2.2,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Role Selection Segmented Tabs: Member | Student | Coach | Admin
                  _buildRoleTabs(),
                  SizedBox(height: 18.h),

                  // Main Login Form Card: Welcome Back
                  _buildLoginFormCard(context),
                  SizedBox(height: 26.h),

                  // Bottom Sports Showcase: Cricket, Football, Basketball, Badminton, Pickleball
                  _buildSportsShowcase(),
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
  // TOP BRANDING WIDGETS
  // ==========================================

  Widget _buildHeaderLogo() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient golden glow ring
          Container(
            width: 100.h,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x55F59E0B),
                width: 1.5,
              ),
            ),
          ),

          // Inner circular badge with logo
          Container(
            width: 84.h,
            height: 84.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF131722),
              border: Border.all(
                color: const Color(0xFFF59E0B),
                width: 2.8,
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
                    size: 42.sp,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'SPORTS ',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          TextSpan(
            text: 'ACADEMY',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF59E0B),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROLE SELECTION TABS
  // ==========================================

  Widget _buildRoleTabs() {
    final roles = [
      {'title': 'Member', 'icon': Icons.people_alt_rounded},
      {'title': 'Student', 'icon': Icons.school_rounded},
      {'title': 'Coach', 'icon': Icons.groups_2_rounded},
      {'title': 'Admin', 'icon': Icons.settings_rounded},
    ];

    return Obx(() {
      final currentRole = controller.selectedRole.value;

      return Row(
        children: roles.map((roleData) {
          final title = roleData['title'] as String;
          final icon = roleData['icon'] as IconData;
          final isSelected = currentRole == title;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
              child: GestureDetector(
                onTap: () => controller.selectRole(title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF141923),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF262E3E),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 20.sp,
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        title,
                        style: TextStyle(fontFamily: 'Nunito', 
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ==========================================
  // LOGIN FORM CARD
  // ==========================================

  Widget _buildLoginFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF121622),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFF263044),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: Welcome Back
          Text(
            'Welcome Back',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Text(
            'Login to access your dashboard, bookings, trainings and more.',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
              height: 1.35,
            ),
          ),
          SizedBox(height: 20.h),

          // Input 1: Email or Mobile Number
          _buildInputField(
            controller: controller.identifierController,
            hintText: 'Email or Mobile Number',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 14.h),

          // Input 2: Password
          Obx(
            () => _buildInputField(
              controller: controller.pinController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.isPasswordVisible.value,
              keyboardType: TextInputType.text,
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me Checkbox
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleRememberMe,
                  child: Row(
                    children: [
                      Container(
                        width: 18.h,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: controller.rememberMe.value
                              ? const Color(0xFFF59E0B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: controller.rememberMe.value
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF475569),
                            width: 1.5,
                          ),
                        ),
                        child: controller.rememberMe.value
                            ? Icon(
                                Icons.check_rounded,
                                size: 13.sp,
                                color: const Color(0xFF0F172A),
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Remember me',
                        style: TextStyle(fontFamily: 'Nunito', 
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Forgot Password Link
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Password Recovery',
                    'A password reset link has been sent to your registered contact.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E293B),
                    colorText: const Color(0xFFFBBF24),
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Primary CTA Button: Login ->
          Obx(
            () => GestureDetector(
              onTap: controller.isLoading.value ? null : controller.submit,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.8,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(fontFamily: 'Nunito', 
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Divider: OR CONTINUE WITH
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFF263044),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(fontFamily: 'Nunito', 
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFF263044),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Social Login Buttons: Google & Apple
          Row(
            children: [
              // Google Button
              Expanded(
                child: _buildSocialButton(
                  label: 'Google',
                  iconWidget: _buildGoogleLogo(),
                  onTap: () {
                    Get.snackbar(
                      'Google Sign-In',
                      'Authenticating with Google Account...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E293B),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),

              // Apple Button
              Expanded(
                child: _buildSocialButton(
                  label: 'Apple',
                  iconWidget: Icon(
                    Icons.apple_rounded,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Get.snackbar(
                      'Apple Sign-In',
                      'Authenticating with Apple ID...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E293B),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          // New to Sports Academy? & Create Account Button
          Center(
            child: Text(
              'New to Sports Academy?',
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Outline Button: Create Account ->
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.facilities);
            },
            child: Container(
              width: double.infinity,
              height: 46.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1017),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17.sp,
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INPUT FIELD HELPER
  // ==========================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF263044),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontFamily: 'Nunito', 
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 14.w),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: 'Nunito', 
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 19.sp,
            color: const Color(0xFF94A3B8),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 42.w),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: BoxConstraints(minWidth: 38.w),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFF161C28),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF263044),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 18.h,
      height: 18.h,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'G',
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM SPORTS SHOWCASE
  // ==========================================

  Widget _buildSportsShowcase() {
    final sports = [
      {
        'title': 'CRICKET',
        'icon': Icons.sports_cricket_rounded,
        'gradient': [Color(0xFF2D2418), Color(0xFF161410)],
      },
      {
        'title': 'FOOTBALL',
        'icon': Icons.sports_soccer_rounded,
        'gradient': [Color(0xFF142238), Color(0xFF0C1320)],
      },
      {
        'title': 'BASKETBALL',
        'icon': Icons.sports_basketball_rounded,
        'gradient': [Color(0xFF381F14), Color(0xFF1E100A)],
      },
      {
        'title': 'BADMINTON',
        'icon': Icons.sports_tennis_rounded,
        'gradient': [Color(0xFF122C38), Color(0xFF0A1820)],
      },
      {
        'title': 'PICKLEBALL',
        'icon': Icons.sports_handball_rounded,
        'gradient': [Color(0xFF1E1A38), Color(0xFF100E20)],
      },
    ];

    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: sports.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final sport = sports[index];
          final title = sport['title'] as String;
          final icon = sport['icon'] as IconData;
          final grad = sport['gradient'] as List<Color>;

          return Container(
            width: 88.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFF59E0B),
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sport Icon
                Container(
                  width: 44.h,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: const Color(0xFFFBBF24),
                  ),
                ),

                // Sport Title & Gold Underline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      width: 26.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
