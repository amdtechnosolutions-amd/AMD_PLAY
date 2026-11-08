import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Clean, catchy User Role Selection Screen for INERTIA SPORTS ACADEMY
class UserSelectionScreen extends GetView<AuthController> {
  const UserSelectionScreen({super.key});

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
                top: MediaQuery.of(context).padding.top + 20.h,
                bottom: 24.h,
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
                    // Brand Logo with Ambient Gold Halo
                    _buildLogo(),
                    SizedBox(height: 12.h),

                    // Brand Title
                    Text(
                      'INERTIA',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Nunito', 
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
                        style: TextStyle(fontFamily: 'Nunito', 
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF9E7B1A),
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Subtitle
                    Text(
                      'Multi-Sport Training, High Performance &\nArena Bookings',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: slateText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Catchy Amenity Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAmenityBadge(
                          icon: Icons.sports_tennis_rounded,
                          label: 'Rackets',
                        ),
                        SizedBox(width: 8.w),
                        _buildAmenityBadge(
                          icon: Icons.sports_rounded,
                          label: 'Nets',
                        ),
                        SizedBox(width: 8.w),
                        _buildAmenityBadge(
                          icon: Icons.sports_soccer_rounded,
                          label: 'Arena Turf',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // USER ROLE SELECTION SECTION
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
                  // Subtle Profile Selector Pill
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
                            'CHOOSE PROFILE',
                            style: TextStyle(fontFamily: 'Nunito', 
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

                  // Header: Welcome to the Club
                  Center(
                    child: Text(
                      'Welcome to the Club',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Center(
                    child: Text(
                      'Select your membership profile to sign in',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: slateText,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Catchy Role Selection Cards
                  _buildRoleSelectionCards(),
                  SizedBox(height: 28.h),

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
        width: 125.h,
        height: 125.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0x35D4AF37),
              Color(0x10D4AF37),
              Colors.transparent,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/logo/logo.png',
          height: 98.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 68.sp,
              color: goldAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityBadge({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x66D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14D4AF37),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: goldAccent),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(fontFamily: 'Nunito', 
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionCards() {
    return Column(
      children: [
        // 1. BOOKING (FEATURED / QUICK ACCESS)
        _buildRoleCard(
          profile: MembershipProfile.booking,
          roleName: 'Guest',
          title: 'Booking',
          badgeText: 'COURT BOOKING',
          featuredTag: 'QUICK ACCESS',
          subtitle: 'Instant court reservations, guest access & equipment',
          icon: Icons.confirmation_number_rounded,
          isFeatured: true,
          iconGradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: const Color(0xFF0F172A),
        ),
        SizedBox(height: 14.h),

        // 2. STUDENTS (ACADEMY PORTAL)
        _buildRoleCard(
          profile: MembershipProfile.parents,
          roleName: 'Student',
          title: 'Students',
          badgeText: 'STUDENT PORTAL',
          subtitle: 'Student training batches, attendance, fees & court booking',
          icon: Icons.school_rounded,
          isFeatured: false,
          iconGradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: goldAccent,
        ),
        SizedBox(height: 14.h),

        // 3. MEMBERS (VIP ACCESS)
        _buildRoleCard(
          profile: MembershipProfile.members,
          roleName: 'Member',
          title: 'Members',
          badgeText: '★ VIP ACCESS',
          subtitle: 'VIP Lounge, court reservations & locker access',
          icon: Icons.workspace_premium_rounded,
          isFeatured: false,
          iconGradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconColor: goldAccent,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required MembershipProfile profile,
    required String roleName,
    required String title,
    required String badgeText,
    required String subtitle,
    required IconData icon,
    required bool isFeatured,
    required LinearGradient iconGradient,
    required Color iconColor,
    String? featuredTag,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectRole(roleName);
          controller.selectProfile(profile);
          if (profile == MembershipProfile.booking) {
            controller.startGuestBookingFlow(goToDashboard: true);
          } else {
            Get.toNamed(AppRoutes.login);
          }
        },
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
          decoration: BoxDecoration(
            gradient: isFeatured
                ? const LinearGradient(
                    colors: [Color(0xFFFFFDF7), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Color(0xFFFBFBFD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isFeatured ? const Color(0x8AD4AF37) : const Color(0x40D4AF37),
              width: isFeatured ? 1.4 : 1.1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28D4AF37),
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 6,
                spreadRadius: -1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Vibrant Left Icon Container
              Container(
                width: 48.h,
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  borderRadius: BorderRadius.circular(14.r),
                  border: isFeatured
                      ? Border.all(color: Colors.white, width: 1.5)
                      : Border.all(color: const Color(0x40D4AF37), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: isFeatured ? const Color(0x40D4AF37) : const Color(0x180F172A),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24.sp, color: iconColor),
              ),
              SizedBox(width: 14.w),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontFamily: 'Nunito', 
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1FD4AF37),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0x80D4AF37),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF9E7B1A),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        if (featuredTag != null) ...[
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 10.sp, color: const Color(0xFF0F172A)),
                                SizedBox(width: 2.w),
                                Text(
                                  featuredTag,
                                  style: TextStyle(fontFamily: 'Nunito', 
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        color: slateText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Action Arrow Button
              Container(
                width: 32.h,
                height: 32.h,
                decoration: BoxDecoration(
                  color: isFeatured ? const Color(0xFFFFF9E6) : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFeatured ? const Color(0x80D4AF37) : const Color(0x33D4AF37),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: isFeatured ? const Color(0xFF9E7B1A) : darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom grid lines painter for subtle warm hero background
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
